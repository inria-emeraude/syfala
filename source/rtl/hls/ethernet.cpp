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

enum ETHERNET_ERROR {
    EOK = 0,
    NOT_READY = 10,
    BUFFER_LEN_ZERO = 11,
    BUFFER_LEN_NOT_POW_OF_TWO = 12,
    BUFFER_LEN_NOT_MULTIPLE_OF_AUDIO_LEN = 13
};

// amount of channels that come from computer to FPGA
#define CHANNELS_IN #ETH_I
// amount of channels that goes to faust to computer
#define CHANNELS_OUT #ETH_O

static int audio_clk = 0;
static int read_index = 0;
static int out_write_index = 0;

// checks if x is 2^N and at least 2
bool is_pow_of_two(int x) {
    return (x > 1) && ((x & (x - 1)) == 0);
}

void eth_audio (
    float* ram_in,      // from ddr
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

    sy_ap_int audio_in_#ETH_N,  // from i2s
    sy_ap_int* audio_out_#ETH_N, // to i2s
    int* status,
    int* read_clk
) {
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

    *audio_in_channels = CHANNELS_IN;
    *audio_out_channels = CHANNELS_OUT;
    // Error handling
    ETHERNET_ERROR local_status = EOK;
    // if ARM eth not ready yet
    if (!eth_ok) {
        local_status = NOT_READY;
    }
    // catch div by 0
    if (audio_out_len == 0 || audio_in_len == 0) {
        local_status = BUFFER_LEN_ZERO;
    }

    if (audio_in_len % CHANNELS_IN != 0 || audio_out_len % CHANNELS_OUT != 0) {
        local_status = BUFFER_LEN_NOT_MULTIPLE_OF_AUDIO_LEN;
    }
    /*if (!is_pow_of_two(audio_in_len) || !is_pow_of_two(audio_out_len)) {
        local_status = BUFFER_LEN_NOT_POW_OF_TWO;
    }*/
    // latching the status
    *status = local_status;
    // reset
    if (local_status != EOK) {
        *audio_in_r = 0;
        *audio_in_w = 0;
        *audio_out_r = 0;
        *audio_out_w = 0;
        read_index = 0;
        out_write_index = 0;

        return;
    }
    // convert float to L24 and write data form RAM to IP output
    *audio_out_#ETH_N = sy_ap_int(ram_in[read_index + #ETH_N] * SCALE_FACTOR);

    // set 0
    ram_in[read_index + #ETH_N] = 0.0f;

    // advance read index
    read_index += CHANNELS_IN;
    read_index %= audio_in_len;

    // write data to RAM
    ram_out[out_write_index + #ETH_N] = audio_in_#ETH_N.to_float() / SCALE_FACTOR;

    // advance write index
    out_write_index += CHANNELS_OUT;
    out_write_index %= audio_out_len;

    // pass data to axi
    *audio_in_r = read_index;
    *audio_out_w = out_write_index;
    // debug
    audio_clk++;
}
