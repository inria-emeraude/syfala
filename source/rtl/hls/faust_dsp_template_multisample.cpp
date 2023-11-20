
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

// assign active controller values to matching dsp struct members
#define ACTIVE_ELEMENT_OUT(type, ident, name, var, def, min, max, step) \
DSP.var = *(sy_real_t*) &controller[field++];

/* receive controllers values from ARM */
static void read(mydsp& DSP, ap_int<32>* controller) {
    int field = 0;
    FAUST_LIST_ACTIVES(ACTIVE_ELEMENT_OUT);
}

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

static int N_min   = min(FAUST_INPUTS, FAUST_OUTPUTS);
static int N_max   = max(FAUST_INPUTS, FAUST_OUTPUTS);
#if (FAUST_INPUTS > FAUST_OUTPUTS)
    static int N0 = 0;
#else // --------------------------
    static int N0 = N_max - N_min;
#endif // -------------------------

// ----------------------------------------------------------------------------
// HLS TOP-LEVEL FUNCTION
// ----------------------------------------------------------------------------

void syfala (
     sy_ap_int audio_in_#IN[SYFALA_BLOCK_NSAMPLES],
     sy_ap_int audio_out_#ON[SYFALA_BLOCK_NSAMPLES],
         float arm_control_f[FAUST_REAL_CONTROLS],
           int arm_control_i[FAUST_INT_CONTROLS],
         float arm_control_p[FAUST_PASSIVES],
          int* control_block,
    #if SYFALA_DEBUG_AUDIO // -------------
         float arm_debug[FAUST_OUTPUTS],
    #endif // ----------------- -----------
           int arm_ok,
         bool* i2s_rst,
         bool* audio_start,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
){
#pragma HLS INTERFACE ap_fifo port=audio_in_#IN
#pragma HLS INTERFACE ap_fifo port=audio_out_#ON
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
        #ifdef __CSIM__
            printf("[CSIM] Initializing DSP constants, memory & controls\n");
            instanceInitmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
            controlmydsp(&DSP, arm_control_i, arm_control_f, mem_zone_i, mem_zone_f);
        #elif SYFALA_MEMORY_USE_DDR
            /* from values initialised in DDR */
            instanceConstantsFromMemmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #else
            /* directly on the FPGA */
            staticInitmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
            instanceConstantsmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #endif
            initialize = false;
        } else {
            /* Allocate 'inputs' and 'outputs' for 'compute' method */
            static sy_real_t inputs[SYFALA_BLOCK_NSAMPLES][FAUST_INPUTS];
            static sy_real_t outputs[SYFALA_BLOCK_NSAMPLES][FAUST_OUTPUTS];

            // Convert ap_int inputs to float in local array.
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                 inputs[n][#IN] = audio_in_#IN[n].to_float() / SCALE_FACTOR;
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
                for (int n = 0; n < N_min; ++n) {
                    for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m)
                         outputs[n][m] = inputs[n][m];
                }
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    for (int m = 0; m < N0; ++m)
                         outputs[n][m] = 0.f;
                }
            } else if (mute) {
                // If 'mute' switch is UP: set all outputs to 0.
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    for (int m = 0; m < FAUST_OUTPUTS; ++m)
                     outputs[n][m] = 0;
                }
            } else {
                // Otherwise, make the computations.
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     computemydsp(&DSP, inputs[n], outputs[n], control_i, control_f, mem_zone_i, mem_zone_f);
                }
            }
            // Clip & copy produced audio outputs.
            for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                 outputs[n][#ON] = clip<sy_real_t>(outputs[n][#ON], -1, 1);
                 audio_out_#ON[n] = sy_ap_int(outputs[n][#ON] * SCALE_FACTOR);
            }
        // If there are any 'passive' controllers, such as bargraphs, update them.
        #if FAUST_PASSIVES
            write(DSP, arm_control_p);
        #endif
        }
    }
}
