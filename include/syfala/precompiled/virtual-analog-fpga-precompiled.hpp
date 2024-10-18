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

typedef struct {
    int iVec0[2];
    FAUSTFLOAT fHslider0;
    int fSampleRate;
    float fConst0;
    float fConst1;
    float fRec0[2];
    float fConst2;
    float fConst3;
    FAUSTFLOAT fHslider1;
    float fRec1[2];
    float fConst4;
    int iRec3[2];
    FAUSTFLOAT fHslider2;
    FAUSTFLOAT fButton0;
    FAUSTFLOAT fHslider3;
    float fRec4[2];
    float fConst6;
    float fConst7;
    float fRec6[2];
    float fRec7[2];
    FAUSTFLOAT fButton1;
    float fRec2[3];
    FAUSTFLOAT fHslider4;
    float fRec8[2];
    FAUSTFLOAT fHslider5;
} mydsp;


void instanceConstantsFromMemmydsp(mydsp* dsp, int sample_rate, int* RESTRICT iZone, float* RESTRICT fZone) {
    dsp->fConst0 = fZone[0];
    dsp->fConst1 = fZone[1];
    dsp->fConst2 = fZone[2];
    dsp->fConst3 = fZone[3];
    dsp->fConst4 = fZone[4];
    dsp->fConst6 = fZone[5];
    dsp->fConst7 = fZone[6];
}

void framemydsp(mydsp* dsp, FAUSTFLOAT* RESTRICT inputs, FAUSTFLOAT* RESTRICT outputs, int* RESTRICT iControl, FAUSTFLOAT* RESTRICT fControl, int* RESTRICT iZone, FAUSTFLOAT* RESTRICT fZone) {
    dsp->iVec0[0] = 1;
    int iTemp0 = 1 - dsp->iVec0[1];
    float fTemp1 = ((iTemp0) ? 0.0f : fControl[0] + dsp->fRec0[1]);
    dsp->fRec0[0] = fTemp1 - floorf(fTemp1);
    float fTemp2 = 1.0f - fabsf(2.0f * dsp->fRec0[0] + -1.0f);
    dsp->fRec1[0] = fControl[1] + dsp->fConst3 * dsp->fRec1[1];
    float fTemp3 = tanf(dsp->fConst4 * (dsp->fRec1[0] * fTemp2 + 5e+01f));
    float fTemp4 = (1.0f / fTemp3 + 0.2f) / fTemp3 + 1.0f;
    float fTemp5 = tanf(dsp->fConst4 * (0.5f * dsp->fRec1[0] * (2.0f * fTemp2 + -1.0f + 1.0f) + 5e+01f));
    float fTemp6 = 1.0f / fTemp5;
    dsp->iRec3[0] = 1103515245 * dsp->iRec3[1] + 12345;
    float fTemp7 = fControl[4] + dsp->fRec4[1] + -1.0f;
    int iTemp8 = fTemp7 < 0.0f;
    float fTemp9 = fControl[4] + dsp->fRec4[1];
    dsp->fRec4[0] = ((iTemp8) ? fTemp9 : fTemp7);
    float fRec5 = ((iTemp8) ? fTemp9 : fControl[4] + dsp->fRec4[1] + fControl[5] * fTemp7);
    dsp->fRec6[0] = dsp->fConst7 * dsp->fRec7[1] + dsp->fConst6 * dsp->fRec6[1];
    dsp->fRec7[0] = (float)(iTemp0) + dsp->fConst6 * dsp->fRec7[1] - dsp->fConst7 * dsp->fRec6[1];
    dsp->fRec2[0] = fControl[6] * dsp->fRec7[0] * (2.0f * fRec5 + -1.0f) + fControl[2] * (float)(dsp->iRec3[0]) - (dsp->fRec2[2] * ((fTemp6 + -0.2f) / fTemp5 + 1.0f) + 2.0f * dsp->fRec2[1] * (1.0f - 1.0f / mydsp_faustpower2_f(fTemp5))) / ((fTemp6 + 0.2f) / fTemp5 + 1.0f);
    float fTemp10 = dsp->fRec2[2] + dsp->fRec2[0] + 2.0f * dsp->fRec2[1];
    dsp->fRec8[0] = fControl[7] + dsp->fConst3 * dsp->fRec8[1];
    outputs[0] = (FAUSTFLOAT)(fControl[8] * ((1.0f - dsp->fRec8[0]) * fTemp10 / fTemp4));
    outputs[1] = (FAUSTFLOAT)(fControl[8] * (dsp->fRec8[0] * fTemp10 / fTemp4));
    dsp->iVec0[1] = dsp->iVec0[0];
    dsp->fRec0[1] = dsp->fRec0[0];
    dsp->fRec1[1] = dsp->fRec1[0];
    dsp->iRec3[1] = dsp->iRec3[0];
    dsp->fRec4[1] = dsp->fRec4[0];
    dsp->fRec6[1] = dsp->fRec6[0];
    dsp->fRec7[1] = dsp->fRec7[0];
    dsp->fRec2[2] = dsp->fRec2[1];
    dsp->fRec2[1] = dsp->fRec2[0];
    dsp->fRec8[1] = dsp->fRec8[0];
}

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 9

