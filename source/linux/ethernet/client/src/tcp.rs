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

use futures::{SinkExt, StreamExt};
use shared::control::{
    EstablishDataChannelPacket, Event, FPGAConnectPacket, PacketCodec, PacketCodecError,
    SocketPacket,
};
use std::net::SocketAddr;
use tokio::net::TcpStream;
use tokio::sync::mpsc;
use tokio_util::codec::Framed;

pub struct TcpHandler {
    framed: Framed<TcpStream, PacketCodec>,
    stats_rx: mpsc::UnboundedReceiver<Event>,
    stats_tx: mpsc::UnboundedSender<Event>,
}

impl TcpHandler {
    pub async fn new(
        addr: &SocketAddr,
        channels_in: usize,
        channels_out: usize,
        name: &str,
    ) -> Result<Self, PacketCodecError> {
        let tcp = TcpStream::connect(addr)
            .await
            .map_err(PacketCodecError::Io)?;
        let mut framed = Framed::new(tcp, PacketCodec::new(1024));
        framed
            .send(SocketPacket::FPGAConnect(FPGAConnectPacket {
                name: name.to_string(),
                channel_in: channels_in,
                channel_out: channels_out,
            }))
            .await
            .unwrap();

        let (stats_tx, stats_rx) = mpsc::unbounded_channel();
        Ok(Self {
            framed,
            stats_rx,
            stats_tx,
        })
    }
    pub fn get_stats_tx(&self) -> mpsc::UnboundedSender<Event> {
        self.stats_tx.clone()
    }
    /// waits for an EstablishDataChannelPacket and returns it
    pub async fn await_connect_request(
        &mut self,
    ) -> Result<EstablishDataChannelPacket, PacketCodecError> {
        let packet = self
            .framed
            .next()
            .await
            .ok_or_else(|| PacketCodecError::FoundNoting)??;
        match packet {
            SocketPacket::EstablishDataChannel(packet) => Ok(packet),
            _packet => Err(PacketCodecError::FoundNoting),
        }
    }
    pub async fn handle(&mut self) -> Result<(), PacketCodecError> {
        loop {
            tokio::select! {
                res = self.framed.next() => {
                    match res {
                        Some(Ok(packet)) => {
                            tracing::info!("packet: {:?}", packet);
                        }
                        None => {
                            tracing::info!("connection closed");
                            return Ok(())
                        }
                        Some(Err(err)) => {
                            tracing::error!("error: {}", err);
                        }
                    }
                }
                res = self.stats_rx.recv() => {
                    match res {
                        Some(event) => {
                            self.framed.send(SocketPacket::Event(event)).await?;
                        }
                        _ => {
                            tracing::error!("unknown event");
                        }
                    }
                }
            }
        }
    }
}
