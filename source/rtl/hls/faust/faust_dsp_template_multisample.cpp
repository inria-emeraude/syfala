
/************************************************************************
 ************************************************************************
    Syfala compilation flow
    Copyright (C) 2022 INSA-LYON, INRIA, GRAME-CNCM
---------------------------------------------------------------------
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ************************************************************************
 ************************************************************************/

#include <algorithm>
#include <cmath>
#include <inttypes.h>
#include <string.h>
#include <syfala/utilities.hpp>

#define SYFALA_BLOCK_SIZE SYFALA_BLOCK_NSAMPLES
using namespace std;

#if SYFALA_REAL_FIXED_POINT // -------------------
      using fixpoint_t = sy_real_t;
      #define FAUSTFLOAT fixpoint_t
#endif
// -----------------------------------------------
#define FAUST_UIMACROS 1
// -----------------------------------------------
/* Generic definition used to accept a variable
   number of controllers */
#define FAUST_ADDBUTTON(l,f)
#define FAUST_ADDCHECKBOX(l,f)
#define FAUST_ADDVERTICALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDHORIZONTALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDNUMENTRY(l,f,i,a,b,s)
#define FAUST_ADDVERTICALBARGRAPH(l,f,a,b)
#define FAUST_ADDHORIZONTALBARGRAPH(l,f,a,b)

#ifdef SYFALA_TESTING_PRECOMPILED // -------------
    #include FAUST_PRECOMPILED_EXAMPLE_FPGA_TARGET
#else // -----------------------------------------
    // The Faust compiler will insert the C code here
    <<includeIntrinsic>>
    <<includeclass>>
#endif // ----------------------------------------

#if SYFALA_REAL_FIXED_POINT // -------------------
    #include <type_traits>
    static_assert(std::is_same<FAUSTFLOAT,fixpoint_t>::value,
                  "FAUSTFLOAT should not be float");
#endif // ---------------------------------------

//  assign passive controller values from matching dsp struct members
#define ACTIVE_ELEMENT_IN(type, ident, name, var, def, min, max, step)  \
pcontrol[field++] = *(ap_int<32>*) &DSP.var;

/* send passive controllers values to ARM */
static void write(mydsp& DSP, float* pcontrol) {
    int field = 0;
    FAUST_LIST_PASSIVES(ACTIVE_ELEMENT_IN);
}

static void copy_control (
            float* src_f,
              int* src_i,
        sy_real_t* dst_f,
              int* dst_i
){
    for (int i = 0; i < FAUST_REAL_CONTROLS; ++i)
         dst_f[i] = sy_real_t(src_f[i]);

    for (int i = 0; i < FAUST_INT_CONTROLS; ++i)
         dst_i[i] = src_i[i];
}

// Control arrays
static sy_real_t
control_f[FAUST_REAL_CONTROLS];

static int
control_i[FAUST_INT_CONTROLS];

static bool initialize = true;

// DSP struct
static mydsp DSP;

static int N_min   = std::min(FAUST_INPUTS, FAUST_OUTPUTS);
static int N_max   = std::max(FAUST_INPUTS, FAUST_OUTPUTS);
#if (FAUST_INPUTS > FAUST_OUTPUTS)
    static int N0 = 0;
#else // --------------------------
    static int N0 = N_max - N_min;
#endif // -------------------------

// ----------------------------------------------------------------------------
// HLS TOP-LEVEL FUNCTION
// ----------------------------------------------------------------------------

void syfala (
     sy_ap_int audio_in[FAUST_INPUTS][SYFALA_BLOCK_NSAMPLES],
     sy_ap_int audio_out[FAUST_OUTPUTS][SYFALA_BLOCK_NSAMPLES],
         float arm_control_f[FAUST_REAL_CONTROLS],
           int arm_control_i[FAUST_INT_CONTROLS],
         float arm_control_p[FAUST_PASSIVES],
          int* control_block,
    #if SYFALA_DEBUG_AUDIO // -------------
         float arm_debug[FAUST_OUTPUTS],
    #endif // ----------------- -----------
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
){
#pragma HLS INTERFACE ap_fifo port=audio_in
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_control_f
#pragma HLS INTERFACE s_axilite port=arm_control_i
#pragma HLS INTERFACE s_axilite port=arm_control_p
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=control_block
#if SYFALA_DEBUG_AUDIO //-------------------------
    #pragma HLS INTERFACE s_axilite port=arm_debug
#endif //-----------------------------------------
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // Active high reset, this HAVE TO BE DONE FIRST
    // (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

    /* RAM must be enabled by ARM before any computation */
    if (arm_ok) {
        if (initialize) {
            /* first iteration: constant initialization */
            /* from values initialised in DDR */
            instanceConstantsFromMemmydsp(
                &DSP, SYFALA_SAMPLE_RATE,
                mem_zone_i, mem_zone_f
            );
            initialize = false;
        } else {
            /* Allocate 'inputs' and 'outputs' for 'compute' method */
            static sy_real_t
            inputs[FAUST_INPUTS][SYFALA_BLOCK_NSAMPLES];

            static sy_real_t
            outputs[FAUST_OUTPUTS][SYFALA_BLOCK_NSAMPLES];

            // Convert ap_int inputs to float in local array.
            for (int n = 0; n < FAUST_INPUTS; ++n) {
                for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
                    // Warning: we invert the array orders here.
                     inputs[n][m] = Syfala::HLS::ioreadf(audio_in[n][m]);
                }
            }
            /* All other iterations:
             * - update controllers values from IP ports
             */
            if (*control_block == SYFALA_CONTROL_RELEASE) {
                *control_block =  SYFALA_CONTROL_BLOCK_FPGA;
                copy_control(arm_control_f, arm_control_i, control_f, control_i);
                *control_block =  SYFALA_CONTROL_RELEASE;
            }
            if (bypass) {
                /*
                 * If bypass switch is UP:
                 * - if there are audio inputs, pass them to the outputs.
                 * - if there are not the same number of inputs & outputs:
                 *   set the other outputs to 0.
                 */
                for (int m = 0; m < N_min; ++m) {
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n)
                         outputs[m][n] = inputs[m][n];
                }
                for (int m = 0; m < N0; ++m)
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                         outputs[m][n] = 0.f;
                }
            } else if (mute) {
                // If 'mute' switch is UP: set all outputs to 0.
                for (int m = 0; m < FAUST_OUTPUTS; ++m)
                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                         outputs[m][n] = 0;
                }
            } else {
                // Otherwise, make the computations.
                computeBlockmydsp(&DSP,
                        inputs, outputs,
                     control_i, control_f,
                    mem_zone_i, mem_zone_f
                );
            }
            for (int m = 0; m < FAUST_OUTPUTS; ++m) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    outputs[m][n] = clip<sy_real_t>(outputs[m][n], -1, 1);
                    Syfala::HLS::iowritef(outputs[m][n], audio_out[m][n]);
                }
            }
            // If there are any 'passive' controllers, such as bargraphs, update them.
        #if FAUST_PASSIVES
            write(DSP, arm_control_p);
        #endif
        }
    }
}
