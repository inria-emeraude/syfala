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

use std::{io, time};
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};
use std::time::Duration;

use crate::ethernet::axi::axilite::AxiLite;
use clap::Parser;
use tokio::signal;
use tokio::time::sleep;

use crate::ethernet::connection::ConnectionConfig;
use crate::ethernet::{hls_const as HLS};
use crate::Cli;
use crate::ethernet::tcp::TcpHandler;
use shared::control::if_local_ipv6_set_scope;

#[tokio::main]
pub async fn run() -> io::Result<()> {
    let subscriber = tracing_subscriber::fmt()
        .compact()
        .with_file(true)
        .with_line_number(true)
        .with_thread_ids(false)
        .with_target(false)
        .finish();
    tracing::subscriber::set_global_default(subscriber).unwrap();
    let args = Cli::parse();
    let config = ConnectionConfig {
                     uio: "uio1".to_string(),
                     mem: "/dev/mem".to_string(),
                  mem_in: 0x35500000,
         mem_in_max_size: 1024 * 1024 * 8,
                 mem_out: 0x35500000 + 0x800000,
        mem_out_max_size: 1024 * 1024 * 8,
    };
    // AXI-related
    let mut axi = AxiLite::new(&config.uio);
    let mut io = (0, 0);
    loop {
        io.0 = axi.get_output_channels();
        io.1 = axi.get_input_channels();
        match io {
            (0, 0) => {
                tracing::warn!(
                    "Could not parse number of input/output channels. \
                    Retrying..."
                );
                std::thread::sleep(std::time::Duration::from_secs(1));
            }
            _ => break
        }
    }
    tracing::info!("Number of i/o channels: {:?}", io);

    let axi = Arc::new(Mutex::new(axi));
    let server = args.ethernet.unwrap();

    // Reconnect loop
    loop {
        tokio::select! {
            _ = connect(axi.clone(), io.1, io.0, &config, &server, &args.name) => {
                tracing::debug!("Exiting connect");
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

async fn connect(axi: Arc<Mutex<AxiLite>>,
     channels_in: usize,
    channels_out: usize,
          config: &ConnectionConfig,
            addr: &SocketAddr,
            name: &str
){
    let mut tcp = match TcpHandler::new(addr, channels_out, channels_in, name).await {
        Ok(tcp) => tcp,
        Err(e) => {
            tracing::warn!("Connection error: {:?}", e);
            return
        }
    };
    // Await for server sending a UDP connection request
    let mut connection_properties = match tcp.await_connect_request().await {
        Ok(connection_properties) => connection_properties,
        Err(e) => {
            tracing::error!("Could not get TCP handshake {:?}", e);
            return
        }
    };
    // If link local ipv6 addresses are used, the scope of the interface has to be set as
    // scope of server is not the same as locally:
    // https://stackoverflow.com/questions/15242988/reason-to-mention-scope-id-in-link-local-address-of-ipv6
    connection_properties.local = if_local_ipv6_set_scope(
        connection_properties.local,
        &addr.to_string()
    );
    connection_properties.remote = if_local_ipv6_set_scope(
        connection_properties.remote,
        &addr.to_string()
    );
    // Start UDP server
    let mut udp = udp::UdpConnection::new(
        config, axi.clone(),
        connection_properties,
        tcp.get_stats_tx()
    ).await;
    tracing::info!("UDP started");

    // Run TCP and UDP at the same time.
    tokio::select! {
        e = tcp.handle() => {
            tracing::info!("TCP handler returned with: {:?}", e);
        },
        e = udp.handle() => {
            tracing::error!("UDP handler returned with: {:?}", e);
        }
    }
    axi.lock().unwrap().deactivate();
}
