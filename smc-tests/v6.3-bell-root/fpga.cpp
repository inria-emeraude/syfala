
#include <algorithm>
#include <ap_int.h>
#include <cmath>
#include <inttypes.h>
#include <string.h>

#include "configFAUST.h"

#define FAUST_UIMACROS 1

// but we will ignore most of them
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
static FAUSTFLOAT fcontrol[FAUST_REAL_CONTROLS];

#ifndef USE_DDR
// DSP arrays
static int izone[FAUST_INT_ZONE];
static FAUSTFLOAT fzone[FAUST_FLOAT_ZONE];
#define I_ZONE izone
#define F_ZONE fzone
#else
#define I_ZONE (int*)&ram[base_index]
#define F_ZONE &ram[base_index+FAUST_INT_ZONE]
#endif

static void receiveFromARM(ap_int<32> *ARM_active_controller)
{
    //std::cout << "receiveFromARM\n";
    int field = 0;
    // La macro ACTIVE_ELEMENT_OUT copie la valeur du tableau ARM_active_controller_out dans le champ de la structure DSP
#define ACTIVE_ELEMENT_OUT(type, ident, name, var, def, min, max, step) DSP.var = *(float*)&ARM_active_controller[field++];
    FAUST_LIST_ACTIVES(ACTIVE_ELEMENT_OUT);
}

static void sendToARM(ap_int<32>* ARM_passive_controller)
{
    //std::cout << "sendToARM\n";
    int field = 0;
    // La macro ACTIVE_ELEMENT_IN copie la valeur du champ de la structure DSP dans le tableau ARM_passive_controller
#define ACTIVE_ELEMENT_IN(type, ident, name, var, def, min, max, step) ARM_passive_controller[field++] = *(ap_int<32>*)&DSP.var;
    FAUST_LIST_ACTIVES(ACTIVE_ELEMENT_IN);
}

void copyARMControl(int* ARM_fControl, int* ARM_iControl, FAUSTFLOAT* RESTRICT fControl, int* RESTRICT iControl)
{
    float* fARM_fControl = (float*)ARM_fControl;
    
    for (int i=0; i<FAUST_REAL_CONTROLS; i++) {
        fControl[i] = fARM_fControl[i];
    }
    for (int i=0; i<FAUST_INT_CONTROLS; i++) {
        iControl[i] = ARM_iControl[i];
    }
}

int cpt=0;
bool state=0;
int debugBuff=0;
const float scaleFactor = SCALE_FACTOR; //Why can't we just call the define directly in the loop?

void faust_v6(ap_int<DATA_WIDTH> in_left_V, ap_int<DATA_WIDTH> in_right_V, ap_int<DATA_WIDTH> *out_left_V,
	      ap_int<DATA_WIDTH> *out_right_V, FAUSTFLOAT *ram,  bool *outGPIO1, bool *outGPIO2,
	      bool debugSwitch, int ARM_fControl[16], int ARM_iControl[16], int DEBUG_toIP_tab[32],
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

  int base_index = ramBaseAddr/4; //divide by 4 to get a 32bit index and not a byte address
  
  // Update control
  copyARMControl(ARM_fControl,ARM_iControl,fcontrol,icontrol);

  // Allocate 'inputs' and 'outputs' for 'compute' method
  FAUSTFLOAT inputs[FAUST_INPUTS], outputs[FAUST_OUTPUTS];
  
  //const float scaleFactor = 8388607.0f;	 //Set scale factor (original:8388607, patch:4194304 (décalé d'1 bit))
  
  // Prepare inputs for 'compute' method
#if FAUST_INPUTS > 0
  inputs[0] = in_left_V.to_float() / scaleFactor;
#endif
#if FAUST_INPUTS > 1
  inputs[1] =  in_right_V.to_float() / scaleFactor;
#endif

  if (enable_RAM_access) {
    if (cpt==0) {
      cpt++:
#ifdef USE_DDR
      instanceConstantsFromMemmydsp(&DSP,SAMPLE_RATE,I_ZONE,F_ZONE);
      //instanceResetUserInterfacemydsp(&DSP);
#else
      staticInitmydsp(&DSP, SAMPLE_RATE,I_ZONE,F_ZONE);
      instanceConstantsmydsp(&DSP,SAMPLE_RATE,I_ZONE,F_ZONE);
      //instanceResetUserInterfacemydsp(&DSP);
#endif
    }
    else
      {
        computemydsp(&DSP, inputs, outputs, icontrol, fcontrol, I_ZONE, F_ZONE);
	
        /*
	  if(debugSwitch==1)
	  {
	  if(debugBuff>=32)debugBuff=0; // Stop recording at the end of the first buffer ( no circular buffer)
	  else    //recording
	  {
	  ap_int<DATA_WIDTH> castBuffer=ap_int<DATA_WIDTH>(outputs[0] * scaleFactor);
	  ARM_passive_controller[debugBuff++]=*(int*)&castBuffer;
	  }
	  }
	  else
	  {
	  debugBuff=0;
	  
	  }*/
        
      }
  } else {
    outputs[0]=inputs[0];
  }
    
    state=!state;    //change state of GPIO each cycle to see cycle time
    *outGPIO2=state;
    
    // Copy produced outputs
    *out_left_V = ap_int<DATA_WIDTH>(outputs[0] * scaleFactor);
#if FAUST_OUTPUTS > 1
    *out_right_V = ap_int<DATA_WIDTH>(outputs[1] * scaleFactor);
#else
    *out_right_V = ap_int<DATA_WIDTH>(outputs[0] * scaleFactor);
#endif
}
