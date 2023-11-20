/* ------------------------------------------------------------
name: "virtualAnalog"
Code generated with Faust 2.41.1 (https://faust.grame.fr)
Compilation options: -a /home/pierre/Repositories/syfala-dev/source/faust/control/gui-controls.cpp -lang cpp -es 1 -mcd 16 -single -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__

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
	
 private:
	
	FAUSTFLOAT fHslider0;
	int fSampleRate;
	float fConst0;
	float fConst1;
	FAUSTFLOAT fHslider1;
	float fConst2;
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
	float fRec1[3];
	
 public:
	
	void metadata(Meta* m) { 
		m->declare("compile_options", "-a /home/pierre/Repositories/syfala-dev/source/faust/control/gui-controls.cpp -lang cpp -es 1 -mcd 16 -single -ftz 0");
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
		m->declare("filters.lib/version", "0.3");
		m->declare("maths.lib/author", "GRAME");
		m->declare("maths.lib/copyright", "GRAME");
		m->declare("maths.lib/license", "LGPL with exception");
		m->declare("maths.lib/name", "Faust Math Library");
		m->declare("maths.lib/version", "2.5");
		m->declare("name", "virtualAnalog");
		m->declare("noises.lib/name", "Faust Noise Generator Library");
		m->declare("noises.lib/version", "0.4");
		m->declare("oscillators.lib/lf_sawpos:author", "Bart Brouns, revised by Stéphane Letz");
		m->declare("oscillators.lib/lf_sawpos:licence", "STK-4.3");
		m->declare("oscillators.lib/lf_triangle:author", "Bart Brouns");
		m->declare("oscillators.lib/lf_triangle:licence", "STK-4.3");
		m->declare("oscillators.lib/name", "Faust Oscillator Library");
		m->declare("oscillators.lib/saw1:author", "Bart Brouns");
		m->declare("oscillators.lib/saw1:licence", "STK-4.3");
		m->declare("oscillators.lib/version", "0.3");
		m->declare("platform.lib/name", "Generic Platform Library");
		m->declare("platform.lib/version", "0.2");
		m->declare("signals.lib/name", "Faust Signal Routing Library");
		m->declare("signals.lib/version", "0.3");
	}

	virtual int getNumInputs() {
		return 0;
	}
	virtual int getNumOutputs() {
		return 2;
	}
	
	static void classInit(int sample_rate) {
	}
	
	virtual void instanceConstants(int sample_rate) {
		fSampleRate = sample_rate;
		fConst0 = std::min<float>(192000.0f, std::max<float>(1.0f, float(fSampleRate)));
		fConst1 = 44.0999985f / fConst0;
		fConst2 = 1.0f - fConst1;
		float fConst3 = 2764.60156f / fConst0;
		fConst4 = std::sin(fConst3);
		fConst5 = std::cos(fConst3);
		fConst6 = 1.0f / fConst0;
		fConst7 = 3.14159274f / fConst0;
	}
	
	virtual void instanceResetUserInterface() {
		fHslider0 = FAUSTFLOAT(0.80000000000000004f);
		fHslider1 = FAUSTFLOAT(0.5f);
		fButton0 = FAUSTFLOAT(0.0f);
		fHslider2 = FAUSTFLOAT(80.0f);
		fButton1 = FAUSTFLOAT(0.0f);
		fHslider3 = FAUSTFLOAT(0.0f);
		fHslider4 = FAUSTFLOAT(1000.0f);
		fHslider5 = FAUSTFLOAT(1.0f);
	}
	
	virtual void instanceClear() {
		for (int l0 = 0; l0 < 2; l0 = l0 + 1) {
			iVec0[l0] = 0;
		}
		for (int l1 = 0; l1 < 2; l1 = l1 + 1) {
			fRec0[l1] = 0.0f;
		}
		for (int l2 = 0; l2 < 2; l2 = l2 + 1) {
			fRec2[l2] = 0.0f;
		}
		for (int l3 = 0; l3 < 2; l3 = l3 + 1) {
			fRec3[l3] = 0.0f;
		}
		for (int l4 = 0; l4 < 2; l4 = l4 + 1) {
			fRec4[l4] = 0.0f;
		}
		for (int l5 = 0; l5 < 2; l5 = l5 + 1) {
			iRec6[l5] = 0;
		}
		for (int l6 = 0; l6 < 2; l6 = l6 + 1) {
			fRec7[l6] = 0.0f;
		}
		for (int l7 = 0; l7 < 2; l7 = l7 + 1) {
			fRec8[l7] = 0.0f;
		}
		for (int l8 = 0; l8 < 3; l8 = l8 + 1) {
			fRec1[l8] = 0.0f;
		}
	}
	
	virtual void init(int sample_rate) {
		classInit(sample_rate);
		instanceInit(sample_rate);
	}
	virtual void instanceInit(int sample_rate) {
		instanceConstants(sample_rate);
		instanceResetUserInterface();
		instanceClear();
	}
	
	virtual mydsp* clone() {
		return new mydsp();
	}
	
	virtual int getSampleRate() {
		return fSampleRate;
	}
	
	virtual void buildUserInterface(UI* ui_interface) {
		ui_interface->openVerticalBox("virtualAnalog");
		ui_interface->declare(&fButton1, "switch", "6");
		ui_interface->addButton("activateNoise", &fButton1);
		ui_interface->declare(&fButton0, "switch", "5");
		ui_interface->addButton("killSwitch", &fButton0);
		ui_interface->declare(&fHslider5, "knob", "2");
		ui_interface->addHorizontalSlider("lfoFreq", &fHslider5, FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f), FAUSTFLOAT(8.0f), FAUSTFLOAT(0.00999999978f));
		ui_interface->declare(&fHslider4, "knob", "3");
		ui_interface->addHorizontalSlider("lfoRange", &fHslider4, FAUSTFLOAT(1000.0f), FAUSTFLOAT(10.0f), FAUSTFLOAT(5000.0f), FAUSTFLOAT(0.00999999978f));
		ui_interface->declare(&fHslider0, "slider", "8");
		ui_interface->addHorizontalSlider("masterVol", &fHslider0, FAUSTFLOAT(0.800000012f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f));
		ui_interface->declare(&fHslider3, "slider", "7");
		ui_interface->addHorizontalSlider("noiseGain", &fHslider3, FAUSTFLOAT(0.0f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f));
		ui_interface->declare(&fHslider2, "knob", "1");
		ui_interface->addHorizontalSlider("oscFreq", &fHslider2, FAUSTFLOAT(80.0f), FAUSTFLOAT(50.0f), FAUSTFLOAT(500.0f), FAUSTFLOAT(0.00999999978f));
		ui_interface->declare(&fHslider1, "knob", "4");
		ui_interface->addHorizontalSlider("pan", &fHslider1, FAUSTFLOAT(0.5f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f));
		ui_interface->closeBox();
	}
	
	virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
		FAUSTFLOAT* output0 = outputs[0];
		FAUSTFLOAT* output1 = outputs[1];
		float fSlow0 = mydsp_faustpower2_f(float(fHslider0));
		float fSlow1 = fConst1 * float(fHslider1);
		float fSlow2 = 0.25f * (1.0f - float(fButton0));
		float fSlow3 = std::max<float>(1.1920929e-07f, std::fabs(float(fHslider2)));
		float fSlow4 = fConst6 * fSlow3;
		float fSlow5 = 1.0f - fConst0 / fSlow3;
		float fSlow6 = 4.65661287e-10f * float(fButton1) * mydsp_faustpower2_f(float(fHslider3));
		float fSlow7 = fConst1 * float(fHslider4);
		float fSlow8 = fConst6 * float(fHslider5);
		for (int i0 = 0; i0 < count; i0 = i0 + 1) {
			iVec0[0] = 1;
			fRec0[0] = fSlow1 + fConst2 * fRec0[1];
			fRec2[0] = fConst4 * fRec3[1] + fConst5 * fRec2[1];
			fRec3[0] = (float(1 - iVec0[1]) + fConst5 * fRec3[1]) - fConst4 * fRec2[1];
			float fTemp0 = fSlow4 + fRec4[1] + -1.0f;
			int iTemp1 = fTemp0 < 0.0f;
			float fTemp2 = fSlow4 + fRec4[1];
			fRec4[0] = ((iTemp1) ? fTemp2 : fTemp0);
			float fThen1 = fSlow4 + fRec4[1] + fSlow5 * fTemp0;
			float fRec5 = ((iTemp1) ? fTemp2 : fThen1);
			iRec6[0] = 1103515245 * iRec6[1] + 12345;
			fRec7[0] = fSlow7 + fConst2 * fRec7[1];
			fRec8[0] = fSlow8 + fRec8[1] - std::floor(fSlow8 + fRec8[1]);
			float fTemp3 = std::tan(fConst7 * (0.5f * fRec7[0] * (2.0f * (1.0f - std::fabs(2.0f * fRec8[0] + -1.0f)) + -1.0f + 1.0f) + 50.0f));
			float fTemp4 = 1.0f / fTemp3;
			float fTemp5 = (fTemp4 + 0.200000003f) / fTemp3 + 1.0f;
			fRec1[0] = (fSlow2 * fRec3[0] * (2.0f * fRec5 + -1.0f) + fSlow6 * float(iRec6[0])) - (fRec1[2] * ((fTemp4 + -0.200000003f) / fTemp3 + 1.0f) + 2.0f * fRec1[1] * (1.0f - 1.0f / mydsp_faustpower2_f(fTemp3))) / fTemp5;
			float fTemp6 = fRec1[2] + fRec1[0] + 2.0f * fRec1[1];
			output0[i0] = FAUSTFLOAT(fSlow0 * ((1.0f - fRec0[0]) * fTemp6) / fTemp5);
			output1[i0] = FAUSTFLOAT(fSlow0 * (fRec0[0] * fTemp6) / fTemp5);
			iVec0[1] = iVec0[0];
			fRec0[1] = fRec0[0];
			fRec2[1] = fRec2[0];
			fRec3[1] = fRec3[0];
			fRec4[1] = fRec4[0];
			iRec6[1] = iRec6[0];
			fRec7[1] = fRec7[0];
			fRec8[1] = fRec8[0];
			fRec1[2] = fRec1[1];
			fRec1[1] = fRec1[0];
		}
	}

};

#endif
