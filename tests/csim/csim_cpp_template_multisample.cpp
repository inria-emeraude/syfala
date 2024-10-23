#include <iostream>
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <hls_stream.h>
#include <fstream>
#include <syfala/utilities.hpp>
#include "csim_template_utilities.hpp"

void syfala (
#if (SYFALA_NUM_INPUTS) // ---------------
    sy_ap_int audio_in[SYFALA_NUM_INPUTS][SYFALA_BLOCK_NSAMPLES],
#endif // --------------------------------
     sy_ap_int audio_out[SYFALA_NUM_OUTPUTS][SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
);

int main(int argc, char* argv[]) {
    // Déclaration et initialisation des variables nécessaires
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

    int arm_ok = true;
    bool i2s_rst = false;
    float* mem_zone_f = nullptr;
    int* mem_zone_i = nullptr;
    bool bypass = false;
    bool mute   = false;
    bool debug  = false;

    std::vector<std::ifstream> fstreams_i;
    std::vector<std::ofstream> fstreams_o;

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
    // Appel de la fonction syfala
    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
         printf("[syfala-csim] csim iteration: %d\n", i+1);
         // Don't fetch inputs for the first iteration:
         // The DSP IP will initialize itself and won't process the samples.
         if (i > 0 && fstreams_i.size() > 0) {
             // Stream input file data into float input array.
             for (int c = 0; c < SYFALA_NUM_INPUTS; ++c) {
                 for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     float tmp;
                     fstreams_i[n] >> tmp;
                     f_inputs[c][n] = tmp;
                     printf("[syfala-csim] input value read for ch%d: %f\n", c, f_inputs[c][n]);
                 }
            }
        }
         for (int c = 0; c < SYFALA_NUM_INPUTS; ++c) {
            for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
                 Syfala::HLS::iowritef(f_inputs[c][m], audio_in[c][m]);
            }
         }
         // -------------------------------------------------------------------
         // Syfala function call
         // -------------------------------------------------------------------
         syfala(
        #if (SYFALA_NUM_INPUTS)
             audio_in,
        #endif
             audio_out,
             arm_ok, &i2s_rst,
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
                 printf("[syfala-csim] Sample %d of audio_out_%d: %f\n",
                        n, c, f_outputs[c][n]);
            }
        }
         if (fstreams_o.size() > 0) {
            for (int c = 0; c < SYFALA_NUM_OUTPUTS; ++c) {
                 for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     fstreams_o[c] << f_outputs[c][n];
                     fstreams_o[c] << std::endl;
                 }
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
