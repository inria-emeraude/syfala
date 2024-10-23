#include <syfala/utilities.hpp>
#include "plateModalData.h"

#define INPUTS 0
#define OUTPUTS 2
#define OS_FAC 1
#define BASE_SR 48000

static const float base_sample_rate = OS_FAC * BASE_SR;
static float k;
static float k2;
static float excit[modesNumber] = {0};
static float x[modesNumber] = {0};
static float x_prev[modesNumber] = {0};
static float x_next[modesNumber] = {0};

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
) {
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
            for (int n = 0; n < modesNumber; ++n) {
                excit[n] = 1000000;
            }
            k  = 1.0/base_sample_rate;
            k2 = k * k;
            initialization = false;
        } else {
            if (mute) {
                for (int o = 0; o < OUTPUTS; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        audio_out[o][n] = 0;
                    }
                }
            } else{
                if (bypass) {
                    excit[0] = 1.0;
                }
                float output[SYFALA_BLOCK_NSAMPLES] = {0};
                for (int m = 0 ; m < modesNumber; ++m) {
                     float damp_coeffs_k = dampCoeffs[m] * k;
                     #pragma HLS unroll factor=4
                     #pragma HLS pipeline II=1
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                         float c1 = (2 - eigenFreqs[m] * eigenFreqs[m] * k2) / (damp_coeffs_k + 1.f);
                         float c2 = (damp_coeffs_k - 1.f) / (damp_coeffs_k + 1.f);
                         float c3 = k2 / (damp_coeffs_k + 1.f);
                         x_next[m] = c1 * x[m] + c2 * x_prev[m] + c3 * excit[m] * modesIn[m];
                         x_prev[m] = x[m];
                         x[m] = x_next[m];
                         output[n] += x_next[m] * modesOut[m];
                         excit[m] = 0.0;
                    }
                }
                // for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                //      output[n] *= SCALE_FACTOR;
                // }
                for (int o = 0; o < OUTPUTS; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        Syfala::HLS::iowritef(output[n], audio_out[o][n]);
                    }
                }
            }
        }
    }
}

