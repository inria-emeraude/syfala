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

use crate::axi::perror;
use libc::off_t;
use std::ffi::{c_void, CString};
use std::mem::size_of;
use std::os::raw::c_char;
use std::{fs, ptr};

pub struct Mem {
    buffer: *mut c_void,
    size: usize,
}
// to send between threads
unsafe impl Send for Mem {}

impl Mem {
    /// creates a new memory mapping on in `name` defined device with `base` address and `size` in bytes
    pub fn new(name: &str, base: usize, size: usize) -> Self {
        // get mmap minimum block size. this is necessary to be aligned with the page size
        // both length and base must be multiples of this value
        let mmap_min_addr = fs::read_to_string("/proc/sys/vm/mmap_min_addr")
            .unwrap()
            .trim()
            .parse::<usize>()
            .unwrap();
        let size_in_bytes = size * size_of::<f32>();
        // checks if float is base aligned with the base address... this should always be the case
        assert_eq!(
            base % size_of::<f32>(),
            0,
            "Can not nmap with unaligned base 0x{:x}",
            base
        );
        // checks if the base address is multiple of mmap_min_addr.
        assert_eq!(
            base % mmap_min_addr,
            0,
            "Can not nmap with base 0x{:x} base needs to be multiple of mmap_min_addr {} Bytes",
            base,
            mmap_min_addr
        );
        // size gets adjusted by the kernel to be a multiple of mmap_min_addr
        // assert_eq!(size_in_bytes % mmap_min_addr, 0, "Can not nmap with size {} Bytes. Size needs to be multiple of mmap_min_addr {} Bytes", size_in_bytes, mmap_min_addr);

        // opening file using libc open
        let cname = CString::new(name).unwrap();
        let cname = cname.as_ptr() as *const c_char;
        let fd = unsafe { libc::open(cname, libc::O_RDWR | libc::O_SYNC) };
        if fd == -1 {
            perror(&format!("open {} failed", name));
            panic!("open failed {}", name);
        }
        // memory map
        let buffer = unsafe {
            libc::mmap(
                ptr::null_mut(),
                size_in_bytes,
                libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_FILE | libc::MAP_SHARED,
                fd,
                base as off_t,
            )
        };
        // error handling
        if buffer == libc::MAP_FAILED {
            perror("nmap failed");
            panic!(
                "mmap failed! name: {} base: 0x{:x} size {}",
                name, base, size
            );
        }
        Self { buffer, size }
    }
    /// puts data into RAM
    /// panics if offset + buf.len() > size
    pub fn set_buf(&mut self, buf: &[f32], offset: usize) {
        assert!(
            (offset + buf.len()) <= self.size,
            "out of bound: write at {} although size {}",
            (offset + buf.len()),
            self.size
        );
        let b = self.buffer as *mut f32;
        unsafe {
            ptr::copy(buf.as_ptr(), b.add(offset), buf.len());
        }
    }
    /// gets data from RAM
    /// panics if offset + len > size
    pub fn get_buf(&mut self, offset: usize, len: usize) -> Vec<f32> {
        assert!(
            (offset + len) <= self.size,
            "out of bound: read at {} although size {}",
            (offset + len),
            self.size
        );
        let mut buffer = vec![0.0; len];
        let b = self.buffer as *mut f32;
        unsafe {
            ptr::copy(b.add(offset), buffer.as_mut_ptr(), len);
        }

        buffer
    }
}

impl Drop for Mem {
    fn drop(&mut self) {
        tracing::info!("dropping Mem...");
        unsafe {
            libc::munmap(self.buffer, self.size);
        }
    }
}
