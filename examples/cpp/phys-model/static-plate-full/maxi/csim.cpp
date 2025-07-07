#include <syfala/utilities.hpp>
#include "csim_template_utilities.hpp"
#include <iostream>
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <cassert>
#include <vector>
// #include "AudioFile/AudioFile.h"
// #include "plateModalData.h"
// #include "plateModalData_small.h"
#include "plateModalData_mid.h"
#include "syfala/config_common.hpp"

#define modesNumber 12952

void syfala (
    sy_ap_int audio_out[2][SYFALA_BLOCK_NSAMPLES],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
       float* out_samples,
         bool bypass,
         bool mute,
         bool debug
);

#define OS_FAC 1
#define BASE_SR 48000

static const double base_sample_rate = OS_FAC * BASE_SR;
static double k = 1.0/base_sample_rate;

static void initialize_coeffs(float* coeffs) {
    int c = 0;
    for (int m = 0 ; m < modesNumber; ++m) {
         coeffs[c] =
             (2.f * std::exp(-dampCoeffs[m] * k)
                  * std::cos(k * std::sqrt(
                     (eigenFreqs[m] * eigenFreqs[m])
                   - (dampCoeffs[m] * dampCoeffs[m])
                  ))
             );
         coeffs[c+1] = (-std::exp(-2.f * dampCoeffs[m] * k));
         coeffs[c+2] = (k * k * modesIn[m]);
         coeffs[c+3] = modesOut[m];
         c += 4;
    }
    // n: 0, c1: 1.999913, c2: -0.999922, c3: 0.000000
    // n: 1, c1: 1.999913, c2: -0.999922, c3: 0.000000
    // n: 2, c1: 1.999913, c2: -0.999922, c3: -0.000000
    // n: 3, c1: 1.999913, c2: -0.999922, c3: -0.000000
    // n: 4, c1: 1.999912, c2: -0.999922, c3: -0.000000
    // n: 5, c1: 1.999912, c2: -0.999922, c3: -0.000000
    // n: 6, c1: 1.999912, c2: -0.999922, c3: 0.000000
    // n: 7, c1: 1.999912, c2: -0.999922, c3: 0.000000
    // n: 8, c1: 1.999912, c2: -0.999922, c3: -0.000000
    // n: 9, c1: 1.999912, c2: -0.999922, c3: -0.000000
    // for (int n = 0; n < 40; n += 4) {
    //      printf("n: %d, c1: %f, c2: %f, c3: %f\n",
    //         n, coeffs[n], coeffs[n+1], coeffs[n+2]
    //     );
    // }
    fprintf(stderr, "Modal coefficients initialized\r\n");
}

static bool i2s_rst = false;

int main(int argc, char* argv[])
{
    float* mem = new float[modesNumber * 4];
    static float out_samples[SYFALA_SAMPLE_RATE];
    static int mem_zone_i[10];
    // AudioFile<float> out;
    bool rst = true;
    initialize_coeffs(mem);
    // out.setNumChannels(2);
    // out.setSampleRate(48000);
    // out.setNumSamplesPerChannel(48000);

    static sy_ap_int
    audio_out[2][SYFALA_BLOCK_NSAMPLES];

    static float
    f_outputs[2][SYFALA_BLOCK_NSAMPLES];

    for (int n = 0; n < 2; ++n) {
        for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
             audio_out[n][m] = 0;
             f_outputs[n][m] = 0;
        }
    }
    std::vector<std::ofstream> fstreams_o;
    fstreams_o = Syfala::CSIM::get_fstreams<std::ofstream>(argv[1], "out", 2);
    // -------------------------------------------------------------------
    fprintf(stderr, "[syfala-csim] csim start\n");
    // -------------------------------------------------------------------
    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
         fprintf(stderr, "[syfala-csim] csim iteration: %d\n", i+1);
        // Don't fetch inputs for the first iteration:
        // The DSP IP will initialize itself and won't process the samples.
        // -------------------------------------------------------------------
        // Syfala function call
        // -------------------------------------------------------------------
        syfala(audio_out, true, &rst, mem, nullptr, out_samples,
               false, false, false
        );
        // -------------------------------------------------------------------
        // Writing outputs
        // -------------------------------------------------------------------
        for (int c = 0; c < 2; ++c) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                int w = i*SYFALA_BLOCK_NSAMPLES+n;
                float f = Syfala::HLS::ioreadf(audio_out[c][n]);
                f_outputs[c][n] = f;
                // out.samples[c][w] = f;
                // hls::print("[syfala-csim] Sample %d of audio_out_%d:" %f\n",
                //        w, c, f_outputs[c][n]);
            }
        }

        if (fstreams_o.size() > 0) {
            for (int c = 0; c < 2; ++c) {
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
    for (auto& fstream : fstreams_o) {
         fstream.close();
    }
    // out.save("res.wav", AudioFileFormat::Wave);
    delete[] mem;
    return 0;
}
