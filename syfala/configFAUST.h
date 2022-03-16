/* ################################################################### */
/* ######################### USER CONFIG ############################# */
/* ################################################################### */

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
 /* ####################### UART log ################################# */
 /**
   * @brief  Enable UART log in uart.log file.
	*/
//#define LOG_UART

/* ####################### Zybo version ################################# */
/**
  * @brief Define zybo version. Z10 and Z20 only, old zybo is not supported.
	*If you have a VGA port (rather than 2 HDMI port), you have an old zybo version
	* which is not supported.
  *     Z10: Zybo Z10
  *     Z20: Zybo Z20
  */
#define ZYBO_VERSION Z20

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
#define CONTROLLER_TYPE	PCB1


/* ######################### DDR ##################################### */
/**
  * @brief select if external DDR3 is used. Enable if you use some delay,
  *     disable if you do want any  memory access (should not be disable)
*/
#define USE_DDR


/* ######################## Sample rate ############################### */
/**
  * @brief Change sample rate value (Hz).
  *	Only 48k and 96k is available for SSM embeded codec
  *	 	48000 (default)
  *	 	96000
  *	 	192000 (ADAU1777 and ADAU1787 only)
  *	 	384000 (ADAU1787 only)
  *	 	768000 (ADAU1787 only AND DATA_WIDTH=16b only)
  *
*/
#define SAMPLE_RATE 48000

/* ########################### Data width ############################# */
/**
  * @brief Define sample bit depth
  *	 	16
  *	 	24 (default)
  *	 	32
*/
#define DATA_WIDTH 24



/* ####################### SSM Codec volume ############################ */
/**
  * @brief Choose audio codec to use. For now, it only changes the scale factor
  *      FULL: Maximum !WARNING! For speaker only. Do not use with headphone.
  *      HEADPHONE: Slower volume for headphone use
  *		   DEFAULT: Default value +1db because the true 0db (0b001111001) decreases the signal a little bit
*/
#define VOLUME_SSM HEADPHONE

/* ################## SSM Codec ADC/DAC speed ########################## */
/**
  * @brief Change SSM ADC/DAC sample rate
  *        DEFAULT: 48khz sample rate
  *        FAST: 96Khz sample rate
*/
#define SSM_SPEED DEFAULT

/* #################################################################### */
/* ###################### END OF USER CONFIG ########################## */
/* #################################################################### */

#define SCALE_FACTOR (float)((1<<(DATA_WIDTH-1))-1)


#define KNOB 0U
#define SWITCH 1U
#define SLIDER KNOB

#define DEMO 1U
#define PCB0 2U
#define PCB1 1U
#define PCB2 3U
#define PCB3 4U

int controllerBoard[8]={
#if CONTROLLER_TYPE == 2U
// PCB config 2: 4 knobs first, then 4 switches
KNOB,	//Channel 1
KNOB,	//Channel 2,
KNOB,	//Channel 3,
KNOB,	//Channel 4,
SWITCH,	//Channel 5,
SWITCH,	//Channel 6,
SWITCH,	//Channel 7,
SWITCH	//Channel 8,

#elif CONTROLLER_TYPE == 1U
// PCB config 1: 4 knobs first, then 2 switches, then 2 slider
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
// PCB config 4: knobs on channels 1,3,5,7 and switches on channels 2,4,6, 8
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
#define DEFAULT 0b001111010 //(+1db because the true 0db (0b001111001) decreases the signal a little bit)


/* SSM_R07 is used to tune I2S Bclk depending on sample bit depth */
#if DATA_WIDTH == 16
	#define SSM_R07 0b000000010
#elif DATA_WIDTH == 24
	#define SSM_R07 0b000001010
#elif DATA_WIDTH == 32
	#define SSM_R07 0b000001110
#endif



#if SSM_SPEED == FAST
	#define SSM_R08 0b001011100
#elif SSM_SPEED == DEFAULT
	#define SSM_R08 0b000000000
#endif