#define FAUST_INT_ZONE 0
#define FAUST_FLOAT_ZONE 7

#ifdef FAUST_UIMACROS

#define FAUST_FILE_NAME "virtualAnalog.dsp"
#define FAUST_CLASS_NAME "mydsp"
#define FAUST_COMPILATION_OPIONS "-a /home/pierre/Repositories/syfala/dev-fvector/source/rtl/hls/faust_dsp_template.cpp -lang c -fpga-mem 10000 -os -mem3 -it -ec -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -uim -single -ftz 0"
#define FAUST_INPUTS 0
#define FAUST_OUTPUTS 2
#define FAUST_ACTIVES 8
#define FAUST_PASSIVES 0

FAUST_ADDBUTTON("activateNoise", fButton0);
FAUST_ADDBUTTON("killSwitch", fButton1);
FAUST_ADDHORIZONTALSLIDER("lfoFreq", fHslider0, 1.0f, 0.01f, 8.0f, 0.01f);
FAUST_ADDHORIZONTALSLIDER("lfoRange", fHslider1, 1e+03f, 1e+01f, 5e+03f, 0.01f);
FAUST_ADDHORIZONTALSLIDER("masterVol", fHslider5, 0.8f, 0.0f, 1.0f, 0.01f);
FAUST_ADDHORIZONTALSLIDER("noiseGain", fHslider2, 0.0f, 0.0f, 1.0f, 0.01f);
FAUST_ADDHORIZONTALSLIDER("oscFreq", fHslider3, 8e+01f, 5e+01f, 5e+02f, 0.01f);
FAUST_ADDHORIZONTALSLIDER("pan", fHslider4, 0.5f, 0.0f, 1.0f, 0.01f);

#define FAUST_LIST_ACTIVES(p) \
p(BUTTON, activateNoise, "activateNoise", fButton0, 0.0f, 0.0f, 1.0f, 1.0f) \
    p(BUTTON, killSwitch, "killSwitch", fButton1, 0.0f, 0.0f, 1.0f, 1.0f) \
    p(HORIZONTALSLIDER, lfoFreq, "lfoFreq", fHslider0, 1.0f, 0.01f, 8.0f, 0.01f) \
    p(HORIZONTALSLIDER, lfoRange, "lfoRange", fHslider1, 1e+03f, 1e+01f, 5e+03f, 0.01f) \
    p(HORIZONTALSLIDER, masterVol, "masterVol", fHslider5, 0.8f, 0.0f, 1.0f, 0.01f) \
    p(HORIZONTALSLIDER, noiseGain, "noiseGain", fHslider2, 0.0f, 0.0f, 1.0f, 0.01f) \
    p(HORIZONTALSLIDER, oscFreq, "oscFreq", fHslider3, 8e+01f, 5e+01f, 5e+02f, 0.01f) \
    p(HORIZONTALSLIDER, pan, "pan", fHslider4, 0.5f, 0.0f, 1.0f, 0.01f) \

#define FAUST_LIST_PASSIVES(p) \

#endif

#ifdef __cplusplus
}
#endif
