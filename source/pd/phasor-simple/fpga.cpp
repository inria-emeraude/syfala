#include <stdio.h>
//#include "Heavy_heavy.hpp"
//#include "Heavy_heavy.h"
//#include "HvHeavy.h"
#include "HvSignalPhasor.h"
#include "HvSignalVar.h"
#include <syfala/utilities.hpp>

static inline float ioreadf(sy_ap_int const& input) {
    return input.to_float() * SCALE_FACTOR;
}

static inline void iowritef(float f, sy_ap_int* output) {
    *output = sy_ap_int(f * SCALE_FACTOR);
}

static bool initialization = true;

void syfala(
        sy_ap_int audio_in_#N,
       sy_ap_int* audio_out_#N,
        float* mem_zone_f,
          int* mem_zone_i,
        int arm_ok,
        bool bypass,
        bool mute,
        bool debug
) {
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
    // 1. Figure out a way to fetch number of input/output
    // channels programatically
    // 2. For each syfala function call,
    // just compute a block of one sample (for now)
    static struct SignalPhasor ph;
    // temporary signal vars
    hv_bufferf_t Bf0, Bf1;

    // input and output vars
    hv_bufferf_t O0, O1;

    // declare and init the zero buffer
    hv_bufferf_t ZERO; __hv_zero_f(VOf(ZERO));

    if (initialization) {
        sPhasor_k_init(&ph, 220, SYFALA_SAMPLE_RATE);
        initialization = false;

    }
    __hv_zero_f(VOf(O0));
    __hv_zero_f(VOf(O1));

    // process all signal functions
    __hv_phasor_k_f(&ph, &Bf0);
    __hv_var_k_f(VOf(Bf1), 0.25f, 0.25f, 0.25f, 0.25f, 0.25f, 0.25f, 0.25f, 0.25f);
    __hv_mul_f(VIf(Bf0), VIf(Bf1), VOf(Bf1));
    __hv_add_f(VIf(Bf1), VIf(O1), VOf(O1));
    __hv_add_f(VIf(Bf1), VIf(O0), VOf(O0));

    iowritef(O0, audio_out_0);
    iowritef(O1, audio_out_1);
}

// original code from Mike:
//int main(int argc, const char *argv[]) {
//  double sampleRate = 44100.0;

//  HeavyContextInterface *context = hv_heavy_new(sampleRate);

//  int numIterations = 10;
//  int numOutputChannels = hv_getNumOutputChannels(context);
//  int blockSize = 256; // should be a multiple of 8

//  float **outBuffers = (float **) hv_malloc(numOutputChannels * sizeof(float *));
//  for (int i = 0; i < numOutputChannels; ++i) {
//    outBuffers[i] = (float *) hv_malloc(blockSize * sizeof(float));
//  }

//  // main processing loop
//  for (int i = 0; i < numIterations; ++i) {
//    hv_process(context, NULL, outBuffers, blockSize);
//    for (int c = 0; c < numOutputChannels; ++c) {
//      for (int s = 0; s < blockSize; ++s) {
//        printf("%.3f ", outBuffers[c][s]);
//      }
//    }
//  }
//  hv_delete(context);
//  return 0;
//}
