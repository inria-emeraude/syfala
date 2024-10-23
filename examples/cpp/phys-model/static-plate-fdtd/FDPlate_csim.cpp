#include <iostream>
#include <cmath>
#include <cstdint>
#include <string>
#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include <syfala/../../tests/csim/csim_template_utilities.hpp>
// #include </home/syfala/syfala/tests/csim/csim_template_utilities.hpp>
#include <fstream>
#include <cassert>

typedef sy_real_t f32;
typedef uint32_t  u32;
typedef uint16_t  u16;
typedef uint8_t   u8;

#define INPUTS 0
#define OUTPUTS 2

static const std::string outputfname = "output_files/Plate_csim_unpartitioned_gcc.wav";

void syfala(
    sy_ap_int   audio_out[OUTPUTS],

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

    #include "FDPlate_unpartitioned_hls.cpp"
#endif // GCC STANDALONE
#include "grid_config.h"


int main(int argc, char **argv) {

    int arm_ok        = true;
    bool i2s_rst      = false;

    float* mem_zone_f = (float*)calloc(num_max_samples*3, sizeof(float));
    int* mem_zone_i   = nullptr;

    bool bypass       = false;
    bool mute         = false;
    bool debug        = false;

    std::ofstream output_stream(
        "/home/syfala/syfala/examples/cpp/phys-model/static-plate-fdtd/csim_signals/unpartitioned_output.txt"
    );
    assert(output_stream.is_open());
    
    AudioFile<float> output_file;

    const int n_samples = SYFALA_CSIM_NUM_ITER;
    double *wav_signal = (double*)malloc(n_samples * sizeof(double));

    sy_ap_int audio_out[OUTPUTS];

    // compute the mean of the signal to check if it is well centered around 0
    double sum = 0.0;
    
    printf("[syfala-csim] csim start\n");
    printf("[syfala-csim] Num samples to gnerate : %d\n", n_samples);
    printf("[syfala-csim] Grid dimensions : %d x %d = %d\n", grid_height, grid_width, grid_length);

    for (uint32_t iter = 0; iter < n_samples; iter++) {
        
        if (iter % 10000 == 0) { printf("[syfala-csim] iteration no : %d\n", iter); }

        syfala(audio_out, arm_ok, &i2s_rst, mem_zone_f, mem_zone_i, bypass, mute, debug);
        float output_sample = Syfala::HLS::ioreadf(audio_out[0]);
                
        wav_signal[iter] = output_sample;
        sum += output_sample;

        output_stream << output_sample << '\n';
    }
        
    printf("\n[syfala-csim] closing the streams\n");
    output_stream.close();

    sum /= (double)n_samples;
    printf("[syfala-csim] the mean of the output signal is : %f\n", sum);

    writeWav(wav_signal, wav_signal, outputfname.data(), n_samples, SYFALA_SAMPLE_RATE);
    printf("[syfala-csim] wrote to wav_file \n");

    free(wav_signal);
    free(mem_zone_f);

    return 0;
}
