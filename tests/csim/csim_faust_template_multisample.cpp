#include <iostream>
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include <fstream>
#include <cassert>
#include "csim_template_utilities.hpp"

void syfala (
    sy_ap_int audio_in[SYFALA_NUM_INPUTS][SYFALA_BLOCK_NSAMPLES],
    sy_ap_int audio_out[SYFALA_NUM_OUTPUTS][SYFALA_BLOCK_NSAMPLES],
        float arm_control_f[SYFALA_NCONTROLS_F],
          int arm_control_i[SYFALA_NCONTROLS_I],
        float arm_control_p[SYFALA_NCONTROLS_P],
         int* control_block,
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug
);

int main(int argc, char* argv[]) {
    printf("[syfala-csim] csim start\n");
    sy_ap_int audio_in[SYFALA_NUM_INPUTS][SYFALA_BLOCK_NSAMPLES];
    sy_ap_int audio_out[SYFALA_NUM_OUTPUTS][SYFALA_BLOCK_NSAMPLES];
    float f_inputs[SYFALA_NUM_INPUTS][SYFALA_BLOCK_NSAMPLES] = {};
    float f_outputs[SYFALA_NUM_OUTPUTS][SYFALA_BLOCK_NSAMPLES] = {};

    for (int n = 0; n < SYFALA_NUM_INPUTS; ++n)
        for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m)
            audio_in[n][m] = 0;

    for (int n = 0; n < SYFALA_NUM_OUTPUTS; ++n)
        for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m)
            audio_out[n][m] = 0;

    float arm_control_p[SYFALA_NCONTROLS_P];
    float arm_control_f[SYFALA_NCONTROLS_F];
    int arm_control_i[SYFALA_NCONTROLS_I];
    float mem_zone_f[SYFALA_NMEM_F];
    int mem_zone_i[SYFALA_NMEM_I];

    memset(audio_in, 0, sizeof(audio_in));
    memset(audio_out, 0, sizeof(audio_out));
    memset(arm_control_p, 0, sizeof(arm_control_p));
    memset(arm_control_f, 0, sizeof(arm_control_f));
    memset(arm_control_i, 0, sizeof(arm_control_i));

    int control_block = SYFALA_CONTROL_RELEASE;
    int arm_ok = true;
    bool i2s_rst = false;
    bool bypass = false;
    bool mute   = false;
    bool debug  = false;

    // Declare input streams
    std::vector<std::ifstream> fstreams_i;
    std::vector<std::ofstream> fstreams_o;

    // argv[0] == 'csim.exe' when called from Vitis_HLS
    if (argc == 2) {
        // If we have only one argument:
        // // The path to the 'outputs' txt file directory containing output samples.
        fstreams_o = Syfala::CSIM::get_fstreams<std::ofstream>(
            argv[1], "out", SYFALA_NUM_OUTPUTS
            );
    } else if (argc == 3) {
        // If two arguments:
        // 1 - The path to the 'inputs' txt file directory containing input samples.
        // 2 - The path to the 'outputs' txt file directory containing output samples.
        fstreams_i = Syfala::CSIM::get_fstreams<std::ifstream>(
            argv[2], "in", SYFALA_NUM_INPUTS
            );
    }
    // -------------------------------------------------------------------
    printf("[syfala-csim] csim start\n");
    // -------------------------------------------------------------------
    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
        printf("[syfala-csim] csim iteration: %d\n", i+1);
        // Don't fetch inputs for the first iteration:
        // The DSP IP will initialize itself and won't process the samples.
        if (i > 0 && fstreams_i.size() > 0) {
            // Stream input file data into float input array.
            for (int c = 0; c < SYFALA_NUM_INPUTS; ++c) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     float tmp;
                     fstreams_i[c] >> tmp;
                     f_inputs[c][n] = tmp;
                }
            }
        }
        for (int c = 0; c < SYFALA_NUM_INPUTS; ++c) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                 Syfala::HLS::iowritef(f_inputs[c][n], audio_in[c][n]);
                 printf("input_%d value: %f\n", c, f_inputs[c][n]);
            }
        }

        // -------------------------------------------------------------------
        // Syfala function call
        // -------------------------------------------------------------------
        syfala(
            audio_in, audio_out,
            arm_control_f, arm_control_i, arm_control_p,
            &control_block, arm_ok, &i2s_rst,
            mem_zone_f, mem_zone_i,
            bypass, mute,
            debug
            );
        // -------------------------------------------------------------------
        // Writing outputs
        // -------------------------------------------------------------------
        for (int c = 0; c < SYFALA_NUM_OUTPUTS; ++c) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                 f_outputs[c][n] = Syfala::HLS::ioreadf(audio_out[c][n]);
                 printf("[syfala-csim] Value of audio_out_%d: %f\n", c, f_outputs[c][n]);
            }
        }
        if (fstreams_o.size() > 0) {
            for (int c = 0; c < SYFALA_NUM_OUTPUTS; ++c) {
                fstreams_o[c] << f_outputs[c];
                fstreams_o[c] << std::endl;
            }
        }
    }
    // -------------------------------------------------------------------
    // Close I/O files
    // -------------------------------------------------------------------
    for (auto& fstream : fstreams_i) {
        fstream.close();
    }
    for (auto& fstream : fstreams_o) {
        fstream.close();
    }
    return 0;
}
