#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <syfala/utilities.hpp>
#include "coeffs.hpp"

#define INPUTS 0
#define OUTPUTS 2
#define NCOEFFS 115

static bool initialization = true;
static float samples[NCOEFFS];
static float sawtooth;

float compute_fir() {
    float out = 0;
    sawtooth += 0.01f;
    sawtooth = fmodf(sawtooth, 1.f);
    samples[0] = sawtooth;
    for (int n = 0; n < NCOEFFS; ++n) {
        #pragma HLS unroll factor=10
         out += samples[n] * coeffs115[n];
    }
    for (int j0 = NCOEFFS-1; j0 > 0; --j0) {
         samples[j0] = samples[j0-1];
    }
    return out;
}

void syfala (
        sy_ap_int audio_out[2],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
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
             * 1. process the bypass & mute switches... */
            if (bypass || mute) {
                audio_out[0] = 0;
                audio_out[1] = 0;
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                float f = compute_fir();
                Syfala::HLS::iowritef(f, audio_out[0]);
                Syfala::HLS::iowritef(f, audio_out[1]);
            }
        }
    }
}
