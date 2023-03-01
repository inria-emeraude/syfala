/************************************************************************
 *
 *	SyFala: SSM2603, ADAU1761 and ADAU1787 codec initialisation,
 *  Based on audio_demo.h
 *
 * @authors M.POPOFF
 *
 * @date 2022-sept
 *
 *****************************************************************************/

#ifndef IIC_CONFIG_H_
#define IIC_CONFIG_H_

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xil_types.h"
#include "xiicps.h"
#include "sleep.h"

//#include "xparameters.h"
//#include "xil_printf.h"

#include <syfala/arm/ADAU1777Reg.h>
#include <syfala/arm/ADAU1787Reg.h>
#include <syfala/arm/ADAU1761Reg.h>

extern XIicPs Iic0;		/* Instance of the IIC_0 Device */
extern XIicPs Iic1;		/* Instance of the IIC_1 Device */


/* IIC address of the SSM2603 device */
#define IIC_SSM_SLAVE_ADDR		0b0011010

//IIC address of the ADAU1761 audio controller
#define IIC_GENESYS_SLAVE_ADDR			0x3B

//IIC addresses of the ADAU1777 audio controller
#define IIC_ADAU1777_SLAVE_ADDR_0			0x3C
#define IIC_ADAU1777_SLAVE_ADDR_1			0x3D
#define IIC_ADAU1777_SLAVE_ADDR_2			0x3E
#define IIC_ADAU1777_SLAVE_ADDR_3			0x3F

//IIC addresses of the ADAU1787 audio controller
#define IIC_ADAU1787_SLAVE_ADDR_0			0x28
#define IIC_ADAU1787_SLAVE_ADDR_1			0x29
#define IIC_ADAU1787_SLAVE_ADDR_2			0x2A
#define IIC_ADAU1787_SLAVE_ADDR_3			0x2B

#define IIC_SCLK_RATE		40000
/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */
/* ----- Global ------ */
int initIic(XIicPs*,int);
int initIicInterrupt(XIicPs*);
void Handler(void*, u32);
static int SetupInterruptSystem(XIicPs*);

/* ----- SSM ------ */
int SSMRegWrite(XIicPs*, u8, u16);
int SSMCoreReset(void);
int SSMSetConfig(int,int,int);

/* ----- Genesys ------ */
XStatus ADAU1761SetConfig(void);

/* ----- ADAU1787 ------ */
XStatus ADAU1787SetConfig(void);
XStatus ADAU1787BootSequence(void);

/* ----- ADAU1777 ------ */
XStatus ADAU1777SetConfig(void);

/* ----- ADAU17XX ------ */
XStatus ADAU17XXRegWriteITR(u16, u8, XIicPs*);
XStatus ADAU17XXRegWrite(u16, u8, XIicPs*);
XStatus ADAU17XXRegRead(u16,u8*,XIicPs*);

/* ------------------------------------------------------------ */

/************************************************************************/

#endif /* IIC_CONFIG_H_ */
