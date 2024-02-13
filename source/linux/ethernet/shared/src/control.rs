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

use bytes::{Buf, BytesMut};
use serde::{Deserialize, Serialize};
use std::{cmp, io};
use thiserror::Error;
use tokio_util::codec::{Decoder, Encoder};

use crate::buffer_manager::{AudioStreamChange, AudioStreamInError, BufferManagerConfig};
use bincode::{deserialize, serialize, ErrorKind};
use bytes::BufMut;
use std::net::SocketAddrV6;
use std::str::Utf8Error;
use std::{str, usize};

/// Maximum size of UDP packet
/// this number states how many f32 will be encoded in one UDP packet

/// The Codec encodes/decodes SocketPackets.
/// It uses newline as packet separator and encodes/decodes the packets as json
#[derive(Clone, Debug)]
pub struct PacketCodec {
    max_length: usize,
    // all data before next_index do not contain a newline
    next_index: usize,
}
#[derive(Debug, Error)]
pub enum PacketCodecError {
    /// The maximum line length was exceeded.
    #[error("Max line length exceeded")]
    MaxLineLengthExceeded,
    #[error("Invalid UTF-8")]
    InvalidUtf8(Utf8Error),
    #[error("Invalid JSON")]
    InvalidJson(serde_json::Error),
    #[error("Didn't get response")]
    FoundNoting,
    /// An IO error occurred.
    #[error("I/O Error")]
    Io(io::Error),
}
impl From<io::Error> for PacketCodecError {
    fn from(e: io::Error) -> PacketCodecError {
        PacketCodecError::Io(e)
    }
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Stats {
    pub wealth: Option<usize>,
    pub average_wealth: Option<usize>,
    pub optimal_wealth: usize,
    pub samples_skipped: usize,
    pub samples_added: usize,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub enum Event {
    Stats(Stats),
    Change(AudioStreamChange),
    Error(AudioStreamInError),
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct FPGAConnectPacket {
    pub name: String,
    pub channel_in: usize,
    pub channel_out: usize,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AdminConnectPacket {
    pub name: String,
    pub password: String,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct DiscoveryPacket {
    pub ip: String,
    pub buffer_size: usize,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct EstablishDataChannelPacket {
    pub remote: String,
    pub local: String,
    pub channel_in: usize,
    pub channel_out: usize,
    pub buffer_size: usize,
    pub buffer_manager_config: BufferManagerConfig,
    pub max_frame_size: usize,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub enum SocketPacket {
    Discovery(DiscoveryPacket),
    FPGAConnect(FPGAConnectPacket),
    AdminConnect(AdminConnectPacket),
    EstablishDataChannel(EstablishDataChannelPacket),
    Event(Event),
    Disconnect,
}
impl PacketCodec {
    pub fn new(max_length: usize) -> Self {
        Self {
            max_length,
            next_index: 0,
        }
    }
}
fn without_carriage_return(s: &[u8]) -> &[u8] {
    if let Some(&b'\r') = s.last() {
        &s[..s.len() - 1]
    } else {
        s
    }
}
impl Decoder for PacketCodec {
    type Item = SocketPacket;
    type Error = PacketCodecError;

    fn decode(&mut self, buf: &mut BytesMut) -> Result<Option<SocketPacket>, PacketCodecError> {
        let read_to = cmp::min(self.max_length.saturating_add(1), buf.len());
        let newline_offset = buf[self.next_index..read_to]
            .iter()
            .position(|b| *b == b'\n');

        let line = match newline_offset {
            Some(offset) => {
                // Found a line!
                let newline_index = offset + self.next_index;
                self.next_index = 0;
                let line = buf.split_to(newline_index + 1);
                let line = &line[..line.len() - 1];
                let line = without_carriage_return(line);
                let line = str::from_utf8(line).map_err(PacketCodecError::InvalidUtf8)?;
                line.to_string()
            }
            None => {
                if buf.len() > self.max_length {
                    buf.advance(read_to);
                    return Err(PacketCodecError::MaxLineLengthExceeded);
                }
                // No line found, increase the index so that we don't search
                // again in the next call.
                self.next_index = buf.len();
                return Ok(None);
            }
        };
        // deserialize json
        let packet = serde_json::from_str::<SocketPacket>(&line)
            .map_err(PacketCodecError::InvalidJson)?;
        Ok(Some(packet))
    }
}

impl Encoder<SocketPacket> for PacketCodec {
    type Error = PacketCodecError;

    fn encode(&mut self, packet: SocketPacket, dst: &mut BytesMut) -> Result<(), PacketCodecError> {
        let string = serde_json::to_string(&packet).map_err(PacketCodecError::InvalidJson)?;

        // Don't send a string if it is longer than the other end will
        // accept.
        if string.len() > self.max_length {
            return Err(PacketCodecError::MaxLineLengthExceeded);
        }

        dst.reserve(string.len() + 1);
        dst.put(string.as_bytes());
        dst.put_u8(b'\n');
        Ok(())
    }
}
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Frame {
    pub seq: u32,
    pub is_first: bool,
    pub buffer: Vec<f32>,
}
impl Frame {
    pub fn new(seq: u32, is_first: bool, buffer: Vec<f32>) -> Self {
        Self {
            seq,
            is_first,
            buffer,
        }
    }
}
#[derive(Debug, Error)]
pub enum FrameEncodingError {
    #[error("Invalid UDP packet frame format")]
    InvalidFormat(Box<ErrorKind>),
}

impl Frame {
    /// encodes a frame into bytes
    pub fn encode(self) -> Vec<u8> {
        serialize(&self).unwrap()
    }
    /// Decodes a Frame from a byte slice
    /// throws an error if the slice is not a valid Frame
    pub fn from_u8(bytes: &[u8]) -> Result<Self, FrameEncodingError> {
        deserialize::<Frame>(bytes).map_err(FrameEncodingError::InvalidFormat)
    }
}
/// this function detects if IPv6 address is local or not and rewrites the scope id
/// this is important to set the correct scope id
#[allow(dead_code)]
pub fn if_local_ipv6_set_scope(ip: String, scope_ip: &str) -> String {
    // unfortunatally there is no more idiomatic solution to detect if an ip is local or not
    // https://doc.rust-lang.org/std/net/struct.Ipv6Addr.html#method.is_global
    if ip.starts_with("[fe80") || ip.starts_with("[2001") {
        if let Ok(mut ip) = ip.parse::<SocketAddrV6>() {
            if let Ok(scope_ip) = scope_ip.parse::<SocketAddrV6>() {
                tracing::info!(
                    "Rewriting scope of link local address {ip} to {}...",
                    scope_ip.scope_id()
                );
                ip.set_scope_id(scope_ip.scope_id());
                return ip.to_string();
            }
        }
    }
    ip
}
