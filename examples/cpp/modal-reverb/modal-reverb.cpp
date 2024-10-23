#include <syfala/utilities.hpp>

#define INPUTS 1 // in case we'd want to feed an audio signal directly into the modes...
#define OUTPUTS 2

// a-s are generated using coefs.m
#include "coefs.h"

// period of the "click generator" in samples
int period = 336000;

int cnt_sample = 0;
float div_nmodes = (1.0f/NMODES);
float w[NMODES*NCHANS][3] = {{0.0f}};

static void compute(
        sy_ap_int const inputs[INPUTS][SYFALA_BLOCK_NSAMPLES],
              sy_ap_int outputs[OUTPUTS][SYFALA_BLOCK_NSAMPLES]
){
    float x[SYFALA_BLOCK_NSAMPLES] = {0.0f};
    float y[NCHANS][SYFALA_BLOCK_NSAMPLES] = {{0.0f}};

    // input...
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
        // click generator
//         float impulse = 0.0f;
//         if (cnt_sample == 0) impulse = 1.0f;
//         cnt_sample = (cnt_sample + 1) % period;
//         x[n] = impulse;
        x[n] = Syfala::HLS::ioreadf(inputs[0][n]);
    }

    // biquads implemented as direct form 2
    for (int c = 0; c < NCHANS; c++){
        for (int i = 0; i < NMODES; i++){
            #pragma HLS unroll factor=4
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                int i_shift = NMODES*c;
                w[i+i_shift][0] = x[n] - a1[c][i]*w[i+i_shift][1] - a2[c][i]*w[i+i_shift][2];
                y[c][n] += b0[c][i]*w[i+i_shift][0] + b1[c][i]*w[i+i_shift][1];
                for(int j = 2; j > 0 ; --j) {
                    w[i+i_shift][j] = w[i+i_shift][j-1];
                }
            }
        }
    }

    for (int c = 0; c < SYFALA_BLOCK_NSAMPLES; ++c) {
        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
             Syfala::HLS::iowritef(y[c][n], outputs[c][n]);
        }
    }
}

static bool initialization = true;

void syfala (
        sy_ap_int audio_in[INPUTS][SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE ap_fifo port=audio_in
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_in type=complete
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
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out[0][n] = audio_in[0][n];
                     audio_out[1][n] = audio_in[0][n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out[0][n] = 0;
                     audio_out[1][n] = 0;
                }
            } else {
                /* ... or compute samples here */
                compute(audio_in, audio_out);
            }
        }
    }
}
