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
                for (int n = 0; n < 2; ++n)
                    for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m)
                        audio_out[n][m] = audio_in[n][m];
            } else if (mute) {
                for (int n = 0; n < 2; ++n)
                    for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m)
                         audio_out[n][m] = 0;
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                for (int n = 0; n < 2; ++n)
                    for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
                      float f0 = Syfala::HLS::ioreadf(audio_in[n][m]);
                      Syfala::HLS::iowritef(f0, audio_out[n][m]);
                 }
            }
        }
    }
}
