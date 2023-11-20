/* ------------------------------------------------------------
name: "sigma-delta"
Code generated with Faust 2.60.0 (https://faust.grame.fr)
Compilation options: -a /home/pierre/Repositories/syfala/dev-make/source/rtl/hls/faust_dsp_template.cpp -lang c -os2 -fpga-mem 10000 -light -ct 1 -es 1 -mcd 16 -uim -single -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__


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
#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif


#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define RESTRICT __restrict
#else
#define RESTRICT __restrict__
#endif

#include <math.h>
#include <stdint.h>
#include <stdlib.h>


#ifndef FAUSTCLASS
#define FAUSTCLASS mydsp
#endif

#ifdef __APPLE__
#define exp10f __exp10f
#define exp10 __exp10
#endif

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)


typedef struct {
	float fRec2[2];
	float fRec1[2];
	int iRec0[2];
	int fSampleRate;
} mydsp;

#ifndef TESTBENCH

int getSampleRatemydsp(mydsp* RESTRICT dsp) {
	return dsp->fSampleRate;
}

int getNumInputsmydsp(mydsp* RESTRICT dsp) {
	return 1;
}
int getNumOutputsmydsp(mydsp* RESTRICT dsp) {
	return 1;
}

void classInitmydsp(int sample_rate) {}

void staticInitmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
	dsp->fSampleRate = sample_rate;
}

void instanceConstantsFromMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
	dsp->fSampleRate = sample_rate;
}

void instanceConstantsToMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
	dsp->fSampleRate = sample_rate;
}

void instanceResetUserInterfacemydsp(mydsp* dsp) {
}

void instanceClearmydsp(mydsp* dsp, int* iZone, float* fZone) {
	/* C99 loop */
	{
		int l0;
		for (l0 = 0; l0 < 2; l0 = l0 + 1) {
			dsp->fRec2[l0] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l1;
		for (l1 = 0; l1 < 2; l1 = l1 + 1) {
			dsp->fRec1[l1] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l2;
		for (l2 = 0; l2 < 2; l2 = l2 + 1) {
			dsp->iRec0[l2] = 0;
		}
	}
}

void instanceInitmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
	staticInitmydsp(dsp, sample_rate, iZone, fZone);
	instanceConstantsmydsp(dsp, sample_rate, iZone, fZone);
	instanceConstantsToMemmydsp(dsp, sample_rate, iZone, fZone);
	instanceResetUserInterfacemydsp(dsp);
	instanceClearmydsp(dsp, iZone, fZone);
}

void initmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
	instanceInitmydsp(dsp, sample_rate, iZone, fZone);
}

void controlmydsp(mydsp* dsp, int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
}

int getNumIntControlsmydsp(mydsp* dsp) { return 0; }
int getNumRealControlsmydsp(mydsp* dsp) { return 0; }

int getiZoneSizemydsp(mydsp* dsp) { return 0; }
int getfZoneSizemydsp(mydsp* dsp) { return 0; }

void computemydsp(mydsp* dsp, FAUSTFLOAT* RESTRICT inputs, FAUSTFLOAT* RESTRICT outputs, int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
	float fTemp0 = (float)(((dsp->iRec0[1] == 1) ? -1 : 1));
	dsp->fRec2[0] = fTemp0 + (float)(inputs[0]) + dsp->fRec2[1];
	dsp->fRec1[0] = fTemp0 + dsp->fRec2[0] + dsp->fRec1[1];
	dsp->iRec0[0] = dsp->fRec1[0] >= 0.0f;
	outputs[0] = (FAUSTFLOAT)(dsp->iRec0[0]);
	dsp->fRec2[1] = dsp->fRec2[0];
	dsp->fRec1[1] = dsp->fRec1[0];
	dsp->iRec0[1] = dsp->iRec0[0];
}

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 0

#define FAUST_INT_ZONE 0
#define FAUST_FLOAT_ZONE 0

#endif // TESTBENCH


#ifdef FAUST_UIMACROS

	#define FAUST_FILE_NAME "sigma-delta.dsp"
	#define FAUST_CLASS_NAME "mydsp"
	#define FAUST_COMPILATION_OPIONS "-a /home/pierre/Repositories/syfala/dev-make/source/rtl/hls/faust_dsp_template.cpp -lang c -os2 -fpga-mem 10000 -light -ct 1 -es 1 -mcd 16 -uim -single -ftz 0"
	#define FAUST_INPUTS 1
	#define FAUST_OUTPUTS 1
	#define FAUST_ACTIVES 0
	#define FAUST_PASSIVES 0


	#define FAUST_LIST_ACTIVES(p) \

	#define FAUST_LIST_PASSIVES(p) \

#endif
#ifdef __cplusplus
}
#endif
#endif // ----------------------------------------

#if SYFALA_REAL_FIXED_POINT // -------------------
    #include <type_traits>
    static_assert(std::is_same<FAUSTFLOAT,fixpoint_t>::value,
                  "FAUSTFLOAT should not be float");
#endif // ---------------------------------------


static bool initialize = true;

// DSP struct
static mydsp DSP;

// ----------------------------------------------------------------------------
// HLS TOP-LEVEL FUNCTION
// ----------------------------------------------------------------------------

void sigma_delta (
     sy_ap_int audio_in_0,
         bool* audio_out_0
){
    /* Convert ap_int<24> IP inputs to float in a local array */
    static sy_real_t inputs[FAUST_INPUTS];
    inputs[0] = audio_in_0.to_float() / SCALE_FACTOR;

    static sy_real_t outputs[FAUST_OUTPUTS];
    for (int n = 0; n < FAUST_OUTPUTS; ++n)
         outputs[n] = 0.f;

    if (initialize) {
        /* First iteration: constant initialization */
    #if SYFALA_MEMORY_USE_DDR
        // A. From values initialised in DDR
        instanceConstantsFromMemmydsp(&DSP, SYFALA_SAMPLE_RATE, nullptr, nullptr);
    #else
        // B. Else, from static arrays
        staticInitmydsp(&DSP, SYFALA_SAMPLE_RATE, nullptr, nullptr);
        instanceConstantsmydsp(&DSP, SYFALA_SAMPLE_RATE, nullptr, nullptr);
    #endif
        initialize = false;
    } else {
        /* All other iterations:
         * - Compute one sample */
        computemydsp(&DSP, inputs, outputs, nullptr, nullptr, nullptr, nullptr);
        /* Clip outputs */
        for (int n = 0; n < FAUST_OUTPUTS; ++n)
             outputs[n] = clip<sy_real_t>(outputs[n], -1, 1);
    }
    /* Copy produced outputs */
    for (int n = 0; n < FAUST_OUTPUTS; ++n)
         outputs[n] = clip<sy_real_t>(outputs[n], -1, 1);
    *audio_out_0 = outputs[0] >= 1.f ? 1 : 0;
}

#endif
