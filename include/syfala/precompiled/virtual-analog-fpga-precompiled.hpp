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
  FAUSTFLOAT fHslider0;
  int fSampleRate;
  float fConst0;
  float fConst1;
  FAUSTFLOAT fHslider1;
  float fConst2;
  int IOTA0;
  int iVec0[2];
  float fRec0[2];
  FAUSTFLOAT fButton0;
  float fConst4;
  float fConst5;
  float fRec2[2];
  float fRec3[2];
  float fConst6;
  FAUSTFLOAT fHslider2;
  float fRec4[2];
  FAUSTFLOAT fButton1;
  FAUSTFLOAT fHslider3;
  int iRec6[2];
  float fConst7;
  FAUSTFLOAT fHslider4;
  float fRec7[2];
  FAUSTFLOAT fHslider5;
  float fRec8[2];
  float fRec1[4];
} mydsp;

#ifndef TESTBENCH

int getSampleRatemydsp(mydsp* dsp) {
  return dsp->fSampleRate;
}

int getNumInputsmydsp(mydsp* dsp) {
  return 0;
}
int getNumOutputsmydsp(mydsp* dsp) {
  return 2;
}

void classInitmydsp(int sample_rate) {}

void staticInitmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
}

void instanceResetUserInterfacemydsp(mydsp* dsp) {
  dsp->fHslider0 = (FAUSTFLOAT)(0.80000000000000004f);
  dsp->fHslider1 = (FAUSTFLOAT)(0.5f);
  dsp->fButton0 = (FAUSTFLOAT)(0.0f);
  dsp->fHslider2 = (FAUSTFLOAT)(80.0f);
  dsp->fButton1 = (FAUSTFLOAT)(0.0f);
  dsp->fHslider3 = (FAUSTFLOAT)(0.0f);
  dsp->fHslider4 = (FAUSTFLOAT)(1000.0f);
  dsp->fHslider5 = (FAUSTFLOAT)(1.0f);
}

void instanceClearmydsp(mydsp* dsp, int* iZone, float* fZone) {
  dsp->IOTA0 = 0;
  /* C99 loop */
  {
      int l0;
      for (l0 = 0; l0 < 2; l0 = l0 + 1) {
            dsp->iVec0[l0] = 0;
          }
    }
  /* C99 loop */
  {
      int l1;
      for (l1 = 0; l1 < 2; l1 = l1 + 1) {
            dsp->fRec0[l1] = 0.0f;
          }
    }
  /* C99 loop */
  {
      int l2;
      for (l2 = 0; l2 < 2; l2 = l2 + 1) {
            dsp->fRec2[l2] = 0.0f;
          }
    }
  /* C99 loop */
  {
      int l3;
      for (l3 = 0; l3 < 2; l3 = l3 + 1) {
            dsp->fRec3[l3] = 0.0f;
          }
    }
  /* C99 loop */
  {
      int l4;
      for (l4 = 0; l4 < 2; l4 = l4 + 1) {
            dsp->fRec4[l4] = 0.0f;
          }
    }
  /* C99 loop */
  {
      int l5;
      for (l5 = 0; l5 < 2; l5 = l5 + 1) {
            dsp->iRec6[l5] = 0;
          }
    }
  /* C99 loop */
  {
      int l6;
      for (l6 = 0; l6 < 2; l6 = l6 + 1) {
            dsp->fRec7[l6] = 0.0f;
          }
    }
  /* C99 loop */
  {
      int l7;
      for (l7 = 0; l7 < 2; l7 = l7 + 1) {
            dsp->fRec8[l7] = 0.0f;
          }
    }
  /* C99 loop */
  {
      int l8;
      for (l8 = 0; l8 < 4; l8 = l8 + 1) {
            dsp->fRec1[l8] = 0.0f;
          }
    }
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
  dsp->fSampleRate = sample_rate;
  dsp->fConst0 = fminf(192000.0f, fmaxf(1.0f, (float)(dsp->fSampleRate)));
  dsp->fConst1 = 44.0999985f / dsp->fConst0;
  dsp->fConst2 = 1.0f - dsp->fConst1;
  float fConst3 = 2764.60156f / dsp->fConst0;
  dsp->fConst4 = sinf(fConst3);
  dsp->fConst5 = cosf(fConst3);
  dsp->fConst6 = 1.0f / dsp->fConst0;
  dsp->fConst7 = 3.14159274f / dsp->fConst0;
}

void instanceConstantsFromMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
  dsp->fSampleRate = sample_rate;
  dsp->fConst0 = fZone[0];
  dsp->fConst1 = fZone[1];
  dsp->fConst2 = fZone[2];
  dsp->fConst4 = fZone[3];
  dsp->fConst5 = fZone[4];
  dsp->fConst6 = fZone[5];
  dsp->fConst7 = fZone[6];
}

void instanceConstantsToMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
  dsp->fSampleRate = sample_rate;
  fZone[0] = dsp->fConst0;
  fZone[1] = dsp->fConst1;
  fZone[2] = dsp->fConst2;
  fZone[3] = dsp->fConst4;
  fZone[4] = dsp->fConst5;
  fZone[5] = dsp->fConst6;
  fZone[6] = dsp->fConst7;
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
  fControl[0] = mydsp_faustpower2_f((float)(dsp->fHslider0));
  fControl[1] = dsp->fConst1 * (float)(dsp->fHslider1);
  fControl[2] = 0.25f * (1.0f - (float)(dsp->fButton0));
  fControl[3] = fmaxf(1.1920929e-07f, fabsf((float)(dsp->fHslider2)));
  fControl[4] = dsp->fConst6 * fControl[3];
  fControl[5] = 1.0f - dsp->fConst0 / fControl[3];
  fControl[6] = 4.65661287e-10f * (float)(dsp->fButton1) * mydsp_faustpower2_f((float)(dsp->fHslider3));
  fControl[7] = dsp->fConst1 * (float)(dsp->fHslider4);
  fControl[8] = dsp->fConst6 * (float)(dsp->fHslider5);
}

int getNumIntControlsmydsp(mydsp* dsp) { return 0; }
int getNumRealControlsmydsp(mydsp* dsp) { return 9; }

int getiZoneSizemydsp(mydsp* dsp) { return 0; }
int getfZoneSizemydsp(mydsp* dsp) { return 7; }

void computemydsp(mydsp* dsp, float* RESTRICT inputs, float* RESTRICT outputs, int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
  dsp->iVec0[dsp->IOTA0 & 1] = 1;
  dsp->fRec0[dsp->IOTA0 & 1] = fControl[1] + dsp->fConst2 * dsp->fRec0[(dsp->IOTA0 - 1) & 1];
  float fTemp0 = dsp->fRec0[dsp->IOTA0 & 1];
  float fTemp1 = dsp->fRec3[(dsp->IOTA0 - 1) & 1];
  float fTemp2 = dsp->fRec2[(dsp->IOTA0 - 1) & 1];
  dsp->fRec2[dsp->IOTA0 & 1] = dsp->fConst4 * fTemp1 + dsp->fConst5 * fTemp2;
  dsp->fRec3[dsp->IOTA0 & 1] = ((float)(1 - dsp->iVec0[(dsp->IOTA0 - 1) & 1]) + dsp->fConst5 * fTemp1) - dsp->fConst4 * fTemp2;
  float fTemp3 = dsp->fRec4[(dsp->IOTA0 - 1) & 1];
  float fTemp4 = fControl[4] + fTemp3 + -1.0f;
  int iTemp5 = fTemp4 < 0.0f;
  float fTemp6 = fControl[4] + fTemp3;
  dsp->fRec4[dsp->IOTA0 & 1] = ((iTemp5) ? fTemp6 : fTemp4);
  float fThen1 = fControl[4] + fTemp3 + fControl[5] * fTemp4;
  float fRec5 = ((iTemp5) ? fTemp6 : fThen1);
  dsp->iRec6[dsp->IOTA0 & 1] = 1103515245 * dsp->iRec6[(dsp->IOTA0 - 1) & 1] + 12345;
  float fTemp7 = dsp->fRec1[(dsp->IOTA0 - 2) & 3];
  dsp->fRec7[dsp->IOTA0 & 1] = fControl[7] + dsp->fConst2 * dsp->fRec7[(dsp->IOTA0 - 1) & 1];
  float fTemp8 = dsp->fRec8[(dsp->IOTA0 - 1) & 1];
  dsp->fRec8[dsp->IOTA0 & 1] = fControl[8] + fTemp8 - floorf(fControl[8] + fTemp8);
  float fTemp9 = tanf(dsp->fConst7 * (0.5f * dsp->fRec7[dsp->IOTA0 & 1] * (2.0f * (1.0f - fabsf(2.0f * dsp->fRec8[dsp->IOTA0 & 1] + -1.0f)) + -1.0f + 1.0f) + 50.0f));
  float fTemp10 = 1.0f / fTemp9;
  float fTemp11 = dsp->fRec1[(dsp->IOTA0 - 1) & 3];
  float fTemp12 = (fTemp10 + 0.200000003f) / fTemp9 + 1.0f;
  dsp->fRec1[dsp->IOTA0 & 3] = (fControl[2] * dsp->fRec3[dsp->IOTA0 & 1] * (2.0f * fRec5 + -1.0f) + fControl[6] * (float)(dsp->iRec6[dsp->IOTA0 & 1])) - (fTemp7 * ((fTemp10 + -0.200000003f) / fTemp9 + 1.0f) + 2.0f * fTemp11 * (1.0f - 1.0f / mydsp_faustpower2_f(fTemp9))) / fTemp12;
  float fTemp13 = fTemp7 + dsp->fRec1[dsp->IOTA0 & 3] + 2.0f * fTemp11;
  outputs[0] = (FAUSTFLOAT)(fControl[0] * ((1.0f - fTemp0) * fTemp13) / fTemp12);
  outputs[1] = (FAUSTFLOAT)(fControl[0] * (fTemp0 * fTemp13) / fTemp12);
  dsp->IOTA0 = dsp->IOTA0 + 1;
}

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 9

