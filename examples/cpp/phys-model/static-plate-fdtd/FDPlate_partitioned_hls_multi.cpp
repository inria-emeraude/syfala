// #define SYFALA_REAL_FIXED_POINT

#include <syfala/utilities.hpp>
#include <cstdint>
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

constexpr u32 inint       = ((u32)((grid_height+1.0)*inposY))  * grid_width + (u32)(grid_width*inposX);
constexpr u32 outint      = ((u32)((grid_height+1.0)*outposY)) * grid_width + (u32)(grid_width*outposX);


#include "constants.h"


void process(bool trigger, f32 *out_sample, f32 *u, f32 *u1, f32 *u2) {

    windows_loop:
    for (u16 index = 0; index < num_windows; index++) {

        u32 window_index = window_indexes[index];

        f32 u1_cache[window_length];
        f32 u2_cache[window_length];
        #pragma HLS array_reshape variable=u1_cache type=cyclic factor=4*window_width
        #pragma HLS array_reshape variable=u2_cache type=cyclic factor=4*window_width
        #pragma HLS bind_storage  variable=u1_cache type=RAM_2P impl=BRAM
        #pragma HLS bind_storage  variable=u2_cache type=RAM_2P impl=BRAM
        
        
        #pragma HLS dataflow
        fetch_outer_loop:
        for (u32 row_index = 0; row_index < window_height; row_index++) {
            #pragma HLS PIPELINE

            fetch_inner_loop:
            for (u32 col_index = 0; col_index < window_width; col_index++) {
                #pragma HLS UNROLL
                u32 lin_u_index = window_index + row_index*grid_width + col_index;
                u32 lin_window_index = row_index*window_width + col_index;
                
                u1_cache[lin_window_index] = u1[lin_u_index];
                u2_cache[lin_window_index] = u2[lin_u_index];
            }
        }


        update_outer_loop:
        for (u32 row_index = border_size; row_index < (window_height - border_size); row_index++) {
            #pragma HLS PIPELINE

            update_inner_loop:
            for (u32 col_index = border_size; col_index < (window_width - border_size); col_index++) {
                #pragma HLS UNROLL
                u32 lin_u_index =  window_index + row_index*grid_width + col_index;
                u32 lin_window_index = row_index*window_width + col_index;

                #ifdef GCC_STANDALONE
                assert((lin_window_index <= window_length && lin_u_index < grid_length) && "out of bounds access");
                #endif // GCC_STANDALONE

                f32 partial1 = B1 * (u1_cache[lin_window_index-1]
                                + u1_cache[lin_window_index+1]
                                + u1_cache[lin_window_index-window_width]
                                + u1_cache[lin_window_index+window_width]);
                f32 partial2 = B2 * (u1_cache[lin_window_index-2]
                                + u1_cache[lin_window_index+2]
                                + u1_cache[lin_window_index-2*window_width]
                                + u1_cache[lin_window_index+2*window_width]);
                f32 partial3 = B3 * (u1_cache[lin_window_index+window_width-1]
                                + u1_cache[lin_window_index+window_width+1]
                                + u1_cache[lin_window_index-window_width-1]
                                + u1_cache[lin_window_index-window_width+1]);
                f32 partial4 = C1 * (u2_cache[lin_window_index-1]
                                + u2_cache[lin_window_index+1]
                                + u2_cache[lin_window_index-window_width]
                                + u2_cache[lin_window_index+window_width]);
                f32 result = partial1 + partial2 + partial3 + partial4
                                + B4 * u1_cache[lin_window_index]
                                + C2 * u2_cache[lin_window_index];

                #ifdef GCC_STANDALONE
                assert(!isnan(result) && "result is nan\n");
                #endif // GCC_STANDALONE

                u[lin_u_index] = result;

            }
        }


        store_outer_loop:
        for (u32 row_index = 0; row_index < window_height; row_index++) {
            #pragma HLS PIPELINE

            store_inner_loop:
            for (u32 col_index = 0; col_index < window_width; col_index++) {
                #pragma HLS UNROLL
                u32 lin_u_index =  window_index + row_index*grid_width + col_index;
                u32 lin_window_index = row_index*window_width + col_index;
                
                u1[lin_u_index] = u1_cache[lin_window_index];
                u2[lin_u_index] = u2_cache[lin_window_index];
            }
        }
    }

    // Add impulse
    if (trigger) {
        u[inint] += 1.0;
    }

    // read output
    *out_sample = 0.1f * u[outint];
}


void write_outputs_multisample(f32 output[SYFALA_BLOCK_NSAMPLES], sy_ap_int syfala_outputs[2][SYFALA_BLOCK_NSAMPLES]) {
    for (u32 index = 0; index < SYFALA_BLOCK_NSAMPLES; index++) {
        Syfala::HLS::iowritef(output[index], syfala_outputs[0][index]);
        Syfala::HLS::iowritef(output[index], syfala_outputs[1][index]);
    }
}


void syfala(
    sy_ap_int   audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],

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
        for (u32 index = 0; index < SYFALA_BLOCK_NSAMPLES; index++) {
            audio_out[0][index] = 0;
            audio_out[1][index] = 0;
        }
        return;
    }

    f32 output[SYFALA_BLOCK_NSAMPLES];

    u32 offsets_0;
    u32 offsets_1;
    u32 offsets_2;

    multi_sample_loop:
    for (u32 sample_index = 0; sample_index < SYFALA_BLOCK_NSAMPLES; sample_index++) {

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
            #ifdef GCC_STANDALONE
            assert(false && "invalid permutation index value");
            #endif
            break;
        }

        process(trigger, &output[sample_index],
                mem_zone_f + offsets_0,
                mem_zone_f + offsets_1,
                mem_zone_f + offsets_2);

        write_outputs_multisample(output, audio_out);
        
        if (trigger) { trigger = false; }

        permutation_index++;
        permutation_index = permutation_index == 3 ? 0 : permutation_index;
    }
}
