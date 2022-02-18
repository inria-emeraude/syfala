/************************************************************************/
/*																		*/
/*	SyFala: SSM2603 codec initialisation, based on audio_demo.h			*/
/*																		*/
/************************************************************************/


/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "iic_config.h"
#include <stdio.h>
#include <stdlib.h>

#include "xparameters.h"
#include "xil_printf.h"
#include "xiicps.h"
#include "xuartps.h"


#include "sleep.h"

/* Redefine the XPAR constants */
#define IIC_DEVICE_ID		XPAR_XIICPS_0_DEVICE_ID


XIicPs Iic;		/* Instance of the IIC Device */


/***	SSMPreheat()
**
**	Parameters:
**
**	Return Value: int
**		XST_SUCCESS if successful
**
**	Errors:
**
**	Description:
**		Not a true reset, it disable and enable digital core. 
**		If we use the non patched value in R6, it will act like the old bad behavior we had
**
*/
int SSMCoreReset()
{
	int Status;

	/*
	 * Write to the SSM2603 audio codec registers to configure the device. Refer to the
	 * SSM2603 Audio Codec data sheet for information on what these writes do.
	 */

	Status = AudioRegSet(&Iic, 9, 0b000000000);
	Status |= AudioRegSet(&Iic, 6, 0b000110000); //Power up NOT PATCHED
	usleep(75000);
	Status |= AudioRegSet(&Iic, 9, 0b000000001);
	Status |= AudioRegSet(&Iic, 6, 0b000100000);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/***	SSMInitialize()
**
**	Return Value: int
**		XST_SUCCESS if successful
**
**	Errors:
**
**	Description:
**		Initializes the Audio demo. Must be called once and only once
**
*/
int SSMInitialize()
{
	int Status;
	XIicPs_Config *Config;

	/*
	 * Initialize the IIC driver so that it's ready to use
	 * Look up the configuration in the config table,
	 * then initialize it.
	 */
	Config = XIicPs_LookupConfig(IIC_DEVICE_ID);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XIicPs_CfgInitialize(&Iic, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built correctly.
	 */
	Status = XIicPs_SelfTest(&Iic);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the IIC serial clock rate.
	 */
	Status = XIicPs_SetSClk(&Iic, IIC_SCLK_RATE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

}


/***	SSMSetRegisters()
**
**  Argument:
**		int volume: SSM output volume
**		int R7: SSM R7 register to select bit width
**	Return Value: int
**		XST_SUCCESS if successful
**
**	Errors:
**
**	Description:
**		Initializes registers of SSM. Separate from initialization to call the init only one time before preheat
**
*/
int SSMSetRegister(int volume, int R7)
{
	int Status;
	/*
	 * Write to the SSM2603 audio codec registers to configure the device. Refer to the
	 * SSM2603 Audio Codec data sheet for information on what these writes do.
	 */
	Status = AudioRegSet(&Iic, 15, 0b000000000); //Perform Reset
	usleep(75000);
	Status |= AudioRegSet(&Iic, 6, 0b010011111); //Power up F**KING PATCHED
	Status |= AudioRegSet(&Iic, 0, 0b000010111);
	Status |= AudioRegSet(&Iic, 1, 0b000010111);
	Status |= AudioRegSet(&Iic, 2, volume); 
	Status |= AudioRegSet(&Iic, 3, volume); 
	Status |= AudioRegSet(&Iic, 4, 0b000010000);
	Status |= AudioRegSet(&Iic, 5, 0b000000000);
	Status |= AudioRegSet(&Iic, 7, R7); //Changed so Word length is 24
	Status |= AudioRegSet(&Iic, 8, 0b000000000); //Changed so no CLKDIV2
	usleep(75000);
	Status |= AudioRegSet(&Iic, 9, 0b000000001);
	Status |= AudioRegSet(&Iic, 6, 0b000100000);
	
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
/* ------------------------------------------------------------ */

/***	AudioRegSet(XIicPs *IIcPtr, u8 regAddr, u16 regData)
**
**	Parameters:
**		IIcPtr - Pointer to the initialized XIicPs struct
**		regAddr - Register in the SSM2603 to write to
**		regData - Data to write to the register (lower 9 bits are used)
**
**	Return Value: int
**		XST_SUCCESS if successful
**
**	Errors:
**
**	Description:
**		Writes a value to a register in the SSM2603 device over IIC.
**
*/
int AudioRegSet(XIicPs *IIcPtr, u8 regAddr, u16 regData)
{
	int Status;
	u8 SendBuffer[2];

	SendBuffer[0] = regAddr << 1;
	SendBuffer[0] = SendBuffer[0] | ((regData >> 8) & 0b1);

	SendBuffer[1] = regData & 0xFF;

	Status = XIicPs_MasterSendPolled(IIcPtr, SendBuffer,
				 2, IIC_SLAVE_ADDR);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC send failed\n\r");
		return XST_FAILURE;
	}
	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(IIcPtr)) {
		/* NOP */
	}
	return XST_SUCCESS;

}

/************************************************************************/