#define FAUST_INT_ZONE 0
#define FAUST_FLOAT_ZONE 7

#endif // TESTBENCH

#ifdef FAUST_UIMACROS

    #define FAUST_FILE_NAME "virtualAnalog.dsp"
    #define FAUST_CLASS_NAME "mydsp"
    #define FAUST_COMPILATION_OPIONS "-a /home/pierre/Repositories/syfala-v7/build/sources/fpga.cpp -lang c -os2 -light -es 1 -mcd 0 -uim -single -ftz 0"
    #define FAUST_INPUTS 0
    #define FAUST_OUTPUTS 2
    #define FAUST_ACTIVES 8
    #define FAUST_PASSIVES 0

    FAUST_ADDBUTTON("activateNoise", fButton1);
    FAUST_ADDBUTTON("killSwitch", fButton0);
    FAUST_ADDHORIZONTALSLIDER("lfoFreq", fHslider5, 1.0f, 0.01f, 8.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("lfoRange", fHslider4, 1000.0f, 10.0f, 5000.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("masterVol", fHslider0, 0.80000000000000004f, 0.0f, 1.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("noiseGain", fHslider3, 0.0f, 0.0f, 1.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("oscFreq", fHslider2, 80.0f, 50.0f, 500.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("pan", fHslider1, 0.5f, 0.0f, 1.0f, 0.01f);

    #define FAUST_LIST_ACTIVES(p) \
        p(BUTTON, activateNoise, "activateNoise", fButton1, 0.0f, 0.0f, 1.0f, 1.0f) \
        p(BUTTON, killSwitch, "killSwitch", fButton0, 0.0f, 0.0f, 1.0f, 1.0f) \
        p(HORIZONTALSLIDER, lfoFreq, "lfoFreq", fHslider5, 1.0f, 0.01f, 8.0f, 0.01f) \
        p(HORIZONTALSLIDER, lfoRange, "lfoRange", fHslider4, 1000.0f, 10.0f, 5000.0f, 0.01f) \
        p(HORIZONTALSLIDER, masterVol, "masterVol", fHslider0, 0.80000000000000004f, 0.0f, 1.0f, 0.01f) \
        p(HORIZONTALSLIDER, noiseGain, "noiseGain", fHslider3, 0.0f, 0.0f, 1.0f, 0.01f) \
        p(HORIZONTALSLIDER, oscFreq, "oscFreq", fHslider2, 80.0f, 50.0f, 500.0f, 0.01f) \
        p(HORIZONTALSLIDER, pan, "pan", fHslider1, 0.5f, 0.0f, 1.0f, 0.01f) \

    #define FAUST_LIST_PASSIVES(p) \

#endif
#ifdef __cplusplus
}
#endif
