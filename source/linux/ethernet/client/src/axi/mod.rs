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

pub mod axilite;
pub mod ram;

use std::ffi::CString;
use std::fs::File;
use std::io::Read;

/// Reads a hex value from file and panics if something goes wrong.
fn get_hex_from_file(file_name: String) -> usize {
    let mut fp = File::open(file_name.clone())
        .unwrap_or_else(|_|
            panic!("{file_name} not found")
    );
    let mut buf = String::new();
    fp.read_to_string(&mut buf).unwrap();
    let buf = buf.trim().trim_start_matches("0x");
    usize::from_str_radix(buf, 16).unwrap()
}

/// Wrapper for libc perror.
fn perror(txt: &str) {
    let perror_txt = CString::new(txt).unwrap();
    let perror_txt = perror_txt.as_ptr();
    unsafe {
        libc::perror(perror_txt);
    }
}
