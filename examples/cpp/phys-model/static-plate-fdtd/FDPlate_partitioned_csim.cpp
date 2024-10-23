#include <iostream>
#include <cmath>
#include <cstdint>
#include <string>
#include <syfala/utilities.hpp>
#include <syfala/../../../tests/csim/csim_template_utilities.hpp>
#include <assert.h>

typedef sy_real_t f32;
typedef uint32_t  u32;
typedef uint16_t  u16;
typedef uint8_t   u8;

#define INPUTS 0
#define OUTPUTS 2

static const std::string outputfname = "output_files/Plate_csim_partitioned_gcc.wav";

void syfala(
    sy_ap_int   audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],

    int         arm_ok,
    bool*       i2s_rst,
    float*      mem_zone_f,
    int*        mem_zone_i,

    bool        bypass,
    bool        mute,
    bool        debug
);

#ifdef GCC_STANDALONE
    #undef SYFALA_CSIM_NUM_ITER
    #define SYFALA_CSIM_NUM_ITER 48000 * 10

    #include "FDPlate_partitioned_hls_multi.cpp"
#endif // GCC STANDALONE
#include "grid_config.h"


int main(int argc, char **argv) {

    int arm_ok        = true;
    bool i2s_rst      = false;

    float* mem_zone_f = (float*)calloc(3*num_max_samples, sizeof(float));
    int* mem_zone_i   = nullptr;

    bool bypass       = false;
    bool mute         = false;
    bool debug        = false;
    
    const int n_samples = SYFALA_CSIM_NUM_ITER;
    AudioFile<float> output_file;
    output_file.samples.resize(1);
    output_file.samples[0].resize(n_samples);

    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES];

    // compute the mean of the signal to check if it is well centered around 0
    float sum = 0.0;

    printf("[syfala-csim] csim start\n");
    printf("[syfala-csim] Num samples to gnerate : %d\n", n_samples);
    printf("[syfala-csim] Grid dimensions : %d x %d = %d\n", grid_height, grid_width, grid_length);
    printf("[syfala-csim] Window width : %d\n", window_width);
    printf("[syfala-csim] Number of windows : %d\n", num_windows);

    for (uint32_t iter = 0; iter < n_samples; iter += SYFALA_BLOCK_NSAMPLES) {
        
        syfala(audio_out, arm_ok, &i2s_rst, mem_zone_f, mem_zone_i, bypass, mute, debug);
        
        for (uint16_t block_index = 0; block_index < SYFALA_BLOCK_NSAMPLES; block_index++) {
            
            if ((iter + block_index) % 10000 == 0) { 
                printf("[syfala-csim] iteration no : %d\n", iter);
            }
            
            float output_sample = Syfala::HLS::ioreadf(audio_out[0][block_index]);
                
            output_file.samples[0][iter + block_index] = output_sample;
            sum += output_sample;

        }
    }

    sum /= (float)n_samples;
    printf("[syfala-csim] the mean of the output signal is : %f\n", sum);

    //write to output_file
    output_file.save(outputfname, AudioFileFormat::Wave);
    printf("[syfala-csim] wrote to wav_file \n");


    free(mem_zone_f);

    return 0;
}
