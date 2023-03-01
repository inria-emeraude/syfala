/************************************************************************
 *
 *	SyFala: SSM2603, ADAU1761 and ADAU1787 codec initialisation,
 *  Based on audio_demo.h and exemples in https://github.com/Xilinx/embeddedsw/tree/master/XilinxProcessorIPLib/drivers/iicps/examples
 *
 * @authors M.POPOFF
 *
 * @date 2022-sept
 *
 *****************************************************************************/

#include <syfala/arm/iic_config.h>
#include <syfala/arm/utils.h>

#include "xil_exception.h"
#include "xscugic.h"

volatile u32 SendComplete;
volatile u32 RecvComplete;
volatile u32 errorEvent;

XScuGic InterruptController;	/* Instance of the Interrupt Controller */

/* codec_IIC_addr= global addr to set the address of the currently configured codec just once
 * High Byte=  address of the multiplexer
 * Low Byte= IIC address of the codec */
extern uint16_t codec_IIC_addr;

/* ------------------------------------------------------------ */
/* --------------------------- All -------------------------- */
/* ------------------------------------------------------------ */

/***	initIic()
**
**	Parameters:
**		InstancePtr - Pointer to the XIicPs struct to be initialized
**		Iic_device_idAddr - Address of the corresponding IIC from xparameter.h
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
int initIic(XIicPs *InstancePtr,int Iic_device_id)
{
	int Status;
	XIicPs_Config *Config;

   Config = XIicPs_LookupConfig(Iic_device_id);

	/*
	 * Initialize the IIC driver so that it's ready to use
	 * Look up the configuration in the config table,
	 * then initialize it.
	 */
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XIicPs_CfgInitialize(InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built correctly.
	 */
	Status = XIicPs_SelfTest(InstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the IIC serial clock rate.
	 */
	Status = XIicPs_SetSClk(InstancePtr, IIC_SCLK_RATE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	PRINT_DEBUG(" >[IIC] IIC Rate= %d \n\r",IIC_SCLK_RATE);
	return XST_SUCCESS;
}

/******************************************************************************/
/**
* Initialise Interrupt mode for IIC.
*
* @param	InstancePtr - Pointer to the XIicPs struct to be initialized
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
*******************************************************************************/
int initIicInterrupt(XIicPs *InstancePtr)
{
	int Status;
  /*
   * Connect the IIC to the interrupt subsystem such that interrupts can
   * occur. This function is application specific.
   */
  Status = SetupInterruptSystem(InstancePtr);
  if (Status != XST_SUCCESS) {
    return XST_FAILURE;
  }

  /*
   * Setup the handlers for the IIC that will be called from the
   * interrupt context when data has been sent and received, specify a
   * pointer to the IIC driver instance as the callback reference so
   * the handlers are able to access the instance data.
   */
  XIicPs_SetStatusHandler(InstancePtr, (void *)InstancePtr, Handler);

  return XST_SUCCESS;
}

/*******************************************************************************
* This function is the handler which performs processing to handle data events
* from the IIC.  It is called from an interrupt context such that the amount
* of processing performed should be minimized.
*
* This handler provides an example of how to handle data for the IIC and
* is application specific.
*
* @param	CallBackRef contains a callback reference from the driver, in
*		this case it is the instance pointer for the IIC driver.
* @param	Event contains the specific kind of event that has occurred.
*
* @return	None.
*
* @note		None.
*
*******************************************************************************/
void Handler(void *CallBackRef, u32 Event)
{
	/*
	 * All of the data transfer has been finished.
   * Avoid printf here?
	 */
	if ((Event & XIICPS_EVENT_COMPLETE_RECV) != 0){
		RecvComplete = TRUE;
	} else if ((Event & XIICPS_EVENT_COMPLETE_SEND) != 0) {
		SendComplete = TRUE;
	} else if ((Event & XIICPS_EVENT_SLAVE_RDY) == 0){
		/*
		 * If it is other interrupt but not slave ready interrupt, it is
		 * an error.
		 * Data was received with an error.
		 */
		errorEvent=Event;
	}

}
/******************************************************************************/
/**
*
* This function setups the interrupt system such that interrupts can occur
* for the IIC.  This function is application specific since the actual
* system may or may not have an interrupt controller.  The IIC could be
* directly connected to a processor without an interrupt controller.  The
* user should modify this function to fit the application.
*
* @param	IicPsPtr contains a pointer to the instance of the Iic
*		which is going to be connected to the interrupt controller.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
*******************************************************************************/
static int SetupInterruptSystem(XIicPs *IicPsPtr)
{
	int Status;
	XScuGic_Config *IntcConfig; /* Instance of the interrupt controller */

	Xil_ExceptionInit();

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&InterruptController, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
				(Xil_ExceptionHandler)XScuGic_InterruptHandler,
				&InterruptController);

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(&InterruptController, XPAR_XIICPS_1_INTR,
			(Xil_InterruptHandler)XIicPs_MasterInterruptHandler,
			(void *)IicPsPtr);
	if (Status != XST_SUCCESS) {
		return Status;
	}

	/*
	 * Enable the interrupt for the Iic device.
	 */
	XScuGic_Enable(&InterruptController, XPAR_XIICPS_1_INTR);


	/*
	 * Enable interrupts in the Processor.
	 */
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/* --------------------------- SSM -------------------------- */
/* ------------------------------------------------------------ */

/***	SSMRegWrite(XIicPs *IIcPtr, u8 regAddr, u16 regData)
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
**    This function is not in interrupt mode, still in polled!
*/
int SSMRegWrite(XIicPs *IIcPtr, u8 regAddr, u16 regData)
{
	int Status;
	u8 SendBuffer[2];

	SendBuffer[0] = regAddr << 1;
	SendBuffer[0] = SendBuffer[0] | ((regData >> 8) & 0b1);

	SendBuffer[1] = regData & 0xFF;

	Status = XIicPs_MasterSendPolled(IIcPtr, SendBuffer,
				 2, IIC_SSM_SLAVE_ADDR);
	if (Status != XST_SUCCESS) {
		PRINT_DEBUG(" >[SSM] IIC send failed  (addr=0x%x)\n\r",IIC_SSM_SLAVE_ADDR);
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

/***	SSMCoreReset()
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
   * SSM is on the IIC_0
	 */
	Status = SSMRegWrite(&Iic0, 9, 0b000000000);
	Status |= SSMRegWrite(&Iic0, 6, 0b000110000); //Power up NOT PATCHED
	usleep(75000);
	Status |= SSMRegWrite(&Iic0, 9, 0b000000001);
	Status |= SSMRegWrite(&Iic0, 6, 0b000100000);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/***	SSMSetConfig()
**
**  Argument:
**		int volume: SSM output volume
**		int R7: SSM R7 register to select bit width
**		int R8: SSM R8 register to select ADC/DAC frequency
**	Return Value: int
**		XST_SUCCESS if successful
**
**	Errors:
**
**	Description:
**		Initializes registers of SSM. Separate from initialization to call the init only one time before preheat
**
*/
int SSMSetConfig(int volume, int R7, int R8)
{
	int Status;
	/*
	 * Write to the SSM2603 audio codec registers to configure the device. Refer to the
	 * SSM2603 Audio Codec data sheet for information on what these writes do.
   * SSM is on the IIC_0
	 */
	Status = SSMRegWrite(&Iic0, 15, 0b000000000); //Perform Reset
	usleep(75000);
	Status |= SSMRegWrite(&Iic0, 6, 0b010011111); //Power up F**KING PATCHED
	Status |= SSMRegWrite(&Iic0, 0, 0b000010111);
	Status |= SSMRegWrite(&Iic0, 1, 0b000010111);
	Status |= SSMRegWrite(&Iic0, 2, volume);
	Status |= SSMRegWrite(&Iic0, 3, volume);
	Status |= SSMRegWrite(&Iic0, 4, 0b000010010); //000001010 to bypass (enable bypass, disable DAC)
	Status |= SSMRegWrite(&Iic0, 5, 0b000000000);
	Status |= SSMRegWrite(&Iic0, 7, R7); //Changed so Word length is 24
	Status |= SSMRegWrite(&Iic0, 8, R8); //Changed so no CLKDIV2
	usleep(75000);
	Status |= SSMRegWrite(&Iic0, 9, 0b000000001);
	Status |= SSMRegWrite(&Iic0, 6, 0b000100000);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


/* ------------------------------------------------------------------- */
/* --------------------------- ADAU Codec-------------------------- */
/* ------------------------------------------------------------------ */
/******************************************************************************
 * Interrupt mode NOT USED
 * Function to write one byte (8-bits) to one of the registers from the audio
 * controller.
 * Adapted to be general for ADAU1761 and ADAU1787.
 *
 * @param	u8RegAddr is the 2 bytes of the register address
 * @param	u8Data is the data byte to write.
 * @param	IIcPtr - Pointer to the initialized XIicPs struct
 *
 * @return	XST_SUCCESS if all the bytes have been sent to Controller.
 * 			XST_FAILURE otherwise.
 *****************************************************************************/
XStatus ADAU17XXRegWriteITR(u16 RegAddr, u8 u8Data, XIicPs *InstancePtr) {
	int Status;
	u8 u8TxData[3];

	u8TxData[0] = ((RegAddr >> 8) & 0xFF);  //Reg Subaddress high byte (0x40 for ADAU1761, 0xC0 for ADAU1787)
	u8TxData[1] = RegAddr & 0xFF; //Reg Subaddress low byte
	u8TxData[2] = u8Data; //Reg data
  /*
    for (int i=0; i<3; i++)
    {
       PRINT_DEBUG("\n\r -u8TxData[%d]: %x",i,u8TxData[i]);
    }
  */
    /* Wait for bus to become idle*/
  while (XIicPs_BusIsBusy(InstancePtr)) {/* NOP */ }

  SendComplete = FALSE;
	XIicPs_MasterSend(InstancePtr, u8TxData, 3, (codec_IIC_addr & 0xFF));
  while (SendComplete == FALSE) {
		if (errorEvent != 0) {
      if((errorEvent & (XIICPS_EVENT_TIME_OUT | XIICPS_EVENT_ERROR | XIICPS_EVENT_NACK)) != 0){
        PRINT_DEBUG(" >[ADAU] No codec found at address 0x%04x (Handler event=0x%02x)\n\r",codec_IIC_addr,errorEvent);
        return XST_DEVICE_NOT_FOUND;
      }
      else
      {
        PRINT_DEBUG(" >[ADAU] IIC send failed (addr=0x%04x), Handler event= 0x%02x\n\r",codec_IIC_addr,errorEvent);
			  return XST_FAILURE;
      }
		}
	}
	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(InstancePtr)) {	/* NOP */}
	return XST_SUCCESS;
}
/******************************************************************************
 * Polled mode
 * Function to write one byte (8-bits) to one of the registers from the audio
 * controller.
 * Adapted to be general for ADAU1761 and ADAU1787.
 *
 * @param	u8RegAddr is the 2 bytes of the register address
 * @param	u8Data is the data byte to write.
 * @param	IIcPtr - Pointer to the initialized XIicPs struct
 *
 * @return	XST_SUCCESS if all the bytes have been sent to Controller.
 * 			XST_FAILURE otherwise.
 *****************************************************************************/
XStatus ADAU17XXRegWrite(u16 RegAddr, u8 u8Data, XIicPs *InstancePtr) {
	int Status;
	u8 u8TxData[3];

	u8TxData[0] = ((RegAddr >> 8) & 0xFF);  //Reg Subaddress high byte (0x40 for ADAU1761, 0xC0 for ADAU1787)
	u8TxData[1] = RegAddr & 0xFF; //Reg Subaddress low byte
	u8TxData[2] = u8Data; //Reg data
  /*
    for (int i=0; i<3; i++)
    {
       PRINT_DEBUG("\n\r -u8TxData[%d]: %x",i,u8TxData[i]);
    }
  */
	Status = XIicPs_MasterSendPolled(InstancePtr, u8TxData, 3, (codec_IIC_addr & 0xFF));
	if (Status != XST_SUCCESS) {
    PRINT_DEBUG(" >[ADAU] IIC polled send failed  (addr=0x%04x)\n\r",codec_IIC_addr);
		return XST_FAILURE;
	}
	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(InstancePtr)) {
		/* NOP */
	}
	return XST_SUCCESS;
}


/******************************************************************************
 * Interrupt mode
 *
 * @param	u8RegAddr is the 2 bytes of the register address
 * @param	u8RxData is the data byte received.
 * @param	IIcPtr - Pointer to the initialized XIicPs struct
 *
 * Note: if more than 1 byte is asked in XIicPs_MasterRecv,
 * it return the byte of the following register.
 * @authors: M. POPOFF
 *
 * @return	XST_SUCCESS if all the bytes have been sent to Controller.
 * 			XST_FAILURE otherwise.
 *****************************************************************************/
 XStatus ADAU17XXRegRead(u16 RegAddr, u8* u8RxData,XIicPs *InstancePtr) {
	int Status;
	u8 u8TxData[2];

	u8TxData[0] = ((RegAddr >> 8) & 0xFF);  //Reg Subaddress high byte (0x40 for ADAU1761, 0xC0 for ADAU1787)
	u8TxData[1] = RegAddr & 0xFF; //Reg Subaddress low byte

	XIicPs_MasterSend(InstancePtr, u8TxData, 2, (codec_IIC_addr & 0xFF));
  while (SendComplete == FALSE) {
		if (errorEvent != 0) {
      if((errorEvent & (XIICPS_EVENT_TIME_OUT | XIICPS_EVENT_ERROR | XIICPS_EVENT_NACK)) != 0){
        PRINT_DEBUG(" >[ADAU] No codec found at address 0x%04x (Handler event=0x%02x)\n\r",codec_IIC_addr,errorEvent);
        return XST_DEVICE_NOT_FOUND;
      }
      else
      {
        PRINT_DEBUG(" >[ADAU] IIC send failed (addr=0x%04x), Handler event= 0x%02x\n\r",codec_IIC_addr,errorEvent);
			  return XST_FAILURE;
      }
		}
	}
	XIicPs_MasterRecv(InstancePtr, u8RxData, 1, (codec_IIC_addr & 0xFF)); //If more than 1 byte is asked, it return the byte of the following register.
  while (SendComplete == FALSE) {
		if (errorEvent != 0) {
      PRINT_DEBUG(" >[ADAU] IIC receive failed (addr=0x%04x), Handler event= 0x%02x\n\r",codec_IIC_addr,errorEvent);
			return XST_FAILURE;
		}
	}
  /*
		PRINT_DEBUG("\n\r  u8RxData: %x \r\n",*u8RxData);
  */
	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(InstancePtr)) {
		/* NOP */
	}
	return XST_SUCCESS;
}


XStatus ADAU1787BootSequence() {
 int Status;
 u8 regData;
 // POWER_EN:1
 Status = ADAU17XXRegWrite(REG_CHIP_PWR_IC_1_Sigma_ADDR, 0x11,&Iic1);
 if (Status != XST_SUCCESS) {
   if(Status == XST_FAILURE) PRINT_DEBUG(" >[ADAU1787]Error: could not write REG_ADC_DAC_HP_PWR_IC_1_Sigma\n\r");
   return Status;
 }
 usleep(40000);
 //CM_STARTUP_OVER=1
 Status = ADAU17XXRegWrite(REG_CHIP_PWR_IC_1_Sigma_ADDR, 0x15,&Iic1);
 if (Status != XST_SUCCESS) {
   if(Status == XST_FAILURE) PRINT_DEBUG(" >[ADAU1787]Error: could not write REG_ADC_DAC_HP_PWR_IC_1_Sigma\n\r");
   return Status;
 }
 usleep(40000);

 // Check for POWER_UP_COMPLETE=1
 /*do{
   Status = ADAU17XXRegRead(REG_STATUS2_IC_1_Sigma_ADDR, &regData);
   if (Status == XST_FAILURE) {
       PRINT_DEBUG("\r\nError: could not write REG_ADC_DAC_HP_PWR_IC_1_Sigma");

     return XST_FAILURE;
   }
     PRINT_DEBUG("\r\n  POWER_UP_COMPLETE=%b", regData);
 }while((regData & 0b10000000) == 0);
*/
PRINT_DEBUG(" >[ADAU1787]WARNING: POWER_UP_COMPLETE not checked\r\n");

 //MASTER_BLOCK_EN=1
 Status = ADAU17XXRegWrite(REG_CHIP_PWR_IC_1_Sigma_ADDR, 0x17,&Iic1);
 if (Status != XST_SUCCESS) {
   if(Status == XST_FAILURE) PRINT_DEBUG(" >[ADAU1787]Error: could not write REG_ADC_DAC_HP_PWR_IC_1_Sigma\n\r");
   return Status;
 }
 return XST_SUCCESS;
}
