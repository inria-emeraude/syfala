#include <syfala/utilities.hpp>
#include <cmath>

/**
 * /!\ These macros are always required when writing a
 * Syfala C++ program: it will inform the toolchain to use:
 * - audio_in_# (here audio_in_0 and audio_in_1)
 * - audio_out_# (here audio_out_0 and audio_out_1)
 * as audio input and output ports.
 */
#define INPUTS 4
#define OUTPUTS 8

static int nbands = 2; // bands
static int decoder_type = 2; // decoder type

static float xover_freq = 400; // crossover frequency in Hz (typically 200-800)
static float lfhf_ratio = 1; // lfhf_balance (typically -+3db but here linear)
static float output_gain = 1; // in dB in original code

static int decoder_order = 1;
static int co[4] = {0,1,1,1}; // ambisonic order of each input component
static int input_full_set = 0; // use full or reduced input set
static int delay_comp = 1; // delay compensation
static int level_comp = 1; // level compensation
static int nfc_output = 0; // nfc on input or output
static int nfc_input  = 1; // nfc on input or output
static int output_gain_muting = 1; // enable output gain and muting controls
static int ns = OUTPUTS; // number of speakers
static int rs[OUTPUTS] = {1,1,1,1,1,1,1,1}; // radius for each speaker in meters
static float gammas[2][2] = {{1.0f,1.0f},{2.0f,1.154700538f}}; // per order gains, 0 for LF, 1 for HF. Used to implement shelf filters, or to modify velocity matrix for max_rE decoding, and so forth.  See Appendix A of BLaH6.
static float s[8][4] = {{0.1767766953f,0.2165063509f,0.2165063509f,0.2165063509f},
    {0.1767766953f,0.2165063509f,-0.2165063509f,0.2165063509f},
    {0.1767766953f,-0.2165063509f,-0.2165063509f,0.2165063509f},
    {0.1767766953f,-0.2165063509f,0.2165063509f,0.2165063509f},
    {0.1767766953f,0.2165063509f,0.2165063509f,-0.2165063509f},
    {0.1767766953f,0.2165063509f,-0.2165063509f,-0.2165063509f},
    {0.1767766953f,-0.2165063509f,-0.2165063509f,-0.2165063509f},
    {0.1767766953f,-0.2165063509f,0.2165063509f,-0.2165063509f}};
static float temp_celcius = 20.0f;

float r_bar;
float c;
float nfc_omega;
float nfc_b1;
float nfc_g1;
float nfc_d1;
float nfc_g;
float nfc_del[INPUTS-1];

float xover_k;
float xover_k2;
float xover_d;
float xover_b_hf[3];
float xover_b_lf[3];
float xover_a[2];
float xover_iir_del[INPUTS];
float xover_fir0_del[INPUTS];
float xover_fir1_del[INPUTS][2];
float xover_fir2_del[INPUTS][2];

static bool initialization = true;

