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

use std::sync::{Arc, Mutex};

use crate::ethernet::axi::axilite::AxiLite;
use crate::ethernet::axi::ram::Mem;
use serde::{Deserialize, Serialize};

use shared::buffer_manager::RingBuffer;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ConnectionConfig {
    pub uio: String,
    pub mem: String,
    pub mem_in: usize,
    pub mem_out: usize,
    pub mem_in_max_size: usize,
    pub mem_out_max_size: usize,
}

pub struct AudioStreamOut {
    axi: Arc<Mutex<AxiLite>>,
    mem: Mem,
    ring_size: usize,
    read_index: usize,
}
impl AudioStreamOut {
    pub fn new(axi: Arc<Mutex<AxiLite>>, config: &ConnectionConfig, ring_size: usize) -> Self {
        {
            let mut axi = axi.lock().unwrap();
            axi.set_output_ring_size(ring_size);
            axi.set_output_mem_offset(config.mem_out);
        }
        let mem = Mem::new(&config.mem, config.mem_out, ring_size);
        Self {
            axi,
            mem,
            ring_size,
            read_index: 0,
        }
    }
}
pub struct AudioStreamIn {
    axi: Arc<Mutex<AxiLite>>,
    mem: Mem,
    ring_size: usize,
    write_index: usize,
    read_index: usize,
}
impl AudioStreamIn {
    pub fn new(axi: Arc<Mutex<AxiLite>>, config: &ConnectionConfig, ring_size: usize) -> Self {
        {
            let mut axi = axi.lock().unwrap();
            axi.set_input_ring_size(ring_size);
            axi.set_input_mem_offset(config.mem_in);
        }
        let mem = Mem::new(&config.mem, config.mem_in, ring_size);

        Self {
            axi,
            mem,
            ring_size,
            write_index: 0,
            read_index: 0,
        }
    }
}

impl RingBuffer for AudioStreamOut {
    fn push(&mut self, _buf: &[f32]) {
        todo!()
    }

    fn pop(&mut self, len: usize) -> Vec<f32> {
        let mut buffer = Vec::new();
        let mut end_read = self.read_index + len;
        end_read %= self.ring_size;
        // if buffer wraps around
        if end_read < self.read_index {
            let mut buf1 = self
                .mem
                .get_buf(self.read_index, self.ring_size - self.read_index);
            let mut buf2 = self.mem.get_buf(0, end_read);
            buffer.append(&mut buf1);
            buffer.append(&mut buf2);
        } else {
            buffer = self
                .mem
                .get_buf(self.read_index, end_read - self.read_index);
        }
        self.read_index = end_read;
        return buffer;
    }

    fn len(&self) -> usize {
        return self.ring_size;
    }

    fn wealth(&self) -> usize {
        let write_index = {
            let mut axi = self.axi.lock().unwrap();
            axi.get_output_write_index()
        };
        assert!(write_index < self.ring_size,
            "Write index ({}) is bigger than Ring Buffer size {}",
            write_index, self.ring_size
        );
        if write_index < self.read_index {
            return self.ring_size - self.read_index + write_index;
        } else {
            return write_index - self.read_index;
        }
    }

    fn clear(&mut self) {
        todo!()
    }
}

impl RingBuffer for AudioStreamIn {
    fn push(&mut self, buf: &[f32]) {
        // splitting the buffer in two if crossing the MAX -> 0 threshold
        if buf.len() + self.write_index > self.ring_size {
            // splitting buffer in 2
            let split_point = self.ring_size - self.write_index; // idk why, ask chat.openai.com
            let (buf1, buf2) = buf.split_at(split_point);
            self.mem.set_buf(buf1, self.write_index);
            self.mem.set_buf(buf2, 0);
        } else {
            self.mem.set_buf(buf, self.write_index);
        }
        self.write_index += buf.len();
        self.write_index %= self.ring_size;
        {
            // setting read and write index on the FPGA
            let mut axi = self.axi.lock().unwrap();
            self.read_index = axi.get_input_last_read();
            axi.set_input_last_write(self.write_index);
        }
    }
    /// Does not return anything as it is just a placeholder and the read buffer gets advanced by the FPGA
    /// Always returns None
    fn pop(&mut self, len: usize) -> Vec<f32> {
        // not really necessary just advance read index...
        self.read_index += len;
        self.read_index %= self.ring_size;
        Vec::new()
    }

    fn len(&self) -> usize {
        self.ring_size
    }

    fn wealth(&self) -> usize {
        //println!("read index: {}", self.read_index);
        assert!(
            self.read_index < self.ring_size,
            "got bigger read index than ring size from FPGA: (ring size) {} < {} (read_index)!",
            self.ring_size,
            self.read_index
        );
        if self.write_index >= self.read_index {
            self.write_index - self.read_index
        } else {
            (self.ring_size - self.read_index) + self.write_index
        }
    }

    fn clear(&mut self) {
        {
            // setting read and write index on the FPGA
            let mut axi = self.axi.lock().unwrap();
            self.read_index = axi.get_input_last_read();
            self.write_index = self.read_index;
            axi.set_input_last_write(self.write_index);
        }
    }
}
