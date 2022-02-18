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
  * @brief Change sample rate value (Hz).
  *	Only 48k is available for SSM embeded codec
  *	 	24000 (ADAU only)
  *	 	48000
  *	 	192000 (ADAU only)
  *	 	384000 (ADAU only)
  *	 	768000 (ADAU only AND DATA_WIDTH=16b only)
  *	
*/
#define SAMPLE_RATE 48000

/* ################## Data width ########################## */
/** 
  * @brief Define words resolution (bits)
  *	 	16
  *	 	24
  *	 	32
*/
#define DATA_WIDTH 24




/* ################## SSM Codec volume ########################## */
/** 
  * @brief Choose audio codec to use. For now, it only changes the scale factor
  *        FULL: !WARNING! For speaker only. Do not use with headphone.
  *        HEADPHONE: Slower volume for headphone use
*/
#define VOLUME_SSM HEADPHONE



/* ################################################################ */
/* ################## END OF USER CONFIG ########################## */
/* ################################################################ */

//For the ADAU, we leave the full scale factor
//(2^DATA_WIDTH)-1
//#define SCALE_FACTOR 8388607.0f
#define SCALE_FACTOR (float)((1<<(DATA_WIDTH-1))-1)


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


#define HEADPHONE 0b001011111
#define FULL 0b001111111


#if DATA_WIDTH == 16
	#define SSM_R07 0b000000010
#elif DATA_WIDTH == 24
	#define SSM_R07 0b000001010
#elif DATA_WIDTH == 32
	#define SSM_R07 0b000001110
#endif 


#define LED_COLOR 0b101 //RGB LED COLOR (use to identify uploded program)
  
