
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
#include <ap_int.h>
#include <cmath>
#include <inttypes.h>
#include <string.h>

/* faust IP configuration */
#include "configFAUST.h"

#define FAUST_UIMACROS 1

/* generic definition used to accept a variable
   number of controllers */
#define FAUST_ADDBUTTON(l,f)
#define FAUST_ADDCHECKBOX(l,f)
#define FAUST_ADDVERTICALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDHORIZONTALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDNUMENTRY(l,f,i,a,b,s)
#define FAUST_ADDVERTICALBARGRAPH(l,f,a,b)
#define FAUST_ADDHORIZONTALBARGRAPH(l,f,a,b)

// The Faust compiler will insert the C code here
<<includeIntrinsic>>

<<includeclass>>

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
static float fcontrol[FAUST_REAL_CONTROLS];

#ifndef USE_DDR
// no DDR used: izone and fzone in BRAMs
static int izone[FAUST_INT_ZONE];
static float fzone[FAUST_FLOAT_ZONE];
#define I_ZONE izone
#define F_ZONE fzone
#else
// DDR used izone and fzone in RAM
#define I_ZONE (int*)&ram[base_index]
#define F_ZONE (float*)&ram[base_index+FAUST_INT_ZONE]
#endif

/* receive controllers values from ARM */
static void receiveFromARM(ap_int<32> *ARM_active_controller)
{
  int field = 0;
  //  Macro ACTIVE_ELEMENT_OUT copy ARM_active_controller values in DSP struct
#define ACTIVE_ELEMENT_OUT(type, ident, name, var, def, min, max, step) DSP.var = *(float*)&ARM_active_controller[field++];
  // apply ACTIVE_ELEMENT_OUT on all existing controllers
  FAUST_LIST_ACTIVES(ACTIVE_ELEMENT_OUT);
}

/* send passive controllers values to ARM */
static void sendToARM(int* ARM_passive_controller)
{
    //std::cout << "sendToARM\n";
    int field = 0;
    //  Macro ACTIVE_ELEMENT_IN copy DSP struct values to  ARM_passive_controller array
#define ACTIVE_ELEMENT_IN(type, ident, name, var, def, min, max, step) ARM_passive_controller[field++] = *(ap_int<32>*)&DSP.var;
    // apply ACTIVE_ELEMENT_IN on all existing passive controllers
    FAUST_LIST_PASSIVES(ACTIVE_ELEMENT_IN);
}

void copyARMControl(int* ARM_fControl, int* ARM_iControl, float* RESTRICT fControl, int* RESTRICT iControl)
{
  float* fARM_fControl = (float*)ARM_fControl;

  for (int i=0; i<FAUST_REAL_CONTROLS; i++) {
    fControl[i] = fARM_fControl[i];
  }
  for (int i=0; i<FAUST_INT_CONTROLS; i++) {
    iControl[i] = ARM_iControl[i];
  }
}


/* cpt use to distinguish first iteration */
int cpt=0;
/* variable used for debugging purpose */
bool state=0;
int debugBuff=0;

/* scale factor is used to transfer float to ap_int<DATA_WIDTH> */
const float scaleFactor = SCALE_FACTOR; //Why can't we just call the define directly in the loop?

/************************************************************************************************/
/*************** FAUST IP                                                           *************/
/************************************************************************************************/
void faust_v6(ap_int<DATA_WIDTH> in_left_V, ap_int<DATA_WIDTH> in_right_V, ap_int<DATA_WIDTH> *out_left_V,
	      ap_int<DATA_WIDTH> *out_right_V, FAUSTFLOAT *ram,  bool *outGPIO1, bool *outGPIO2,
	      bool debugSwitch, int ARM_fControl[32], int ARM_iControl[32], int DEBUG_toIP_tab[32],
	      int ARM_passive_controller[32], int soft_reset, int ramBaseAddr, int ramDepth,
	      int userVar, bool enable_RAM_access)
{
#pragma HLS INTERFACE s_axilite port=ARM_fControl
#pragma HLS INTERFACE s_axilite port=ARM_iControl
#pragma HLS INTERFACE s_axilite port=ARM_passive_controller
#pragma HLS INTERFACE s_axilite port=DEBUG_toIP_tab
#pragma HLS INTERFACE s_axilite port=soft_reset
#pragma HLS INTERFACE s_axilite port=ramBaseAddr
#pragma HLS INTERFACE s_axilite port=ramDepth
#pragma HLS INTERFACE s_axilite port=userVar
#pragma HLS INTERFACE s_axilite port=enable_RAM_access
#pragma HLS INTERFACE m_axi port=ram latency=50

  /* used to address ram as an 32-bit objects (int or float)  array */
  int base_index = ramBaseAddr/4;

  /* Update controllers values from IP ports */
  copyARMControl(ARM_fControl,ARM_iControl,fcontrol,icontrol);

  /* Allocate 'inputs' and 'outputs' for 'compute' method */
  FAUSTFLOAT inputs[FAUST_INPUTS], outputs[FAUST_OUTPUTS];


  // Prepare inputs for 'compute' method
#if FAUST_INPUTS > 0
  inputs[0] = in_left_V.to_float() / scaleFactor;
#endif
#if FAUST_INPUTS > 1
  inputs[1] =  in_right_V.to_float() / scaleFactor;
#endif

  /* RAM must be enabled by ARM before any computation */
  if (enable_RAM_access) {
    if (cpt==0) {
      /* first iteration: constant initialization */
      cpt++:
#ifdef USE_DDR
      /* from values initialised in DDR */
      instanceConstantsFromMemmydsp(&DSP,SAMPLE_RATE,I_ZONE,F_ZONE);
#else
      /* directly on the FPGA */
      staticInitmydsp(&DSP, SAMPLE_RATE,I_ZONE,F_ZONE);
      instanceConstantsmydsp(&DSP,SAMPLE_RATE,I_ZONE,F_ZONE);
#endif
    }
    else
      {
	/* all other iterations: compute one sample */
        computemydsp(&DSP, inputs, outputs, icontrol, fcontrol, I_ZONE, F_ZONE);
		sendToARM(ARM_passive_controller);
      }
  } else {
    /* if RAM access is not enable, simple bypass */
    outputs[0] = inputs[0];
  }


  /* debug: change state of GPIO each cycle to see cycle time */
  state=!state;
  *outGPIO2=state;

  // Copy produced outputs
  if (outputs[0]> 1.0) outputs[0]=1.0;
  else if (outputs[0]< -1.0) outputs[0]=-1.0;
  *out_left_V = ap_int<DATA_WIDTH>(outputs[0] * scaleFactor);
#if FAUST_OUTPUTS > 1
  if (outputs[1]> 1.0) outputs[1]=1.0;
  else if (outputs[1]< -1.0) outputs[1]=-1.0;
  *out_right_V = ap_int<DATA_WIDTH>(outputs[1] * scaleFactor);
#else
  *out_right_V = ap_int<DATA_WIDTH>(outputs[0] * scaleFactor);
#endif
}
