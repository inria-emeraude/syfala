#include <iostream>
#include <cmath>
#include <stdint.h>
#include <string>
#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include "templates_utilitites.hpp"
#include <fstream>
#include <cassert>

#include "common.h"

void syfala (
    sy_ap_int   audio_in[INPUTS],
    sy_ap_int   audio_out[OUTPUTS],

    int         arm_ok,
    bool*       i2s_rst,
    float*      mem_zone_f,
    int*        mem_zone_i,

    bool        bypass,
    bool        mute,
    bool        debug,

    float       axi_filters[N_FILTERS * sizeof(Biquad)],
    float       master_vol
);

int main(int argc, char **argv) {


    sy_ap_int audio_in[2] = {0, 0};
    sy_ap_int audio_out[2] = {0, 0};
    int arm_ok = true;
    bool i2s_rst = false;


    float mem_zone_f[N_FILTERS * BIQUAD_SIZE] = { 0 };

    int*  mem_zone_i  = nullptr;
    bool bypass = false;
    bool mute   = false;
    bool debug  = false;

    float filters_params[15] = {100.0f, 250.0f, 500.0f, 2000.0f, 8000.0f, 
                                2.0f,  2.0f,   2.0f,   2.0f,    2.0f, 
                                0.0f,  6.0f,   6.0f,   6.0f,    0.0f};
    
    float master_vol = 1.0f;
    float f_inputs[2]  = {0, 0};
    float f_outputs[2] = {0, 0};

    std::vector<std::ifstream> fstreams_i;
    std::vector<std::ofstream> fstreams_o;


    printf("[syfala-csim] csim start\n");

    // argv[0] == 'csim.exe' when called from Vitis_HLS
    if (argc >= 2) {
        // If we have only one argument:
        // // The path to the 'outputs' txt file directory containing output samples.
        fstreams_o = Syfala::CSIM::get_fstreams<std::ofstream>(
            argv[1], "csim_param_eq_output", SYFALA_NUM_OUTPUTS
        );
    }
    if (argc >= 3) {
        // If two arguments:
        // 1 - The path to the 'inputs' txt file directory containing input samples.
        // 2 - The path to the 'outputs' txt file directory containing output samples.
        fstreams_i = Syfala::CSIM::get_fstreams<std::ifstream>(
            argv[2], "csim_noise", SYFALA_NUM_INPUTS
        );
    }


    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
        // printf("[syfala-csim] csim iteration: %d\n", i+1);
        // Don't fetch inputs for the first iteration:
        // The DSP IP will initialize itself and won't process the samples.
        if (i > 0 && fstreams_i.size() > 0) {
            // Stream input file data into float input array.
            for (int n = 0; n < SYFALA_NUM_INPUTS; ++n) {
                float tmp;
                fstreams_i[n] >> tmp;
                f_inputs[n] = tmp;
            }
        }
        for (int n = 0; n < SYFALA_NUM_INPUTS; ++n) {
            Syfala::HLS::iowritef(f_inputs[n], audio_in[n]);
            // printf("input_%d value: %f\n", n, f_inputs[n]);
        }
        // -------------------------------------------------------------------
        // Syfala function call
        // -------------------------------------------------------------------
        syfala (
        #if (SYFALA_NUM_INPUTS)
            audio_in,
        #endif
            audio_out,
            arm_ok, &i2s_rst,
            mem_zone_f, mem_zone_i,
            bypass, mute,
            debug,
            filters_params,
            master_vol
        );
        // -------------------------------------------------------------------
        // Writing outputs
        // -------------------------------------------------------------------
        for (int n = 0; n < SYFALA_NUM_OUTPUTS; ++n) {
            f_outputs[n] = Syfala::HLS::ioreadf(audio_out[n]);
            // printf("[syfala-csim] Sample of audio_out_%d: %f\n", n, f_outputs[n]);
        }
        if (fstreams_o.size() > 0) {
            for (int n = 0; n < SYFALA_NUM_OUTPUTS; ++n) {
                fstreams_o[n] << f_outputs[n];
                fstreams_o[n] << std::endl;
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