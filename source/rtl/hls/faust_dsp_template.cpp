
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
#if FAUST_REAL_CONTROLS
    for (int i = 0; i < FAUST_REAL_CONTROLS; ++i)
         dst_f[i] = sy_real_t(src_f[i]);
#endif
#if FAUST_INT_CONTROLS
    for (int i = 0; i < FAUST_INT_CONTROLS; ++i)
         dst_i[i] = src_i[i];
#endif
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
static int N0    = N_max - N_min;

// ----------------------------------------------------------------------------
// HLS TOP-LEVEL FUNCTION
// ----------------------------------------------------------------------------

void syfala (
     sy_ap_int audio_in_#IN,
    sy_ap_int* audio_out_#ON,
         float arm_control_f[#KF],
           int arm_control_i[#KI],
         float arm_control_p[#KP],
#if SYFALA_AUDIO_DEBUG_UART //----------
         float arm_debug[FAUST_OUTPUTS],
#endif //-------------------------------
          int* control_block,
           int arm_ok,
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
#if SYFALA_AUDIO_DEBUG_UART //--------------------
    #pragma HLS INTERFACE s_axilite port=arm_debug
#endif //-----------------------------------------
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

#if FAUST_INPUTS //-------------------------------------
    /* Convert ap_int<24> IP inputs to float in a local array */
    static sy_real_t inputs[FAUST_INPUTS];
    inputs[#IN] = audio_in_#IN.to_float() / SCALE_FACTOR;
#endif
    static sy_real_t outputs[FAUST_OUTPUTS];
    for (int n = 0; n < FAUST_OUTPUTS; ++n)
         outputs[n] = 0.f;

    /* Check if ARM is ready to initialize and send control values */
    if (arm_ok) {
        if (initialize) {
            /* First iteration: constant initialization */
        #if SYFALA_MEMORY_USE_DDR
            // A. From values initialised in DDR
            instanceConstantsFromMemmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #else
            // B. Else, from static arrays
            staticInitmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
            instanceConstantsmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #endif
            initialize = false;
        } else {
            /* All other iterations:
             * - Update controller values (from ARM)
             * - Compute one sample
             * - Write back passive controller values
             */
            if (*control_block == SYFALA_CONTROL_RELEASE) {
                *control_block =  SYFALA_CONTROL_BLOCK_FPGA;
                 copy_control(arm_control_f, arm_control_i, control_f, control_i);
                *control_block =  SYFALA_CONTROL_RELEASE;
            }
            if (bypass) {
                // if bypass switch is UP
            #if FAUST_INPUTS
                for (int n = 0; n < N_min; ++n)
                     outputs[n] = inputs[n];
            #endif
                for (int n = 0; n < N0; ++n)
                     outputs[n] = 0.f;
            } else if (mute) {
                // if 'mute' switch is up
                for (int n = 0; n < FAUST_OUTPUTS; ++n)
                     outputs[n] = 0.f;
            } else {
            #if FAUST_INPUTS
                computemydsp(&DSP, inputs, outputs, control_i, control_f, mem_zone_i, mem_zone_f);
            #else
                computemydsp(&DSP, 0, outputs, control_i, control_f, mem_zone_i, mem_zone_f);
            #endif
                // clip outputs
                for (int n = 0; n < FAUST_OUTPUTS; ++n)
                     outputs[n] = clip<sy_real_t>(outputs[n], -1, 1);
            }
        #if FAUST_PASSIVES
            write(DSP, arm_control_p);
        #endif
        }
    } else {
        // If ARM is not ready yet, make a simple bypass
    #if FAUST_INPUTS
        for (int n = 0; n < N_min; ++n)
             outputs[n] = inputs[n];
    #endif
        for (int n = 0; n < N0; ++n)
             outputs[n] = 0.f;
    }
    /* debug: change state of GPIO each cycle to see cycle time */
    if (bypass) {
    #if FAUST_INPUTS // ---------------------------------------------
        for (int n = 0; n < N_min; ++n)
             outputs[n] = inputs[n];
    #endif // -------------------------------------------------------
        for (int n = 0; n < N0; ++n)
             outputs[n] = 0.f;
    } else if (mute) {
        for (int n = 0; n < FAUST_OUTPUTS; ++n)
             outputs[n] = 0.f;
    } else {
        // copy produced outputs
        for (int n = 0; n < FAUST_OUTPUTS; ++n)
             outputs[n] = clip<sy_real_t>(outputs[n], -1, 1);
        *audio_out_#ON = sy_ap_int(outputs[#ON] * SCALE_FACTOR);
    }
}
