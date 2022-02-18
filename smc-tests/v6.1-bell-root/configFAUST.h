/* ################################################################ */
/* ######################### USER CONFIG ########################## */
/* ################################################################ */



/* ################## Controller ########################## */
/** 
  * @brief Define the controller used to drive the controls (see bottom left corner for PCB number)
  *         Software   (SOFT): Control with PC
  *         Demo Box (DEMO): Popophone...
  *         Handmade PCB (PCB0): PCB Card with 4 knob and 4 switch handmade
  *			Printed PCB #1 (PCB1): 4 knob, 2 switch, 2 slider
  *			Printed PCB #2 (PCB2): 8 knob
  *			Printed PCB #3 (PCB3): 4 knob, 4 switch
  *			Printed PCB #4 (PCB4): ???, 4 slider
  *			LMFA Card (LMFA): ???
  */
#define CONTROLLER_TYPE	SOFT


/* ################## DDR ########################## */
/** 
  * @brief select if external DDR3 is used. Enable if you use some delay, disable if you do a lot of memory access (more tahn 40)
*/
#define USE_DDR


/* ################## Sample rate ########################## */
/** 
  * @brief Change sample rate value. See note at the end of this file.
*/
#define SAMPLE_RATE 48000


/* ################## Audio CODEC ########################## */
/** 
  * @brief Choose audio codec to use. For now, it only changes the scale factor
  *        SSM (0): On board audio codec
  *        ADAU (1): External audio codec
*/
#define AUDIO_CODEC 0


/* ################################################################ */
/* ################## END OF USER CONFIG ########################## */
/* ################################################################ */


#if AUDIO_CODEC == 0U
// For the SSM, we patch the scale factor by shifting one bit to the right
#define SCALE_FACTOR 4194304.0f

#else
//For the ADAU, we leave the full scale factor
#define SCALE_FACTOR 8388607.0f

#endif 

#define KNOB 0U
#define SWITCH 1U
#define SLIDER KNOB

#define SOFT 0U
#define DEMO 1U
#define PCB0 2U
#define PCB1 1U
#define PCB2 3U
#define PCB3 4U

int controllerBoard[8]={
#if CONTROLLER_TYPE == 2U
// 8 Control card description with 4 knobs first, then 4 switches
KNOB,	//Channel 1
KNOB,	//Channel 2,
KNOB,	//Channel 3,
KNOB,	//Channel 4,
SWITCH,	//Channel 5,
SWITCH,	//Channel 6,
SWITCH,	//Channel 7,
SWITCH	//Channel 8,

#elif CONTROLLER_TYPE == 1U
// 8 Control card description with 4 knobs first, then 2 switches, then 2 slider
KNOB,	//Channel 1
KNOB,	//Channel 2,
KNOB,	//Channel 3,
KNOB,	//Channel 4,
SWITCH,	//Channel 5,
SWITCH,	//Channel 6,
SLIDER,	//Channel 7,
SLIDER	//Channel 8,

#elif CONTROLLER_TYPE == 3U
// 8 Control card description with 8 knobs
KNOB,	//Channel 1
KNOB,	//Channel 2,
KNOB,	//Channel 3,
KNOB,	//Channel 4,
SWITCH,	//Channel 5,
SWITCH,	//Channel 6,
SLIDER,	//Channel 7,
SLIDER	//Channel 8,

#elif CONTROLLER_TYPE == 4U
// 8 Control card description with knob on channels 1,3,5,7 and switches on channels 2,4,6 and 8
KNOB,	//Channel 1
SWITCH,	//Channel 2,
KNOB,	//Channel 3,
SWITCH,	//Channel 4,
KNOB,	//Channel 5,
SWITCH,	//Channel 6,
KNOB,	//Channel 7,
SWITCH	//Channel 8,

#else
//no controler
0

#endif 
};



/********* SAMPLE RATE CHANGE METHODE ********
  Please use following value in the project_v6.tcl in order to change sample rate in block design too.
  Put these value in the  "# Create instance: clk_wiz_0, and set properties " part
  *        192000: 
	CONFIG.CLKOUT1_JITTER {113.124} \
   	CONFIG.CLKOUT1_PHASE_ERROR {89.430} \
   	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {120.000} \
   	CONFIG.CLKOUT2_JITTER {134.978} \
   	CONFIG.CLKOUT2_PHASE_ERROR {89.430} \
   	CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {49.152} \
   	CONFIG.CLKOUT2_USED {true} \
   	CONFIG.CLK_OUT1_PORT {sys_clock} \
   	CONFIG.CLK_OUT2_PORT {mclk} \
   	CONFIG.MMCM_CLKFBOUT_MULT_F {9.000} \
   	CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
   	CONFIG.MMCM_CLKOUT0_DIVIDE_F {9.375} \
   	CONFIG.MMCM_CLKOUT1_DIVIDE {23} \
   	
  *        48000: 
	CONFIG.CLKOUT1_JITTER {113.124} \
	CONFIG.CLKOUT1_PHASE_ERROR {89.430} \
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {120.000} \
	CONFIG.CLKOUT2_JITTER {179.449} \
	CONFIG.CLKOUT2_PHASE_ERROR {89.430} \
	CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {12.228} \
	CONFIG.CLKOUT2_USED {true} \
	CONFIG.CLK_OUT1_PORT {sys_clock} \
	CONFIG.CLK_OUT2_PORT {mclk} \
	CONFIG.MMCM_CLKFBOUT_MULT_F {9.000} \
	CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
	CONFIG.MMCM_CLKOUT0_DIVIDE_F {9.375} \
	CONFIG.MMCM_CLKOUT1_DIVIDE {92} \
	  
  *        24000: 
	CONFIG.CLKOUT1_JITTER {129.915} \
	CONFIG.CLKOUT1_PHASE_ERROR {112.379} \
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {120.000} \
	CONFIG.CLKOUT2_JITTER {235.084} \
	CONFIG.CLKOUT2_PHASE_ERROR {112.379} \
	CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {6.144} \
	CONFIG.CLKOUT2_USED {true} \
	CONFIG.CLK_OUT1_PORT {sys_clock} \
	CONFIG.CLK_OUT2_PORT {mclk} \
	CONFIG.MMCM_CLKFBOUT_MULT_F {6.000} \
	CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
	CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.250} \
	CONFIG.MMCM_CLKOUT1_DIVIDE {122} \
  */
  
