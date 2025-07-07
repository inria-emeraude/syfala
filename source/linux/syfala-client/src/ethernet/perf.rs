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

use std::cmp::Ordering;

#[derive(Debug, Clone)]
pub struct PerfCounter {
    pub counter: Vec<u32>,
    pub others: Vec<u32>,
}

impl PerfCounter {
    pub(crate) fn new(len: usize) -> PerfCounter {
        let counter = vec![0; len];

        PerfCounter {
            counter,
            others: vec![],
        }
    }
    pub fn add(&mut self, value: u32) {
        if let Some(ptr) = self.counter.get_mut(value as usize) {
            *ptr += 1;
        } else {
            self.others.push(value)
        }
    }
    #[allow(dead_code)]
    pub fn median(&mut self) -> u32 {
        let index_of_max: Option<usize> = self
            .counter
            .iter()
            .enumerate()
            .max_by(|(_, a), (_, b)| a.partial_cmp(b).unwrap_or(Ordering::Equal))
            .map(|(index, _)| index);
        index_of_max.unwrap() as u32
    }
    #[allow(dead_code)]
    pub fn reset(&mut self) {
        self.counter.iter_mut().for_each(|e| *e = 0);
    }
}
