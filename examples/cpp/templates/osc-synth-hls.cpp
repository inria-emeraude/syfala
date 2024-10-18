#include <syfala/utilities.hpp>
#include <cmath>

/**
 * /!\ These macros are always required when writing a
 * Syfala C++ program: it will inform the toolchain to use:
 * - audio_in_# (here audio_in)
 * - audio_out_# (here audio_out_0 and audio_out_1)
 * as audio input and output ports.
 */

#define INPUTS 0
#define OUTPUTS 2

static bool initialization = true;

void syfala (
    sy_ap_int audio_out[OUTPUTS],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug,
        float frequency,
        float gain
) {
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=frequency
#pragma HLS INTERFACE s_axilite port=gain
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
                audio_out[0] = 0;
                audio_out[1] = 0;
            } else {
                /* ... or compute samples here */
                // read input, write it into memory
                static float phase;
                static int iphase;
                float incr = frequency/SYFALA_SAMPLE_RATE;
                iphase = (int)(phase * 16384);
                float f = mem_zone_f[iphase];
            #ifdef __CSIM__
                printf("iphase: %d, f: %f\n", iphase, f);
            #endif
                f *= gain;
                Syfala::HLS::iowritef(f, audio_out[0]);
                Syfala::HLS::iowritef(f, audio_out[1]);
                phase += incr;
                phase = fmodf(phase, 1.f);
            }
        }
    }
}
