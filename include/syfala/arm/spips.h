//spips.h encapsulates Xilinx spi bare metal driver
#ifndef SRC_SPIPS_H_
#define SRC_SPIPS_H_

#include "xparameters.h"	/* SDK generated parameters */
#include "xspips.h"		    /* SPI device driver */
#include "xil_printf.h"

void SpiPs_Read (u8 *ReadBuffer, int ByteCount);
void SpiPs_Send (u8 *SendBuffer, int ByteCount);
int  SpiPs_Init (u16 SpiDeviceId);
void SpiPs_Reset(void);
int readADC(int channel);


#define SPI_DEVICE_ID		XPAR_XSPIPS_0_DEVICE_ID
#define MAX_DATA		32
#define SpiPs_RecvByte(BaseAddress) (u8)XSpiPs_In32((BaseAddress) + XSPIPS_RXD_OFFSET)
#define SpiPs_SendByte(BaseAddress, Data) XSpiPs_Out32((BaseAddress) + XSPIPS_TXD_OFFSET, (Data))


#endif /* SRC_SPIPS_H_ */
