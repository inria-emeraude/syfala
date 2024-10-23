#include <syfala/utilities.hpp>
#include <ap_int.h>
#include <ap_fixed.h>
#include <cmath>
#include <algorithm>
#include <cstdlib>

#define INPUTS 2
#define OUTPUTS 2

// #define CSIM

typedef ap_uint<16> u16;
typedef ap_int<16> i16;

typedef ap_fixed<32, 2> f32;

// Algorithm parameters :
static constexpr uint16_t FILTER_ORDER = 2048; // number of filter coefficients to compute and convolve, higher value gives more precision but costs more resources in loop unrolls and latency.
static constexpr float STEP_SIZE = 0.07;       // value of the learning rate for the filter coefficients update phase.
static float buffer_squared_norm = 0;

static bool initialization = true;

void syfala(
    sy_ap_int   audio_in[INPUTS],
    sy_ap_int   audio_out[OUTPUTS],
    // audio_in[0]  : input of the system
    // audio_in[1]  : output of the unknown system
    // audio_out[0] : output of the filter
    // audio_out[1] : error (audio_in[1] - audio_out[0])    
    
    int         arm_ok,
    bool*       i2s_rst,
    float*      mem_zone_f,
    int*        mem_zone_i,
    
    bool        bypass,
    bool        mute,
    bool        debug
    #ifdef __CSIM__
    , 
    // In regular use we don't need to output the coefficients as we perform the filtering in the algorithm,
    // this is just for debugging purposes in the CSIM (the coefficients are collected at during the last iteration)
    float coefficients_buffer[FILTER_ORDER],
    bool getCoeffs
    #endif
)
{
    #pragma HLS INTERFACE ap_fifo port=audio_in
    #pragma HLS INTERFACE ap_fifo port=audio_out
    #pragma HLS array_partition variable=audio_in type=complete
    #pragma HLS array_partition variable=audio_out type=complete
    #pragma HLS INTERFACE s_axilite port=arm_ok
    #pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
    #pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
    
    // coefficients buffer, allocated at startup, the partitioning splits the arrays in multiples memory blocks for better parrallel access
    static float filter_coeffs[FILTER_ORDER];
    #pragma HLS bind_storage variable=filter_coeffs type=RAM_2P impl=BRAM
    #pragma HLS array_partition variable=filter_coeffs type=cyclic factor=32
    
    static float input_buffer[FILTER_ORDER] = {0};
    #pragma HLS bind_storage variable=input_buffer type=RAM_2P impl=BRAM
    #pragma HLS array_partition variable=input_buffer type=cyclic factor=32

    *i2s_rst = !arm_ok;

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

    float estimated_output = 0.0;
    #pragma HLS bind_storage variable=estimated_output type=RAM_2P

    // recover the input samples
    float system_input_sample = Syfala::HLS::ioreadf(audio_in[0]);
    float system_output_sample = Syfala::HLS::ioreadf(audio_in[1]);
      
    // Remove the oldest sample from the squared norm
    buffer_squared_norm -= input_buffer[FILTER_ORDER - 1] * input_buffer[FILTER_ORDER - 1];
    
    // Shift the input buffer
    // Shifting all the samples is more efficient than wrapping an index
    // Storing and wrapping an index means that we have to adapt our loops every time we iterate over the buffer.*
    // Even worse when we iterate over filter_coeffs as well, we have to manage to different indices.
    // The if statement added to perform the wrapping prevent Vitis to optimise the RTL properly and the program may not even compile.
    // Shifting the buffer allow for good pipeling and making sure filter_coeffs and input_buffer are aligned when we apply and update the filter.
    buffer_shift_loop:
    for (u16 i = FILTER_ORDER - 1; i > 0; i--) {
        #pragma HLS pipeline II=1
        input_buffer[i] = input_buffer[i - 1];
    }
        
    input_buffer[0] = system_input_sample;
    
    // Time domain convolution of one sample
    filter_application_loop:
    for (u16 index = 0; index < FILTER_ORDER; index++) {
        #pragma HLS unroll factor=128
        #pragma HLS pipeline II=8

        estimated_output += filter_coeffs[index] * input_buffer[index];
    }
    
    float error = system_output_sample - estimated_output;
    
    // Add the newest sample to the squared norm
    buffer_squared_norm += input_buffer[0] * input_buffer[0];
    
    // Define a regularization value to avoid dividing by 0 if norm of input_buffer  is 0
    constexpr float regularization_parameter = 0.001f;
    
    // Update the filter coefficients with the nLMS algo
    float temp = STEP_SIZE * error / (buffer_squared_norm + regularization_parameter);
    
    filter_update_loop:
    for (u16 index = 0; index < FILTER_ORDER; index++) {
        #pragma HLS unroll factor=128
        #pragma HLS pipeline II=6

        filter_coeffs[index] += input_buffer[index] * temp;
    }
    
    // Write the estimated sample and error to the output
    Syfala::HLS::iowritef(estimated_output, audio_out[0]);
    Syfala::HLS::iowritef(error, audio_out[1]);

    #ifdef __CSIM__ 
    // output the filter coefficients to the buffer for visualisation
    if (getCoeffs) {
        printf("[syfala-HLS] exporting the filter coefficients\n");
        for (uint32_t i = 0; i < FILTER_ORDER; i++) {
            coefficients_buffer[i] = filter_coeffs[i];
        }
    }
    #endif // __CSIM__
}
