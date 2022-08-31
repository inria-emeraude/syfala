#include <ap_int.h>
#include <stdio.h>

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

void faust_v4(ap_int<24> in_left, ap_int<24> in_right, ap_int<24> *out_left,
           ap_int<24> *out_right, 
	      bool bypass_dsp, bool bypass_faust);
