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

use crate::audio_server::{
    AudioServer, AudioServerConfig, AudioServerTx, JackAudioServer, JackBuffer,
};
use crate::Distributor;
use futures::{SinkExt, StreamExt};
use shared::buffer_manager::BufferManagerConfig;
use shared::control::{EstablishDataChannelPacket, PacketCodec, SocketPacket};
use std::collections::HashMap;
use std::net::SocketAddr;
use std::sync::Arc;
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::Mutex;
use tokio_util::codec::Framed;

impl Distributor {
    /// crates new Table containing a list of all audio servers
    /// if audio server gets removed, destructor gets called automatically and audio server connection
    /// will be closed gracefully
    pub fn new() -> Self {
        Distributor {
            servers: HashMap::new(),
            buffers: HashMap::new(),
        }
    }
    /// adds new audio server to the distributer. Distributer holds reference
    pub fn add(
        &mut self,
        addr: SocketAddr,
        jack: JackAudioServer,
        buffer: Arc<std::sync::Mutex<JackBuffer>>,
    ) {
        self.servers.insert(addr, jack);
        self.buffers.insert(addr, buffer);
    }
    /// get ring buffer for audio server
    pub fn get_buffer(
        &mut self,
        addr: SocketAddr,
    ) -> Option<&mut Arc<std::sync::Mutex<JackBuffer>>> {
        self.buffers.get_mut(&addr)
    }
    /// removes audio server and deactivates it (calls destructors of audio server)
    pub fn remove(&mut self, addr: SocketAddr) {
        let server = self.servers.remove(&addr);
        match server {
            None => {
                println!("No server found for addr: {}", addr);
            }
            Some(mut server) => {
                println!("Deactivating server");
                server.deactivate();
            }
        }
        self.buffers.remove(&addr);
    }
}

pub struct TCPControl {
    distributor: Arc<Mutex<Distributor>>,
}

impl TCPControl {
    /// handles the TCP connection
    /// spawns a new task for each connection and manages the connection using the `handle_tcp_connection` function
    pub(crate) async fn new(
        bind_addr: &SocketAddr,
        tx: AudioServerTx,
        config: AudioServerConfig,
    ) -> Self {
        // create new tcp listener
        let tcp = TcpListener::bind(bind_addr).await.unwrap();
        // create distributor to distribute audio from and to audio servers
        // this struct contains the audio server object
        let dist = Arc::new(Mutex::new(Distributor::new()));
        let distributor = dist.clone();
        // running TCP socket in another context to not block audio receiving with non-critical TCP control and management data
        tokio::spawn(async move {
            loop {
                // wait for new connection
                let accept = tcp.accept().await.unwrap();
                // spawns new task to handle connection
                tokio::spawn(handle_tcp_connection(
                    accept,
                    distributor.clone(),
                    tx.clone(),
                    config.clone(),
                ));
            }
        });
        TCPControl { distributor: dist }
    }
    pub(crate) fn get_distributor(&self) -> Arc<Mutex<Distributor>> {
        self.distributor.clone()
    }
}

async fn handle_tcp_connection(
    accept: (TcpStream, SocketAddr),
    distributor: Arc<Mutex<Distributor>>,
    tx: AudioServerTx,
    config: AudioServerConfig,
) {
    let (socket, addr) = accept;
    // Create new codec to encode and decode packets to structs
    let mut framed = Framed::new(socket, PacketCodec::new(1024 * 8));
    loop {
        match framed.next().await {
            None => {
                distributor.lock().await.remove(addr);
                println!("Connection closed");
                break;
            }
            Some(Ok(packet)) => match packet {
                SocketPacket::FPGAConnect(connect) => {
                    let local_addr = framed.get_mut().local_addr().unwrap();
                    let remote_addr = framed.get_mut().peer_addr().unwrap();
                    framed
                        .send(SocketPacket::EstablishDataChannel(
                            EstablishDataChannelPacket {
                                remote: local_addr.to_string(),
                                local: remote_addr.to_string(),
                                channel_in: connect.channel_in,
                                channel_out: connect.channel_out,
                                buffer_size: config.buffer_size,
                                buffer_manager_config: BufferManagerConfig::default(
                                    connect.channel_out,
                                    config.buffer_size,
                                    config.buffering,
                                    config.responsiveness
                                ),
                                max_frame_size: config.max_frame_size
                            },
                        ))
                        .await
                        .unwrap();
                    // create big enough buffer
                    let buffer = JackBuffer::new(1024 * 1024);
                    let buffer = Arc::new(std::sync::Mutex::new(buffer));
                    let mut jack = JackAudioServer::new(
                        &connect.name,
                        connect.channel_out,
                        connect.channel_in,
                        buffer.clone(),
                    );
                    jack.give_tx(tx.clone(), addr);
                    println!("Connect: {:?}", connect);
                    let buffer_manager_config = BufferManagerConfig::default(
                        connect.channel_in,
                        config.buffer_size,
                        config.buffering,
                        config.responsiveness
                    );
                    println!("buffer_manager_config: {:?}", buffer_manager_config);
                    jack.start(buffer_manager_config);
                    distributor.lock().await.add(addr, jack, buffer);
                }
                SocketPacket::Event(event) => {
                    //let timestamp = SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_millis();
                    //println!("|ev|{timestamp}|{addr}|{:?}", event);
//                    tracing::warn!("Event: {:?}", event);
                }
                SocketPacket::Disconnect => {
                    tracing::info!("Connection closed");
                    break;
                }
                pkg => {
                    tracing::warn!("Unknown packet, {:?}", pkg);
                    break;
                }
            },
            Some(Err(err)) => {
                tracing::error!("Error: {:?}", err);
                break;
            }
        }
    }
    distributor.lock().await.remove(addr);
}
