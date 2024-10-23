    // The Faust compiler will insert the C code here
#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <math.h>

#ifndef FAUSTCLASS
#define FAUSTCLASS mydsp
#endif

#ifdef __APPLE__
#define exp10f __exp10f
#define exp10 __exp10
#endif

#if defined(_WIN32)
#define RESTRICT __restrict
#else
#define RESTRICT __restrict__
#endif

static float mydsp_faustpower2_f(float value) {
    return value * value;
}

class mydsp : public dsp {

public:

    FAUSTFLOAT fHslider0;
    int fSampleRate;
    float fConst0;
    float fConst1;
    float fConst2;
    float fConst3;
    FAUSTFLOAT fHslider1;
    float fConst4;
    FAUSTFLOAT fHslider2;
    FAUSTFLOAT fButton0;
    FAUSTFLOAT fHslider3;
    float fConst6;
    float fConst7;
    FAUSTFLOAT fButton1;
    FAUSTFLOAT fHslider4;
    FAUSTFLOAT fHslider5;
    float* fControl;
    int* iZone;
    float* fZone;

public:

    mydsp() {
        fControl = nullptr;
        iZone = nullptr;
        fZone = nullptr;
    }
    mydsp(int* icontrol, float* fcontrol, int* izone, float* fzone) {
        fControl = fcontrol;
        iZone = izone;
        fZone = fzone;
    }
    void setMemory(int* icontrol, float* fcontrol, int* izone, float* fzone) {
        fControl = fcontrol;
        iZone = izone;
        fZone = fzone;
    }

    void metadata(Meta* m) {
        m->declare("compile_options", "-a include/syfala/arm/faust/control.hpp -lang cpp -os -mem2 -it -ec -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -uim -single -ftz 0");
        m->declare("filename", "virtualAnalog.dsp");
        m->declare("filters.lib/fir:author", "Julius O. Smith III");
        m->declare("filters.lib/fir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/fir:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/iir:author", "Julius O. Smith III");
        m->declare("filters.lib/iir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/iir:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/lowpass0_highpass1", "MIT-style STK-4.3 license");
        m->declare("filters.lib/name", "Faust Filters Library");
        m->declare("filters.lib/nlf2:author", "Julius O. Smith III");
        m->declare("filters.lib/nlf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/nlf2:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/resonlp:author", "Julius O. Smith III");
        m->declare("filters.lib/resonlp:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/resonlp:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/tf2:author", "Julius O. Smith III");
        m->declare("filters.lib/tf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/tf2:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/tf2s:author", "Julius O. Smith III");
        m->declare("filters.lib/tf2s:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/tf2s:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/version", "1.3.0");
        m->declare("maths.lib/author", "GRAME");
        m->declare("maths.lib/copyright", "GRAME");
        m->declare("maths.lib/license", "LGPL with exception");
        m->declare("maths.lib/name", "Faust Math Library");
        m->declare("maths.lib/version", "2.8.0");
        m->declare("name", "virtualAnalog");
        m->declare("noises.lib/name", "Faust Noise Generator Library");
        m->declare("noises.lib/version", "1.4.1");
        m->declare("oscillators.lib/lf_sawpos:author", "Bart Brouns, revised by Stéphane Letz");
            m->declare("oscillators.lib/lf_sawpos:licence", "STK-4.3");
        m->declare("oscillators.lib/lf_triangle:author", "Bart Brouns");
        m->declare("oscillators.lib/lf_triangle:licence", "STK-4.3");
        m->declare("oscillators.lib/name", "Faust Oscillator Library");
        m->declare("oscillators.lib/saw1:author", "Bart Brouns");
        m->declare("oscillators.lib/saw1:licence", "STK-4.3");
        m->declare("oscillators.lib/saw2ptr:author", "Julius O. Smith III");
        m->declare("oscillators.lib/saw2ptr:license", "STK-4.3");
        m->declare("oscillators.lib/version", "1.5.0");
        m->declare("platform.lib/name", "Generic Platform Library");
        m->declare("platform.lib/version", "1.3.0");
        m->declare("signals.lib/name", "Faust Signal Routing Library");
        m->declare("signals.lib/version", "1.5.0");
    }

    virtual int getNumInputs() {
        return 0;
    }
    virtual int getNumOutputs() {
        return 2;
    }

    static void classInit(int sample_rate) {}

    void staticInit(int sample_rate) {
    }

    static void classDestroy() {
    }

