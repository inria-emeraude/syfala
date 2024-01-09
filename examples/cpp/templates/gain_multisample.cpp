#include <syfala/utilities.hpp>

/**
 * /!\ These macros are always required when writing a
 * Syfala C++ program: it will inform the toolchain to use:
 * - audio_in_# (here audio_in_0 and audio_in_1)
 * - audio_out_# (here audio_out_0 and audio_out_1)
 * as audio input and output ports.
 */
#define INPUTS 2
#define OUTPUTS 2

static void compute(sy_ap_int const input_0[],
                    sy_ap_int const input_1[],
                    sy_ap_int output_0[],
                    sy_ap_int output_1[])
{
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
         // if you need to convert to float, use the following:
         // (audio inputs and outputs are 24-bit integers by default)
         float f0 = Syfala::HLS::ioreadf(input_0[n]) * 0.5f;
         float f1 = Syfala::HLS::ioreadf(input_1[n]) * 0.5f;
         Syfala::HLS::iowritef(f0, output_0[n]);
         Syfala::HLS::iowritef(f1, output_1[n]);
    }
}

static bool initialization = true;

void syfala (
        sy_ap_int audio_in_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_in_1[SYFALA_BLOCK_NSAMPLES],
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
#pragma HLS INTERFACE ap_fifo port=audio_in_1
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
                     audio_out_1[n] = audio_in_1[n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = 0;
                     audio_out_1[n] = 0;
                }
            } else {
                /* ... or compute samples here */
                compute(audio_in_0, audio_in_1, audio_out_0, audio_out_1);
            }
        }
    }
}
