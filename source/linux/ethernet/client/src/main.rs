/************************************************************************
 ************************************************************************
    Syfala Ethernet Transmission
    Copyright (C) 2023 Jurek Weber
---------------------------------------------------------------------
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ************************************************************************
 ************************************************************************/

mod axi;
mod connection;
mod hls_const;
mod perf;
mod tcp;
mod udp;

use std::io;
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};
use std::time::Duration;

use crate::axi::axilite::AxiLite;
use clap::Parser;
use tokio::signal;
use tokio::time::sleep;

use crate::connection::ConnectionConfig;
use crate::hls_const as HLS;
use crate::tcp::TcpHandler;
use shared::control::if_local_ipv6_set_scope;

const DESCRIPTION: &str =
    "The Syfala client can be used to connect to a Syfala server and stream audio data to it.
using the IPv6 link local address of the server, you have to provide the scope id of the interface
you can get the scope by running `ip addr` which gives you the scope id in the first column";

#[derive(Parser, Debug)]
#[command(name="Syfala Client", version, about="Streams audio via UDP", long_about = DESCRIPTION)]
struct Args {
    /// The Server IP with port, e.g. [fe80::aaa:bbbb:cccc:dddd%2]:6910
    #[arg(short='s', long, value_hint=clap::ValueHint::Hostname)]
    server: SocketAddr,
    /// The name as which the client should register at the Audio Server
    #[arg(short='n', long, default_value = "Syfala FPGA", value_hint=clap::ValueHint::Other)]
    name: String,
}

#[tokio::main]
async fn main() -> io::Result<()> {
    let subscriber = tracing_subscriber::fmt()
        .compact()
        .with_file(true)
        .with_line_number(true)
        .with_thread_ids(false)
        .with_target(false)
        .finish();

    tracing::subscriber::set_global_default(subscriber).unwrap();

    let args = Args::parse();

    let config = ConnectionConfig {
        uio: "uio1".to_string(),
        mem: "/dev/mem".to_string(),
        mem_in: 0x35000000,
        mem_in_max_size: 1024 * 1024 * 8,
        mem_out: 0x35000000 + 0x800000,
        mem_out_max_size: 1024 * 1024 * 8,
    };
    // AXI stuff
    let mut axi = AxiLite::new(&config.uio);

    let channels_in = axi.get_input_channels();
    let channels_out = axi.get_output_channels();
    tracing::info!(
        "channels in {}, channels out: {}",
        channels_in,
        channels_out
    );

    if channels_in == 0 && channels_out == 0 {
        tracing::error!(
            "Neither input nor output channels found! did you load do syfala-load yet?"
        );
        return Ok(());
    }

    let axi = Arc::new(Mutex::new(axi));

    // reconnect loop
    loop {
        tokio::select! {
            _ = connect(axi.clone(), channels_in, channels_out, &config, &args.server, &args.name) => {
                tracing::debug!("exiting connect");
            }
            _ =  signal::ctrl_c() => {
                tracing::info!("Stopping...");
                break;
            }
        }
        tokio::select! {
            _ = sleep(Duration::from_millis(1000)) => {}
            _ =  signal::ctrl_c() => {
                tracing::info!("Stopping...");
                break;
            }
        }
    }

    Ok(())
}

async fn connect(axi: Arc<Mutex<AxiLite>>, channels_in: usize, channels_out: usize, config: &ConnectionConfig, addr: &SocketAddr, name: &str) {
    let mut tcp = match TcpHandler::new(addr, channels_out, channels_in, name).await {
        Ok(tcp) => tcp,
        Err(e) => {
            tracing::warn!("Connection error: {:?}", e);
            return
        }
    };
    // await for server sending a UDP connection request
    let mut connection_properties = match tcp.await_connect_request().await {
        Ok(connection_properties) => connection_properties,
        Err(e) => {
            tracing::error!("Could not get first welcome packet {:?}", e);
            return
        }
    };

    // if link local ipv6 addresses are used, the scope of the interface has to be set as scope of server is not the same as locally
    // https://stackoverflow.com/questions/15242988/reason-to-mention-scope-id-in-link-local-address-of-ipv6
    connection_properties.local =
        if_local_ipv6_set_scope(connection_properties.local, &addr.to_string());
    connection_properties.remote =
        if_local_ipv6_set_scope(connection_properties.remote, &addr.to_string());

    // start udp server
    let mut udp = udp::UdpConnection::new(config, axi.clone(), connection_properties, tcp.get_stats_tx()).await;
    tracing::info!("UDP OK");

    // run tcp and udp at same time
    tokio::select! {
        e = tcp.handle() => {
            tracing::info!("tcp handler returned with: {:?}", e);
        },
        e = udp.handle() => {
            tracing::error!("udp handler returned with: {:?}", e);
        }
    }
    axi.lock().unwrap().deactivate();
}
