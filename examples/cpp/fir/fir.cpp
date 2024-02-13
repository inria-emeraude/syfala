#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <syfala/utilities.hpp>
#include "coeffs_115.hpp"

#define INPUTS 0
#define OUTPUTS 2
#define NCOEFFS 115

static bool initialization = true;
static float samples[NCOEFFS] = {0.f};
static float sawtooth = 0.f;

void compute(float* coeffs, float* outputs) {
    float fTemp = 0;
    samples[0] = sawtooth;
    for (int n = 0; n < NCOEFFS; ++n) {
         fTemp += samples[n] * coeffs[n];
    }
    for (int j0 = NCOEFFS-1; j0 > 0; --j0) {
         samples[j0] = samples[j0-1];
    }
    sawtooth += 0.01f;
    sawtooth = fmodf(sawtooth, 1.f);
    outputs[0] = fTemp;
    outputs[1] = fTemp;
}

void syfala (
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
          int* control_block,
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
                *audio_out_0 = 0;
                *audio_out_1 = 0;
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                float outputs[2];
                compute(coeffs115, outputs);
                outputs[0] = clip<sy_real_t>(outputs[0], -1.f, 1.f);
                outputs[1] = clip<sy_real_t>(outputs[1], -1.f, 1.f);
                Syfala::HLS::iowritef(outputs[0], audio_out_0);
                Syfala::HLS::iowritef(outputs[1], audio_out_1);
            }
        }
    }
}
