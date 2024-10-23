#include <syfala/utilities.hpp>
#include <cmath>
#include <algorithm>
#include <cstdlib>
#include <ap_int.h>

typedef float f32;
typedef uint32_t u32;
typedef uint16_t u16;
typedef uint8_t  u8;

#define INPUTS 0
#define OUTPUTS 2

static bool initialization = true;
static bool trigger        = true;

#include "grid_config.h"

constexpr f32 outposX     = 0.72f;
constexpr f32 outposY     = 0.41f;
constexpr f32 inposX      = 0.41f;
constexpr f32 inposY      = 0.55f;

constexpr u32 inint       = ((int)((grid_height+1.0)*inposY))  * grid_width + (int)(grid_width*inposX);
constexpr u32 outint      = ((int)((grid_height+1.0)*outposY)) * grid_width + (int)(grid_width*outposX);

#include "constants.h"

// firt oder highpass filter to remove any offset in the resulting signal
constexpr f32 highpass_coeff_b0 = 0.00019634955f;
constexpr f32 highpass_coeff_a1 = highpass_coeff_b0 - 1.0f;
f32 highpass_state = 0.0f;

void process(bool trigger, f32 *output, f32 *u, f32 *u1, f32 *u2) {

    f32 u1_cache[grid_length];
    f32 u2_cache[grid_length];
    #pragma HLS array_partition variable=u1_cache type=block factor=grid_width*2
    #pragma HLS bind_storage variable=u1_cache type=RAM_2P impl=BRAM
    #pragma HLS array_partition variable=u2_cache type=block factor=grid_width*2
    #pragma HLS bind_storage variable=u2_cache type=RAM_2P impl=BRAM

    fetch_outer_loop:
    for (u32 row_index = 0; row_index < grid_height; row_index++) {
        #pragma HLS PIPELINE

        fetch_inner_loop:
        for (u32 col_index = 0; col_index < grid_height; col_index++) {
            #pragma HLS UNROLL
            u32 lin_index = row_index*grid_width + col_index;
    
            u1_cache[lin_index] = u1[lin_index];
            u2_cache[lin_index] = u2[lin_index];        
        }
    }

    udpate_outer_loop: 
    for (u32 row_index = border_size; row_index < (grid_height-border_size); row_index++) {
        // #pragma HLS PIPELINE II=2

        update_inner_loop: 
        for (u32 col_index = border_size; col_index < (grid_width-border_size); col_index++) {
            #pragma HLS UNROLL factor = 16
            u32 linear_index = row_index*grid_width+col_index;
            
            f32 partial1 = B1 * (u1_cache[linear_index-1]
                            + u1_cache[linear_index+1]
                            + u1_cache[linear_index-grid_width]
                            + u1_cache[linear_index+grid_width]);
            f32 partial2 = B2 * (u1_cache[linear_index-2]
                            + u1_cache[linear_index+2]
                            + u1_cache[linear_index-2*grid_width]
                            + u1_cache[linear_index+2*grid_width]);
            f32 partial3 = B3 * (u1_cache[linear_index+grid_width-1]
                            + u1_cache[linear_index+grid_width+1]
                            + u1_cache[linear_index-grid_width-1]
                            + u1_cache[linear_index-grid_width+1]);
            f32 partial4 = C1 * (u2_cache[linear_index-1]
                            + u2_cache[linear_index+1]
                            + u2_cache[linear_index-grid_width]
                            + u2_cache[linear_index+grid_width]);
            f32 result = partial1 + partial2 + partial3 + partial4
                            + B4 * u1_cache[linear_index]
                            + C2 * u2_cache[linear_index];

            #ifdef GCC_STANDALONE
            assert(abs(result < 1.0) && "[HLS] illegal result in scanning");
            #endif
    
            u[linear_index] = result;
        }
    }

    store_outer_loop:
    for (u32 row_index = 0; row_index < grid_height; row_index++) {
        #pragma HLS PIPELINE

        store_inner_loop:
        for (u32 col_index = 0; col_index < grid_width; col_index++) {
            #pragma HLS UNROLL
            u32 lin_index = row_index*grid_width + col_index;
            
            u1[lin_index] = u1_cache[lin_index];
            u2[lin_index] = u2_cache[lin_index];
        }
    }

    // Add impulse
    if (trigger) {
        u[inint] += 1.0;
    }
    
    // highpass filtering
    f32 temp = u[outint] * highpass_coeff_b0 - highpass_state * highpass_coeff_a1;
    f32 output_sample = u[outint] - temp;
    highpass_state = temp;

    *output = output_sample;
}


void write_outputs(f32 output, sy_ap_int syfala_outputs[2]) {
    Syfala::HLS::iowritef(output, syfala_outputs[0]);
    Syfala::HLS::iowritef(output, syfala_outputs[1]);
}


void syfala(
    sy_ap_int   audio_out[OUTPUTS],
    
    int         arm_ok,
    bool*       i2s_rst,
    float*      mem_zone_f,
    int*        mem_zone_i,
    
    bool        bypass,
    bool        mute,
    bool        debug
) 
{
    #pragma HLS array_partition variable=audio_out type=complete
    #pragma HLS INTERFACE ap_fifo port=audio_out
    #pragma HLS INTERFACE s_axilite port=arm_ok
    #pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
    #pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
    
    static u8 permutation_index = 0;

    *i2s_rst = !arm_ok;
        
    (void)debug;
    
    if (!arm_ok) { return; }
    if (initialization) {
        initialization = false;
        return;
    }
    
    if (bypass || mute) {
        audio_out[0] = 0;
        audio_out[1] = 0;
        return;
    }            

    f32 output = 0.0f;
                
    u32 offsets_0;
    u32 offsets_1;
    u32 offsets_2;

    switch (permutation_index) {
    case 0: 
        offsets_0 = 0;
        offsets_1 = num_max_samples;
        offsets_2 = num_max_samples * 2;
        break;
    
    case 1:
        offsets_0 = num_max_samples * 2;
        offsets_1 = 0;
        offsets_2 = num_max_samples;
        break;
    
    case 2:
        offsets_0 = num_max_samples;
        offsets_1 = num_max_samples * 2;
        offsets_2 = 0;
        break;
    
    default:
        break;
    }

    process(trigger, &output, 
            mem_zone_f + offsets_0, 
            mem_zone_f + offsets_1, 
            mem_zone_f + offsets_2);

    #ifdef GCC_STANDALONE
    assert(fabs(output) < 1.0 && "[HLS] output overflow");
    #endif // GCC_STANDALONE

    write_outputs(output, audio_out);

    if (trigger) { trigger = false; }

    permutation_index++;
    if (permutation_index == 3) { permutation_index = 0; }
}
