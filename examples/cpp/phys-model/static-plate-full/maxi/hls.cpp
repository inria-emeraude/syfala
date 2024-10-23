#include <syfala/utilities.hpp>
#include <cmath>

// #define modesNumberFull 123459
#define modesNumber 30000

#define INPUTS 0
#define OUTPUTS 2

static bool initialization = true;

void syfala (
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
          int arm_ok,
        bool* i2s_rst,
 const float* coeffs,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug
){
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=coeffs bundle=ram depth=modesNumber*4 latency=30
#pragma HLS INTERFACE m_axi port=mem_zone_f bundle=ram latency=30
#pragma HLS INTERFACE m_axi port=mem_zone_i bundle=ram latency=30

    static float x[modesNumber];
    static float x_prev[modesNumber];
    static float x_next[modesNumber];
    static float input[SYFALA_BLOCK_NSAMPLES];

    if (arm_ok) {
        if (initialization) {
            input[0] = 1.f;
            initialization = false;
        #ifdef __CSIM__
            for (int n = 0; n < 40; n += 4) {
                 printf("n: %d, c1: %f, c2: %f, c3: %f\n",
                    n, coeffs[n], coeffs[n+1], coeffs[n+2]
                );
            }
        #endif
        }
        int c = 0;
        float output[SYFALA_BLOCK_NSAMPLES] = {0.f};
        for (int m = 0 ; m < modesNumber; m++) {
            #pragma HLS performance target_tl=SYFALA_BLOCK_NSAMPLES*1750
            float c1 = coeffs[c];
            float c2 = coeffs[c+1];
            float c3 = coeffs[c+2];
            float mo = coeffs[c+3];
            float x_next_m = x_next[m];
            float x_m = x[m];
            float x_prev_m = x_prev[m];
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                x_next_m  = c1 * x_m
                          + c2 * x_prev_m
                          + c3 * input[n];
                x_prev_m = x_m;
                x_m = x_next_m;
                output[n] += x_next_m * mo;
            }
            x_next[m] = x_next_m;
            x[m] = x_m;
            x_prev[m] = x_prev_m;
            c += 4;
        }
        input[0] = 0;
        for (int o = 0; o < OUTPUTS; ++o) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                float f = output[n] * 100000;
                Syfala::HLS::iowritef(f, audio_out[o][n]);
            }
        }
    }
}
