#include <syfala/utilities.hpp>
#include <math.h>

// Ideally this should be declared in a shared .h file but this seems to break the system
#ifndef __CSIM__
    #define NSOURCES 8 // number of sources...
    #define INPUTS 0
    #define OUTPUTS 32 // number of speakers...
#endif

#define DEL_MAX 512 // this could be computed automatically based on OUPUTS and speakers_dist (must be a power of 2 here)
#define ARM_BLOCK_SIZE 1024

static bool initialization = true;

const static float devfilter_b1 = -0.8715;
const static float devfilter_b2 = 0.0412;
const static float devfilter_a1 = -0.31134;
const static float devfilter_a2 = -0.088955;
const static float mem_f_channel_size = NSOURCES * ARM_BLOCK_SIZE * 32;
static float devfilter_fbdel[NSOURCES][2] = {};
static float devfilter_ffdel[NSOURCES][2] = {};
static float fdel_del[NSOURCES][DEL_MAX] = {};
static int fdel_idx[NSOURCES] = {};
static int current_read_index = 0;


void syfala (
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
    int arm_ok,
    bool* i2s_rst,
    float* mem_zone_f,
    int* mem_zone_i,
    bool bypass,
    bool mute,
    bool debug,
    float ctrl[NSOURCES*OUTPUTS*2],
    int* hls_current_index,
    float gain,
    float *last_sample
) {
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=ctrl
#pragma HLS INTERFACE s_axilite port=hls_current_index
#pragma HLS INTERFACE s_axilite port=gain
#pragma HLS INTERFACE s_axilite port=last_sample
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

#pragma HLS array_partition variable=fdel_del        type=complete
// #pragma HLS array_partition variable=devfilter_fbdel type=block factor=2 dim=2
// #pragma HLS array_partition variable=devfilter_ffdel type=block factor=2 dim=2
#pragma HLS array_partition variable=fdel_idx        type=complete

    *i2s_rst = !arm_ok;

    #ifdef __CSIM__
    initialization = false;
    #endif

    if (arm_ok) {
        if (initialization) {
            initialization = false;
        }
        else {
            if (bypass || mute) {
                for (int o = 0; o < OUTPUTS; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n){
                        // #pragma HLS unroll
                        audio_out[o][n] = 0;
                    }
                }
            } else {

                float ins[NSOURCES][SYFALA_BLOCK_NSAMPLES] = {};
                float outs[OUTPUTS][SYFALA_BLOCK_NSAMPLES] = {};
                #pragma HLS array_partition variable=ins type=complete
                #pragma HLS array_partition variable=outs type=complete

                mem_zone_f_read_loop:
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    for (int i = 0; i < NSOURCES; ++i){
                        ins[i][n] = mem_zone_f[current_read_index + i + n*NSOURCES] * gain;
                    }
                }

                current_read_index += SYFALA_BLOCK_NSAMPLES*NSOURCES;
                if (current_read_index >= mem_f_channel_size) {
                    current_read_index = 0;
                }
                *hls_current_index = current_read_index;

                // derivating filter
                filter_derivation_loop:
                for (int i = 0; i < NSOURCES; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        #pragma HLS unroll factor = 4
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
                ring_buffer_loop:
                for (int i = 0; i < NSOURCES; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        #pragma HLS unroll factor = 4
                        fdel_del[i][fdel_idx[i] & 511] = ins[i][n];
                        fdel_idx[i] = fdel_idx[i] + 1;
                    }
                }
                // fractional delay using a bit shift and applying final gains
                frationnal_delays_loop:
                for (int i = 0; i < NSOURCES; ++i){
                    for (int o = 0; o < OUTPUTS; ++o){
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            #pragma HLS unroll factor = 4
                            int d_idx = o + OUTPUTS*i*2;
                            int g_idx = d_idx + OUTPUTS;
                            int c_idx = ((int)(fdel_idx[i] - 1 - SYFALA_BLOCK_NSAMPLES - int(ctrl[d_idx]) + n)) & 511;
                            float del_frac = ctrl[d_idx] - floor(ctrl[d_idx]);
                            outs[o][n] += (fdel_del[i][c_idx]*(1-del_frac) + fdel_del[i][c_idx-1]*del_frac)*ctrl[g_idx];
                        }
                    }
                }

                *last_sample = outs[16][SYFALA_BLOCK_NSAMPLES -1];

                output_loop:
                for (int o = 0; o < OUTPUTS; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        // #pragma HLS unroll
                        Syfala::HLS::iowritef(clip(outs[o][n], -1.0f, 1.0f), audio_out[o][n]);
                    }
                }
            }
        }
    }
}
