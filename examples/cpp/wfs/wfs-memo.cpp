// WARNING
// This code is just here as a memo for various things we tried: it is not in a working state

#include <syfala/utilities.hpp>
#include <math.h>

#define INPUTS 8
#define OUTPUTS 32

#define DEL_MAX 355

static bool initialization = true;

static float devfilter_b1 = -0.8715;
static float devfilter_b2 = 0.0412;
static float devfilter_a1 = -0.31134;
static float devfilter_a2 = -0.088955;
float devfilter_fbdel[INPUTS][2];
float devfilter_ffdel[INPUTS][2];

//float fdel_del[INPUTS][DEL_MAX];
float fdel_del[INPUTS][DEL_MAX+SYFALA_BLOCK_NSAMPLES+1]; // +1 is to account for fdelay
int fdel_idx[INPUTS];

float ctrl_bis[INPUTS*OUTPUTS*2];

// ARM parameters to be...
// float pregains[INPUTS][OUTPUTS];
// float dels[INPUTS][OUTPUTS];

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
    float ctrl[INPUTS*OUTPUTS*2],
    int update
) {
#pragma HLS INTERFACE ap_fifo port=audio_in
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=ctrl
#pragma HLS INTERFACE s_axilite port=update
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    *i2s_rst = !arm_ok;

    if (arm_ok) {
        if (initialization) {
            for (int i = 0; i < INPUTS; ++i){
                fdel_idx[i] = 0;
                for (int j = 0; j < (DEL_MAX); ++j){
                    fdel_del[i][j] = 0.0;
                }
                for (int j = 0; j < 2; ++j){
                    devfilter_fbdel[i][j] = 0.0;
                    devfilter_ffdel[i][j] = 0.0;
                }
                // for (int o = 0; o < OUTPUTS; ++o){
                //     pregains[i][o] = 1.0f;
                //     dels[i][o] = 100.5f;
                // }
                // for (int o = 0; o < OUTPUTS; ++o){
                //     pregains[i][o] = ((float)o)/128.0 + i*0.25f;
                //     dels[i][o] = ((float)o) + i*32.0;
                // }
            }
            initialization = false;
        }
        else {
            if (bypass) {
                for (int i = 0; i < INPUTS; ++i){
                    for (int o = 0; o < OUTPUTS; ++o){
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n){
                            audio_out[o][n] = audio_in[i][n];
                        }
                    }
                }
            }
            else if (mute) {
                for (int o = 0; o < 2; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n){
                         audio_out[o][n] = 0;
                    }
                }
            }
            else {
                if (update == 1){
                    for (int i = 0; i < INPUTS*OUTPUTS*2; i++){
                        ctrl_bis[i] = ctrl[i];
                    }
                }
                for (int i = 0; i < INPUTS*OUTPUTS*2; i++){
                    ctrl_bis[i] = ctrl[i];
                }
                float ins[INPUTS][SYFALA_BLOCK_NSAMPLES] = {0.0f};
                float outs[OUTPUTS][SYFALA_BLOCK_NSAMPLES] = {{0.0f}};
                for (int i = 0; i < INPUTS; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        ins[i][n] = Syfala::HLS::ioreadf(audio_in[i][n]);
                    }
                }
                for (int i = 0; i < INPUTS; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        // TODO possible optimization on y/x
                        ins[i][n] = ins[i][n] - devfilter_fbdel[i][0]*devfilter_a1 + devfilter_fbdel[i][1]*devfilter_a2;
                        devfilter_fbdel[i][1] = devfilter_fbdel[i][0];
                        devfilter_fbdel[i][0] = ins[i][n];
                        float x = ins[i][n];
                        ins[i][n] = x + devfilter_ffdel[i][0]*devfilter_b1 + devfilter_ffdel[i][1]*devfilter_b2;
                        devfilter_ffdel[i][1] = devfilter_ffdel[i][0];
                        devfilter_ffdel[i][0] = x;
                    }
                }
                 // Note: merging this loop with the previous one increases latency and reduces ressources allocation
                for (int i = 0; i < INPUTS; ++i){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        fdel_del[i][0] = ins[i][n];
                        #pragma HLS pipeline II=1
                        for (int j = (DEL_MAX+SYFALA_BLOCK_NSAMPLES); j > 0; --j){
                            fdel_del[i][j] = fdel_del[i][j-1];
                        }
                    }
                }
                for (int i = 0; i < INPUTS; ++i){
                    for (int o = 0; o < OUTPUTS; ++o){
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            int d_idx = o + OUTPUTS*i*2;
                            int g_idx = d_idx + OUTPUTS;
                            int ct_idx = int(ctrl_bis[d_idx]) + (SYFALA_BLOCK_NSAMPLES-1) - n;
                            float del_frac = ctrl_bis[d_idx] - floor(ctrl_bis[d_idx]);
                            outs[o][n] += (fdel_del[i][ct_idx]*(1-del_frac) + fdel_del[i][ct_idx+1]*del_frac)*ctrl_bis[g_idx];
                        }
                    }
                }
                // Modulo approach (less latency but more resources)
                // for (int i = 0; i < INPUTS; ++i){
                //     for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                //         //fdel_idx[i] = (n)%DEL_MAX;
                //         fdel_del[i][fdel_idx[i]] = ins[i][n];
                //         fdel_idx[i] = (fdel_idx[i] + 1)%DEL_MAX;
                //     }
                // }
                // for (int i = 0; i < INPUTS; ++i){
                //     for (int o = 0; o < OUTPUTS; ++o){
                //         for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                //             // int c_idx = (fdel_idx[i] - 1 - SYFALA_BLOCK_NSAMPLES - int(dels[i][o]) + n)%int(DEL_MAX);
                //             // float del_frac = dels[i][o] - floor(dels[i][o]);
                //             // outs[o][n] += (fdel_del[i][c_idx]*(1-del_frac) + fdel_del[i][c_idx-1]*del_frac)*pregains[i][o];
                //
                //             // int c_idx = (fdel_idx[i] - 1 - SYFALA_BLOCK_NSAMPLES - 20 + n)%int(DEL_MAX);
                //             // outs[o][n] += fdel_del[i][c_idx];//*pregains[i][o];
                //
                //             // int d_idx = o + OUTPUTS*i*2;
                //             // int g_idx = d_idx + OUTPUTS;
                //             // int c_idx = (fdel_idx[i] - 1 - SYFALA_BLOCK_NSAMPLES - int(mem_zone_f[d_idx]) + n)%int(DEL_MAX);
                //             // float del_frac = mem_zone_f[d_idx] - floor(mem_zone_f[d_idx]);
                //             // outs[o][n] += (fdel_del[i][c_idx]*(1-del_frac) + fdel_del[i][c_idx-1]*del_frac)*mem_zone_f[g_idx];
                //
                //             int d_idx = o + OUTPUTS*i*2;
                //             int g_idx = d_idx + OUTPUTS;
                //             int c_idx = (fdel_idx[i] - 1 - SYFALA_BLOCK_NSAMPLES - int(ctrl_bis[d_idx]) + n)%int(DEL_MAX);
                //             float del_frac = ctrl_bis[d_idx] - floor(ctrl_bis[d_idx]);
                //             outs[o][n] += (fdel_del[i][c_idx]*(1-del_frac) + fdel_del[i][c_idx-1]*del_frac)*ctrl_bis[g_idx];
                //         }
                //     }
                // }
                for (int o = 0; o < OUTPUTS; ++o){
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        Syfala::HLS::iowritef(outs[o][n], audio_out[o][n]);
                    }
                }
            }
        }
    }
}
