//spips.c
// Based from this: https://www.programmersought.com/article/13156971872/
// Add ADC read/write function



#include "spips.h"
#include <cstdio>



/************************** Variable Definitions *****************************/

u8 ReadBuf[MAX_DATA];
u8 SendBuf[MAX_DATA];

XSpiPs SpiInstance;
XSpiPs_Config *SpiConfig;

int SpiPs_Init(u16 SpiDeviceId)
{
	int Status;
	// u8 *BufferPtr;
	/*
	 * Initialize the SPI driver so that it's ready to use
	 */
	SpiConfig = XSpiPs_LookupConfig(SpiDeviceId);
	if (NULL == SpiConfig) {
		return XST_FAILURE;
	}

	Status = XSpiPs_CfgInitialize((&SpiInstance), SpiConfig,
					SpiConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * The SPI device is a slave by default and the clock phase
	 * have to be set according to its master. In this example, CPOL is set
	 * to quiescent high and CPHA is set to 1.
	 */
	Status = XSpiPs_SetOptions((&SpiInstance),  XSPIPS_MASTER_OPTION);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XSpiPs_SetClkPrescaler(&SpiInstance, XSPIPS_CLK_PRESCALE_64); // 64

	/*
	 * Enable the device.
	 */
	XSpiPs_Enable(&SpiInstance);
	return XST_SUCCESS;
}

void SpiPs_Reset()
{
	XSpiPs_Reset(&SpiInstance);
  XSpiPs_ResetHw(SpiConfig->BaseAddress);
}
void SpiPs_Read(u8 *ReadBuffer,int ByteCount)
{
	int Count;
	u32 StatusReg;

	do{
		StatusReg = XSpiPs_ReadReg(SpiInstance.Config.BaseAddress,
					XSPIPS_SR_OFFSET);
	}while(!(StatusReg & XSPIPS_IXR_RXNEMPTY_MASK));

	/*
	 * Reading the Rx Buffer
	 */
	for(Count = 0; Count < ByteCount; Count++){
		ReadBuffer[Count] = SpiPs_RecvByte(
				SpiInstance.Config.BaseAddress);
	}
}

void SpiPs_Send(u8 *SendBuffer, int ByteCount)
{
	u32 StatusReg;
	int TransCount = 0;

	/*
	 * Fill the TXFIFO with as many bytes as it will take (or as
	 * many as we have to send).
	 */
	while ((ByteCount > 0) &&
		(TransCount < XSPIPS_FIFO_DEPTH)) {
		SpiPs_SendByte(SpiInstance.Config.BaseAddress,
				*SendBuffer);
		SendBuffer++;
		++TransCount;
		ByteCount--;
	}

	/*
	 * Wait for the transfer to finish by polling Tx fifo status.
	 */
	do {
		StatusReg = XSpiPs_ReadReg(
				SpiInstance.Config.BaseAddress,
					XSPIPS_SR_OFFSET);
	} while ((StatusReg & XSPIPS_IXR_TXOW_MASK) == 0);
}



/******************************************************************************
*
* This function does the SPI communication and returns the decimal value
* read from the MCP3008 ADC.
*
* @param  channel is the ADC channel [0;7] you want to listen to.
* @return adc_value_decimal is the 10bit value read from the ADC.
*
******************************************************************************/
int readADC(int channel)
{
	// start bit
	SendBuf[0] = 0b00000001;

	// configuration bits
	char config_bits = channel;
	config_bits |= 0x18;
	config_bits <<= 4;
	SendBuf[1] = config_bits;

	// don't care bits
	SendBuf[2] = 0;

	// transmission
	SpiPs_Send(SendBuf,3); /* sending three bytes
	 	 	 	 	 	 	* SendBuf[0] : start bit
	 	 	 	 	 	 	* SendBuf[1] : configuration (channel choice)
	 	 	 	 	 	 	* SendBuf[2] : don't care */

	SpiPs_Read(ReadBuf,3); /* receiving three bytes
						   * first byte (ReadBuf[0])  : don't care
						   * second byte (ReadBuf[1]) : 2 last bits are the most significant bits
						   * third byte (ReadBuf[2])  : all 8 bits are data bits */

	int adc_value_decimal= ((ReadBuf[1] & 0b00000011) << 8) | ReadBuf[2] ;
	return adc_value_decimal;
}
