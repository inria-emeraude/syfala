/*
* syfala example : stereo parametric EQ
* HLS file 
* Written by Benjamin Quiédeville (April 2024)
* 
*/

#include <syfala/utilities.hpp>
#include <cmath>
#include <algorithm>
#include "common.h"
#include <stdint.h>

#define INPUTS 2
#define OUTPUTS 2



static bool initialization = true;
static float signal_sampleL = 0.0f;
static float signal_sampleR = 0.0f;


void syfala (
    sy_ap_int   audio_in[INPUTS],
    sy_ap_int   audio_out[OUTPUTS],
    
    int         arm_ok,
    bool*       i2s_rst,
    float*      mem_zone_f,
    int*        mem_zone_i,
    
    bool        bypass,
    bool        mute,
    bool        debug,
    
    float       axi_filters[N_FILTERS * sizeof(Biquad)],
    float       master_vol
)
{
    // declare inputs and outputs to HLS
    #pragma HLS array_partition variable=audio_in type=complete
    #pragma HLS array_partition variable=audio_out type=complete
    // declare functions parameters
    #pragma HLS INTERFACE s_axilite port=arm_ok
    #pragma HLS INTERFACE s_axilite port=axi_filters
    #pragma HLS INTERFACE s_axilite port=master_vol
    // declare memory zones
    #pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
    #pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // reset
    *i2s_rst = !arm_ok;

    // float filter_params_local[PARAM_SIZE];
    // #pragma HLS array_partition variable=filter_params_local type=cyclic factor=N_FILTERS
    // #pragma HLS bind_storage variable=filter_params_local type=RAM_1P impl=BRAM
        
    Biquad filter_array[N_FILTERS];
    #pragma HLS array_partition variable=filter_array type=block factor=N_FILTERS
    #pragma HLS bind_storage variable=filter_array type=RAM_2P impl=BRAM

    // gets the filter coefficients and feedback values from DDR and puts them in BRAM for faster access
    filter_data_fetch:
    for (uint8_t filter_index = 0; filter_index < N_FILTERS; filter_index++) {
        filter_array[filter_index] = *reinterpret_cast<Biquad*>(axi_filters + filter_index*sizeof(Biquad));
    }
    
    // filter_parameters_fetch:
    // for (uint16_t index = 0; index < PARAM_SIZE; index++) {
    //     filter_params_local[index] = filter_params[index];
    // }

    if (arm_ok) {
        if (initialization) {
                        
            feedback_reset:
            for (uint8_t i = 0; i < N_FILTERS; i++) {
                #pragma HLS unroll
                biquad_reset_feedback(&filter_array[i]);
            }
            
            initialization = false;
            
        } else {
            if (bypass || mute) {
                audio_out[0] = 0;
                audio_out[1] = 0;
                
            } else {
                
                // read the inputs
                signal_sampleL = Syfala::HLS::ioreadf(audio_in[0]);
                signal_sampleR = Syfala::HLS::ioreadf(audio_in[1]);
                
                process_loop:
                for (uint8_t i = 0; i < N_FILTERS; i++) {
                    #pragma HLS pipeline II=1
                    biquad_process(&filter_array[i], &signal_sampleL, &signal_sampleR);
                }
                
                
                // clip, attenuate and write to output
                signal_sampleL = CLIP(signal_sampleL, -1.0f, 1.0f);
                signal_sampleL *= CLIP(master_vol, 0.0f, 1.0f);
                
                signal_sampleR = CLIP(signal_sampleR, -1.0f, 1.0f);
                signal_sampleR *= CLIP(master_vol, 0.0f, 1.0f);
                
                Syfala::HLS::iowritef(signal_sampleL, audio_out[0]);
                Syfala::HLS::iowritef(signal_sampleR, audio_out[1]);
            }
        }
    }
}
