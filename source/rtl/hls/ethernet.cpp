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

#include <syfala/utilities.hpp>
#include <stdbool.h>

#if (SYFALA_ETHERNET_NO_OUTPUT)
    #define SYFALA_ETHERNET_NCHANNELS_FROM_I2S 0
#endif

enum ETHERNET_ERROR {
    EOK = 0,
    NOT_READY = 10,
    BUFFER_LEN_ZERO = 11,
    BUFFER_LEN_NOT_POW_OF_TWO = 12,
    BUFFER_LEN_NOT_MULTIPLE_OF_AUDIO_LEN = 13
};

// Checks if x is 2^N and at least 2
bool is_pow_of_two(int x) {
    return (x > 1) && ((x & (x - 1)) == 0);
}

static int audio_clk;
static int read_index;
static int out_write_index;

void eth_audio (
    float* ram_in,
    float* ram_out,
       int eth_ok,
       int audio_in_len,
       int audio_out_len,
      int* audio_in_channels,
      int* audio_out_channels,
      int* audio_in_r,
      int* audio_in_w,
      int* audio_out_r,
      int* audio_out_w,
    sy_ap_int audio_in[SYFALA_ETHERNET_NCHANNELS_FROM_I2S],
    sy_ap_int audio_out[SYFALA_ETHERNET_NCHANNELS_TO_I2S],
      int* status,
      int* read_clk,
    int* read_debug,
    int* write_debug
) {
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE m_axi port=ram_in latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=ram_out latency=30 bundle=ram
#pragma HLS INTERFACE s_axilite port=eth_ok
#pragma HLS INTERFACE s_axilite port=audio_in_len
#pragma HLS INTERFACE s_axilite port=audio_out_len
#pragma HLS INTERFACE s_axilite port=audio_in_channels
#pragma HLS INTERFACE s_axilite port=audio_out_channels
#pragma HLS INTERFACE s_axilite port=audio_in_r
#pragma HLS INTERFACE s_axilite port=audio_in_w
#pragma HLS INTERFACE s_axilite port=audio_out_r
#pragma HLS INTERFACE s_axilite port=audio_out_w
#pragma HLS INTERFACE s_axilite port=status
#pragma HLS INTERFACE s_axilite port=read_clk

    *audio_in_channels  = SYFALA_ETHERNET_NCHANNELS_TO_I2S;
    *audio_out_channels = SYFALA_ETHERNET_NCHANNELS_FROM_I2S;

    // Error handling
    ETHERNET_ERROR local_status = EOK;
    // if ARM eth not ready yet
    if (!eth_ok) {
        local_status = NOT_READY;
    }
#if (SYFALA_ETHERNET_NCHANNELS_TO_I2S)
    if (audio_in_len == 0) {
        local_status = BUFFER_LEN_ZERO;
    }
    if (audio_in_len & SYFALA_ETHERNET_NCHANNELS_TO_I2S != 0) {
        local_status = BUFFER_LEN_NOT_MULTIPLE_OF_AUDIO_LEN;
    }
#endif
#if (SYFALA_ETHERNET_NCHANNELS_FROM_I2S)
    if (audio_out_len == 0) {
        local_status = BUFFER_LEN_ZERO;
    }
    if (audio_out_len % SYFALA_ETHERNET_NCHANNELS_FROM_I2S != 0) {
        local_status = BUFFER_LEN_NOT_MULTIPLE_OF_AUDIO_LEN;
    }
#endif
    /*if (!is_pow_of_two(audio_in_len) || !is_pow_of_two(audio_out_len)) {
        local_status = BUFFER_LEN_NOT_POW_OF_TWO;
    }*/
    *status = local_status;
    // Reset
    if (local_status != EOK) {
        *audio_in_r = 0;
        *audio_in_w = 0;
        *audio_out_r = 0;
        *audio_out_w = 0;
        read_index = 0;
        out_write_index = 0;
        return;
    }
    // Read data from RAM and output it
    for (int n = 0; n < SYFALA_ETHERNET_NCHANNELS_TO_I2S; ++n) {
         float f = ram_in[read_index];
         Syfala::HLS::iowritef(f, audio_out[n]);
         ram_in[read_index] = 0.0f;
         read_index++;
         if (audio_in_len) {
             read_index %= audio_in_len;
         }
    }
    // Write data back to RAM
    for (int n = 0; n < SYFALA_ETHERNET_NCHANNELS_FROM_I2S; ++n) {
         float f = Syfala::HLS::ioreadf(audio_in[n]);
         ram_out[out_write_index] = f;
         out_write_index++;
         if (audio_out_len) {
             out_write_index %= audio_out_len;
         }
    }
    // Update read/write indexes
    *audio_out_w = out_write_index;
    *audio_in_r = read_index;

    // debug
    audio_clk++;
    *read_debug = read_index;
    *write_debug = out_write_index;
}
