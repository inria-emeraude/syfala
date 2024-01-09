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
        sy_ap_int  audio_in_0,
        sy_ap_int  audio_in_1,
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

    /* Initialization and computations can start after the ARM
     * has been properly initialized */
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
                *audio_out_0 = audio_in_0;
                *audio_out_1 = audio_in_0;
            } else if (mute) {
                *audio_out_0 = 0;
                *audio_out_1 = 0;
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                 float f0 = Syfala::HLS::ioreadf(audio_in_0);
                 float f1 = Syfala::HLS::ioreadf(audio_in_1);
                 Syfala::HLS::iowritef(f0, audio_out_0);
                 Syfala::HLS::iowritef(f1, audio_out_1);
            }
        }
    }
}
