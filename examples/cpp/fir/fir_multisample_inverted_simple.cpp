
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include "coeffs.hpp"

#define INPUTS 0
#define OUTPUTS 2
#define NCOEFFS 115

static bool initialization = true;

void syfala (
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug
){
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;
    /* Initialization and computations can start after the ARM
     * has been initialized */
    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
        // Initialize all runtime data here.
        // don't forget to toggle the variable off
           initialization = false;
        } else {
            /* ... or compute samples here
             * if you need to convert to float, use the following:
             * (audio inputs and outputs are 24-bit integers) */
            static float mem[NCOEFFS+SYFALA_BLOCK_NSAMPLES];
            static float sawtooth;
            float out[SYFALA_BLOCK_NSAMPLES] = {0};

            for (int s = 0; s < SYFALA_BLOCK_NSAMPLES; ++s) {
                 mem[SYFALA_BLOCK_NSAMPLES-1-s] = sawtooth;
                 sawtooth += 0.01f;
                 sawtooth = sawtooth > 1 ? sawtooth -1 : sawtooth;
            }
            for (int c = 0; c < NCOEFFS; ++c) {
                // #pragma HLS unroll factor=5
                for (int s = 0; s < SYFALA_BLOCK_NSAMPLES; ++s) {
                     #pragma HLS unroll
                     out[s] += mem[SYFALA_BLOCK_NSAMPLES+c-1-s] * coeffs115[c];
                }
            }
            for (int j = NCOEFFS+SYFALA_BLOCK_NSAMPLES-1; j > SYFALA_BLOCK_NSAMPLES; --j) {
                 mem[j] = mem[j-SYFALA_BLOCK_NSAMPLES];
            }
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; n++) {
                 Syfala::HLS::iowritef(out[n], audio_out[0][n]);
                 Syfala::HLS::iowritef(out[n], audio_out[1][n]);
            }
        }
    }
}

