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

use jack::{ClosureProcessHandler, Control, ProcessScope};
use shared::buffer_manager::{AudioStreamChange, BufferManager, BufferManagerConfig, RingBuffer};
use std::net::SocketAddr;
use std::ops::DerefMut;
use std::sync::{Arc, Mutex};
use std::time::Instant;
use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender};
use tokio::sync::oneshot;

/// Data contains audio data interleaved
#[derive(Debug, Clone)]
pub struct AudioServerEvent {
    pub data: Vec<f32>,
    pub channels: usize,
    pub id: SocketAddr,
}
/// Audio Server Configuration
#[derive(Debug, Clone)]
pub struct AudioServerConfig {
    pub buffering: usize,
    pub buffer_size: usize,
    pub responsiveness: usize,
    pub max_frame_size: usize,
}

pub type AudioServerTx = UnboundedSender<AudioServerEvent>;

#[allow(dead_code)]
pub type AudioServerRx = UnboundedReceiver<AudioServerEvent>;

pub trait AudioServer {
    /// Instantiates a new AudioServer,
    fn new(
        name: &str,
        channel_in: usize,
        channel_out: usize,
        ring_buffer: Arc<Mutex<JackBuffer>>,
    ) -> Self;
    /// Starts the AudioServer, it will begin processing audio samples.
    fn start(&mut self, config: BufferManagerConfig);
    /// Returns the audio server 'tx' to send audio to the clients on the network.
    fn give_tx(&mut self, tx: AudioServerTx, jack_id: SocketAddr);
}

pub struct JackAudioServer {
    pub name: String,
    channel_in: usize,
    channel_out: usize,
    tx: Option<AudioServerTx>,
    ring_buffer: Arc<Mutex<JackBuffer>>,
    kill: Option<oneshot::Sender<i32>>,
    jack_id: Option<SocketAddr>,
}

impl AudioServer for JackAudioServer {
    fn new(
        name: &str,
        channel_in: usize,
        channel_out: usize,
        ring_buffer: Arc<Mutex<JackBuffer>>,
    ) -> Self {
        Self {
            name: name.to_string(),
            channel_in,
            channel_out,
            tx: None,
            ring_buffer,
            kill: None,
            jack_id: None,
        }
    }

