
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
static int
control_i[FAUST_INT_CONTROLS];

static sy_real_t
control_f[FAUST_REAL_CONTROLS];

static bool initialize = true;

// DSP struct
static mydsp DSP;

static int N_min = min(FAUST_INPUTS, FAUST_OUTPUTS);
static int N_max = max(FAUST_INPUTS, FAUST_OUTPUTS);

#if (FAUST_INPUTS > FAUST_OUTPUTS)
    static int N0 = 0;
#else
    static int N0 = N_max - N_min;
#endif

// ----------------------------------------------------------------------------
// HLS TOP-LEVEL FUNCTION
// ----------------------------------------------------------------------------

void syfala (
     sy_ap_int audio_in_#IN,
    sy_ap_int* audio_out_#ON,
         float arm_control_f[FAUST_REAL_CONTROLS],
           int arm_control_i[FAUST_INT_CONTROLS],
         float arm_control_p[FAUST_PASSIVES],
#if SYFALA_DEBUG_AUDIO //---------------
         float arm_debug[FAUST_OUTPUTS],
#endif //-------------------------------
          int* control_block,
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
){
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

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

    /* Check if ARM is ready to initialize and send control values
     * Note: don't write anything to the audio outputs outside
     * of the 'arm_ok' scope. */
    if (arm_ok) {
        if (initialize) {
            /* First iteration: constant initialization */
        #ifdef __CSIM__
            /* With CSIM, intialize normally, as we do in C/C++.
             * Initialize control arrays as well. */
            printf("[CSIM] Initializing DSP constants, memory & controls\n");
            instanceInitmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
            controlmydsp(&DSP, arm_control_i, arm_control_f, mem_zone_i, mem_zone_f);
            /*
             * With HLS, two options for initialization:
             */
        #elif SYFALA_MEMORY_USE_DDR
            // A. From values initialised in DDR
            instanceConstantsFromMemmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #else
            // B. Else, from static arrays
            staticInitmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
            instanceConstantsmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #endif
            initialize = false;
        } else {
            // All other iterations:
            // Convert ap_int inputs to float in local array.
            static sy_real_t outputs[FAUST_OUTPUTS];
            static sy_real_t inputs[FAUST_INPUTS];
            inputs[#IN] = audio_in_#IN / SCALE_FACTOR;
           /* - Update controller values (from ARM) */
            if (*control_block == SYFALA_CONTROL_RELEASE) {
                *control_block =  SYFALA_CONTROL_BLOCK_FPGA;
                 copy_control(arm_control_f, arm_control_i, control_f, control_i);
                *control_block =  SYFALA_CONTROL_RELEASE;
            }
            if (bypass) {
                // If bypass switch is UP:
                // - if there are audio inputs, pass them to the outputs.
                // - if there are not the same number of inputs & outputs:
                //   set the other outputs to 0.
                for (int n = 0; n < N_min; ++n) {
                     outputs[n] = inputs[n];
                }
                for (int n = 0; n < N0; ++n) {
                     outputs[n] = 0.f;
                }
            } else if (mute) {
                // If 'mute' switch is UP: set all outputs to 0.
                for (int n = 0; n < FAUST_OUTPUTS; ++n)
                     outputs[n] = 0.f;
            } else {
                // Make the computations.
                computemydsp(&DSP, inputs, outputs, control_i, control_f, mem_zone_i, mem_zone_f);
            }
            // Clip & copy produced audio outputs.
            *audio_out_#ON = clip<sy_real_t>(outputs[#ON], -1, 1) * SCALE_FACTOR;
            // If there are any 'passive' controllers, such as bargraphs, update them.
            #if (FAUST_PASSIVES)
                write(DSP, arm_control_p);
            #endif
        }
    }
#if SYFALA_DEBUG_AUDIO
    for (int n = 0; n < FAUST_OUTPUTS; ++n)
         arm_debug[n] = outputs[n];
#endif
}
