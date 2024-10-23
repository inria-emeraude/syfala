#include <syfala/utilities.hpp>
#include <cmath>

#include "plateModalData_mid.h"

#define INPUTS 0
#define OUTPUTS 2
#define OS_FAC 1
#define BASE_SR 48000
#define modesNumber 12952

static const double base_sample_rate = OS_FAC * BASE_SR;
static double k = 1.0/base_sample_rate;
// static float exc_arr[modesNumber];
static double x[modesNumber];
static double x_prev[modesNumber];
static double x_next[modesNumber];

static bool initialization = true;

void syfala (
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug
) {
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
            for (int m = 0 ; m < modesNumber; ++m) {
                 // exc_arr[m] = 170.0;
            }
            initialization = false;
        } else {
            float output[SYFALA_BLOCK_NSAMPLES] = {0};
            for (int m = 0 ; m < modesNumber; ++m) {
                 // #pragma HLS pipeline II=1
                 float damp_coeffs_k = dampCoeffs[m] * k;
                 float c1 = (float)(2.0 * std::exp(-damp_coeffs_k)
                           * std::cos(std::sqrt((eigenFreqs[m] * eigenFreqs[m]) - (dampCoeffs[m] * dampCoeffs[m])) * k));
                 float c2 = (float)(-std::exp(-2.0 * damp_coeffs_k));
                 float c3 = (float)(k*k * modesIn[m]);
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    // #pragma HLS unroll factor=8
                    x_next[m] = c1 * x[m]
                              + c2 * x_prev[m]
                              + c3 * 170.0;
                    x_prev[m] = x[m];
                    x[m] = x_next[m];
                    output[n] += x_next[m] * (float)(modesOut[m]);
                    // exc_arr[m] = 0.f;
                }
            }
            for (int o = 0; o < OUTPUTS; ++o) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    float f = output[n] * 20000;
                    Syfala::HLS::iowritef(f, audio_out[o][n]);
                }
            }
        }
    }
}

#ifdef __SIM_GCC__
/**
 * @brief This is meant to be compiled with the following command:
 * g++ static-plate-full.cpp
 *  -o static-plate-full
 *  -I/../syfala/build/include
 *  -I/../Xilinx/Vitis_HLS/2022.2/include
 *  -D__SIM_GCC__
 *  -D__CSIM__
 */
int main() {
    static sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES];
    bool i2s_rst = false;
    syfala(audio_out, true, &i2s_rst, nullptr, nullptr, false, false, false);
    for (int n = 0; n < 3000; ++n)
        syfala(audio_out, true, &i2s_rst, nullptr, nullptr, false, false, false);
}
#endif
