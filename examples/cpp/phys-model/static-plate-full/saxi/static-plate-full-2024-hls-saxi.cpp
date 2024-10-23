#include <syfala/utilities.hpp>
#include <cmath>

#include "plateModalData_mid.h"

#define INPUTS 0
#define OUTPUTS 2
#define modesNumber 12952

static float x[modesNumber];
static float x_prev[modesNumber];
static float x_next[modesNumber];

static bool initialization = true;

void syfala (
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_i,
       float* mem_zone_f,
        float c1[modesNumber],
        float c2[modesNumber],
        float c3[modesNumber],
        float xc[modesNumber],
        float mo[modesNumber],
         bool bypass,
         bool mute,
         bool debug
){
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=c1
#pragma HLS INTERFACE s_axilite port=c2
#pragma HLS INTERFACE s_axilite port=c3
#pragma HLS INTERFACE s_axilite port=xc
#pragma HLS INTERFACE s_axilite port=mo
#pragma HLS INTERFACE m_axi port=mem_zone_f bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i bundle=ram
    if (arm_ok) {
        float output[SYFALA_BLOCK_NSAMPLES] = {0};
        for (int m = 0 ; m < modesNumber; ++m) {
            #pragma HLS pipeline II=1
            float _c1 = c1[m];
            float _c2 = c2[m];
            float _c3 = c3[m];
            float _xc = xc[m];
            float _mo = mo[m];
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                #pragma HLS unroll
                x_next[m] = _c1 * x[m]
                          + _c2 * x_prev[m]
                          + _c3 * _xc;
                output[n] += x_next[m] * _mo;
                x_prev[m] = x[m];
                x[m] = x_next[m];
                _xc = 0.f;
            }
            xc[m] = _xc;
        }
        for (int o = 0; o < OUTPUTS; ++o) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                 float f = output[n] * 20000;
                 Syfala::HLS::iowritef(f, audio_out[o][n]);
            }
        }
    }
}
