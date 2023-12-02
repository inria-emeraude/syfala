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
#[command(name="Syfala Server", version, about="Streams audio via UDP", long_about = DESCRIPTION)]
/// The Syfala Server\n
struct Args {
    /// how many buffers should be buffered before replaying
    #[arg(long, default_value = "2")]
    buffering: usize,
    /// the ip to bind to
    #[arg(long, default_value = "[::]:6910")]
    bind: SocketAddr,
    /// how many packets have to be received before buffer manager adds/removes samples
    #[arg(short='r', long, default_value = "32")]
    responsiveness: usize,
    /// maximum packet size says how many floats should be put in one packet
    #[arg(short='m', long, default_value = "346")]
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

    let (tx_orig, mut rx) = mpsc::unbounded_channel();
    // listen on both, v4 and v6
    let bind = "[::]:6910".parse::<SocketAddr>().unwrap();
    // get buffer size from jack server
    let jack_buffer_size = match audio_server::get_buffer_size() {
        Ok(size) => size,
        Err(e) => {
            tracing::error!("could not get buffer size from jack. '{}' Jack Running?", e);
            return Err(io::Error::new(
                io::ErrorKind::Other,
                "could not get buffer size from jack",
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
        "got buffer size from jack: {}, using {} buffers, {} responsiveness",
        jack_buffer_size,
        buffering,
        responsiveness
    );

    let sock = UdpSocket::bind(bind).await?;
    let control = TCPControl::new(&bind, tx_orig.clone(), config).await;

    // 5. wait or do some processing while your handler is running in real time.
    tracing::info!("Starting UDP");

    let mut buf = [0; 2048];
    // todo need to clean up after disconnect!
    let mut seq: HashMap<SocketAddr, u32> = HashMap::new();
    loop {
        tokio::select! {
            res = rx.recv() => {
                let res = res.unwrap();
                let data = res.data;
                let channels = res.channels;
                let addr = res.id;
                let max_amount_of_samples = calc_max_buffer(channels, args.max_frame_size);
                //println!("{:?}", frame.sample_rate);
                let mut read_index = 0;
                let mut is_first = true;
                // split in multiple udp packets
                loop {
                    let buff_len = data.len();
                    let end = if data.len() <= max_amount_of_samples + read_index {
                        data.len()
                    } else {
                        read_index + max_amount_of_samples as usize
                    };
                    let mut current_seq = seq.get(&addr).unwrap_or_else(|| &0).clone();
                    let frame = Frame::new(current_seq, is_first, data[read_index..end].to_vec());
                    read_index = end;
                    is_first = false;
                    let _len = sock.send_to(&frame.encode(), addr).await?;

                    current_seq = current_seq.wrapping_add(1);
                    seq.insert(addr, current_seq);


                    if end == buff_len {
                        break;
                    }
                }
            }
            res = sock.recv_from(&mut buf) => {
                match res {
                    Ok(client) => {
                        let addr = client.1.clone();
                        let frame = Frame::from_u8(&buf[0..res.unwrap().0]);

                        if let Ok(frame) = frame {
                            // todo error catching
                            if let Some(buffer) = control.get_distributor().lock().await.get_buffer(addr) {
                                let mut buffer = buffer.lock().unwrap();
                                buffer.push(&frame.buffer);
                            } else {
                                tracing::error!("buffer not found");
                            }
                        } else {
                            tracing::error!("frame encoder: {:?}", frame);
                        }
                    },
                    err => {
                        tracing::error!("recv error: {:?}", err);
                        break;
                    }
                }
            }
        }
    }

    Ok(())
}
