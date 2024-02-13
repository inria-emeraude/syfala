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

use crate::axi::axilite::AxiLite;
use crate::connection::{AudioStreamIn, AudioStreamOut, ConnectionConfig};
use shared::buffer_manager::{AudioStreamChange, BufferManager};
use std::io;
use std::net::SocketAddr;
use std::sync::Arc;
use std::sync::Mutex;
use std::time::{Duration, Instant};
use tokio::net::UdpSocket;

use std::str::FromStr;

use shared::buffer_manager::AudioStreamInError::SequenceError;
use shared::buffer_manager::{calc_max_buffer, RingBuffer};
use tokio::time;

use crate::perf;
use shared::control::{EstablishDataChannelPacket, Event as ControlEvent, Frame};

pub(crate) struct UdpConnection {
    socket: UdpSocket,
    manager: BufferManager,
    aout: AudioStreamOut,
    ain: AudioStreamIn,
    stats_tx: tokio::sync::mpsc::UnboundedSender<ControlEvent>,
    #[allow(dead_code)]
    channels_in: usize,
    channels_out: usize,
    max_frame_size: usize
}

impl UdpConnection {
    pub async fn new(
        config: &ConnectionConfig,
        axi: Arc<Mutex<AxiLite>>,
        properties: EstablishDataChannelPacket,
        stats_tx: tokio::sync::mpsc::UnboundedSender<ControlEvent>,
    ) -> Self {
        // network stuff
        let local_bind = SocketAddr::from_str(properties.local.as_str()).unwrap();
        let remote = SocketAddr::from_str(properties.remote.as_str()).unwrap();
        // channels
        let (channels_in, channels_out) = {
            let mut axi = axi.lock().unwrap();
            (axi.get_input_channels(),
             axi.get_output_channels())
        };

        // make ring size a multiple of channels otherwise FPGA crashes
        let aout_size = if channels_out == 0 { 0 } else {
            config.mem_out_max_size - config.mem_out_max_size % channels_out
        };
        let ain_size = if channels_in == 0 { 0 } else {
            config.mem_in_max_size - config.mem_in_max_size % channels_in
        };
        tracing::info!(
            "aout_size: 0x{:x} ({}), ain_size: 0x{:x} ({})",
            aout_size, aout_size, ain_size, ain_size
        );
        // register AudioStreams
        let aout = AudioStreamOut::new(axi.clone(), config, aout_size);
        let ain = AudioStreamIn::new(axi.clone(), config, ain_size);
        // create buffer manager for audio out stream
        let manager = BufferManager::new(properties.buffer_manager_config);
        // reset axi to set all indexes to 0
        axi.lock().unwrap().deactivate();
        time::sleep(Duration::from_millis(1 )).await;
        axi.lock().unwrap().activate();
        // wait till configuration is set on fpga
        time::sleep(Duration::from_millis(60)).await;
        let status = {
            axi.lock().unwrap().get_status()
        };
        assert_eq!(
            status, 0,
            "FPGA not ready, should have status 0 instead it has {}.
            Check ethernet-ip.cpp for meaning of status bits",
            status
        );
        // bind udp socket to same address as TCP socket
        let socket = UdpSocket::bind(local_bind)
            .await
            .unwrap_or_else(|_| panic!("Could not bind to {}", local_bind));
        // connect to remote server
        socket
            .connect(remote)
            .await
            .unwrap_or_else(|_| panic!("Could not connect to {}!", remote));
        UdpConnection {
            channels_in,
            channels_out,
            socket,
            manager,
            aout,
            ain,
            stats_tx,
            max_frame_size: properties.max_frame_size,
        }
    }
    pub async fn handle(
        &mut self,
    ) -> Result<(), io::Error> {
        let mut buf = [0; 1500];
        let mut calc_time = perf::PerfCounter::new(150);
        let mut rx_seq: u32 = 0;
        let mut tx_seq: u32 = 0;
        let mut last_stats_update = Instant::now();
        tracing::debug!("Starting UDP loop");
        loop {
            tokio::select! {
                res = self.socket.recv(&mut buf) => {
                    let time = Instant::now();
                    // Deserialize frame
                    let mut frame = Frame::from_u8(&buf[0..res.unwrap()]).unwrap();
                    // Check sequence number
//                    tracing::info!("Received frame: {:?}", frame);
                    if frame.seq != rx_seq {
                        self.stats_tx.send(ControlEvent::Error(SequenceError(rx_seq, frame.seq))).unwrap();
                        rx_seq = frame.seq;
                        tracing::warn!("SequenceError");
                    }
                    rx_seq = rx_seq.wrapping_add(1);
                    // If this is the first chunk of the buffer (precise timing): calculate the offset.
                    if frame.is_first {
                        let resp = self.manager.offset_adjustment(self.ain.wealth());
                        if !resp.errors.is_empty() {
                            tracing::warn!("Errors: {:?}", resp.errors);
                            for e in resp.errors.clone() {
                                self.stats_tx.send(ControlEvent::Error(e)).unwrap();
                            }
                        }
                        self.manager.adjust_ring_buffer(resp.change.clone(), &mut self.ain, &mut frame.buffer);
                        if resp.change != AudioStreamChange::None {
                            tracing::warn!("Change: {:?}", resp.change);
                            let mut stats = self.manager.get_stats();
                            stats.wealth = Some(self.ain.wealth());
                            self.stats_tx.send(ControlEvent::Change(resp.change)).unwrap();
                            self.stats_tx.send(ControlEvent::Stats(stats)).unwrap();
                        }
                        let time = time.elapsed();
                        calc_time.add(time.as_micros() as u32);
                        if time.as_micros() > 500 {
                            //tracing::warn!("calc took {:?}", time);
                        }
                        if last_stats_update + Duration::from_millis(1000) < Instant::now() {
                            let mut stats = self.manager.get_stats();
                            stats.wealth = Some(self.ain.wealth());
                            self.stats_tx.send(ControlEvent::Stats(stats)).unwrap();
                            last_stats_update = Instant::now();
                        }
                    }
                    self.ain.push(&frame.buffer);

                    ////////////////////////////////////////////////////////////
                    // transmitting data from FPGA to PC
                    ////////////////////////////////////////////////////////////
                    if self.channels_out > 0 {
                        let max_amount_of_samples = calc_max_buffer(
                            self.channels_out,
                            self.max_frame_size
                        );
                        'sendloop: loop {
                            // get how much data is in the buffer
                            let wealth = self.aout.wealth();
                            if wealth < max_amount_of_samples {
                                break 'sendloop;
                            }
                            let buffer = self.aout.pop(max_amount_of_samples);
                            let frame = Frame::new(tx_seq, true, buffer);
                            tx_seq = tx_seq.wrapping_add(1);
                            self.socket.send(&frame.encode()).await?;
                        }
                        let buffer = self.aout.pop(max_amount_of_samples);
                        let frame = Frame::new(tx_seq, true, buffer);
                        tx_seq = tx_seq.wrapping_add(1);
                        self.socket.send(&frame.encode()).await?;
                    }
                },
            }
        }
    }
}