void syfala (
        sy_ap_int audio_in_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_in_1[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_in_2[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_in_3[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_2[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_3[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_4[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_5[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_6[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_7[SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE ap_fifo port=audio_in_0
#pragma HLS INTERFACE ap_fifo port=audio_in_1
#pragma HLS INTERFACE ap_fifo port=audio_in_2
#pragma HLS INTERFACE ap_fifo port=audio_in_3
#pragma HLS INTERFACE ap_fifo port=audio_out_0
#pragma HLS INTERFACE ap_fifo port=audio_out_1
#pragma HLS INTERFACE ap_fifo port=audio_out_2
#pragma HLS INTERFACE ap_fifo port=audio_out_3
#pragma HLS INTERFACE ap_fifo port=audio_out_4
#pragma HLS INTERFACE ap_fifo port=audio_out_5
#pragma HLS INTERFACE ap_fifo port=audio_out_6
#pragma HLS INTERFACE ap_fifo port=audio_out_7
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

    /* Initialization and computations can start after the ARM
     * has been initialized */
    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
            for(int i = 0; i < INPUTS; i++){
                r_bar += rs[i];
            }
            r_bar /= ns;
            c = 331.3f * sqrt(1.0f + (temp_celcius/273.15f)); // speed of sound m/s

            nfc_omega = c/(r_bar*SYFALA_SAMPLE_RATE);
            nfc_b1 = nfc_omega/2.0f;
            nfc_g1 = 1.0f + nfc_b1;
            nfc_d1 = 0.0f - (2.0f * nfc_b1) / nfc_g1;
            nfc_g = 1.0f/nfc_g1; // where 1.0f is gain in Faust but it's always 1
            for(int i = 0; i < (INPUTS-1); i++){
                nfc_del[i] = 0.0f;
            }

            xover_k = tan(M_PI*xover_freq/SYFALA_SAMPLE_RATE);
            xover_k2 = xover_k*xover_k;
            xover_d =  xover_k2 + 2*xover_k + 1;
            xover_b_hf[0] = 1/xover_d;
            xover_b_hf[1] = -2/xover_d;
            xover_b_hf[2] = 1/xover_d;
            xover_b_lf[0] = xover_k2/xover_d;
            xover_b_lf[1] = 2*xover_k2/xover_d;
            xover_b_lf[2] = xover_k2/xover_d;
            xover_a[0] = 2 * (xover_k2-1) / xover_d;
            xover_a[1] = (xover_k2 - 2*xover_k + 1) / xover_d;
            for(int i = 0; i < INPUTS; i++){
                xover_iir_del[i] = 0.0f;
                xover_fir0_del[i] = 0.0f;
                xover_fir1_del[i][0] = 0.0f;
                xover_fir1_del[i][1] = 0.0f;
                xover_fir2_del[i][0] = 0.0f;
                xover_fir2_del[i][1] = 0.0f;
            }

            initialization = false;
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = audio_in_0[n];
                     audio_out_1[n] = audio_in_1[n];
                     audio_out_2[n] = audio_in_2[n];
                     audio_out_3[n] = audio_in_3[n];
                     audio_out_4[n] = audio_in_0[n];
                     audio_out_5[n] = audio_in_1[n];
                     audio_out_6[n] = audio_in_2[n];
                     audio_out_7[n] = audio_in_3[n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = 0;
                     audio_out_1[n] = 0;
                     audio_out_2[n] = 0;
                     audio_out_3[n] = 0;
                     audio_out_4[n] = 0;
                     audio_out_5[n] = 0;
                     audio_out_6[n] = 0;
                     audio_out_7[n] = 0;
                }
            } else {
                float ins[INPUTS][SYFALA_BLOCK_NSAMPLES] = {{0.0f}};
                float outs[OUTPUTS][SYFALA_BLOCK_NSAMPLES] = {{0.0f}};

                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    ins[0][n] = Syfala::HLS::ioreadf(audio_in_0[n]);
                    ins[1][n] = Syfala::HLS::ioreadf(audio_in_1[n]);
                    ins[2][n] = Syfala::HLS::ioreadf(audio_in_2[n]);
                    ins[3][n] = Syfala::HLS::ioreadf(audio_in_3[n]);
                }


                for(int i = 0; i < INPUTS; i++){
                    // near field correction (NFC)
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                        if(co[i] == 1){
                            ins[i][n] = ins[i][n]*nfc_g + nfc_del[i]*nfc_d1;
                            nfc_del[i] = ins[i] + nfc_del[i];
                        }
                        // TODO missing else for other cases...
                    }

                         // shelf filter decoder
                         ins[i] = ins[i] - xover_iir_del[i];
                         xover_iir_del[i] = ins[i]*xover_a[0] + xover_fir0_del[i]*xover_a[1];
                         xover_fir0_del[i] = ins[i];
                         float fir1_y = ins[i]*xover_b_lf[0] + xover_fir1_del[i][0]*xover_b_lf[1] + xover_fir1_del[i][1]*xover_b_lf[2];
                         xover_fir1_del[i][1] = xover_fir1_del[i][0];
                         xover_fir1_del[i][0] = fir1_y;
                         float fir2_y = ins[i]*xover_b_hf[0] + xover_fir2_del[i][0]*xover_b_hf[1] + xover_fir2_del[i][1]*xover_b_hf[2];
                         xover_fir2_del[i][1] = xover_fir2_del[i][0];
                         xover_fir2_del[i][0] = fir2_y;
                         ins[i] = fir1_y*(gammas[0][co[i]]/lfhf_ratio) - fir2_y*(gammas[1][co[i]]*lfhf_ratio);
                     }

                     // speaker chain scaling
                     for(int i = 0; i < OUTPUTS; i++){
                         for(int j = 0; j < INPUTS; j++){
                            outs[i] += ins[j]*s[i][j];
                         }
                         outs[i]*output_gain;
                     }

                      Syfala::HLS::iowritef(outs[0], &audio_out_0[n]);
                      Syfala::HLS::iowritef(outs[1], &audio_out_1[n]);
                      Syfala::HLS::iowritef(outs[2], &audio_out_2[n]);
                      Syfala::HLS::iowritef(outs[3], &audio_out_3[n]);
                      Syfala::HLS::iowritef(outs[4], &audio_out_4[n]);
                      Syfala::HLS::iowritef(outs[5], &audio_out_5[n]);
                      Syfala::HLS::iowritef(outs[6], &audio_out_6[n]);
                      Syfala::HLS::iowritef(outs[7], &audio_out_7[n]);
                 }
            }
        }
    }
}
