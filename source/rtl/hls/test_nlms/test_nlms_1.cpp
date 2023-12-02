/* ------------------------------------------------------------
author: "Niels Mortensen - Sonotronex AG"
name: "Normalized Least Mean Square Algorithm for System Identification"
version: "0.1"
Code generated with Faust 2.54.9 (https://faust.grame.fr)
Compilation options: -a /home/pierre/Repositories/syfala/dev-arch/source/rtl/hls/faust_dsp_template.cpp -lang c -os2 -light -es 1 -mcd 128 -uim -single -ftz 0
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

static float mydsp_faustpower2_f(float value) {
    return value * value;
}

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
    int fSampleRate;
    float fConst1;
    float fConst3;
    float fConst4;
    int iRec1[2];
    float fRec0[3];
    float fVec0[32];
    FAUSTFLOAT fEntry0;
    FAUSTFLOAT fCheckbox0;
    FAUSTFLOAT fButton0;
    float fRecG0[32];
    float fRecG1[32];
    float fRec2[2];
    float fRec3[2];
    float fRec4[2];
    float fRec5[2];
    float fRec6[2];
    float fRec7[2];
    float fRec8[2];
    float fRec9[2];
    float fRec10[2];
    float fRec11[2];
    float fRec12[2];
    float fRec13[2];
    float fRec14[2];
    float fRec15[2];
    float fRec16[2];
    float fRec17[2];
    float fRec18[2];
    float fRec19[2];
    float fRec20[2];
    float fRec21[2];
    float fRec22[2];
    float fRec23[2];
    float fRec24[2];
    float fRec25[2];
    float fRec26[2];
    float fRec27[2];
    float fRec28[2];
    float fRec29[2];
    float fRec30[2];
    float fRec31[2];
    float fRec32[2];
    float fRec33[2];
    FAUSTFLOAT fHbargraph[32];
    FAUSTFLOAT fHbargraph0;
    FAUSTFLOAT fHbargraph1;
    FAUSTFLOAT fHbargraph2;
    FAUSTFLOAT fHbargraph3;
    FAUSTFLOAT fHbargraph4;
    FAUSTFLOAT fHbargraph5;
    FAUSTFLOAT fHbargraph6;
    FAUSTFLOAT fHbargraph7;
    FAUSTFLOAT fHbargraph8;
    FAUSTFLOAT fHbargraph9;
    FAUSTFLOAT fHbargraph10;
    FAUSTFLOAT fHbargraph11;
    FAUSTFLOAT fHbargraph12;
    FAUSTFLOAT fHbargraph13;
    FAUSTFLOAT fHbargraph14;
    FAUSTFLOAT fHbargraph15;
    FAUSTFLOAT fHbargraph16;
    FAUSTFLOAT fHbargraph17;
    FAUSTFLOAT fHbargraph18;
    FAUSTFLOAT fHbargraph19;
    FAUSTFLOAT fHbargraph20;
    FAUSTFLOAT fHbargraph21;
    FAUSTFLOAT fHbargraph22;
    FAUSTFLOAT fHbargraph23;
    FAUSTFLOAT fHbargraph24;
    FAUSTFLOAT fHbargraph25;
    FAUSTFLOAT fHbargraph26;
    FAUSTFLOAT fHbargraph27;
    FAUSTFLOAT fHbargraph28;
    FAUSTFLOAT fHbargraph29;
    FAUSTFLOAT fHbargraph30;
    FAUSTFLOAT fHbargraph31;
} mydsp;

#ifndef TESTBENCH

int getSampleRatemydsp(mydsp* dsp) {
    return dsp->fSampleRate;
}

int getNumInputsmydsp(mydsp* dsp) {
    return 2;
}
int getNumOutputsmydsp(mydsp* dsp) {
    return 2;
}

void classInitmydsp(int sample_rate) {}

void staticInitmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
    dsp->fSampleRate = sample_rate;
    float fConst0 = tanf(31415.926f / fminf(1.92e+05f, fmaxf(1.0f, (float)(dsp->fSampleRate))));
    dsp->fConst1 = 2.0f * (1.0f - 1.0f / mydsp_faustpower2_f(fConst0));
    float fConst2 = 1.0f / fConst0;
    dsp->fConst3 = (fConst2 + -1.4285715f) / fConst0 + 1.0f;
    dsp->fConst4 = 1.0f / ((fConst2 + 1.4285715f) / fConst0 + 1.0f);
}

void instanceConstantsFromMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
    dsp->fSampleRate = sample_rate;
    dsp->fConst1 = fZone[0];
    dsp->fConst3 = fZone[1];
    dsp->fConst4 = fZone[2];
}

void instanceConstantsToMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
    dsp->fSampleRate = sample_rate;
    fZone[0] = dsp->fConst1;
    fZone[1] = dsp->fConst3;
    fZone[2] = dsp->fConst4;
}

void instanceResetUserInterfacemydsp(mydsp* dsp) {
    dsp->fEntry0 = (FAUSTFLOAT)(0.0001f);
    dsp->fCheckbox0 = (FAUSTFLOAT)(0.0f);
    dsp->fButton0 = (FAUSTFLOAT)(0.0f);
}

void instanceClearmydsp(mydsp* dsp, int* iZone, float* fZone) {
    /* C99 loop */
    {
        int l0;
        for (l0 = 0; l0 < 2; l0 = l0 + 1) {
            dsp->iRec1[l0] = 0;
        }
    }
    /* C99 loop */
    {
        int l1;
        for (l1 = 0; l1 < 3; l1 = l1 + 1) {
            dsp->fRec0[l1] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l2;
        for (l2 = 0; l2 < 32; l2 = l2 + 1) {
            dsp->fVec0[l2] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l3;
        for (l3 = 0; l3 < 2; l3 = l3 + 1) {
            dsp->fRec2[l3] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l4;
        for (l4 = 0; l4 < 2; l4 = l4 + 1) {
            dsp->fRec3[l4] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l5;
        for (l5 = 0; l5 < 2; l5 = l5 + 1) {
            dsp->fRec4[l5] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l6;
        for (l6 = 0; l6 < 2; l6 = l6 + 1) {
            dsp->fRec5[l6] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l7;
        for (l7 = 0; l7 < 2; l7 = l7 + 1) {
            dsp->fRec6[l7] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l8;
        for (l8 = 0; l8 < 2; l8 = l8 + 1) {
            dsp->fRec7[l8] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l9;
        for (l9 = 0; l9 < 2; l9 = l9 + 1) {
            dsp->fRec8[l9] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l10;
        for (l10 = 0; l10 < 2; l10 = l10 + 1) {
            dsp->fRec9[l10] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l11;
        for (l11 = 0; l11 < 2; l11 = l11 + 1) {
            dsp->fRec10[l11] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l12;
        for (l12 = 0; l12 < 2; l12 = l12 + 1) {
            dsp->fRec11[l12] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l13;
        for (l13 = 0; l13 < 2; l13 = l13 + 1) {
            dsp->fRec12[l13] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l14;
        for (l14 = 0; l14 < 2; l14 = l14 + 1) {
            dsp->fRec13[l14] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l15;
        for (l15 = 0; l15 < 2; l15 = l15 + 1) {
            dsp->fRec14[l15] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l16;
        for (l16 = 0; l16 < 2; l16 = l16 + 1) {
            dsp->fRec15[l16] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l17;
        for (l17 = 0; l17 < 2; l17 = l17 + 1) {
            dsp->fRec16[l17] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l18;
        for (l18 = 0; l18 < 2; l18 = l18 + 1) {
            dsp->fRec17[l18] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l19;
        for (l19 = 0; l19 < 2; l19 = l19 + 1) {
            dsp->fRec18[l19] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l20;
        for (l20 = 0; l20 < 2; l20 = l20 + 1) {
            dsp->fRec19[l20] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l21;
        for (l21 = 0; l21 < 2; l21 = l21 + 1) {
            dsp->fRec20[l21] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l22;
        for (l22 = 0; l22 < 2; l22 = l22 + 1) {
            dsp->fRec21[l22] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l23;
        for (l23 = 0; l23 < 2; l23 = l23 + 1) {
            dsp->fRec22[l23] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l24;
        for (l24 = 0; l24 < 2; l24 = l24 + 1) {
            dsp->fRec23[l24] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l25;
        for (l25 = 0; l25 < 2; l25 = l25 + 1) {
            dsp->fRec24[l25] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l26;
        for (l26 = 0; l26 < 2; l26 = l26 + 1) {
            dsp->fRec25[l26] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l27;
        for (l27 = 0; l27 < 2; l27 = l27 + 1) {
            dsp->fRec26[l27] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l28;
        for (l28 = 0; l28 < 2; l28 = l28 + 1) {
            dsp->fRec27[l28] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l29;
        for (l29 = 0; l29 < 2; l29 = l29 + 1) {
            dsp->fRec28[l29] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l30;
        for (l30 = 0; l30 < 2; l30 = l30 + 1) {
            dsp->fRec29[l30] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l31;
        for (l31 = 0; l31 < 2; l31 = l31 + 1) {
            dsp->fRec30[l31] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l32;
        for (l32 = 0; l32 < 2; l32 = l32 + 1) {
            dsp->fRec31[l32] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l33;
        for (l33 = 0; l33 < 2; l33 = l33 + 1) {
            dsp->fRec32[l33] = 0.0f;
        }
    }
    /* C99 loop */
    {
        int l34;
        for (l34 = 0; l34 < 2; l34 = l34 + 1) {
            dsp->fRec33[l34] = 0.0f;
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
    fControl[0] = dsp->fConst4 * (float)(dsp->fCheckbox0) * (float)(dsp->fEntry0);
    fControl[1] = 1.0f - (float)(dsp->fButton0);
}

int getNumIntControlsmydsp(mydsp* dsp) { return 0; }
int getNumRealControlsmydsp(mydsp* dsp) { return 2; }

int getiZoneSizemydsp(mydsp* dsp) { return 0; }
int getfZoneSizemydsp(mydsp* dsp) { return 3; }

void computemydsp(mydsp* dsp, float* RESTRICT inputs, float* RESTRICT outputs, int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
    dsp->iRec1[0] = 1103515245 * dsp->iRec1[1] + 12345;
    dsp->fRec0[0] = 4.656613e-10f * (float)(dsp->iRec1[0]) - dsp->fConst4 * (dsp->fConst3 * dsp->fRec0[2] + dsp->fConst1 * dsp->fRec0[1]);
    float fTemp0 = dsp->fRec0[2] + dsp->fRec0[0] + 2.0f * dsp->fRec0[1];
    dsp->fVec0[0] = fTemp0;
    float fTemp1 = dsp->fConst4 * fTemp0;
    float fTemp2 = mydsp_faustpower2_f(fTemp1);
    for (int n = 1; n < 32; ++n) {
         fTemp2 += mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[n]);
    }
//	float fTemp2 = mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[25]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[16]) + mydsp_faustpower2_f(fTemp1) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[1]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[2]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[3]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[4]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[5]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[6]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[7]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[8]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[9]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[10]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[11]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[12]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[13]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[14]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[15]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[17]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[18]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[19]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[20]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[21]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[22]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[23]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[24]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[26]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[27]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[28]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[29]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[30]) + mydsp_faustpower2_f(dsp->fConst4 * dsp->fVec0[31]);
    float fTemp3 = (float)(inputs[1]) - (float)(inputs[0]);
    dsp->fRecG0[0] = fControl[1] * dsp->fRecG1[0] + fControl[0] * (fTemp3 * fTemp0 / fTemp2);

    for (int n = 1; n < 32; ++n) {
         dsp->fRecG0[n] = fControl[1] * dsp->fRecG1[n] + fControl[0] * (fTemp3 * dsp->fVec0[n] / fTemp2);
    }

//    dsp->fRec2[0] = fControl[1] * dsp->fRec2[1] + fControl[0] * (fTemp3 * fTemp0 / fTemp2);
//    dsp->fRec3[0] = fControl[1] * dsp->fRec3[1] + fControl[0] * (fTemp3 * dsp->fVec0[1] / fTemp2);
//    dsp->fRec4[0] = fControl[1] * dsp->fRec4[1] + fControl[0] * (fTemp3 * dsp->fVec0[2] / fTemp2);
//    dsp->fRec5[0] = fControl[1] * dsp->fRec5[1] + fControl[0] * (fTemp3 * dsp->fVec0[3] / fTemp2);
//    dsp->fRec6[0] = fControl[1] * dsp->fRec6[1] + fControl[0] * (fTemp3 * dsp->fVec0[4] / fTemp2);
//    dsp->fRec7[0] = fControl[1] * dsp->fRec7[1] + fControl[0] * (fTemp3 * dsp->fVec0[5] / fTemp2);
//    dsp->fRec8[0] = fControl[1] * dsp->fRec8[1] + fControl[0] * (fTemp3 * dsp->fVec0[6] / fTemp2);
//    dsp->fRec9[0] = fControl[1] * dsp->fRec9[1] + fControl[0] * (fTemp3 * dsp->fVec0[7] / fTemp2);
//    dsp->fRec10[0] = fControl[1] * dsp->fRec10[1] + fControl[0] * (fTemp3 * dsp->fVec0[8] / fTemp2);
//    dsp->fRec11[0] = fControl[1] * dsp->fRec11[1] + fControl[0] * (fTemp3 * dsp->fVec0[9] / fTemp2);
//    dsp->fRec12[0] = fControl[1] * dsp->fRec12[1] + fControl[0] * (fTemp3 * dsp->fVec0[10] / fTemp2);
//    dsp->fRec13[0] = fControl[1] * dsp->fRec13[1] + fControl[0] * (fTemp3 * dsp->fVec0[11] / fTemp2);
//    dsp->fRec14[0] = fControl[1] * dsp->fRec14[1] + fControl[0] * (fTemp3 * dsp->fVec0[12] / fTemp2);
//    dsp->fRec15[0] = fControl[1] * dsp->fRec15[1] + fControl[0] * (fTemp3 * dsp->fVec0[13] / fTemp2);
//    dsp->fRec16[0] = fControl[1] * dsp->fRec16[1] + fControl[0] * (fTemp3 * dsp->fVec0[14] / fTemp2);
//    dsp->fRec17[0] = fControl[1] * dsp->fRec17[1] + fControl[0] * (fTemp3 * dsp->fVec0[15] / fTemp2);
//    dsp->fRec18[0] = fControl[1] * dsp->fRec18[1] + fControl[0] * (fTemp3 * dsp->fVec0[16] / fTemp2);
//    dsp->fRec19[0] = fControl[1] * dsp->fRec19[1] + fControl[0] * (fTemp3 * dsp->fVec0[17] / fTemp2);
//    dsp->fRec20[0] = fControl[1] * dsp->fRec20[1] + fControl[0] * (fTemp3 * dsp->fVec0[18] / fTemp2);
//    dsp->fRec21[0] = fControl[1] * dsp->fRec21[1] + fControl[0] * (fTemp3 * dsp->fVec0[19] / fTemp2);
//    dsp->fRec22[0] = fControl[1] * dsp->fRec22[1] + fControl[0] * (fTemp3 * dsp->fVec0[20] / fTemp2);
//    dsp->fRec23[0] = fControl[1] * dsp->fRec23[1] + fControl[0] * (fTemp3 * dsp->fVec0[21] / fTemp2);
//    dsp->fRec24[0] = fControl[1] * dsp->fRec24[1] + fControl[0] * (fTemp3 * dsp->fVec0[22] / fTemp2);
//    dsp->fRec25[0] = fControl[1] * dsp->fRec25[1] + fControl[0] * (fTemp3 * dsp->fVec0[23] / fTemp2);
//    dsp->fRec26[0] = fControl[1] * dsp->fRec26[1] + fControl[0] * (fTemp3 * dsp->fVec0[24] / fTemp2);
//    dsp->fRec27[0] = fControl[1] * dsp->fRec27[1] + fControl[0] * (fTemp3 * dsp->fVec0[25] / fTemp2);
//    dsp->fRec28[0] = fControl[1] * dsp->fRec28[1] + fControl[0] * (fTemp3 * dsp->fVec0[26] / fTemp2);
//    dsp->fRec29[0] = fControl[1] * dsp->fRec29[1] + fControl[0] * (fTemp3 * dsp->fVec0[27] / fTemp2);
//    dsp->fRec30[0] = fControl[1] * dsp->fRec30[1] + fControl[0] * (fTemp3 * dsp->fVec0[28] / fTemp2);
//    dsp->fRec31[0] = fControl[1] * dsp->fRec31[1] + fControl[0] * (fTemp3 * dsp->fVec0[29] / fTemp2);
//    dsp->fRec32[0] = fControl[1] * dsp->fRec32[1] + fControl[0] * (fTemp3 * dsp->fVec0[30] / fTemp2);
//    dsp->fRec33[0] = fControl[1] * dsp->fRec33[1] + fControl[0] * (fTemp3 * dsp->fVec0[31] / fTemp2);
    for (int n = 0; n < 32; ++n) {
         int m = 32-n;
         dsp->fHbargraph[n] = (FAUSTFLOAT) dsp->fRecG0[m];
    }
//    dsp->fHbargraph0 = (FAUSTFLOAT)(dsp->fRec33[0]);
//    dsp->fHbargraph1 = (FAUSTFLOAT)(dsp->fRec32[0]);
//    dsp->fHbargraph2 = (FAUSTFLOAT)(dsp->fRec31[0]);
//    dsp->fHbargraph3 = (FAUSTFLOAT)(dsp->fRec30[0]);
//    dsp->fHbargraph4 = (FAUSTFLOAT)(dsp->fRec29[0]);
//    dsp->fHbargraph5 = (FAUSTFLOAT)(dsp->fRec28[0]);
//    dsp->fHbargraph6 = (FAUSTFLOAT)(dsp->fRec27[0]);
//    dsp->fHbargraph7 = (FAUSTFLOAT)(dsp->fRec26[0]);
//    dsp->fHbargraph8 = (FAUSTFLOAT)(dsp->fRec25[0]);
//    dsp->fHbargraph9 = (FAUSTFLOAT)(dsp->fRec24[0]);
//    dsp->fHbargraph10 = (FAUSTFLOAT)(dsp->fRec23[0]);
//    dsp->fHbargraph11 = (FAUSTFLOAT)(dsp->fRec22[0]);
//    dsp->fHbargraph12 = (FAUSTFLOAT)(dsp->fRec21[0]);
//    dsp->fHbargraph13 = (FAUSTFLOAT)(dsp->fRec20[0]);
//    dsp->fHbargraph14 = (FAUSTFLOAT)(dsp->fRec19[0]);
//    dsp->fHbargraph15 = (FAUSTFLOAT)(dsp->fRec18[0]);
//    dsp->fHbargraph16 = (FAUSTFLOAT)(dsp->fRec17[0]);
//    dsp->fHbargraph17 = (FAUSTFLOAT)(dsp->fRec16[0]);
//    dsp->fHbargraph18 = (FAUSTFLOAT)(dsp->fRec15[0]);
//    dsp->fHbargraph19 = (FAUSTFLOAT)(dsp->fRec14[0]);
//    dsp->fHbargraph20 = (FAUSTFLOAT)(dsp->fRec13[0]);
//    dsp->fHbargraph21 = (FAUSTFLOAT)(dsp->fRec12[0]);
//    dsp->fHbargraph22 = (FAUSTFLOAT)(dsp->fRec11[0]);
//    dsp->fHbargraph23 = (FAUSTFLOAT)(dsp->fRec10[0]);
//    dsp->fHbargraph24 = (FAUSTFLOAT)(dsp->fRec9[0]);
//    dsp->fHbargraph25 = (FAUSTFLOAT)(dsp->fRec8[0]);
//    dsp->fHbargraph26 = (FAUSTFLOAT)(dsp->fRec7[0]);
//    dsp->fHbargraph27 = (FAUSTFLOAT)(dsp->fRec6[0]);
//    dsp->fHbargraph28 = (FAUSTFLOAT)(dsp->fRec5[0]);
//    dsp->fHbargraph29 = (FAUSTFLOAT)(dsp->fRec4[0]);
//    dsp->fHbargraph30 = (FAUSTFLOAT)(dsp->fRec3[0]);
//    dsp->fHbargraph31 = (FAUSTFLOAT)(dsp->fRec2[0]);
    float fTemp56 = dsp->fHbargraph[31] * fTemp0;

    for (int n = 1; n < 32; ++n) {
         int m = 31-n;
         fTemp56 += dsp->fHbargraph[m] * dsp->fVec0[n];
    }

    fTemp56 *= dsp->fConst4;

    outputs[0] = fTemp56;
//    outputs[0] = (FAUSTFLOAT)(dsp->fConst4 * (dsp->fHbargraph31 * fTemp0 + dsp->fHbargraph30 * dsp->fVec0[1] + dsp->fHbargraph29 * dsp->fVec0[2] + dsp->fHbargraph28 * dsp->fVec0[3] + dsp->fHbargraph27 * dsp->fVec0[4] + dsp->fHbargraph26 * dsp->fVec0[5] + dsp->fHbargraph25 * dsp->fVec0[6] + dsp->fHbargraph24 * dsp->fVec0[7] + dsp->fHbargraph23 * dsp->fVec0[8] + dsp->fHbargraph22 * dsp->fVec0[9] + dsp->fHbargraph21 * dsp->fVec0[10] + dsp->fHbargraph20 * dsp->fVec0[11] + dsp->fHbargraph19 * dsp->fVec0[12] + dsp->fHbargraph18 * dsp->fVec0[13] + dsp->fHbargraph17 * dsp->fVec0[14] + dsp->fHbargraph16 * dsp->fVec0[15] + dsp->fHbargraph15 * dsp->fVec0[16] + dsp->fHbargraph14 * dsp->fVec0[17] + dsp->fHbargraph13 * dsp->fVec0[18] + dsp->fHbargraph12 * dsp->fVec0[19] + dsp->fHbargraph11 * dsp->fVec0[20] + dsp->fHbargraph10 * dsp->fVec0[21] + dsp->fHbargraph9 * dsp->fVec0[22] + dsp->fHbargraph8 * dsp->fVec0[23] + dsp->fHbargraph7 * dsp->fVec0[24] + dsp->fHbargraph6 * dsp->fVec0[25] + dsp->fHbargraph5 * dsp->fVec0[26] + dsp->fHbargraph4 * dsp->fVec0[27] + dsp->fHbargraph3 * dsp->fVec0[28] + dsp->fHbargraph2 * dsp->fVec0[29] + dsp->fHbargraph1 * dsp->fVec0[30] + dsp->fHbargraph0 * dsp->fVec0[31]));
    outputs[1] = (FAUSTFLOAT)(fTemp1);
    dsp->iRec1[1] = dsp->iRec1[0];
    dsp->fRec0[2] = dsp->fRec0[1];
    dsp->fRec0[1] = dsp->fRec0[0];
    /* C99 loop */
    {
        int j0;
        for (j0 = 31; j0 > 0; j0 = j0 - 1) {
            dsp->fVec0[j0] = dsp->fVec0[j0 - 1];
        }
    }
    for (int n = 0; n < 32; ++n) {
        dsp->fRecG1[n] = dsp->fRecG0[n];
    }
//    dsp->fRec2[1] = dsp->fRec2[0];
//    dsp->fRec3[1] = dsp->fRec3[0];
//    dsp->fRec4[1] = dsp->fRec4[0];
//    dsp->fRec5[1] = dsp->fRec5[0];
//    dsp->fRec6[1] = dsp->fRec6[0];
//    dsp->fRec7[1] = dsp->fRec7[0];
//    dsp->fRec8[1] = dsp->fRec8[0];
//    dsp->fRec9[1] = dsp->fRec9[0];
//    dsp->fRec10[1] = dsp->fRec10[0];
//    dsp->fRec11[1] = dsp->fRec11[0];
//    dsp->fRec12[1] = dsp->fRec12[0];
//    dsp->fRec13[1] = dsp->fRec13[0];
//    dsp->fRec14[1] = dsp->fRec14[0];
//    dsp->fRec15[1] = dsp->fRec15[0];
//    dsp->fRec16[1] = dsp->fRec16[0];
//    dsp->fRec17[1] = dsp->fRec17[0];
//    dsp->fRec18[1] = dsp->fRec18[0];
//    dsp->fRec19[1] = dsp->fRec19[0];
//    dsp->fRec20[1] = dsp->fRec20[0];
//    dsp->fRec21[1] = dsp->fRec21[0];
//    dsp->fRec22[1] = dsp->fRec22[0];
//    dsp->fRec23[1] = dsp->fRec23[0];
//    dsp->fRec24[1] = dsp->fRec24[0];
//    dsp->fRec25[1] = dsp->fRec25[0];
//    dsp->fRec26[1] = dsp->fRec26[0];
//    dsp->fRec27[1] = dsp->fRec27[0];
//    dsp->fRec28[1] = dsp->fRec28[0];
//    dsp->fRec29[1] = dsp->fRec29[0];
//    dsp->fRec30[1] = dsp->fRec30[0];
//    dsp->fRec31[1] = dsp->fRec31[0];
//    dsp->fRec32[1] = dsp->fRec32[0];
//    dsp->fRec33[1] = dsp->fRec33[0];
}

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 2

#define FAUST_INT_ZONE 0
#define FAUST_FLOAT_ZONE 3

#endif // TESTBENCH


#ifdef FAUST_UIMACROS

    #define FAUST_FILE_NAME "NLMSTestToRoundtripOnFPGA.dsp"
    #define FAUST_CLASS_NAME "mydsp"
    #define FAUST_COMPILATION_OPIONS "-a /home/pierre/Repositories/syfala/dev-arch/source/rtl/hls/faust_dsp_template.cpp -lang c -os2 -light -es 1 -mcd 128 -uim -single -ftz 0"
    #define FAUST_INPUTS 2
    #define FAUST_OUTPUTS 2
    #define FAUST_ACTIVES 3
    #define FAUST_PASSIVES 32

    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph1, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph2, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph3, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph4, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph5, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph6, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph7, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph8, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph9, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph10, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph11, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph12, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph13, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph14, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph15, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph16, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph17, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph18, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph19, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph20, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph21, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph22, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph23, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph24, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph25, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph26, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph27, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph28, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph29, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph30, -5.0f, 5.0f);
    FAUST_ADDHORIZONTALBARGRAPH("", fHbargraph31, -5.0f, 5.0f);
    FAUST_ADDCHECKBOX("Adaption on/off", fCheckbox0);
    FAUST_ADDBUTTON("Reset", fButton0);
    FAUST_ADDNUMENTRY("mu", fEntry0, 0.0001f, 1e-07f, 1.0f, 1e-07f);

    #define FAUST_LIST_ACTIVES(p) \
        p(CHECKBOX, Adaption_on/off, "Adaption on/off", fCheckbox0, 0.0f, 0.0f, 1.0f, 1.0f) \
        p(BUTTON, Reset, "Reset", fButton0, 0.0f, 0.0f, 1.0f, 1.0f) \
        p(NUMENTRY, mu, "mu", fEntry0, 0.0001f, 1e-07f, 1.0f, 1e-07f) \

    #define FAUST_LIST_PASSIVES(p) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph0, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph1, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph2, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph3, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph4, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph5, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph6, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph7, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph8, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph9, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph10, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph11, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph12, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph13, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph14, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph15, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph16, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph17, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph18, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph19, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph20, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph21, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph22, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph23, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph24, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph25, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph26, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph27, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph28, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph29, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph30, 0.0, -5.0f, 5.0f, 0.0) \
        p(HORIZONTALBARGRAPH, , "", fHbargraph31, 0.0, -5.0f, 5.0f, 0.0) \

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

static bool cycle_1 = true;

// DSP struct
static mydsp DSP;

static int N_min = min(FAUST_INPUTS, FAUST_OUTPUTS);
static int N_max = max(FAUST_INPUTS, FAUST_OUTPUTS);
static int N0    = N_max - N_min;

// ----------------------------------------------------------------------------
// HLS TOP-LEVEL FUNCTION
// ----------------------------------------------------------------------------

void syfala (
     sy_ap_int audio_in_0,
     sy_ap_int audio_in_1,
    sy_ap_int* audio_out_0,
    sy_ap_int* audio_out_1,
         float arm_control_f[2],
           int arm_control_i[2],
         float arm_control_p[32],
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
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    sy_real_t* ffp = reinterpret_cast<sy_real_t*>(mem_zone_f);

    /* Allocate 'inputs' and 'outputs' for 'compute' method */
#if FAUST_INPUTS
    static sy_real_t inputs[FAUST_INPUTS];
    inputs[0] = audio_in_0.to_float() / SCALE_FACTOR;
    inputs[1] = audio_in_1.to_float() / SCALE_FACTOR;
#endif
    static sy_real_t outputs[FAUST_OUTPUTS];
    for (int n = 0; n < FAUST_OUTPUTS; ++n)
         outputs[n] = 0.f;
    /* RAM must be enabled by ARM before any computation */
    if (arm_ok) {
        if (cycle_1) {
            /* first iteration: constant initialization */
        #if SYFALA_MEMORY_USE_DDR // -------------------------------------------------------
            /* from values initialised in DDR */
            instanceConstantsFromMemmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, ffp);
        #else
            /* directly on the FPGA */
            staticInitmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
            instanceConstantsmydsp(&DSP, SYFALA_SAMPLE_RATE, mem_zone_i, mem_zone_f);
        #endif // --------------------------------------------------------------------------
            cycle_1 = false;
        } else {
            /* All other iterations:
             * - update controllers values from IP ports
             * - compute one sample
             * - write back passive controller values */
            if (*control_block == SYFALA_CONTROL_RELEASE) {
                *control_block =  SYFALA_CONTROL_BLOCK_FPGA;
                copy_control(arm_control_f, arm_control_i, control_f, control_i);
                *control_block =  SYFALA_CONTROL_RELEASE;
            }
        #if FAUST_INPUTS
            computemydsp(&DSP, inputs, outputs, control_i, control_f, mem_zone_i, ffp);
        #else
            computemydsp(&DSP, 0, outputs, control_i, control_f, mem_zone_i, ffp);
        #endif

        #if FAUST_PASSIVES // --------
            write(DSP, arm_control_p);
        #endif // --------------------
        }
    } else {
        /* if memory is not fully initialized, make a simple bypass */
    #if FAUST_INPUTS // ---------------------------------------------
        for (int n = 0; n < N_min; ++n)
             outputs[n] = inputs[n];
    #endif // -------------------------------------------------------
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
        *audio_out_0 = sy_ap_int(outputs[0] * SCALE_FACTOR);
        *audio_out_1 = sy_ap_int(outputs[1] * SCALE_FACTOR);
    }
}

#endif