    virtual void instanceConstants(int sample_rate) {
        fSampleRate = sample_rate;
        fConst0 = std::min<float>(1.92e+05f, std::max<float>(1.0f, float(fSampleRate)));
        fConst1 = 1.0f / fConst0;
        fConst2 = 44.1f / fConst0;
        fConst3 = 1.0f - fConst2;
        fConst4 = 3.1415927f / fConst0;
        float fConst5 = 2764.6016f / fConst0;
        fConst6 = std::cos(fConst5);
        fConst7 = std::sin(fConst5);
    }

    virtual void instanceConstantsFromMem(int sample_rate) {
        fConst0 = fZone[15];
        fConst1 = fZone[16];
        fConst2 = fZone[17];
        fConst3 = fZone[18];
        fConst4 = fZone[19];
        fConst6 = fZone[20];
        fConst7 = fZone[21];
    }

    virtual void instanceConstantsToMem(int sample_rate) {
        fZone[15] = fConst0;
        fZone[16] = fConst1;
        fZone[17] = fConst2;
        fZone[18] = fConst3;
        fZone[19] = fConst4;
        fZone[20] = fConst6;
        fZone[21] = fConst7;
    }

    virtual void instanceResetUserInterface() {
        fHslider0 = FAUSTFLOAT(1.0f);
        fHslider1 = FAUSTFLOAT(1e+03f);
        fHslider2 = FAUSTFLOAT(0.0f);
        fButton0 = FAUSTFLOAT(0.0f);
        fHslider3 = FAUSTFLOAT(8e+01f);
        fButton1 = FAUSTFLOAT(0.0f);
        fHslider4 = FAUSTFLOAT(0.5f);
        fHslider5 = FAUSTFLOAT(0.8f);
    }

    virtual void instanceClear() {
        for (int l0 = 0; l0 < 2; l0 = l0 + 1) {
            iZone[l0] = 0;
        }
        for (int l1 = 0; l1 < 2; l1 = l1 + 1) {
            fZone[l1] = 0.0f;
        }
        for (int l2 = 0; l2 < 2; l2 = l2 + 1) {
            fZone[2 + l2] = 0.0f;
        }
        for (int l3 = 0; l3 < 2; l3 = l3 + 1) {
            iZone[2 + l3] = 0;
        }
        for (int l4 = 0; l4 < 2; l4 = l4 + 1) {
            fZone[4 + l4] = 0.0f;
        }
        for (int l5 = 0; l5 < 2; l5 = l5 + 1) {
            fZone[6 + l5] = 0.0f;
        }
        for (int l6 = 0; l6 < 2; l6 = l6 + 1) {
            fZone[8 + l6] = 0.0f;
        }
        for (int l7 = 0; l7 < 3; l7 = l7 + 1) {
            fZone[10 + l7] = 0.0f;
        }
        for (int l8 = 0; l8 < 2; l8 = l8 + 1) {
            fZone[13 + l8] = 0.0f;
        }
    }

    virtual void init(int sample_rate) {}

    virtual void instanceInit(int sample_rate) {
        staticInit(sample_rate);
        instanceConstants(sample_rate);
        instanceConstantsToMem(sample_rate);
        instanceResetUserInterface();
        instanceClear();
    }

    virtual mydsp* clone() {
        return new mydsp(nullptr, fControl, iZone, fZone);
    }

    virtual int getSampleRate() {
        return fSampleRate;
    }

    virtual void buildUserInterface(UI* ui_interface) {
        ui_interface->openVerticalBox("virtualAnalog");
        ui_interface->declare(&fButton0, "switch", "6");
        ui_interface->addButton("activateNoise", &fButton0);
        ui_interface->declare(&fButton1, "switch", "5");
        ui_interface->addButton("killSwitch", &fButton1);
        ui_interface->declare(&fHslider0, "knob", "2");
        ui_interface->addHorizontalSlider("lfoFreq", &fHslider0, FAUSTFLOAT(1.0f), FAUSTFLOAT(0.01f), FAUSTFLOAT(8.0f), FAUSTFLOAT(0.01f));
        ui_interface->declare(&fHslider1, "knob", "3");
        ui_interface->addHorizontalSlider("lfoRange", &fHslider1, FAUSTFLOAT(1e+03f), FAUSTFLOAT(1e+01f), FAUSTFLOAT(5e+03f), FAUSTFLOAT(0.01f));
        ui_interface->declare(&fHslider5, "slider", "8");
        ui_interface->addHorizontalSlider("masterVol", &fHslider5, FAUSTFLOAT(0.8f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.01f));
        ui_interface->declare(&fHslider2, "slider", "7");
        ui_interface->addHorizontalSlider("noiseGain", &fHslider2, FAUSTFLOAT(0.0f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.01f));
        ui_interface->declare(&fHslider3, "knob", "1");
        ui_interface->addHorizontalSlider("oscFreq", &fHslider3, FAUSTFLOAT(8e+01f), FAUSTFLOAT(5e+01f), FAUSTFLOAT(5e+02f), FAUSTFLOAT(0.01f));
        ui_interface->declare(&fHslider4, "knob", "4");
        ui_interface->addHorizontalSlider("pan", &fHslider4, FAUSTFLOAT(0.5f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.01f));
        ui_interface->closeBox();
    }

