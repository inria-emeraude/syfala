#include <syfala/utilities.hpp>
#include <cmath>

/**
 * /!\ These macros are always required when writing a
 * Syfala C++ program: it will inform the toolchain to use:
 * - audio_in_# (here audio_in_0 and audio_in_1)
 * - audio_out_# (here audio_out_0 and audio_out_1)
 * as audio input and output ports.
 */
#define INPUTS 1
#define OUTPUTS 32

static bool initialization = true;

void syfala (
        sy_ap_int audio_in_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_2[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_3[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_4[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_5[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_6[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_7[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_8[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_9[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_10[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_11[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_12[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_13[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_14[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_15[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_16[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_17[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_18[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_19[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_20[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_21[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_22[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_23[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_24[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_25[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_26[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_27[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_28[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_29[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_30[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_31[SYFALA_BLOCK_NSAMPLES],
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
#pragma HLS INTERFACE ap_fifo port=audio_out_2
#pragma HLS INTERFACE ap_fifo port=audio_out_3
#pragma HLS INTERFACE ap_fifo port=audio_out_4
#pragma HLS INTERFACE ap_fifo port=audio_out_5
#pragma HLS INTERFACE ap_fifo port=audio_out_6
#pragma HLS INTERFACE ap_fifo port=audio_out_7
#pragma HLS INTERFACE ap_fifo port=audio_out_8
#pragma HLS INTERFACE ap_fifo port=audio_out_9
#pragma HLS INTERFACE ap_fifo port=audio_out_10
#pragma HLS INTERFACE ap_fifo port=audio_out_11
#pragma HLS INTERFACE ap_fifo port=audio_out_12
#pragma HLS INTERFACE ap_fifo port=audio_out_13
#pragma HLS INTERFACE ap_fifo port=audio_out_14
#pragma HLS INTERFACE ap_fifo port=audio_out_15
#pragma HLS INTERFACE ap_fifo port=audio_out_16
#pragma HLS INTERFACE ap_fifo port=audio_out_17
#pragma HLS INTERFACE ap_fifo port=audio_out_18
#pragma HLS INTERFACE ap_fifo port=audio_out_19
#pragma HLS INTERFACE ap_fifo port=audio_out_20
#pragma HLS INTERFACE ap_fifo port=audio_out_21
#pragma HLS INTERFACE ap_fifo port=audio_out_22
#pragma HLS INTERFACE ap_fifo port=audio_out_23
#pragma HLS INTERFACE ap_fifo port=audio_out_24
#pragma HLS INTERFACE ap_fifo port=audio_out_25
#pragma HLS INTERFACE ap_fifo port=audio_out_26
#pragma HLS INTERFACE ap_fifo port=audio_out_27
#pragma HLS INTERFACE ap_fifo port=audio_out_28
#pragma HLS INTERFACE ap_fifo port=audio_out_29
#pragma HLS INTERFACE ap_fifo port=audio_out_30
#pragma HLS INTERFACE ap_fifo port=audio_out_31
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
            initialization = false;
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = audio_in_0[n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = 0;
                     audio_out_1[n] = 0;
                     audio_out_2[n] = 0;
                     audio_out_3[n] = 0;
                     audio_out_4[n] = 0;
                     audio_out_5[n] = 0;
                     audio_out_6[n] = 0;
                     audio_out_7[n] = 0;
                     audio_out_8[n] = 0;
                     audio_out_9[n] = 0;
                     audio_out_10[n] = 0;
                     audio_out_11[n] = 0;
                     audio_out_12[n] = 0;
                     audio_out_13[n] = 0;
                     audio_out_14[n] = 0;
                     audio_out_15[n] = 0;
                     audio_out_16[n] = 0;
                     audio_out_17[n] = 0;
                     audio_out_18[n] = 0;
                     audio_out_19[n] = 0;
                     audio_out_20[n] = 0;
                     audio_out_21[n] = 0;
                     audio_out_22[n] = 0;
                     audio_out_23[n] = 0;
                     audio_out_24[n] = 0;
                     audio_out_25[n] = 0;
                     audio_out_26[n] = 0;
                     audio_out_27[n] = 0;
                     audio_out_28[n] = 0;
                     audio_out_29[n] = 0;
                     audio_out_30[n] = 0;
                     audio_out_31[n] = 0;
                }
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                 for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     float ins[INPUTS] = {0.0f};
                     ins[0] = Syfala::HLS::ioreadf(audio_in_0[n]);
                     Syfala::HLS::iowritef(ins[0], &audio_out_0[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_1[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_2[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_3[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_4[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_5[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_6[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_7[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_8[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_9[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_10[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_11[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_12[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_13[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_14[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_15[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_16[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_17[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_18[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_19[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_20[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_21[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_22[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_23[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_24[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_25[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_26[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_27[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_28[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_29[n]);
                     Syfala::HLS::iowritef(0.0f, &audio_out_30[n]);
                     Syfala::HLS::iowritef(ins[0], &audio_out_31[n]);
                 }
            }
        }
    }
}
