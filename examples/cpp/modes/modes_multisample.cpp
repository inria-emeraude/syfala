#include <syfala/utilities.hpp>

#define INPUTS 1 // in case we'd want to feed an audio signal directly into the modes...
#define OUTPUTS 2

#define NMODES 8000

// b-s are static
float b0 = 1.0f;
float b1 = 0.0f;
float b2 = -1.0f;

// a-s are generated using coefs.m
#include "coefs.h"

// period of the "click generator" in samples
int period = 336000;

int cnt_sample = 0;
float div_nmodes = (1.0f/NMODES);
float w[NMODES][3] = {{0.0f}};

static void compute(sy_ap_int const input_0[],
                    sy_ap_int output_0[],
                    sy_ap_int output_1[])
{
    float x[SYFALA_BLOCK_NSAMPLES] = {0.0f};
    float y[SYFALA_BLOCK_NSAMPLES] = {0.0f};

    // input...
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
        // click generator
        float impulse = 0.0f;
        if(cnt_sample == 0) impulse = 1.0f;
        cnt_sample = (cnt_sample + 1)%period;
        //x[n] = impulse;
        // for now we don't take an audio signal in...
        x[n] = Syfala::HLS::ioreadf(input_0[n]) + impulse;
    }

    // biquads implemented as direct form 2
    for (int i = 0; i < NMODES; i++){
        #pragma HLS unroll factor=4
        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
            w[i][0] = x[n] - a1[i]*w[i][1] - a2*w[i][2];
            y[n] += b0*w[i][0] + b1*w[i][1] + b2*w[i][2];
            for(int j = 2; j > 0 ; --j) {
                w[i][j] = w[i][j-1];
            }
        }
    }

    // sacling the output
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
        y[n] = y[n]*div_nmodes;
    }


    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
        Syfala::HLS::iowritef(y[n], output_0[n]);
        Syfala::HLS::iowritef(y[n], output_1[n]);
    }
}

static bool initialization = true;

void syfala (
        sy_ap_int audio_in_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE ap_fifo port=audio_in_0
#pragma HLS INTERFACE ap_fifo port=audio_out_0
#pragma HLS INTERFACE ap_fifo port=audio_out_1
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
                     audio_out_0[n] = audio_in_0[n];
                     audio_out_1[n] = audio_in_0[n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = 0;
                     audio_out_1[n] = 0;
                }
            } else {
                /* ... or compute samples here */
                compute(audio_in_0, audio_out_0, audio_out_1);
            }
        }
    }
}