    fn start(&mut self, config: BufferManagerConfig) {
        let (client, _status) =
            jack::Client::new(&self.name, jack::ClientOptions::NO_START_SERVER).unwrap();
        let mut out_ports = Vec::new();
        let mut in_ports = Vec::new();
        // 2. register port
        for i in 0..self.channel_out {
            out_ports.push(
                client
                    .register_port(format!("out{}", i).as_str(), jack::AudioOut::default())
                    .unwrap(),
            );
        }
        for i in 0..self.channel_in {
            in_ports.push(
                client
                    .register_port(format!("in{}", i).as_str(), jack::AudioIn::default())
                    .unwrap(),
            );
        }
        tracing::info!("Jack ports registered {:?}", config);
        tracing::info!("Jack inputs {:?}", in_ports);
        tracing::info!("Jack outputs {:?}", out_ports);
        let mut manager = BufferManager::new(config);
        // 3. define process callback handler
        let channel_out = self.channel_out;
        let tx = self.tx.clone();
        let ring_buffer = self.ring_buffer.clone();
        let jack_id = self.jack_id.clone().unwrap();

        let process = ClosureProcessHandler::new(
            move |_: &jack::Client, ps: &ProcessScope| -> Control {
                let time = Instant::now();
                // get all output ports
                let mut out = out_ports
                    .iter_mut()
                    .map(|port| port.as_mut_slice(ps))
                    .collect::<Vec<_>>();
                // Output audio from FPGA to computer
                if !out.is_empty() {
                    let out_total_len = out[0].len() * out.len();
                    let mut ringbuffer = ring_buffer.lock().unwrap();

                    // buffer manager
                    let resp = manager.offset_adjustment(ringbuffer.wealth());
                    if resp.change != AudioStreamChange::None {
                        tracing::info!("Change: {:?}", resp);
                    }
                    let mut buffer = manager.get_adjusted_samples(
                        resp.change,
                        ringbuffer.deref_mut(),
                        out_total_len,
                    );
                    assert_eq!(buffer.len(), out_total_len,
                        "Something with the manager.get_adjusted_samples went wrong.
                        The buffer length is not equal to the out length"
                    );
                    // Deinterleave audio
                    for i in 0..out[0].len() {
                        for out_vec in out.iter_mut() {
                            out_vec[i] = buffer.remove(0);
                        }
                    }
                }
                // Input audio from computer to FPGA
                if !in_ports.is_empty() {
                    // convert jack vectors to vector of channel slices
                    let mut input = in_ports
                        .iter_mut()
                        .map(|port| port.as_slice(ps))
                        .collect::<Vec<_>>();
                    let mut buffer = Vec::new();
                    buffer.reserve(input[0].len() * input.len());
                    // interleave audio
                    for i in 0..input[0].len() {
                        for input in input.iter_mut() {
                            buffer.push(input[i]);
                        }
                    }
                    if let Some(tx) = tx.as_ref() {
                        // Send to UDP thread
                        tx.send(AudioServerEvent {
                            channels: channel_out,
                            data: buffer,
                            id: jack_id.clone(),
                        })
                        .expect("Channel communication failed");
                    }
                }
                let elapsed = time.elapsed();
                if elapsed.as_micros() > 500 {
                    //tracing::warn!("jack process took too long: {:?}", elapsed);
                }
                Control::Continue
            },
        );
        let (kill, rx) = oneshot::channel::<i32>();
        self.kill = Some(kill);
        tokio::spawn(async {
            // 4. Activate the client. Also connect the ports to the system audio.
            let active_client = client.activate_async((), process).unwrap();
            tracing::info!("Jack activated");
            rx.await.unwrap();
            active_client.deactivate().unwrap();
            tracing::info!("Jack deactivated");
        });
    }
    fn give_tx(&mut self, tx: AudioServerTx, jack_id: SocketAddr) {
        self.tx = Some(tx);
        self.jack_id = Some(jack_id);
    }
}
impl Drop for JackAudioServer {
    fn drop(&mut self) {
        self.deactivate();
    }
}

impl JackAudioServer {
    pub fn deactivate(&mut self) {
        if let Some(kill) = self.kill.take() {
            kill.send(0).unwrap();
        }
    }
}

pub struct JackBuffer {
    read_index: usize,
    write_index: usize,
    ring_size: usize,
    buffer: Vec<f32>,
}

impl JackBuffer {
    pub fn new(size: usize) -> JackBuffer {
        let mut buffer = Vec::new();
        for _ in 0..size {
            buffer.push(0.0);
        }
        Self {
            read_index: 0,
            write_index: 0,
            ring_size: size,
            buffer,
        }
    }
}

impl RingBuffer for JackBuffer {
    fn push(&mut self, buf: &[f32]) {
        assert_eq!(self.buffer.len(), self.ring_size);
        for i in 0..buf.len() {
            self.buffer[(i + self.write_index) % self.ring_size] = buf[i];
        }
        self.write_index += buf.len();
        self.write_index %= self.ring_size;
    }

    fn pop(&mut self, len: usize) -> Vec<f32> {
        assert_eq!(self.buffer.len(), self.ring_size);
        let mut buffer = Vec::with_capacity(len);
        for i in 0..len {
            buffer.push(self.buffer[(self.read_index + i) % self.ring_size]);
            // clear buffer after reading for less noise after pointer collision
            self.buffer[(self.read_index + i) % self.ring_size] = 0.0;
        }
        self.read_index += len;
        self.read_index %= self.ring_size;
        return buffer;
    }

    fn len(&self) -> usize {
        self.ring_size
    }

    fn wealth(&self) -> usize {
        //println!("write index {} read index {}", self.write_index, self.read_index);
        if self.write_index >= self.read_index {
            self.write_index - self.read_index
        } else {
            (self.ring_size - self.read_index) + self.write_index
        }
    }

    fn clear(&mut self) {
        self.read_index = self.write_index;
    }
}

/// gets buffer size that jack uses
pub fn get_buffer_size() -> Result<usize, jack::Error> {
    Ok(
        jack::Client::new("tmp", jack::ClientOptions::NO_START_SERVER)?
            .0
            .buffer_size() as usize,
    )
}