    void control() {
        fControl[0] = fConst1 * float(fHslider0);
        fControl[1] = fConst2 * float(fHslider1);
        fControl[2] = 4.656613e-10f * float(fButton0) * mydsp_faustpower2_f(float(fHslider2));
        fControl[3] = std::max<float>(1.1920929e-07f, std::fabs(float(fHslider3)));
        fControl[4] = fConst1 * fControl[3];
        fControl[5] = 1.0f - fConst0 / fControl[3];
        fControl[6] = 0.25f * (1.0f - float(fButton1));
        fControl[7] = fConst2 * float(fHslider4);
        fControl[8] = mydsp_faustpower2_f(float(fHslider5));
    }

    virtual void frame(FAUSTFLOAT* RESTRICT inputs, FAUSTFLOAT* RESTRICT outputs) {
        iZone[0] = 1;
        int iTemp0 = 1 - iZone[1];
        float fTemp1 = ((iTemp0) ? 0.0f : fControl[0] + fZone[1]);
        fZone[0] = fTemp1 - std::floor(fTemp1);
        float fTemp2 = 1.0f - std::fabs(2.0f * fZone[0] + -1.0f);
        fZone[2] = fControl[1] + fConst3 * fZone[3];
        float fTemp3 = std::tan(fConst4 * (fZone[2] * fTemp2 + 5e+01f));
        float fTemp4 = (1.0f / fTemp3 + 0.2f) / fTemp3 + 1.0f;
        float fTemp5 = std::tan(fConst4 * (0.5f * fZone[2] * (2.0f * fTemp2 + -1.0f + 1.0f) + 5e+01f));
        float fTemp6 = 1.0f / fTemp5;
        iZone[2] = 1103515245 * iZone[3] + 12345;
        float fTemp7 = fControl[4] + fZone[5] + -1.0f;
        int iTemp8 = fTemp7 < 0.0f;
        float fTemp9 = fControl[4] + fZone[5];
        fZone[4] = ((iTemp8) ? fTemp9 : fTemp7);
        float fRec5 = ((iTemp8) ? fTemp9 : fControl[4] + fZone[5] + fControl[5] * fTemp7);
        fZone[6] = fConst7 * fZone[9] + fConst6 * fZone[7];
        fZone[8] = float(iTemp0) + fConst6 * fZone[9] - fConst7 * fZone[7];
        fZone[10] = fControl[6] * fZone[8] * (2.0f * fRec5 + -1.0f) + fControl[2] * float(iZone[2]) - (fZone[12] * ((fTemp6 + -0.2f) / fTemp5 + 1.0f) + 2.0f * fZone[11] * (1.0f - 1.0f / mydsp_faustpower2_f(fTemp5))) / ((fTemp6 + 0.2f) / fTemp5 + 1.0f);
        float fTemp10 = fZone[12] + fZone[10] + 2.0f * fZone[11];
        fZone[13] = fControl[7] + fConst3 * fZone[14];
        outputs[0] = FAUSTFLOAT(fControl[8] * ((1.0f - fZone[13]) * fTemp10 / fTemp4));
        outputs[1] = FAUSTFLOAT(fControl[8] * (fZone[13] * fTemp10 / fTemp4));
        iZone[1] = iZone[0];
        fZone[1] = fZone[0];
        fZone[3] = fZone[2];
        iZone[3] = iZone[2];
        fZone[5] = fZone[4];
        fZone[7] = fZone[6];
        fZone[9] = fZone[8];
        fZone[12] = fZone[11];
        fZone[11] = fZone[10];
        fZone[14] = fZone[13];
    }

    virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {}

};

#ifdef FAUST_UIMACROS

#define FAUST_FILE_NAME "virtualAnalog.dsp"
#define FAUST_CLASS_NAME "mydsp"
#define FAUST_COMPILATION_OPIONS "-a include/syfala/arm/faust/control.hpp -lang cpp -os -mem2 -it -ec -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -uim -single -ftz 0"
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

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 9

#define FAUST_INT_ZONE 4
#define FAUST_FLOAT_ZONE 22
