#include <syfala/utilities.hpp>

/**
 * /!\ These macros are always required when writing a
 * Syfala C++ program: it will inform the toolchain to use:
 * - audio_in_# (here audio_in)
 * - audio_out_# (here audio_out_0 and audio_out_1)
 * as audio input and output ports.
 */

#define INPUTS 1
#define OUTPUTS 2

static const int MEM_SIZE = 131000;
static float mem[MEM_SIZE];
static int r = 0, w = MEM_SIZE-1;

static bool initialization = true;

void syfala (
    sy_ap_int audio_in[INPUTS],
    sy_ap_int audio_out[OUTPUTS],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug
) {
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
                audio_out[0] = audio_in[0];
                audio_out[1] = audio_in[0];
            } else if (mute) {
                audio_out[0] = 0;
                audio_out[1] = 0;
            } else {
                /* ... or compute samples here */
                // read input, write it into memory
                float i0 = Syfala::HLS::ioreadf(audio_in[0]);
                mem[w] = i0;
                // read last sample in memory
                float m0 = mem[r];
                r = (r+1) % MEM_SIZE;
                w = (w+1) % MEM_SIZE;
                // Write non-delayed input on left channel
                // Write delayed input on right channel
                Syfala::HLS::iowritef(i0, audio_out[0]);
                Syfala::HLS::iowritef(m0, audio_out[1]);
            }
        }
    }
}
