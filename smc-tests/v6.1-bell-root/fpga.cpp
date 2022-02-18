
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

static void sendToARM(ap_int<32> *ARM_passive_controller)
{
    //std::cout << "sendToARM\n";
    int field = 0;
    // La macro ACTIVE_ELEMENT_IN copie la valeur du champ de la structure DSP dans le tableau ARM_passive_controller
#define ACTIVE_ELEMENT_IN(type, ident, name, var, def, min, max, step) ARM_passive_controller[field++] = *(ap_int<32>*)&DSP.var;
    FAUST_LIST_ACTIVES(ACTIVE_ELEMENT_IN);

}

void copyARMControl(int *ARM_fControl,int *ARM_iControl, FAUSTFLOAT* RESTRICT fControl, int* RESTRICT iControl)
{
int i;

	for(i=0;i<FAUST_REAL_CONTROLS;i++)
	{
		fControl[i] = *(float*)&ARM_fControl[i];
	}
	for(i=0;i<FAUST_INT_CONTROLS;i++)
	{
		iControl[i] = ARM_iControl[i];
	}
}






bool state=0;


void faust_v6(ap_int<24> in_left_V, ap_int<24> in_right_V, ap_int<24> *out_left_V,
           ap_int<24> *out_right_V, FAUSTFLOAT *ram,  bool *outGPIO1, bool *outGPIO2,
           bool debugSwitch, int ARM_fControl[16], int ARM_iControl[16], int DEBUG_toIP_tab[32],  int ARM_passive_controller[32], int soft_reset, int ramBaseAddr,int ramDepth,int userVar, bool enable_RAM_access)
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


	if(soft_reset==1)
	{
		staticInitmydsp(&DSP, SAMPLE_RATE,I_ZONE,F_ZONE);
		instanceConstantsmydsp(&DSP, SAMPLE_RATE,I_ZONE,F_ZONE);
		instanceResetUserInterfacemydsp(&DSP);
	}

	// Update control
	  copyARMControl(ARM_fControl,ARM_iControl,fcontrol,icontrol);

	// Allocate 'inputs' and 'outputs' for 'compute' method
	FAUSTFLOAT inputs[FAUST_INPUTS], outputs[FAUST_OUTPUTS];

	//const float scaleFactor = 8388607.0f;	 //Set scale factor (original:8388607, patch:4194304 (décalé d'1 bit))
	
	// Prepare inputs for 'compute' method
#if FAUST_INPUTS > 0
	inputs[0] =  in_left_V.to_float() / SCALE_FACTOR;
#endif
#if FAUST_INPUTS > 1
	inputs[1] =  in_right_V.to_float() / SCALE_FACTOR;
#endif




    if(enable_RAM_access)
    {
    	computemydsp(&DSP, inputs, outputs, icontrol, fcontrol,I_ZONE,F_ZONE); //ram[base_index]=first index of int part, [base_index+FAUST_INT_CONTROLS]=first index of float part

	}	
	else
	{
		outputs[0]=inputs[0];
	}
	
	state=!state;	//change state of GPIO each cycle to see cycle time
	*outGPIO2=state;
    
	// Copy produced outputs
	*out_left_V = ap_int<24>(outputs[0] * SCALE_FACTOR);
#if FAUST_OUTPUTS > 1
	*out_right_V = ap_int<24>(outputs[1] * SCALE_FACTOR);
#else
	*out_right_V = ap_int<24>(outputs[0] * SCALE_FACTOR);
#endif

}
