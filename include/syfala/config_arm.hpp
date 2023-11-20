#pragma once

#include <syfala/config_common.hpp>

#if (SYFALA_SAMPLE_WIDTH) == 16
/* SSM_R07 is used to tune I2S Bclk depending on sample bit depth */
    #define SSM_R07 0b000000010
#elif SYFALA_SAMPLE_WIDTH == 24
    #define SSM_R07 0b000001010
#elif SYFALA_SAMPLE_WIDTH == 32
    #define SSM_R07 0b000001110
#endif

/* ####################### Controller ################################# */
/**
  * @brief Define the controller used to drive the controls (see bottom
  *      left corner for PCB number) when SW3 is UP. (SW3 DONW for software control)
  *     DEMO: Popophone demo box
  *     PCB1: Emeraude PCB config 1: 4 knobs, 2 switchs, 2 sliders (default)
  *	    PCB2: Emeraude PCB config 2: 8 knobs
  *	    PCB3: Emeraude PCB config 3: 4 knob, 4 switch
  *	    PCB4: Emeraude PCB config 4: 4 knods above, 4 switch below
  */
#define SYFALA_CONTROLLER_TYPE PCB1

/* ####################### SSM Codec volume ############################ */
/**
  * @brief Choose audio codec to use. For now, it only changes the scale factor
  *      FULL: Maximum !WARNING! For speaker only. Do not use with headphone.
  *      HEADPHONE: Slower volume for headphone use
  *		   DEFAULT: Default value +1db because the true 0db (0b001111001) decreases the signal a little bit
*/
#define HEADPHONE   0b001011111
#define FULL        0b001111111
// (+1db because the true 0db (0b001111001) decreases the signal a little bit)
#define DEFAULT     0b001111010

#define SYFALA_SSM_VOLUME HEADPHONE

/* ################## SSM Codec ADC/DAC speed ########################## */
/**
  * @brief Change SSM ADC/DAC sample rate
  *        DEFAULT: 48khz sample rate
  *        FAST: 96Khz sample rate
*/
#define SYFALA_SSM_SPEED DEFAULT

#if SYFALA_SSM_SPEED == FAST
    #define SSM_R08 0b001011100
#elif SYFALA_SSM_SPEED == DEFAULT
    #define SSM_R08 0b000000000
#endif

/* #################################################################### */
/* ###################### END OF USER CONFIG ########################## */
/* #################################################################### */

#define KNOB 0U
#define SWITCH 1U
#define SLIDER KNOB

#define DEMO 1U
#define PCB0 2U
#define PCB1 1U
#define PCB2 3U
#define PCB3 4U
#define ARDUINO 5U

static int controllerBoard[8] = {
#if (SYFALA_CONTROLLER_TYPE == 2U)
// PCB config 2: 4 knobs first, then 4 switches
    KNOB,	//Channel 1
    KNOB,	//Channel 2,
    KNOB,	//Channel 3,
    KNOB,	//Channel 4,
    SWITCH,	//Channel 5,
    SWITCH,	//Channel 6,
    SWITCH,	//Channel 7,
    SWITCH	//Channel 8,

#elif (SYFALA_CONTROLLER_TYPE == 1U)
// PCB config 1: 4 knobs first, then 2 switches, then 2 slider
    KNOB,	//Channel 1
    KNOB,	//Channel 2,
    KNOB,	//Channel 3,
    KNOB,	//Channel 4,
    SWITCH,	//Channel 5,
    SWITCH,	//Channel 6,
    SLIDER,	//Channel 7,
    SLIDER	//Channel 8,

#elif (SYFALA_CONTROLLER_TYPE == 3U)
// 8 Control card description with 8 knobs
    KNOB,	//Channel 1
    KNOB,	//Channel 2,
    KNOB,	//Channel 3,
    KNOB,	//Channel 4,
    SWITCH,	//Channel 5,
    SWITCH,	//Channel 6,
    SLIDER,	//Channel 7,
    SLIDER	//Channel 8,

#elif (SYFALA_CONTROLLER_TYPE == 4U)
// PCB config 4: knobs on channels 1,3,5,7 and switches on channels 2,4,6, 8
    KNOB,	//Channel 1
    SWITCH,	//Channel 2,
    KNOB,	//Channel 3,
    SWITCH,	//Channel 4,
    KNOB,	//Channel 5,
    SWITCH,	//Channel 6,
    KNOB,	//Channel 7,
    SWITCH	//Channel 8,
#elif (SYFALA_CONTROLLER_TYPE == TEENSY)
    KNOB,
    KNOB,
    KNOB,
    KNOB,
    KNOB,
    KNOB,
    KNOB,
    KNOB,

#else
// No controller
0
#endif
};

#define SYFALA_UART_BAUD_RATE 115200
#define SYFALA_ARM_BENCHMARK 0
#define SYFALA_VERBOSE 0
#define SYFALA_FAUST_TARGET 1
#define SYFALA_ADAU_EXTERN 0
#define SYFALA_ADAU_MOTHERBOARD 0
#define SYFALA_CONTROL_MIDI 0
#define SYFALA_CONTROL_OSC 0
#define SYFALA_CONTROL_HTTP 0
