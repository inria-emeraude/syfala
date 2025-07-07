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

mod audio_server;
mod sockets;

use crate::audio_server::{AudioServerConfig, JackAudioServer, JackBuffer};
use clap::Parser;
use jack::jack_sys::jackctl_server_start;
use shared::buffer_manager::{calc_max_buffer, RingBuffer};
use shared::control::Frame;
use std::collections::HashMap;
use std::io;
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};

use tokio::net::UdpSocket;
use tokio::sync::mpsc;

use crate::sockets::TCPControl;

struct Distributor {
    servers: HashMap<SocketAddr, JackAudioServer>,
    buffers: HashMap<SocketAddr, Arc<Mutex<JackBuffer>>>,
}

const DESCRIPTION: &str = "The Syfala Server streams Audio to multiple Syfala Clients via UDP.";

#[derive(Parser, Debug)]
#[command(name = "Syfala Server")]
#[command(version)]
#[command(about = "Streams audio via UDP")]
#[command(long_about = DESCRIPTION)]

struct Args {
    // ------------------------------------------------------------------------
    #[arg(long, default_value = "2")]
    #[arg(help = "How many buffers should there be before replaying")]
    buffering: usize,
    // ------------------------------------------------------------------------
    #[arg(long, default_value = "[::]:6910")]
    #[arg(help = "IP address to bind to")]
    bind: SocketAddr,
    // ------------------------------------------------------------------------
    #[arg(short, long, default_value = "32")]
    #[arg(help = "How many packets have to be received before the buffer
    manager adds/removes samples")]
    responsiveness: usize,
    // ------------------------------------------------------------------------
    #[arg(short, long, default_value = "346")]
    #[arg(help = "Maximum packet size")]
    max_frame_size: usize,
}

#[tokio::main]
async fn main() -> io::Result<()> {
    let args = Args::parse();
    let buffering = args.buffering;
    let responsiveness = args.responsiveness;
    let subscriber = tracing_subscriber::fmt()
        .compact()
        .with_file(true)
        .with_line_number(true)
        .with_thread_ids(false)
        .with_target(false)
        .finish();
    tracing::subscriber::set_global_default(subscriber).unwrap();
    // Get asynchronous tx/rx connection between Jack & UDP.
    let (tx_orig, mut rx) = mpsc::unbounded_channel();
    // Listen on both IPv4 and IPv6
    let bind = "[::]:6910".parse::<SocketAddr>().unwrap();
    // Get buffer size from Jack
    let jack_buffer_size = match audio_server::get_buffer_size() {
        Ok(size) => size,
        Err(e) => {
            tracing::error!("Could not get buffer size from jack. '{}'.
            Please make sure Jack is running", e);
            return Err(io::Error::new(
                io::ErrorKind::Other,
                "Could not get buffer size from jack",
            ));
        }
    };
    let config = AudioServerConfig {
        buffering,
        buffer_size: jack_buffer_size,
        responsiveness,
        max_frame_size: args.max_frame_size,
    };
    tracing::info!(
        "Jack buffer size: {}, using {} buffers, {} responsiveness",
        jack_buffer_size, buffering, responsiveness
    );
    let udp_socket = UdpSocket::bind(bind).await?;
    let control = TCPControl::new(&bind, tx_orig.clone(), config).await;
    // Wait or do some processing while your handler is running in real time.
    tracing::info!("Starting UDP");
    let mut buf = [0; 2048];
    // TODO: need to clean up after disconnect!
    // Every time a new client connects to the server, add a new entry to the following hashmap:
    let mut seq: HashMap<SocketAddr, u32> = HashMap::new();
    // Start a loop, and use tokio::select to run two operations in parallel:
    loop {
        tokio::select! {
            // 1. Receive audio data from the Jack audio thread (this is why we use unbounded_channel())
            //    send it back to the ethernet-clients with UDP.
            res = rx.recv() => {
                let res = res.unwrap();
                let data = res.data;
                let channels = res.channels;
                let addr = res.id;
                let max_amount_of_samples = calc_max_buffer(channels, args.max_frame_size);
                let mut read_index = 0;
                let mut is_first = true;
                // Split in multiple UDP packets:
                loop {
                    let buff_len = data.len();
                    let end = if data.len() <= max_amount_of_samples + read_index {
                        data.len()
                    } else {
                        read_index + max_amount_of_samples as usize
                    };
                    let mut current_seq = seq.get(&addr)
                        .unwrap_or_else(|| &0)
                        .clone();
                    let frame = Frame::new(current_seq, is_first, data[read_index..end].to_vec());
                    read_index = end;
                    is_first = false;
                    let _len = udp_socket.send_to(&frame.encode(), addr).await?;
                    current_seq = current_seq.wrapping_add(1);
                    seq.insert(addr, current_seq);
                    if end == buff_len {
                        break;
                    }
                }
            }
            // 2. Receive audio data from FPGA Ethernet clients (UDP).
            res = udp_socket.recv_from(&mut buf) => {
                match res {
                    Ok(client) => {
                        let addr = client.1.clone();
                        let frame = Frame::from_u8(&buf[0..res.unwrap().0]);
                        if let Ok(frame) = frame {
                            // TODO: Error catching
                            if let Some(buffer) = control.get_distributor()
                                .lock()
                                .await.get_buffer(addr) {
                                    let mut buffer = buffer.lock().unwrap();
                                    buffer.push(&frame.buffer);
                            } else {
                                tracing::error!("Buffer not found");
                            }
                        } else {
                            tracing::error!("Frame encoder: {:?}", frame);
                        }
                    },
                    err => {
                        tracing::error!("Recv error: {:?}", err);
                        break;
                    }
                }
            }
        }
    }
    Ok(())
}
