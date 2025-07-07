#include <syfala/utilities.hpp>
#include <math.h>

// Ideally this should be declared in a shared .h file but this seems to break the system
#define INPUTS 16 // number of sources...
#define OUTPUTS 32 // number of speakers...
#define DEL_MAX 512 // this could be computed automatically based on OUPUTS and speakers_dist (must be a power of 2 here)

static bool initialization = true;

const static float devfilter_b1 = -0.8715;
const static float devfilter_b2 = 0.0412;
const static float devfilter_a1 = -0.31134;
const static float devfilter_a2 = -0.088955;
static float devfilter_fbdel[INPUTS][2] = {};
static float devfilter_ffdel[INPUTS][2] = {};
static float fdel_del[INPUTS][DEL_MAX] = {};
static int fdel_idx[INPUTS] = {};

void syfala (
    sy_ap_int audio_in[INPUTS][SYFALA_BLOCK_NSAMPLES],
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
    int arm_ok,
    bool* i2s_rst,
    float* mem_zone_f,
    int* mem_zone_i,
    bool bypass,
    bool mute,
    bool debug,
    float ctrl[INPUTS*OUTPUTS*2]
) {
#pragma HLS INTERFACE ap_fifo port=audio_in
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=ctrl
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    *i2s_rst = !arm_ok;

    if (arm_ok) {
        if (initialization) {
            initialization = false;
        }
        else {
            if (bypass) {
                for (int i = 0; i < INPUTS; ++i){
                    for (int o = 0; o < OUTPUTS; ++o){
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n){
                            #pragma HLS pipeline
                            audio_out[o][n] = audio_in[i][n];
                        }
                    }
                }
            }
            else if (mute) {
                for (int o = 0; o < 2; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n){
                        #pragma HLS pipeline
                         audio_out[o][n] = 0;
                    }
                }
            }
            else {
                float ins[INPUTS][SYFALA_BLOCK_NSAMPLES] = {};
                float outs[OUTPUTS][SYFALA_BLOCK_NSAMPLES] = {};
                for (int i = 0; i < INPUTS; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        ins[i][n] = Syfala::HLS::ioreadf(audio_in[i][n]);
                    }
                }
                // derivating filter
                for (int i = 0; i < INPUTS; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        #pragma HLS pipeline
                        ins[i][n] = ins[i][n] - devfilter_fbdel[i][0]*devfilter_a1 + devfilter_fbdel[i][1]*devfilter_a2;
                        devfilter_fbdel[i][1] = devfilter_fbdel[i][0];
                        devfilter_fbdel[i][0] = ins[i][n];
                        float x = ins[i][n];
                        ins[i][n] = x + devfilter_ffdel[i][0]*devfilter_b1 + devfilter_ffdel[i][1]*devfilter_b2;
                        devfilter_ffdel[i][1] = devfilter_ffdel[i][0];
                        devfilter_ffdel[i][0] = x;
                    }
                }
                // ring buffer for delay (shared between all delay lines)
                for (int i = 0; i < INPUTS; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        #pragma HLS pipeline
                        fdel_del[i][fdel_idx[i] & 511] = ins[i][n];
                        fdel_idx[i] = fdel_idx[i] + 1;
                    }
                }
                // fractional delay using a bit shift and applying final gains
                for (int i = 0; i < INPUTS; ++i){
                    for (int o = 0; o < OUTPUTS; ++o){
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            #pragma HLS pipeline
                            int d_idx = o + OUTPUTS*i*2;
                            int g_idx = d_idx + OUTPUTS;
                            int c_idx = ((int)(fdel_idx[i] - 1 - SYFALA_BLOCK_NSAMPLES - int(ctrl[d_idx]) + n)) & 511;
                            float del_frac = ctrl[d_idx] - floor(ctrl[d_idx]);
                            outs[o][n] += (fdel_del[i][c_idx]*(1-del_frac) + fdel_del[i][c_idx-1]*del_frac)*ctrl[g_idx];
                        }
                    }
                }
                for (int o = 0; o < OUTPUTS; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        Syfala::HLS::iowritef(outs[o][n], audio_out[o][n]);
                    }
                }
            }
        }
    }
}
