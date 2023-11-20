#include <iostream>
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include <fstream>
#include <cassert>

void syfala (
     sy_ap_int audio_in_0,
    sy_ap_int audio_in_1,
    sy_ap_int* audio_out_0,
    sy_ap_int* audio_out_1,
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
    sy_ap_int audio_in_0  = sy_ap_int(0);
    sy_ap_int audio_in_1  = sy_ap_int(0);
    sy_ap_int audio_out_0 = sy_ap_int(0);
    sy_ap_int audio_out_1 = sy_ap_int(0);
    int arm_ok = true;
    bool i2s_rst = false;
    float* mem_zone_f = nullptr;
    int*  mem_zone_i  = nullptr;
    bool bypass = false;
    bool mute   = false;
    bool debug  = false;

    float f_inputs[2]  = {0, 0};
    float f_outputs[2] = {0, 0};

    // -------------------------------------------------------------------
    printf("[syfala-csim] csim start\n");
    // -------------------------------------------------------------------
    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
         printf("[syfala-csim] csim iteration: %d\n", i+1);
         if (i > 0) {
            // first iteration = initialization, inputs will be ignored
             // wait for second iteration.
            f_inputs[0] = (float)rand()/RAND_MAX;
            f_inputs[1] = (float)rand()/RAND_MAX;
         }
         Syfala::HLS::iowritef(f_inputs[0], audio_in_0);
         Syfala::HLS::iowritef(f_inputs[1], audio_in_1);
        // -------------------------------------------------------------------
        // Syfala function call
        // -------------------------------------------------------------------
        syfala(audio_in_0, audio_in_1,
              &audio_out_0, &audio_out_1,
              arm_ok, &i2s_rst,
              mem_zone_f, mem_zone_i,
              bypass, mute, debug
        );
        // -------------------------------------------------------------------
        // Writing outputs
        // -------------------------------------------------------------------
        f_outputs[0] = Syfala::HLS::ioreadf(audio_out_0);
        f_outputs[1] = Syfala::HLS::ioreadf(audio_out_1);
        printf("[ch0] input: %f, result: %f\n", f_inputs[0], f_outputs[0]);
        printf("[ch1] input: %f, result: %f\n", f_inputs[1], f_outputs[1]);
    }
    return 0;
}
