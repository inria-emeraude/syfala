/************************************************************************/
/*																		*/
/*	SyFala: SSM2603 codec initialisation, based on audio_demo.h			*/
/*																		*/
/************************************************************************/

#ifndef IIC_CONFIG_H_
#define IIC_CONFIG_H_

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xil_types.h"
#include "xiicps.h"


/* IIC address of the SSM2603 device and the desired IIC clock speed */
#define IIC_SLAVE_ADDR		0b0011010
#define IIC_SCLK_RATE		400000


/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */
int SSMCoreReset(void);
int SSMSetRegister(int,int);
int SSMInitialize(void);
int AudioRegSet(XIicPs *IIcPtr, u8 regAddr, u16 regData);


/* ------------------------------------------------------------ */

/************************************************************************/

#endif /* IIC_CONFIG_H_ */
