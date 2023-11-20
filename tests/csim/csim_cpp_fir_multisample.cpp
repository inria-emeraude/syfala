#include <iostream>
#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <hls_stream.h>
#include <syfala/utilities.hpp>


void syfala (
        sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
);

int main() {
    // Déclaration et initialisation des variables nécessaires
    printf("[syfala-csim] csim start\n");
    sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES] = {0};
    sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES] = {0};
       int arm_ok = true;
     bool i2s_rst = 0;
    float mem_zone_f = 0;
      int mem_zone_i = 0;
      bool bypass = false;
      bool mute = false;
      bool debug = false;

    // Appel de la fonction syfala
    for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
         printf("[syfala-csim] csim iteration: %d\n", i+1);
         syfala(
             audio_out_0,
             audio_out_1,
             arm_ok,
            &i2s_rst,
            &mem_zone_f,
            &mem_zone_i,
             bypass,
             mute,
             debug
        );
        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
             float f0 = audio_out_0[n].to_float() / SCALE_FACTOR;
             float f1 = audio_out_1[n].to_float() / SCALE_FACTOR;
             printf("[syfala-csim] Sample %d of audio_out_0: %f\n", n, f0);
             printf("[syfala-csim] Sample %d of audio_out_1: %f\n", n, f1);
        }
    }
    // Vous pouvez maintenant utiliser les données de sortie audio_out_0 et audio_out_1
    // pour effectuer d'autres opérations en C++ si nécessaire.
    return 0;
}
