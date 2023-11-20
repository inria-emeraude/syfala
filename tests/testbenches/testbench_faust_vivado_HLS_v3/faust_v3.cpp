/* ------------------------------------------------------------
name: "sawtooth"
Code generated with Faust 2.21.5 (https://faust.grame.fr)
Compilation options: -lang c -os -light -scal -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__


#include <algorithm>
#include <ap_int.h>
#include <cmath>

// The Faust compiler will insert the C code here

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif 


#ifdef __cplusplus
extern "C" {
#endif

#include <math.h>
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
	int fSampleRate;
} mydsp;

#define FAUST_INPUTS 0
#define FAUST_OUTPUTS  2

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 0

#define FAUST_INT_ZONE 1
#define FAUST_FLOAT_ZONE 8

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
int getInputRatemydsp(mydsp* dsp, int channel) {
	int rate;
	switch ((channel)) {
		default: {
			rate = -1;
			break;
		}
	}
	return rate;
}
int getOutputRatemydsp(mydsp* dsp, int channel) {
	int rate;
	switch ((channel)) {
		case 0: {
			rate = 1;
			break;
		}
		case 1: {
			rate = 1;
			break;
		}
		default: {
			rate = -1;
			break;
		}
	}
	return rate;
}

void classInitmydsp(int sample_rate) {}

void staticInitmydsp(mydsp* dsp, int sample_rate, int* iZone, FAUSTFLOAT* fZone) {
	fZone[0+0] = 0.125f;
	fZone[0+1] = 0.25f;
	fZone[0+2] = 0.375f;
	fZone[0+3] = 0.5f;
	fZone[0+4] = 0.625f;
	fZone[0+5] = 0.75f;
	fZone[0+6] = 0.875f;
	fZone[0+7] = 0.0f;
}

void instanceResetUserInterfacemydsp(mydsp* dsp) {
}

void instanceClearmydsp(int* iZone, FAUSTFLOAT* fZone) {
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate, int* iZone, FAUSTFLOAT* fZone) {
	dsp->fSampleRate = sample_rate;
	iZone[0] = 0;
}

void instanceInitmydsp(mydsp* dsp, int sample_rate, int* iZone, FAUSTFLOAT* fZone) {
	staticInitmydsp(dsp, sample_rate, iZone, fZone);
	instanceConstantsmydsp(dsp, sample_rate, iZone, fZone);
	instanceResetUserInterfacemydsp(dsp);
	instanceClearmydsp(iZone, fZone);
}

void initmydsp(mydsp* dsp, int sample_rate, int* iZone, FAUSTFLOAT* fZone) {
	instanceInitmydsp(dsp, sample_rate, iZone, fZone);
}
void controlmydsp(mydsp* dsp, int* iControl, FAUSTFLOAT* fControl, int* iZone, FAUSTFLOAT* fZone) {
}

int getNumIntControlsmydsp(mydsp* dsp) { return 0; }

int getNumRealControlsmydsp(mydsp* dsp) { return 0; }

int getiZoneSizemydsp(mydsp* dsp) { return 1; }

int getfZoneSizemydsp(mydsp* dsp) { return 16; }

void computemydsp(mydsp* dsp, FAUSTFLOAT* inputs, FAUSTFLOAT* outputs, int* iControl, FAUSTFLOAT* fControl, int* iZone, FAUSTFLOAT* fZone) {
	float fTemp0 = fZone[0+iZone[0]];
	outputs[0] = (FAUSTFLOAT)fTemp0;
	outputs[1] = (FAUSTFLOAT)fTemp0;
	iZone[0] = ((1 + iZone[0]) % 8);
}

#endif // TESTBENCH

#ifdef __cplusplus
}
#endif

#ifndef SAMPLE_RATE
#define SAMPLE_RATE 44100
#endif

#if FAUST_INPUTS > 2
#warning More than 2 inputs defined. Only the first 2 will be used!
#endif

#if FAUST_OUTPUTS < 1
#error At least one output is required!
#endif

#if FAUST_OUTPUTS > 2
#warning More than 2 outputs defined. Only the first 2 will be used!
#endif

static char initialized = 0;

// DSP struct
static mydsp DSP;

// Control arrays
static int icontrol[FAUST_INT_CONTROLS];
static FAUSTFLOAT fcontrol[FAUST_REAL_CONTROLS];

// DSP arrays
static int izone[FAUST_INT_ZONE];

void faust_v3(ap_int<24> in_left, ap_int<24> in_right, ap_int<24> *out_left,
           ap_int<24> *out_right, FAUSTFLOAT fzone[FAUST_FLOAT_ZONE],
           bool bypass_dsp, bool bypass_faust)
{
#pragma HLS interface m_axi port=fzone

	if (initialized == 0) {
		initmydsp(&DSP, SAMPLE_RATE, izone, fzone);
		initialized = 1;
	}

	// Update control
	controlmydsp(&DSP, icontrol, fcontrol, izone, fzone);

	// Allocate 'inputs' and 'outputs' for 'compute' method
	FAUSTFLOAT inputs[FAUST_INPUTS], outputs[FAUST_OUTPUTS];

	const float scaleFactor = 8388608.0f;

	// Prepare inputs for 'compute' method
#if FAUST_INPUTS > 0
	inputs[0] =  in_left.to_float() / scaleFactor;
#endif
#if FAUST_INPUTS > 1
	inputs[1] =  in_right.to_float() / scaleFactor;
#endif

	computemydsp(&DSP, inputs, outputs, icontrol, fcontrol, izone, fzone);

	// Copy produced outputs
	*out_left = ap_int<24>(outputs[0] * scaleFactor);
#if FAUST_OUTPUTS > 1
	*out_right = ap_int<24>(outputs[1] * scaleFactor);
#else
	*out_right = ap_int<24>(outputs[0] * scaleFactor);
#endif
}

#endif
