#include <iostream>
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <hls_stream.h>
#include <fstream>
#include <syfala/utilities.hpp>

// Note: number of inputs/outputs are parsed by the syfala preprocessor.
static constexpr int num_inputs  = #I;
static constexpr int num_outputs = #O;

void syfala (
     sy_ap_int audio_in_#IN[SYFALA_BLOCK_NSAMPLES],
     sy_ap_int audio_out_#ON[SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
);

std::string get_file_path(const char* argv, const char* filename, int n) {
    char file[32];
    std::string path = argv;
    sprintf(file, "/%s%d.txt", filename, n);
    path += file;
    return path;
}

bool initialize_input_fstreams(const char* argv, std::ifstream* inputs) {
    char file[32];
    for (int n = 0; n < num_inputs; ++n) {
         std::string path = get_file_path(argv, "in", n);
         inputs[n] = std::ifstream(path);
         if (inputs[n].is_open()) {
             printf("[syfala-csim] input file %s successfully opened\n", path.c_str());
         } else {
             fprintf(stderr, "[syfala-csim] failed to open input file %s\n", path.c_str());
             return false;
         }
    }
    return true;
}

bool initialize_output_fstreams(const char* argv, std::ofstream* outputs) {
    char file[32];
    for (int n = 0; n < num_outputs; ++n) {
         std::string path = get_file_path(argv, "out", n);
         outputs[n] = std::ofstream(path);
         if (outputs[n].is_open()) {
             printf("[syfala-csim] output file %s successfully opened\n", path.c_str());
         } else {
             fprintf(stderr, "[syfala-csim] failed to open output file %s\n", path.c_str());
             return false;
         }
    }
    return true;
}

int main(int argc, char* argv[]) {
    // Déclaration et initialisation des variables nécessaires
    printf("[syfala-csim] csim start\n");
    sy_ap_int audio_in_#IN[SYFALA_BLOCK_NSAMPLES] = {};
    sy_ap_int audio_out_#ON[SYFALA_BLOCK_NSAMPLES] = {};
    int arm_ok = true;
    bool i2s_rst = false;
    float* mem_zone_f = nullptr;
    int* mem_zone_i = nullptr;
    bool bypass = false;
    bool mute   = false;
    bool debug  = false;

    // Declare input streams
    bool has_file_input  = false;
    bool has_file_output = false;
    std::ifstream input_streams[num_inputs] = {};
    std::ofstream output_streams[num_outputs] = {};
    float f_inputs[num_inputs][SYFALA_BLOCK_NSAMPLES] = {};
    float f_outputs[num_outputs][SYFALA_BLOCK_NSAMPLES] = {};

    if (argc == 2) {
        // If we have only one argument:
        // // The path to the 'outputs' txt file directory containing output samples.
       has_file_output = initialize_output_fstreams(argv[1], output_streams);
    } else if (argc == 3) {
        // If two arguments:
        // 1 - The path to the 'inputs' txt file directory containing input samples.
        // 2 - The path to the 'outputs' txt file directory containing output samples.
        has_file_input  = initialize_input_fstreams(argv[1], input_streams);
        has_file_output = initialize_output_fstreams(argv[2], output_streams);
    }
    // -------------------------------------------------------------------
    printf("[syfala-csim] csim start\n");
    // -------------------------------------------------------------------
    // Appel de la fonction syfala
    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
         printf("[syfala-csim] csim iteration: %d\n", i+1);
         // Don't fetch inputs for the first iteration:
         // The DSP IP will initialize itself and won't process the samples.
         if (i > 0 && has_file_input) {
             // Stream input file data into float input array.
             for (int c = 0; c < num_inputs; ++c) {
                 for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     float tmp;
                     input_streams[c] >> tmp;
                     f_inputs[c][n] = tmp;
                     printf("[syfala-csim] input value read for ch%d: %f\n", c, f_inputs[c][n]);
                 }
            }
        }
         for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
             audio_in_#IN[n] = f_inputs[#IN][n] * SCALE_FACTOR;
         }
         // -------------------------------------------------------------------
         // Syfala function call
         // -------------------------------------------------------------------
         syfala(
             audio_in_#IN,
             audio_out_#ON,
             arm_ok,
             &i2s_rst,
             mem_zone_f,
             mem_zone_i,
             bypass,
             mute,
             debug
        );
         // -------------------------------------------------------------------
         // Writing outputs
         // -------------------------------------------------------------------
        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
             f_outputs[#ON][n] = audio_out_#ON[n].to_float() / SCALE_FACTOR;
             printf("[syfala-csim] Sample %d of audio_out_#ON: %f\n", n, f_outputs[#ON][n]);
        }
        if (has_file_output) {
            for (int c = 0; c < num_outputs; ++c) {
                 for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                      output_streams[c] << f_outputs[c][n];
                      output_streams[c] << std::endl;
                 }
            }
        }
    }
    if (has_file_input) {
        for (int n = 0; n < num_inputs; ++n)
             input_streams[n].close();
    }
    if (has_file_output) {
        for (int n = 0; n < num_outputs; ++n)
             output_streams[n].close();
        if (has_file_input) {
            // also copy output files to the same directory as input files
            printf("Copying output files to input files directory\n");
            for (int n = 0; n < num_outputs; ++n) {
                std::string path_i = get_file_path(argv[1], "out", n);
                std::string path_o = get_file_path(argv[2], "out", n);
                std::ofstream dst(path_i, std::ios::binary);
                std::ifstream src(path_o, std::ios::binary);
                dst << src.rdbuf();
                src.close();
                dst.close();
            }
        }
    }
    // Vous pouvez maintenant utiliser les données de sortie audio_out_0 et audio_out_1
    // pour effectuer d'autres opérations en C++ si nécessaire.
    return 0;
}
