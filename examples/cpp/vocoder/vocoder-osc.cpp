#include <cstddef>
#include <cmath>
#include <syfala/utilities.hpp>

/* Inputs (2):
 * - mono, voice (modulator)
 * - mono, synth (carrier)
 *
 * Outputs (2):
 * - stereo, vocoder
 */
#define INPUTS 2
#define OUTPUTS 2

// biquad filter coefs
#include "coefs.h"

// number of oscillators for polyvoice synth
#define NUM_OSC 10
#define OSC_PRE_GAIN 0.5f

#define EQ_PARAMS 19
#define FILTERS_PER_EQ 4

typedef struct {
    float freq;
    float vel;
} Key;

typedef struct {
    float out_gain;
    float voice_gain;
    float voice_attack;
    float voice_release;
    float voice_eq[EQ_PARAMS];
    float carrier_gain;
    float carrier_eq[EQ_PARAMS];
    Key synth_key[NUM_OSC];
    float saw_gain;
    float square_gain;
    float tri_gain;
} Ctrl;

////////// Registers for the vocoder
// Input registers
static float x_reg_mod[3];
static float x_reg_car[3];
// Intermediate registers for filtering
static float y_reg_mod[NUM_FILTERS][3];
static float y_reg_car[NUM_FILTERS][3];
// one-pole switching filter register for envelope detection
static float y_reg_env[NUM_FILTERS][2];

////////// Registers for signal generation
static float sawtooth[NUM_OSC] = {-1.f};
static float square[NUM_OSC] = {-1.f};
static float triangle[NUM_OSC] = {-1.f};
static float synth = 0.f;
static float oscillator[NUM_OSC] = {0.f};

// Insert new sample and keep the two previous ones.
void shift_input_reg(const float modulator, const float carrier)
{
    for (int i=2; i>0; i--) {
        x_reg_mod[i] = x_reg_mod[i-1];
        x_reg_car[i] = x_reg_car[i-1];
    }
    x_reg_mod[0] = modulator;
    x_reg_car[0] = carrier;
}

void filter()
{
    for (int i = 0; i < NUM_FILTERS; i++)
    {
        // coefficients of the biquad filter
        // a => for y
        // b => for x
        float* al = a + i*A_ONE_COEF;  // to be interpreted as a A_ONE_COEF float vector
        float* bl = b + i*B_ONE_COEF;  // to be interpreted as a B_ONE_COEF float vector

        y_reg_mod[i][0] = bl[0] * x_reg_mod[0]
                        + bl[1] * x_reg_mod[1]
                        + bl[2] * x_reg_mod[2]
                        - al[0] * y_reg_mod[i][1]
                        - al[1] * y_reg_mod[i][2];

        y_reg_car[i][0] = bl[0] * x_reg_car[0]
                        + bl[1] * x_reg_car[1]
                        + bl[2] * x_reg_car[2]
                        - al[0] * y_reg_car[i][1]
                        - al[1] * y_reg_car[i][2];
    }
}

void env_detection(const Ctrl ctrl)
{
    for (int i = 0; i < NUM_FILTERS; i++)
    {
        // Envelope Detection
        // Absolute value of the modulator
        int8_t sign_mod = y_reg_mod[i][0] < 0 ? -1 : 1;
        float atk_or_rel = sign_mod * y_reg_mod[i][0] > y_reg_env[i][1] ? OPSF_ATK_COEF * ctrl.voice_attack : OPSF_REL_COEF * ctrl.voice_release;

        // Low Pass Filter
        y_reg_env[i][0] = (1 - atk_or_rel) * sign_mod * y_reg_mod[i][0] + atk_or_rel * y_reg_env[i][1];
    }
}

void shift_reg()
{
    #pragma HLS unroll
    for (int i=0; i<NUM_FILTERS; i++) {
        #pragma HLS dataflow
        shift_mod_car: for (int j=2; j>0; j--) {
            y_reg_mod[i][j] = y_reg_mod[i][j-1];
            y_reg_car[i][j] = y_reg_car[i][j-1];
        }
        shift_env: for (int j=1; j>0; j--) {
            y_reg_env[i][j] = y_reg_env[i][j-1];
        }
    }
}

