#include <hls_stream.h>
#include <syfala/utilities.hpp>
#include "coeffs_5000.hpp"

#define INPUTS 0
#define OUTPUTS 2
#define NCOEFFS 5000

static float sawtooth = 0.0f;

static bool initialization = true;

static inline float ioreadf(sy_ap_int const& input) {
    return input.to_float() * SCALE_FACTOR;
}

static inline void iowritef(float f, sy_ap_int* output) {
    *output = sy_ap_int(f * SCALE_FACTOR);
}



void read_input_samples(hls::stream<float>& input_samples)
{
  static float sawtooth = 0;

	mem_rd:
  for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; n++) {
         input_samples << sawtooth;
         sawtooth += 0.01f;
         sawtooth = sawtooth > 1 ? sawtooth -1 : sawtooth;  }

}

void compute_buffer(hls::stream<float>& input_samples,float* samplesUpdated) {
  static float samples[NCOEFFS+SYFALA_BLOCK_NSAMPLES];// removed init = {0.f};
 loop_shift: for (int j = NCOEFFS+SYFALA_BLOCK_NSAMPLES-1; j >= SYFALA_BLOCK_NSAMPLES; --j) {
    samples[j] = samples[j-SYFALA_BLOCK_NSAMPLES];
    samplesUpdated[j]= samples[j];
    
  }
 loop_input: for (int j = SYFALA_BLOCK_NSAMPLES-1; j >= 0; j--) {
    samples[j]=input_samples.read();
    samplesUpdated[j]= samples[j];
  }
}

void compute_fir(hls::stream<float>& output_samples,
		 float* coeffs,float* samplesUpdated,
		 float* fTemp2) {
  float fTemp[SYFALA_BLOCK_NSAMPLES]={0};
 loop_coeff: for (int i = 0; i < NCOEFFS; i++) {
#pragma HLS PIPELINE rewind
  loop_sample:for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; n++) {
#pragma HLS unroll
      fTemp[n] += samplesUpdated[i+SYFALA_BLOCK_NSAMPLES-1-n] * coeffs[i];
      fTemp2[n] = fTemp[n];
    }
  }
}

void write_output_samples(float *fTemp2,
			  hls::stream<float>& output_samples,
			  sy_ap_int* audio_out_0,
			  sy_ap_int* audio_out_1)
{
 loop_output:for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; n++) {
    float out = 0;
    out = fTemp2[n];
    iowritef(out, &audio_out_0[n]);
    iowritef(out, &audio_out_1[n]);
  }
}

void computemydsp(float* coeffs,
		  sy_ap_int* audio_out_0,
          sy_ap_int* audio_out_1 ) {

static float samplesUpdated[NCOEFFS+SYFALA_BLOCK_NSAMPLES]= {0.f};
// #pragma HLS array_partition type=cyclic factor=8 dim=1 samplesUpdated
float fTemp2[SYFALA_BLOCK_NSAMPLES];

static hls::stream<float> input_samples("input_stream");
static hls::stream<float> output_samples("output_stream");
#pragma HLS STREAM variable = input_samples depth = SYFALA_BLOCK_NSAMPLES
#pragma HLS STREAM variable = output_samples depth = SYFALA_BLOCK_NSAMPLES
#pragma HLS DATAFLOW
read_input_samples(input_samples);
compute_buffer(input_samples,samplesUpdated);
 compute_fir(output_samples,coeffs,samplesUpdated,fTemp2);
 write_output_samples(fTemp2,output_samples,audio_out_0,audio_out_1);
}

#define FAUST_INPUTS 0
#define FAUST_OUTPUTS 2

void syfala (
		sy_ap_int* audio_out_0,
		sy_ap_int* audio_out_1,
           int arm_ok,
            bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
	     ) {
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
#pragma HLS INTERFACE ap_fifo port=audio_out_0
#pragma HLS INTERFACE ap_fifo port=audio_out_1


  static hls::stream<float> input_samples("input_stream");
  static hls::stream<float> output_samples("output_stream");
#pragma HLS STREAM variable = input_samples depth = SYFALA_BLOCK_NSAMPLES
#pragma HLS STREAM variable = output_samples depth = SYFALA_BLOCK_NSAMPLES
#pragma HLS DATAFLOW
  
static float samplesUpdated[NCOEFFS+SYFALA_BLOCK_NSAMPLES]= {0.f};
// #pragma HLS array_partition type=cyclic factor=8 dim=1 samplesUpdated
float fTemp2[SYFALA_BLOCK_NSAMPLES];

 read_input_samples(input_samples);
 compute_buffer(input_samples,samplesUpdated);
 compute_fir(output_samples,coeffs,samplesUpdated,fTemp2);
 write_output_samples(fTemp2,output_samples,audio_out_0,audio_out_1);
 
}

