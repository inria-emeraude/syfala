#include <syfala/utilities.hpp>
#include <cmath>

#define modesNumber 30000
#define INPUTS 0
#define OUTPUTS 2

static float x[modesNumber];
static float x_prev[modesNumber];
static float x_next[modesNumber];
static float input[SYFALA_BLOCK_NSAMPLES];

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
// #pragma HLS cache port=coeffs depth=64 lines=1
#pragma HLS INTERFACE m_axi port=mem_zone_f bundle=ram latency=30
#pragma HLS INTERFACE m_axi port=mem_zone_i bundle=ram latency=30

    if (arm_ok) {
        if (initialization) {
            input[0] = 170;
            initialization = false;
        }
        float output[SYFALA_BLOCK_NSAMPLES] = {0};
        int c = 0;
        for (int m = 0 ; m < modesNumber; m++) {
            #pragma HLS pipeline II=1
            float c1 = coeffs[c];
            float c2 = coeffs[c+1];
            float c3 = coeffs[c+2];
            float mo = coeffs[c+3]; // 'modesOut'
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                #pragma HLS unroll
                x_next[m] = c1 * x[m]
                          + c2 * x_prev[m]
                          + c3 * input[n];
                output[n] += x_next[m] * mo;
                x_prev[m] = x[m];
                x[m] = x_next[m];
            }
            c += 4;
        }
        input[0] = 0;
        for (int o = 0; o < OUTPUTS; ++o) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                float f = output[n] * 20000;
                Syfala::HLS::iowritef(f, audio_out[o][n]);
            }
        }
    }
}
