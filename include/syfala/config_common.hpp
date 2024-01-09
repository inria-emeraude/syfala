#pragma once

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
  *     GENESYS
  */
#define SYFALA_BOARD 10
#define SYFALA_BOARD_Z10 (SYFALA_BOARD == 10)
#define SYFALA_BOARD_Z20 (SYFALA_BOARD == 20)
#define SYFALA_BOARD_ZYBO (SYFALA_BOARD_Z10 | SYFALA_BOARD_Z20)
#define SYFALA_BOARD_GENESYS (SYFALA_BOARD == 30)

/* ######################### DDR ##################################### */
/**
  * @brief select if external DDR3 is used. Enable if you use some delay,
  *     disable if you do want any  memory access (should not be disable)
*/
#define SYFALA_MEMORY_USE_DDR 1

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
#define SYFALA_SAMPLE_RATE 48000

/* ########################### Data width ############################# */
/**
  * @brief Define sample bit depth
  *	 	16
  *	 	24 (default)
  *	 	32
*/
#define SYFALA_SAMPLE_WIDTH 24
#define SYFALA_REAL_FIXED_POINT 0
#define SYFALA_CONTROL_BLOCK 1
#define SYFALA_CONTROL_BLOCK_FPGA 2
#define SYFALA_CONTROL_BLOCK_HOST 1
#define SYFALA_CONTROL_RELEASE 0
#define SYFALA_DEBUG_AUDIO 0
#define SYFALA_BLOCK_NSAMPLES 1
#define SYFALA_CSIM_NUM_ITER 1
#define SYFALA_CSIM_INPUT_DIR 0
#define SYFALA_ETHERNET_NO_OUTPUT 0