// control eq for the modulator and the carrier independently with arm program. 
void band_eq(Ctrl const ctrl)
{
    // Separates first and last filterred signal because they are LPF and HPF.
    y_reg_env[0][0] *= ctrl.voice_eq[0];
    y_reg_env[NUM_FILTERS-1][0] *= ctrl.voice_eq[EQ_PARAMS-1];
    y_reg_car[0][0] *= ctrl.carrier_eq[0];
    y_reg_car[NUM_FILTERS-1][0] *= ctrl.carrier_eq[EQ_PARAMS-1];

    for (int i = 1; i < EQ_PARAMS-2; i++)
    {
        for (int j=0; j<FILTERS_PER_EQ; j++) {
            #pragma HLS unroll
            y_reg_env[i*FILTERS_PER_EQ+j][0] *= ctrl.voice_eq[i];
            y_reg_car[i*FILTERS_PER_EQ+j][0] *= ctrl.carrier_eq[i];
        }
    }
}

void vocoder(float* output)
{
    for (int i=0; i<NUM_FILTERS; i++) {
        #pragma HLS unroll factor=11
        *output += y_reg_car[i][0] * y_reg_env[i][0];
    }
}

void gen_next_sample(const Ctrl ctrl)
{
    synth = 0.f;

    for (int i=0; i<NUM_OSC; i++) {
        // sawtooth /|/|/|/| [0;1] -> [-1;1]
        sawtooth[i] = oscillator[i]*2 - 1;
        // square |-|_|-|_ [0;0.5] -> 1 and [0.5;1] -> -1
        square[i] = oscillator[i] < 0.5 ? 1.f : -1.f;
        // triangle /\/\/\/\ [0;0.5] -> [-1;1] and [0.5;1] -> [1;-1]
        triangle[i] = oscillator[i] < 0.5 ? oscillator[i]*4 - 1 : (oscillator[i]-0.5)*(-4) + 1;

        synth += ctrl.synth_key[i].vel
                * (sawtooth[i] * ctrl.saw_gain
                + square[i] * ctrl.square_gain
                + triangle[i] * ctrl.tri_gain);

        // update oscillators
        oscillator[i] += ctrl.synth_key[i].freq / SYFALA_SAMPLE_RATE;
        oscillator[i] = fmodf(oscillator[i],1.f);
    }
        
}

static void compute(const sy_ap_int input_0,
                    const sy_ap_int input_1,
                    sy_ap_int* output_0,
                    sy_ap_int* output_1,
                    const Ctrl ctrl)
{
    float y = 0.0f; // output
    gen_next_sample(ctrl);

    const float modulator = Syfala::HLS::ioreadf(input_0) * ctrl.voice_gain;
    //float carrier = Syfala::HLS::ioreadf(input_1) * ctrl.carrier_gain;
    const float carrier = synth * ctrl.carrier_gain;

    shift_input_reg(modulator, carrier);

    filter();
    env_detection(ctrl);

    shift_reg();
    band_eq(ctrl);

    vocoder(&y);
    // Output gain control
    y *= ctrl.out_gain;
    Syfala::HLS::iowritef(y, output_0);
    Syfala::HLS::iowritef(y, output_1);
}

static bool initialization = true;

void syfala (
        sy_ap_int audio_in[INPUTS],
        sy_ap_int audio_out[OUTPUTS],
        int arm_ok,
        bool* i2s_rst,
        float* mem_zone_f,
        int* mem_zone_i,
        bool bypass,
        bool mute,
        bool debug,
        Ctrl ctrl
) {
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
#pragma HLS INTERFACE s_axilite port=ctrl

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

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
                audio_out[0] = audio_in[0];
                audio_out[1] = audio_in[1];
            } else if (mute) {
                audio_out[0] = 0;
                audio_out[1] = 0;
            } else {
                /* ... or compute samples here */
                compute(audio_in[0], audio_in[1], &audio_out[0], &audio_out[1], ctrl);
            }
        }
    }
}