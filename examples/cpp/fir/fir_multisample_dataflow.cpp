
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
static float samples[NCOEFFS];
static float sawtooth;

void read_input_samples(hls::stream<float>& input_samples) {
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
         input_samples << sawtooth;
         sawtooth += 0.01f;
         sawtooth = sawtooth > 1 ? sawtooth -1 : sawtooth;
    }
}

void compute_fir(float* coeffs,
    hls::stream<float>& input_samples,
    hls::stream<float>& output_samples
){
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
         float fTemp = 0;
         input_samples >> samples[0];
         for (int j0 = NCOEFFS-1; j0 > 0; --j0) {
              samples[j0] = samples[j0-1];
         }
         for (int n = 0; n < NCOEFFS; ++n) {
             fTemp += samples[n] * coeffs[n];
         }
        output_samples << fTemp;
    }
}

void write_output_samples(
     hls::stream<float>& output_samples,
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES]
){
    float outputs[SYFALA_BLOCK_NSAMPLES][OUTPUTS];
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
         float out = 0;
         output_samples >> out;
         outputs[n][0] = out;
         outputs[n][1] = out;
         Syfala::HLS::iowritef(outputs[n][0], audio_out[0][n]);
         Syfala::HLS::iowritef(outputs[n][1], audio_out[1][n]);
    }
}

void compute(float* coeffs,
		  sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES]
){
    hls::stream<float> input_samples;
    hls::stream<float> output_samples;
#pragma HLS DATAFLOW
    read_input_samples(input_samples);
    compute_fir(coeffs, input_samples, output_samples);
    write_output_samples(output_samples, audio_out);
}

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
        /* Every other iterations:
         * either process the bypass & mute switches... */
            if (bypass || mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out[0][n] = 0;
                     audio_out[1][n] = 0;
                }
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                compute(coeffs115, audio_out);
            }
        }
    }
}
