
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <syfala/utilities.hpp>

static bool initialization = true;

static inline float ioreadf(sy_ap_int const& input) {
    return input.to_float() * SCALE_FACTOR;
}

static inline void iowritef(float f, sy_ap_int* output) {
    *output = sy_ap_int(f * SCALE_FACTOR);
}

#define N 115

static float coeffs[N] = {
    0.000000000000000000,
    -0.000000914435621961,
    0.000000000000000000,
    0.000008609100789076,
    0.000025420364775260,
    0.000040866410043871,
    0.000037502895428171,
    0.000000000000000000,
    -0.000071324335240123,
    -0.000151486409417517,
    -0.000194283788492207,
    -0.000151152432440827,
    0.000000000000000000,
    0.000229345701782282,
    0.000449264111085510,
    0.000538814113536995,
    0.000396109274742860,
    -0.000000000000000001,
    -0.000548778773071200,
    -0.001035667046599439,
    -0.001201561318929539,
    -0.000857382488059990,
    0.000000000000000001,
    0.001128102309297186,
    0.002081515868870454,
    0.002365343045804246,
    0.001655781484631658,
    -0.000000000000000002,
    -0.002105478473898479,
    -0.003826319901434036,
    -0.004287386929845093,
    -0.002962616000144534,
    0.000000000000000003,
    0.003682624812403057,
    0.006627429775216386,
    0.007361792760859879,
    0.005048705049500945,
    -0.000000000000000005,
    -0.006203827454935462,
    -0.011122736966095153,
    -0.012327242485503931,
    -0.008449007041835120,
    0.000000000000000006,
    0.010432078043485586,
    0.018817016431108363,
    0.021045249355710068,
    0.014609752548226412,
    -0.000000000000000007,
    -0.018782565584575684,
    -0.034929251618852221,
    -0.040678277122712603,
    -0.029812439282266644,
    0.000000000000000008,
    0.045850934117128664,
    0.099785588315978307,
    0.150614285676982457,
    0.186866658955143039,
    0.200001818734882209,
    0.186866658955143095,
    0.150614285676982457,
    0.099785588315978307,
    0.045850934117128664,
    0.000000000000000008,
    -0.029812439282266647,
    -0.040678277122712603,
    -0.034929251618852228,
    -0.018782565584575691,
    -0.000000000000000007,
    0.014609752548226414,
    0.021045249355710068,
    0.018817016431108374,
    0.010432078043485588,
    0.000000000000000006,
    -0.008449007041835124,
    -0.012327242485503936,
    -0.011122736966095158,
    -0.006203827454935465,
    -0.000000000000000005,
    0.005048705049500948,
    0.007361792760859883,
    0.006627429775216390,
    0.003682624812403057,
    0.000000000000000003,
    -0.002962616000144535,
    -0.004287386929845092,
    -0.003826319901434036,
    -0.002105478473898480,
    -0.000000000000000002,
    0.001655781484631659,
    0.002365343045804246,
    0.002081515868870456,
    0.001128102309297186,
    0.000000000000000001,
    -0.000857382488059992,
    -0.001201561318929538,
    -0.001035667046599439,
    -0.000548778773071200,
    -0.000000000000000001,
    0.000396109274742860,
    0.000538814113536995,
    0.000449264111085511,
    0.000229345701782281,
    0.000000000000000000,
    -0.000151152432440827,
    -0.000194283788492206,
    -0.000151486409417517,
    -0.000071324335240124,
    0.000000000000000000,
    0.000037502895428171,
    0.000040866410043872,
    0.000025420364775260,
    0.000008609100789076,
    0.000000000000000000,
    -0.000000914435621961,
    0.000000000000000000,
};

static float samples[N] = {0.f};
static float sawtooth = 0.f;

void computemydsp(float* coeffs, float* outputs) {
    float fTemp = 0;
    samples[0] = sawtooth;
    for (int n = 0; n < N; ++n) {
    #pragma HLS performance target_ti=200
         fTemp += samples[n] * coeffs[n];
    }
    for (int j0 = N; j0 > 0; --j0) {
         samples[j0] = samples[j0-1];
    }
    sawtooth += 0.01f;
    sawtooth = fmodf(sawtooth, 1.f);
    outputs[0] = fTemp;
    outputs[1] = fTemp;
}

void syfala (
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
#if SYFALA_AUDIO_DEBUG_UART //---
         float arm_debug[2],
#endif //------------------------
           int arm_ok,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE s_axilite port=arm_ok
#if SYFALA_AUDIO_DEBUG_UART //--------------------
    #pragma HLS INTERFACE s_axilite port=arm_debug
#endif //-----------------------------------------
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
    /* Initialization and computations can start after the ARM
     * has been initialized */
    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
            // Initialize all runtime data here.
            // don't forget to toggle the variable off
            initialization = false;
        } else {
            /* Every other iterations:
             * 1. process the bypass & mute switches... */
            if (bypass || mute) {
                *audio_out_0 = 0;
                *audio_out_1 = 0;
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                float outputs[2];
                computemydsp(coeffs, outputs);
                outputs[0] = clip<sy_real_t>(outputs[0], -1.f, 1.f);
                outputs[1] = clip<sy_real_t>(outputs[1], -1.f, 1.f);
                iowritef(outputs[0], audio_out_0);
                iowritef(outputs[1], audio_out_1);
            #if SYFALA_AUDIO_DEBUG_UART // ------
                arm_debug[0] = outputs[0];
                arm_debug[1] = outputs[1];
            #endif // ---------------------------
            }
        }
    } else {
        /* Waiting for the ARM to be ready,
         * just output zeroes meanwhile... */
        *audio_out_0 = 0;
        *audio_out_1 = 0;
    }
}
