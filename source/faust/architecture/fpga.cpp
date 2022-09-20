
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
#include "syconfig.hpp"

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

using sy_ap_int = ap_int<SYFALA_SAMPLE_WIDTH>;

static char initialized = 0;

// DSP struct
static mydsp DSP;

// Control arrays
static int icontrol[FAUST_INT_CONTROLS];
static float fcontrol[FAUST_REAL_CONTROLS];

#if (SYFALA_MEMORY_USE_DDR == 1)
    // DDR used izone and fzone in RAM
    #define I_ZONE (int*)&ram[base_index]
    #define F_ZONE (float*)&ram[base_index+FAUST_INT_ZONE]
#else
    // no DDR used: izone and fzone in BRAMs
    static int izone[FAUST_INT_ZONE];
    static float fzone[FAUST_FLOAT_ZONE];
    #define I_ZONE izone
    #define F_ZONE fzone
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
void syfala(
        sy_ap_int in_chX_V,
        sy_ap_int* out_chX_V,
        bool *outGPIO, bool debugBtn, bool mute, bool bypass,
        int ARM_fControl[32],
        int ARM_iControl[32],
        int ARM_passive_controller[32],
        FAUSTFLOAT *ram, int ramBaseAddr, int ramDepth, bool enable_RAM_access)
{
#pragma HLS INTERFACE s_axilite port=ARM_fControl
#pragma HLS INTERFACE s_axilite port=ARM_iControl
#pragma HLS INTERFACE s_axilite port=ARM_passive_controller
#pragma HLS INTERFACE s_axilite port=ramBaseAddr
#pragma HLS INTERFACE s_axilite port=ramDepth
#pragma HLS INTERFACE s_axilite port=enable_RAM_access
#pragma HLS INTERFACE m_axi port=ram latency=50

  /* used to address ram as an 32-bit objects (int or float)  array */
  int base_index = ramBaseAddr/4;

  /* Update controllers values from IP ports */
  copyARMControl(ARM_fControl,ARM_iControl,fcontrol,icontrol);

  /* Allocate 'inputs' and 'outputs' for 'compute' method */
  FAUSTFLOAT inputs[FAUST_INPUTS], outputs[FAUST_OUTPUTS];


  // Prepare inputs for 'compute' method
    inputs[X] = in_chX_V.to_float() / scaleFactor;
  /* RAM must be enabled by ARM before any computation */
  if (enable_RAM_access) {
    if (cpt==0) {
      /* first iteration: constant initialization */
      cpt++:

#if (SYFALA_MEMORY_USE_DDR == 1)
      /* from values initialised in DDR */
      instanceConstantsFromMemmydsp(&DSP,SYFALA_SAMPLE_RATE,I_ZONE,F_ZONE);
#else
      /* directly on the FPGA */
      staticInitmydsp(&DSP, SYFALA_SAMPLE_RATE,I_ZONE,F_ZONE);
      instanceConstantsmydsp(&DSP,SYFALA_SAMPLE_RATE,I_ZONE,F_ZONE);
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
  *outGPIO=state;
  if(bypass)
  {
    *out_chX_V=in_chX_V;
  }
  else if(mute)
  {
    *out_chX_V=0;
  }
  else
  {
    // Copy produced outputs
    for(int i=0; i<FAUST_OUTPUTS; i++){
    	if (outputs[i]> 1.0) outputs[i]=1.0;
    	else if (outputs[i]< -1.0) outputs[i]=-1.0;
    }
    *out_chX_V = sy_ap_int(outputs[X] * scaleFactor);

  }
}
