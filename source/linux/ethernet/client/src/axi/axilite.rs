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

use crate::axi::{get_hex_from_file, perror};
use crate::HLS;
use std::ffi::c_void;
use std::fs::OpenOptions;
use std::mem::size_of;
use std::os::unix::io::AsRawFd;
use std::ptr;

#[derive(Debug)]
pub struct AxiLite {
    size: usize,
    buffer: *mut c_void,
}
// this makes it possible to share AxiLite between threads
unsafe impl Send for AxiLite {}

impl AxiLite {
    /// gets the numbers of channels the FPGA accepts as *input*
    pub fn get_input_channels(&mut self) -> usize {
        self.get_u32(HLS::AXI_LITE_AUDIO_IN_CHANNELS) as usize
    }
    /// gets the numbers of channels the FPGA accepts as *output*
    pub fn get_output_channels(&mut self) -> usize {
        self.get_u32(HLS::AXI_LITE_AUDIO_OUT_CHANNELS) as usize
    }
    /// input last read index. Last position in ring buffer the FPGA has read
    pub fn get_input_last_read(&mut self) -> usize {
        self.get_u32(HLS::AXI_LITE_AUDIO_IN_R) as usize
    }
    /// lets last write index of audio in
    /// gets used to set the last position at which has been written by the ARM
    pub fn set_input_last_write(&mut self, val: usize) {
        self.set_u32(HLS::AXI_LITE_AUDIO_IN_W, val as u32);
    }
    /// set input ring size. must be a power of 2
    pub fn set_input_ring_size(&mut self, ring_size: usize) {
        self.set_u32(HLS::AXI_LITE_AUDIO_IN_LEN, ring_size as u32);
    }
    /// set output ring size. must be a power of 2
    pub fn set_output_ring_size(&mut self, ring_size: usize) {
        self.set_u32(HLS::AXI_LITE_AUDIO_OUT_LEN, ring_size as u32);
    }

    pub fn get_output_write_index(&mut self) -> usize {
        self.get_u32(HLS::AXI_LITE_AUDIO_OUT_W) as usize
    }
    pub fn get_status(&mut self) -> u32 {
        self.get_u32(HLS::AXI_LITE_STATUS)
    }
    /// sets memory offset that the FPGA knows where the input ring buffer starts in memory
    /// must fit in the linux memory mapping so area can't be too small or too tight together
    pub fn set_input_mem_offset(&mut self, offset: usize) {
        self.set_u64(
            HLS::AXI_LITE_RAM_IN_1,
            HLS::AXI_LITE_RAM_IN_2,
            offset as u64,
        );
    }
    /// sets memory offset that the FPGA knows where the input ring buffer starts in memory
    /// must fit in the linux memory mapping so area can't be too small or too tight together
    pub fn set_output_mem_offset(&mut self, offset: usize) {
        self.set_u64(
            HLS::AXI_LITE_RAM_OUT_1,
            HLS::AXI_LITE_RAM_OUT_2,
            offset as u64,
        );
    }
    pub fn activate(&mut self) {
        self.set_u32(HLS::AXI_LITE_ETH_OK, 1);
    }
    pub fn deactivate(&mut self) {
        self.set_u32(HLS::AXI_LITE_ETH_OK, 0);
    }
}

impl AxiLite {
    pub fn new(name: &str) -> Self {
        let size = format!("/sys/class/uio/{}/maps/map0/size", name);
        let size = get_hex_from_file(size);

        let dev = format!("/dev/{}", name);
        // todo replace with libc version with correct flags!
        let dev = OpenOptions::new().read(true).write(true).open(dev).unwrap();
        let buffer;
        unsafe {
            // todo maybe use memmap2 crate
            buffer = libc::mmap(
                ptr::null_mut(),
                size,
                libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_SHARED,
                dev.as_raw_fd(),
                0,
            );
            if buffer == libc::MAP_FAILED {
                perror("mmap failed");
                panic!("mmap failed!")
            }
        }

        Self { size, buffer }
    }
    fn write<T>(&mut self, pos: usize, val: T) {
        let size = size_of::<T>();
        assert!(pos * size < self.size, "out of bound!");
        assert_eq!(pos % size, 0, "Unaligned write from buffer!");
        let b = self.buffer as *mut T;
        unsafe {
            ptr::write_volatile(b.add(pos / size), val);
        }
    }
    fn get<T>(&mut self, pos: usize) -> T {
        let size = size_of::<T>();
        assert!(pos * size < self.size, "out of bound!");
        assert_eq!(pos % size, 0, "Unaligned read from buffer!");
        let b = self.buffer as *mut T;
        unsafe { ptr::read_volatile(b.add(pos / size)) }
    }

    #[cfg(target_endian = "little")]
    fn set_u64(&mut self, pos1: usize, pos2: usize, val: u64) {
        let msb = (val >> 32) as u32;
        let lsb = val as u32;
        self.set_u32(pos1, lsb);
        self.set_u32(pos2, msb);
    }
    fn set_u32(&mut self, pos: usize, val: u32) {
        self.write(pos, val);
    }

    fn get_u32(&mut self, pos: usize) -> u32 {
        self.get(pos)
    }

    #[cfg(target_endian = "little")]
    #[allow(dead_code)]
    fn get_u64(&mut self, pos1: usize, pos2: usize) -> u64 {
        let lsb = self.get::<u32>(pos1);
        let msb = self.get::<u32>(pos2);
        lsb as u64 | (msb as u64) << 32
    }
}

impl Drop for AxiLite {
    fn drop(&mut self) {
        tracing::info!("Dropping AxiLite...");
        self.deactivate();
        unsafe {
            libc::munmap(self.buffer, self.size);
        }
    }
}
