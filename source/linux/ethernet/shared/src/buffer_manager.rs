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

use crate::control::Stats;
use serde::{Deserialize, Serialize};
use std::cmp::Ordering;

pub trait RingBuffer {
    /// puts new data in the buffer
    fn push(&mut self, buf: &[f32]);
    /// gets `len` bytes from the ring buffer
    fn pop(&mut self, len: usize) -> Vec<f32>;
    /// returns the size of the ring buffer
    fn len(&self) -> usize;
    /// returns the amount of data stored in the ring buffer
    fn wealth(&self) -> usize;
    /// sets write index to read index
    fn clear(&mut self);
}

pub struct BufferManager {
    initialized: bool,
    samples_added: usize,
    samples_skipped: usize,
    diff_history: RollingMedian,
    channels: usize,
    /// amount of samples between read and write position of buffer
    optimal_wealth: usize,
    /// how big can the jitter be before adjusting
    wealth_window: usize,
    /// absolute maximum. If over this threshold, reset
    max_wealth_diff: usize,
    /// minimum difference between read and write => pointer collision
    minimum_wealth: usize,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct BufferManagerResponse {
    pub change: AudioStreamChange,
    pub wealth: usize,
    pub average_wealth: Option<usize>,
    pub optimal_wealth: usize,
    pub errors: Vec<AudioStreamInError>,
    pub samples_skipped: usize,
    pub samples_added: usize,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct BufferManagerConfig {
    pub channels: usize,
    pub optimal_wealth: usize,
    pub wealth_window: usize,
    pub max_wealth_diff: usize,
    pub minimum_wealth: usize,
    pub responsiveness: usize,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub enum AudioStreamChange {
    Reset,
    Change(isize),
    None,
}

impl BufferManagerConfig {
    /// Creates a default config. `buffering` is the amount of buffers that should be bufferized before replay.
    #[allow(dead_code)]
    pub fn default(channels: usize, buffer_size: usize, buffering: usize, responsiveness: usize) -> Self {
        Self {
            channels,
            // one buffer size in advance
            optimal_wealth: channels * buffer_size * buffering,
            // if wealth is within 1/2 buffer size of optimal wealth, don't change
            wealth_window: channels * buffer_size / 4,
            // if wealth is much too big, reset
            max_wealth_diff: channels * buffer_size * 2,
            // pointer collision if there is only one sample left
            minimum_wealth: channels,
            // responsiveness, how many packets have to be received before removing/adding samples
            responsiveness
        }
    }
}

impl BufferManager {
    pub fn new(config: BufferManagerConfig) -> BufferManager {
        let diff_history = RollingMedian::new(config.responsiveness);
        Self {
            diff_history,
            channels: config.channels,
            optimal_wealth: config.optimal_wealth,
            wealth_window: config.wealth_window,
            max_wealth_diff: config.max_wealth_diff,
            minimum_wealth: config.minimum_wealth,
            initialized: false,
            samples_added: 0,
            samples_skipped: 0,
        }
    }
    /// change buffer manager configuration
    #[allow(dead_code)]
    pub fn change_config(&mut self, config: BufferManagerConfig) {
        self.initialized = false;
        self.channels = config.channels;
        self.optimal_wealth = config.optimal_wealth;
        self.wealth_window = config.wealth_window;
        self.max_wealth_diff = config.max_wealth_diff;
        self.minimum_wealth = config.minimum_wealth;
    }
    /// returns how much buffer should be modified
    pub fn offset_adjustment(
        &mut self,
        wealth: usize,
        //buffer: &mut Vec<f32>,
    ) -> BufferManagerResponse {
        let mut errors = Vec::new();
        let wealth_median = self.diff_history.calc_median();
        self.diff_history.add(wealth);

        // detect overrun
        if wealth < self.minimum_wealth {
            errors.push(AudioStreamInError::PointerCollision);
        }
        let mut change = AudioStreamChange::None;
        // if we have already enough statistics of packet arrival
        if let Some(wealth_median) = wealth_median {
            // amount of difference if is null, no adjustment necessary
            let error_amount = wealth_median as isize - self.optimal_wealth as isize;
            if error_amount.unsigned_abs() > self.wealth_window {
                // first time of execution or very big difference
                if !self.initialized {
                    self.initialized = true;
                    errors.push(AudioStreamInError::Reset(error_amount));
                    change = AudioStreamChange::Reset;
                    self.diff_history.clear_median();
                // if error amount too big, set into not initialized mode
                } else if error_amount.unsigned_abs() > self.max_wealth_diff {
                    self.initialized = false;
                    self.diff_history.clear_median();
                } else if error_amount.abs() > 0 {
                    // if there have to be added samples
                    let samples_to_skip = match error_amount.cmp(&0) {
                        Ordering::Greater => -1,
                        Ordering::Less => 1,
                        Ordering::Equal => 0,
                    };
                    change = AudioStreamChange::Change(samples_to_skip);
                    self.diff_history.clear_median();
                }
            }
        }
        /*if !self.initialized {
            buffer.iter_mut().for_each(|e| *e = 0.0);
        }*/
        BufferManagerResponse {
            change,
            wealth,
            average_wealth: wealth_median,
            optimal_wealth: self.optimal_wealth,
            samples_skipped: self.samples_skipped,
            samples_added: self.samples_added,
            errors,
        }
    }
    /// adjusts the ring buffer when on the writing operation
    pub fn adjust_ring_buffer<T: RingBuffer>(
        &mut self,
        resp: AudioStreamChange,
        ring: &mut T,
        buffer: &mut Vec<f32>,
    ) {
        match resp {
            AudioStreamChange::Reset => {
                ring.clear();
                // align with channel count
                let fill = self.optimal_wealth - self.optimal_wealth % self.channels;
                // to keep the samples aligned
                ring.push(&vec![0.0; fill]);
            }
            AudioStreamChange::Change(change) => {
                change_buffer_size(buffer, self.channels, change);
                self.save_change(change);
            }
            AudioStreamChange::None => {}
        };
    }
    /// adjusts ring buffer on reading
    /// returns the adjusted samples
    #[allow(dead_code)]
    pub fn get_adjusted_samples<T: RingBuffer>(
        &mut self,
        resp: AudioStreamChange,
        ring: &mut T,
        len: usize,
    ) -> Vec<f32> {
        match resp {
            AudioStreamChange::Reset => {
                ring.clear();
                // align with channel count
                let fill = self.optimal_wealth - self.optimal_wealth % self.channels;
                ring.push(&vec![0.0; fill]);
                ring.pop(len)
            }
            AudioStreamChange::Change(change) => {
                let pop_amount = (len as isize - change * self.channels as isize) as usize;
                let mut buffer = ring.pop(pop_amount);
                change_buffer_size(&mut buffer, self.channels, change);
                self.save_change(change);
                buffer
            }
            AudioStreamChange::None => ring.pop(len),
        }
    }
    /// returns the statistics of the buffer manager
    pub fn get_stats(&mut self) -> Stats {
        Stats {
            wealth: self.diff_history.calc_median(),
            average_wealth: self.diff_history.calc_median(),
            optimal_wealth: self.optimal_wealth,
            samples_added: self.samples_added,
            samples_skipped: self.samples_skipped,
        }
    }
    /// saves the change to the internal statistics
    fn save_change(&mut self, change: isize) {
        match change.cmp(&0) {
            Ordering::Greater => self.samples_added += change.unsigned_abs(),
            Ordering::Less => self.samples_skipped += change.unsigned_abs(),
            Ordering::Equal => {}
        }
    }
}

pub struct RollingMedian {
    buffer: Vec<Option<usize>>,
    sorted: Vec<usize>,
    ptr: usize,
    last_median: Option<usize>,
}

impl RollingMedian {
    pub fn new(len: usize) -> RollingMedian {
        assert_ne!(len, 0, "len '0' not allowed!");
        let b = vec![None; len];
        let mut sorted = Vec::new();
        sorted.reserve(len);
        Self {
            buffer: b,
            sorted,
            ptr: 0,
            last_median: None,
        }
    }
    pub fn add(&mut self, val: usize) {
        *self.buffer.get_mut(self.ptr).unwrap() = Some(val);
        self.ptr += 1;
        self.ptr %= self.buffer.len();
        self.last_median = None;
    }
    pub fn calc_median(&mut self) -> Option<usize> {
        if let Some(m) = self.last_median {
            return Some(m);
        }
        self.sorted.clear();
        for v in &self.buffer {
            if let Some(v) = v {
                self.sorted.push(*v);
            } else {
                return None;
            }
        }
        self.sorted.sort_unstable();

        self.last_median = self.sorted.get(self.sorted.len() / 2).cloned();
        self.last_median
    }
    pub fn clear_median(&mut self) {
        self.buffer.iter_mut().for_each(|e| *e = None);
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub enum AudioStreamInError {
    None,
    Reset(isize),
    SampleAdjustment(isize),
    PointerCollision,
    /// (expected, actual)
    SequenceError(u32, u32),
}

pub fn change_buffer_size(buffer: &mut Vec<f32>, channels: usize, change: isize) {
    if change == 0 {
        return;
    }
    assert!(
        buffer.len() >= channels * 3,
        "Provided buffer is too small! It should at least have size of channel * 3!"
    );
    assert!(
        change == 1 || change == 0 || change == -1,
        "Not supported yet! Unimplemented change amount!"
    );

    let center = buffer.len() / 2;
    let center = center - center % channels;
    if change < 0 {
        for i in 0..channels {
            let a = center + i - channels;
            let b = center;
            let a_val = (buffer[a] + buffer[b]) / 2.0;
            buffer[a] = a_val;
            buffer.remove(center);
        }
    }
    if change > 0 {
        let mut add = Vec::new();
        for i in 0..channels {
            let a = center + i - channels;
            let b = center + i;
            let c = (buffer[a] + buffer[b]) / 2.0;
            add.push(c);
        }
        *buffer = [&buffer[0..center], &add[..], &buffer[center..buffer.len()]]
            .concat()
            .to_vec();
    }
}

impl Drop for BufferManager {
    fn drop(&mut self) {
        tracing::info!("dropping buffer manager!");
    }
}
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_change_buffersize() {
        // Test case 1: Negative change
        let mut buffer1 = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
        let channels1 = 2;
        let change1 = -1;
        change_buffer_size(&mut buffer1, channels1, change1);
        assert_eq!(buffer1, vec![2.0, 3.0, 5.0, 6.0]);

        // Test case 2: Positive change
        let mut buffer2 = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
        let channels2 = 2;
        let change2 = 1;
        change_buffer_size(&mut buffer2, channels2, change2);
        assert_eq!(buffer2, vec![1.0, 2.0, 2.0, 3.0, 3.0, 4.0, 5.0, 6.0]);

        // Test case 3: No change
        let mut buffer3 = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
        let original3 = buffer3.clone();
        let channels3 = 2;
        let change3 = 0;
        change_buffer_size(&mut buffer3, channels3, change3);
        assert_eq!(buffer3, original3);
    }

    #[test]
    fn test_new() {
        // Test creating a new RollingMedian instance
        let len = 5;
        let rolling_median = RollingMedian::new(len);
        assert_eq!(rolling_median.buffer.len(), len);
        assert_eq!(rolling_median.sorted.len(), 0);
        assert_eq!(rolling_median.ptr, 0);
    }

    #[test]
    #[should_panic(expected = "len 0 not allowed!")]
    fn test_new_zero_length() {
        // Test creating a new RollingMedian instance with a length of 0
        let len = 0;
        RollingMedian::new(len);
    }

    #[test]
    fn test_add() {
        // Test adding values to the buffer
        let len = 3;
        let mut rolling_median = RollingMedian::new(len);
        rolling_median.add(5);
        rolling_median.add(10);
        rolling_median.add(7);
        assert_eq!(rolling_median.buffer, vec![Some(5), Some(10), Some(7)]);
        assert_eq!(rolling_median.ptr, 0);
    }

    #[test]
    fn test_calc_median() {
        // Test calculating the median
        let len = 5;
        let mut rolling_median = RollingMedian::new(len);
        rolling_median.add(5);
        rolling_median.add(10);
        rolling_median.add(7);
        rolling_median.add(3);
        rolling_median.add(12);
        let median = rolling_median.calc_median();
        assert_eq!(median, Some(7));
    }

    #[test]
    fn test_calc_median_empty() {
        // Test calculating the median when the buffer is empty
        let len = 3;
        let mut rolling_median = RollingMedian::new(len);
        let median = rolling_median.calc_median();
        assert_eq!(median, None);
    }

    #[test]
    fn test_clear_median() {
        // Test clearing the median buffer
        let len = 4;
        let mut rolling_median = RollingMedian::new(len);
        rolling_median.add(5);
        rolling_median.add(10);
        rolling_median.add(7);
        rolling_median.add(3);
        rolling_median.add(33);
        rolling_median.clear_median();
        assert_eq!(rolling_median.buffer, vec![None, None, None, None]);
    }
}

pub const fn calc_max_buffer(channels: usize, max_size: usize) -> usize {
//    assert!(channels > 0, "channels must be greater than 0!");
    assert!(
        channels < max_size,
        "max_size must be greater than channels!"
    );
    if channels > 0 {
        return max_size - max_size % channels;
    } else {
        return max_size;
    }
}
