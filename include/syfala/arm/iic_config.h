/************************************************************************/
/*																		*/
/*	SyFala: SSM2603 and Genesys ADAU codec initialisation, based on audio_demo.h			*/
/*																		*/
/************************************************************************/

#ifndef IIC_CONFIG_H_
#define IIC_CONFIG_H_

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xil_types.h"
#include "xiicps.h"


/* IIC address of the SSM2603 device */
#define IIC_SSM_SLAVE_ADDR		0b0011010

//IIC address of the ADAU audio controller
#define IIC_GENESYS_SLAVE_ADDR			0x3B


#define IIC_SCLK_RATE		400000
/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */
/* ----- Global ------ */
int fnInitIic(void);

/* ----- SSM ------ */
int SSMRegSet(XIicPs*, u8, u16);
int SSMCoreReset(void);
int SSMSetConfig(int,int,int);

/* ----- Genesys ------ */
XStatus fnAudioWriteToReg(u8, u8);
XStatus fnAudioStartupConfig (void);
XStatus GenCodecSetConfig(void);

/* ------------------------------------------------------------ */

/************************************************************************/

#endif /* IIC_CONFIG_H_ */
