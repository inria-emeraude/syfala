#include <iostream>
#include <cmath>
#include <stdint.h>
#include <string>
#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include "./template_utilities.hpp"
#include <fstream>
#include <cassert>

#define INPUTS 2
#define OUTPUTS 2



void syfala(
    sy_ap_int   audio_in[INPUTS],
    sy_ap_int   audio_out[OUTPUTS],
    
    int         arm_ok,
    bool*       i2s_rst,
    float*      mem_zone_f,
    int*        mem_zone_i,
    
    bool        bypass,
    bool        mute,
    bool        debug,
    float       *coefficients_buffer,
    bool        getCoeffs
);

const std::string NLMS_path = "/home/syfala/syfala/examples/cpp/NLMS";

#ifdef GCC_STANDALONE
    #undef SYFALA_CSIM_NUM_ITER
    #define SYFALA_CSIM_NUM_ITER 48000 * 5

    #include "NLMS_hls.cpp"

#else 
static const int FILTER_ORDER = 2048;
#endif // GCC STANDALONE

int main(int argc, char **argv) {
    
    int arm_ok        = true;
    bool i2s_rst      = false;

    float* mem_zone_f = nullptr;
    int*  mem_zone_i  = nullptr;
    bool bypass       = false;
    bool mute         = false;
    bool debug        = false;
    bool getCoeffs    = false;

    std::ifstream input_signal_stream(NLMS_path + "/csim_signals/input_noise.txt");
    std::ifstream system_output_signal_stream(NLMS_path + "/csim_signals/system_output_noise.txt");
    std::ofstream estimation_stream(NLMS_path + "/csim_signals/estimated_output_HLS.txt");
    std::ofstream error_stream(NLMS_path + "/csim_signals/error_HLS.txt");
    std::ofstream filter_coeffs_stream(NLMS_path + "/csim_signals/filter_coeffs_HLS.txt");

    assert(input_signal_stream.is_open());
    assert(system_output_signal_stream.is_open());
    assert(estimation_stream.is_open());
    assert(error_stream.is_open());
    assert(filter_coeffs_stream.is_open());
    
    
    float coefficients_buffer[FILTER_ORDER] = {0};

    sy_ap_int audio_in[INPUTS] = {0};
    sy_ap_int audio_out[OUTPUTS] = {0};

    fprintf(stderr, "[syfala-csim] csim start\n");
    fprintf(stderr, "[syfala-csim] num of iterations : %d\n", SYFALA_CSIM_NUM_ITER);
    fprintf(stderr, "[syfala-csim] filter order : %d\n", FILTER_ORDER);


    for (uint32_t iter = 0; iter < SYFALA_CSIM_NUM_ITER; iter++){
                        
        if (iter % 10000 == 0) { fprintf(stderr, "[syfala-csim] iteration no : %d\n", iter); }
            
        float input_sample;
        float system_output_sample;

        input_signal_stream >> input_sample;            
        system_output_signal_stream >> system_output_sample;
        
        Syfala::HLS::iowritef(input_sample, audio_in[0]);
        Syfala::HLS::iowritef(system_output_sample, audio_in[1]);
        
        if (iter == SYFALA_CSIM_NUM_ITER -1) { getCoeffs = true; }
        
        syfala(audio_in, audio_out,
               arm_ok, &i2s_rst,
               mem_zone_f, mem_zone_i,
               bypass, mute, debug,
               coefficients_buffer, getCoeffs 
            );

        float estimated_sample = Syfala::HLS::ioreadf(audio_out[0]);
        float error_sample = Syfala::HLS::ioreadf(audio_out[1]);
        
        estimation_stream << estimated_sample << '\n';
        error_stream << error_sample << '\n';
    }

    printf("[syfala-csim] Storing filter coefficients\n");
    for (uint32_t i = 0; i < FILTER_ORDER; i++) {
        filter_coeffs_stream << coefficients_buffer[i] << '\n';    
    }

    
    fprintf(stderr, "[syfala-csim] closing the streams\n");

    input_signal_stream.close();
    system_output_signal_stream.close();
    estimation_stream.close();
    error_stream.close();
    filter_coeffs_stream.close();    
    
    return 0;
}
