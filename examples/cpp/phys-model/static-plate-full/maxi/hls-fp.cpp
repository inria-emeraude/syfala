#include <syfala/utilities.hpp>
#include <cmath>

// #define modesNumberFull 123459
#define modesNumber 30000

#define INPUTS 0
#define OUTPUTS 2

static bool initialization = true;
static bool mute_reg = false;

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
#pragma HLS INTERFACE m_axi port=mem_zone_f bundle=ram latency=20 depth=modesNumber*4
#pragma HLS INTERFACE m_axi port=mem_zone_i bundle=ram latency=20

    static float x[modesNumber];
    static float x_prev[modesNumber];
    static float x_next[modesNumber];
    static float input[SYFALA_BLOCK_NSAMPLES];
    // #pragma HLS array_partition variable=input
    // #pragma HLS array_partition variable=x_prev
    // #pragma HLS array_partition variable=x_next
    // #pragma HLS array_partition variable=x

    if (arm_ok) {
        if (initialization) {
            input[0] = 1.f;
            initialization = false;
        #ifdef __CSIM__
            for (int n = 0; n < 40; n += 4) {
                 printf("n: %d, c1: %f, c2: %f, c3: %f\n",
                    n, mem_zone_f[n], mem_zone_f[n+1], mem_zone_f[n+2]
                );
            }
        #endif
        }
        // Map the 'mute' switch to make an impulse:
        if (mute && mute != mute_reg) {
            input[0] = 1.f;
        }
        int c = 0;
        float output[SYFALA_BLOCK_NSAMPLES] = {0.f};
        // #pragma HLS array_partition variable=output
        for (int m = 0 ; m < modesNumber; m++) {
            #pragma HLS performance target_tl=SYFALA_BLOCK_NSAMPLES*1750
            // #pragma HLS pipeline II=5
            float c1 = mem_zone_f[c];
            float c2 = mem_zone_f[c+1];
            float c3 = mem_zone_f[c+2];
            float mo = mem_zone_f[c+3];
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                // #pragma HLS unroll
                x_next[m]  = c1 * x[m]
                          + c2 * x_prev[m]
                          + c3 * input[n];
                x_prev[m] = x[m];
                x[m] = x_next[m];
                #pragma HLS bind_op variable=output op=fmacc impl=auto precision=low
                output[n] += x_next[m] * mo;
            }
            c += 4;
        }
        for (int o = 0; o < OUTPUTS; ++o) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                float f = output[n] * 1000000;
                Syfala::HLS::iowritef(f, audio_out[o][n]);
            }
        }
        input[0] = 0;
        mute_reg = mute;
    }
}
