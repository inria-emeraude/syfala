#include <syfala/utilities.hpp>
#include <ap_fixed.h>

#define modesNumber 350000
#define INPUTS 0
#define OUTPUTS 2

// Define fixed-point types
typedef ap_fixed<16, 8> audio_t;       // 16-bit fixed-point, 8 integer bits
typedef ap_fixed<32, 16> coeff_t;      // 32-bit fixed-point, 16 integer bits
typedef ap_fixed<32, 16> state_t;      // 32-bit fixed-point, 16 integer bits

static bool initialization = true;

void syfala (
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
          int arm_ok,
        bool* i2s_rst,
       float* mem_zone_f,
         int* mem_zone_i,
         bool bypass,
         bool mute,
         bool debug
){
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f bundle=ram latency=20 depth=modesNumber*4
#pragma HLS INTERFACE m_axi port=mem_zone_i bundle=ram latency=20

    static state_t x[modesNumber];
    static state_t x_prev[modesNumber];
    static state_t x_next[modesNumber];
    static audio_t input[SYFALA_BLOCK_NSAMPLES];

#pragma HLS array_partition variable=x cyclic factor=2 dim=1
#pragma HLS array_partition variable=x_prev cyclic factor=2 dim=1
#pragma HLS array_partition variable=x_next cyclic factor=2 dim=1

    if (arm_ok) {
        if (initialization) {
            input[0] = 1.0; // Fixed-point initialization
            initialization = false;
        }

        int c = 0;
        audio_t output[SYFALA_BLOCK_NSAMPLES] = {0};

        coeff_t coeff_buffer[4];
        #pragma HLS array_partition variable=coeff_buffer complete

        for (int m = 0 ; m < modesNumber; m++) {
            #pragma HLS pipeline II=4
            // Load coefficients from memory
            coeff_buffer[0] = mem_zone_f[c];
            coeff_buffer[1] = mem_zone_f[c+1];
            coeff_buffer[2] = mem_zone_f[c+2];
            coeff_buffer[3] = mem_zone_f[c+3];
            
            coeff_t c1 = coeff_buffer[0];
            coeff_t c2 = coeff_buffer[1];
            coeff_t c3 = coeff_buffer[2];
            coeff_t mo = coeff_buffer[3];
            
            state_t x_next_m = x_next[m];
            state_t x_m = x[m];
            state_t x_prev_m = x_prev[m];
            
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                #pragma HLS unroll factor=2
                // Fixed-point computation
                x_next_m  = c1 * x_m + c2 * x_prev_m + c3 * input[n];
                x_prev_m = x_m;
                x_m = x_next_m;
                output[n] += x_next_m * mo;
            }
            x_next[m] = x_next_m;
            x[m] = x_m;
            x_prev[m] = x_prev_m;
            c += 4;
        }

        for (int o = 0; o < OUTPUTS; ++o) {
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                // Scale and write output
                audio_t f = output[n] * 1000000;
                Syfala::HLS::iowritef(f, audio_out[o][n]);
            }
        }
        input[0] = 0;
    }
}