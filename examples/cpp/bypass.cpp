#include <syfala/utilities.hpp>

static bool initialization = true;

static inline float ioreadf(sy_ap_int const& input) {
    return input.to_float() * SCALE_FACTOR;
}

static inline void iowritef(float f, sy_ap_int* output) {
    *output = sy_ap_int(f * SCALE_FACTOR);
}

void syfala (
        sy_ap_int  audio_in_0,
        sy_ap_int  audio_in_1,
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
         float arm_control_f[2],
           int arm_control_i[2],
         float arm_control_p[2],
           int arm_ok,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE s_axilite port=arm_control_f
#pragma HLS INTERFACE s_axilite port=arm_control_i
#pragma HLS INTERFACE s_axilite port=arm_control_p
#pragma HLS INTERFACE s_axilite port=arm_ok
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
             * either process the bypass & mute switches... */
            if (bypass) {
//                *audio_out_0 = audio_in_0;
//                *audio_out_1 = audio_in_0;
            } else if (mute) {
                *audio_out_0 = 0;
                *audio_out_1 = 0;
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                 iowritef(ioreadf(audio_in_0), audio_out_0);
                 iowritef(ioreadf(audio_in_1), audio_out_1);
            }
        }
    } else {
        /* Waiting for the ARM to be ready,
         * just output zeroes meanwhile... */
        *audio_out_0 = 0;
        *audio_out_1 = 0;
    }
}
