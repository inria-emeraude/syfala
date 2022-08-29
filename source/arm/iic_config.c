/************************************************************************/
/*																		*/
/*	SyFala: SSM2603 and ADAU1761 codec initialisation, based on audio_demo.h			*/
/*																		*/
/************************************************************************/


/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include <syfala/arm/iic_config.h>
#include <syfala/arm/genesys_codec_reg.h>
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


/* ------------------------------------------------------------ */
/* --------------------------- All -------------------------- */
/* ------------------------------------------------------------ */

/***	fnInitIic()
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
int fnInitIic()
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
	return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/* --------------------------- SSM -------------------------- */
/* ------------------------------------------------------------ */

/***	SSMRegSet(XIicPs *IIcPtr, u8 regAddr, u16 regData)
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
int SSMRegSet(XIicPs *IIcPtr, u8 regAddr, u16 regData)
{
	int Status;
	u8 SendBuffer[2];

	SendBuffer[0] = regAddr << 1;
	SendBuffer[0] = SendBuffer[0] | ((regData >> 8) & 0b1);

	SendBuffer[1] = regData & 0xFF;

	Status = XIicPs_MasterSendPolled(IIcPtr, SendBuffer,
				 2, IIC_SSM_SLAVE_ADDR);
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

	Status = SSMRegSet(&Iic, 9, 0b000000000);
	Status |= SSMRegSet(&Iic, 6, 0b000110000); //Power up NOT PATCHED
	usleep(75000);
	Status |= SSMRegSet(&Iic, 9, 0b000000001);
	Status |= SSMRegSet(&Iic, 6, 0b000100000);
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
	 */
	Status = SSMRegSet(&Iic, 15, 0b000000000); //Perform Reset
	usleep(75000);
	Status |= SSMRegSet(&Iic, 6, 0b010011111); //Power up F**KING PATCHED
	Status |= SSMRegSet(&Iic, 0, 0b000010111);
	Status |= SSMRegSet(&Iic, 1, 0b000010111);
	Status |= SSMRegSet(&Iic, 2, volume);
	Status |= SSMRegSet(&Iic, 3, volume);
	Status |= SSMRegSet(&Iic, 4, 0b000010010); //000001010 to bypass (enable bypass, disable DAC)
	Status |= SSMRegSet(&Iic, 5, 0b000000000);
	Status |= SSMRegSet(&Iic, 7, R7); //Changed so Word length is 24
	Status |= SSMRegSet(&Iic, 8, R8); //Changed so no CLKDIV2
	usleep(75000);
	Status |= SSMRegSet(&Iic, 9, 0b000000001);
	Status |= SSMRegSet(&Iic, 6, 0b000100000);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


/* ------------------------------------------------------------------- */
/* --------------------------- Genesys Codec-------------------------- */
/* ------------------------------------------------------------------- */



/******************************************************************************
 * M. Popoff:  Based on audio.c find in Genesys-2-DMA Digilent project.
 * Function to write one byte (8-bits) to one of the registers from the audio
 * controller.
 *
 * @param	u8RegAddr is the LSB part of the register address (0x40xx).
 * @param	u8Data is the data byte to write.
 *
 * @return	XST_SUCCESS if all the bytes have been sent to Controller.
 * 			XST_FAILURE otherwise.
 *****************************************************************************/
XStatus fnAudioWriteToReg(u8 u8RegAddr, u8 u8Data) {
	int Status;
	u8 u8TxData[3];

	u8TxData[0] = 0x40;
	u8TxData[1] = u8RegAddr;
	u8TxData[2] = u8Data;

	Status = XIicPs_MasterSendPolled(&Iic, u8TxData, 3, IIC_GENESYS_SLAVE_ADDR);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC send failed\n\r");
		return XST_FAILURE;
	}
	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(&Iic)) {
		/* NOP */
	}
	return XST_SUCCESS;
}


/******************************************************************************
 * Syfala:  Based on audio.c find in Genesys-2-DMA Digilent project.
 * I didn't do a lot of experiment for now, but this is the registrer that an be
 * changed to optimize latency:
 *  R17_CONVERTER_CONTROL_0 (ADC/DAC frequency) and R67_DEJITTER_CONTROL to add interpolator
 *  R57 (DSP frequency), DSP is not used, shouldn't change anything.
 *  R29, R30, R31 and R32 to swap headphone/line
 * -----
 *
 * @param	none.
 *
 * @return	XST_SUCCESS if the configuration is successful
 *****************************************************************************/
XStatus fnAudioStartupConfig ()
{

	int Status;

	//ADAU I2S: slave (syfala: 0x01 to 0x00)
	Status = fnAudioWriteToReg(R15_SERIAL_PORT_CONTROL_0, 0b00000000);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R15_SERIAL_PORT_CONTROL_0 (0x01)");
		}
		return XST_FAILURE;
	}
	//enable Mixer1, mute left single ended: LINPG and LINNG muted, we don't use the pink In Jack
	Status = fnAudioWriteToReg(R4_RECORD_MIXER_LEFT_CONTROL_0, 0x01);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R4_RECORD_MIXER_LEFT_CONTROL_0 (0x01)");
		}
		return XST_FAILURE;
	}
	//Mixer 1 (Record mixer left): enable MixerAux1; input=Left single-ended auxiliary input; mute left differential input
	//(SYFALA: Changed 0x0D to 0x05)
	Status = fnAudioWriteToReg(R5_RECORD_MIXER_LEFT_CONTROL_1, 0x05);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R5_RECORD_MIXER_LEFT_CONTROL_1 (0x05)");
		}
		return XST_FAILURE;
	}
	//Mixer 2 (Record mixer right): mute right single ended: RINPG and RINNG muted, we don't use the pink In Jack
	Status = fnAudioWriteToReg(R6_RECORD_MIXER_RIGHT_CONTROL_0, 0x01);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R6_RECORD_MIXER_RIGHT_CONTROL_0 (0x01)");
		}
		return XST_FAILURE;
	}
	//Mixer 2 (Record mixer right): enable MixerAux2, input=Right single-ended auxiliary input; mute right differential input
	Status = fnAudioWriteToReg(R7_RECORD_MIXER_RIGHT_CONTROL_1, 0x05);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R7_RECORD_MIXER_RIGHT_CONTROL_1 (0x05)");
		}
		return XST_FAILURE;
	}
	//disable Left differential input (SYFALA: changed 0x03 to 0x0 to truly disable the differential input)
	Status = fnAudioWriteToReg(R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL (0x00)");
		}
		return XST_FAILURE;
	}
	//disable right differential input (SYFALA: changed 0x03 to 0x0 to truly disable the differential input)
	Status = fnAudioWriteToReg(R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL (0x00)");
		}
		return XST_FAILURE;
	}
	//Mic bias 90%
	/*Status = fnAudioWriteToReg(R10_RECORD_MICROPHONE_BIAS_CONTROL, 0x01);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R10_RECORD_MICROPHONE_BIAS_CONTROL (0x01)");
		}
		return XST_FAILURE;
	}*/
	//64 bit audio frame(L+R)
	Status = fnAudioWriteToReg(R16_SERIAL_PORT_CONTROL_1, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R16_SERIAL_PORT_CONTROL_1 (0x00)");
		}
		return XST_FAILURE;
	}
	//ADC, DAC sampling rate to 48KHz (SYFALA: 0xx00 to -- )
	Status = fnAudioWriteToReg(R17_CONVERTER_CONTROL_0, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R17_CONVERTER_CONTROL_0 (0x00)");
		}
		return XST_FAILURE;
	}
	//ADC are both connected, normal mic polarity
	Status = fnAudioWriteToReg(R19_ADC_CONTROL, 0x13);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R19_ADC_CONTROL (0x13)");
		}
		return XST_FAILURE;
	}
	//Mixer 3 (Playback Mixer Left): Enable Mixer3 and select the left DAC channel as input, don't use LAUX bypass as input: mute MixerAux3 (MX3AUXG)
	Status = fnAudioWriteToReg(R22_PLAYBACK_MIXER_LEFT_CONTROL_0, 0x21);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R22_PLAYBACK_MIXER_LEFT_CONTROL_0 (0x21)");
		}
		return XST_FAILURE;
	}
	//Mixer 3 (Playback Mixer Left): Don't use right input mixer (mixer1?) and left input mixer (mixer2?) as input for mixer 3
	Status = fnAudioWriteToReg(R23_PLAYBACK_MIXER_LEFT_CONTROL_1, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R23_PLAYBACK_MIXER_LEFT_CONTROL_1 (0x00)");
		}
		return XST_FAILURE;
	}
	//Mixer 4 (Playback Mixer Right): Enable Mixer4 and select the right DAC channel as input don't use RAUX bypass: mute MixerAux4 (MX4AUXG)
	Status = fnAudioWriteToReg(R24_PLAYBACK_MIXER_RIGHT_CONTROL_0, 0x41);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R24_PLAYBACK_MIXER_RIGHT_CONTROL_0 (0x41)");
		}
		return XST_FAILURE;
	}
	//Mixer 4 (Playback Mixer Right): Don't use right input mixer (mixer1?) and left input mixer (mixer2?) as input for mixer 4
	Status = fnAudioWriteToReg(R25_PLAYBACK_MIXER_RIGHT_CONTROL_1, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R25_PLAYBACK_MIXER_RIGHT_CONTROL_1 (0x00)");
		}
		return XST_FAILURE;
	}
	//Mixer 5 (LINE OUT only Mixer Left) 0dB, input = left channel playback mixer (Mixer 4)
	Status = fnAudioWriteToReg(R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL, 0x03);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL (0x03)");
		}
		return XST_FAILURE;
	}
	//Mixer 6 (LINE OUT only Mixer Right) 0dB, input = right channel playback mixer (Mixer 4)
	Status = fnAudioWriteToReg(R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL, 0x09);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL (0x09)");
		}
		return XST_FAILURE;
	}
	//Mixer7 enabled for MONO OUPTUT (syfala: 0x01 to 0x00)
	Status = fnAudioWriteToReg(R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL (0x01)");
		}
		return XST_FAILURE;
	}
	//[HEADPHONE OUTPUT] Left output: 0dB, headĥone mode (syfala: 0x97 to 0xE7)
	Status = fnAudioWriteToReg(R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL, 0b11100110);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL (0xE7)");
		}
		return XST_FAILURE;
	}
	//[HEADPHONE OUTPUT] Right output: 0dB, headĥone mode (syfala: 0x97 to 0xE7)
	Status = fnAudioWriteToReg(R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL, 0b11100111);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL (0xE7)");
		}
		return XST_FAILURE;
	}
	//[LINE OUTPUT] Left output: 0db, headphone mode
	Status = fnAudioWriteToReg(R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL, 0xE7);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL (0xE7)");
		}
		return XST_FAILURE;
	}
	//[LINE OUTPUT] Right output: 0db, headphone mode
	Status = fnAudioWriteToReg(R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL, 0xE7);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL (0xE7)");
		}
		return XST_FAILURE;
	}
	//disable mono
	Status = fnAudioWriteToReg(R33_PLAYBACK_MONO_OUTPUT_CONTROL, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R33_PLAYBACK_MONO_OUTPUT_CONTROL (0x03)");
		}
		return XST_FAILURE;
	}
	//enable pop and click suppression
	Status = fnAudioWriteToReg(R34_PLAYBACK_POP_CLICK_SUPPRESSION, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R34_PLAYBACK_POP_CLICK_SUPPRESSION (0x00)");
		}
		return XST_FAILURE;
	}
	//Enabling both channels
	Status = fnAudioWriteToReg(R35_PLAYBACK_POWER_MANAGEMENT, 0x03);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R35_PLAYBACK_POWER_MANAGEMENT (0x03)");
		}
		return XST_FAILURE;
	}
	//DAC are both connected
	Status = fnAudioWriteToReg(R36_DAC_CONTROL_0, 0x03);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R36_DAC_CONTROL_0 (0x03)");
		}
		return XST_FAILURE;
	}
	//Serial input [L0,R0] to DAC
	Status = fnAudioWriteToReg(R58_SERIAL_INPUT_ROUTE_CONTROL, 0x01);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R58_SERIAL_INPUT_ROUTE_CONTROL (0x01)");
		}
		return XST_FAILURE;
	}
	//Serial output to L0 R0
	Status = fnAudioWriteToReg(R59_SERIAL_OUTPUT_ROUTE_CONTROL, 0x01);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R59_SERIAL_OUTPUT_ROUTE_CONTROL (0x01)");
		}
		return XST_FAILURE;
	}
	//Enable LRCLK and BLCK
	Status = fnAudioWriteToReg(R60_SERIAL_DATA_GPIO_CONGIURATION, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R60_SERIAL_DATA_GPIO_CONGIURATION (0x00)");
		}
		return XST_FAILURE;
	}
	//ADC, DAC sampling rate to 48KHz
	Status = fnAudioWriteToReg(R64_SERIAL_PORT_SAMPLING_RATE, 0x00);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R64_SERIAL_PORT_SAMPLING_RATE (0x00)");
		}
		return XST_FAILURE;
	}
	//Dejitter (interpolator?). Add for syfala
/*	Status = fnAudioWriteToReg(R67_DEJITTER_CONTROL, 0b00000101);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R67_DEJITTER_CONTROL (0b00000101)");
		}
		return XST_FAILURE;
	} */


	//Enable all digital circuits except Codec slew
	Status = fnAudioWriteToReg(R65_CLOCK_ENABLE_0, 0x7F);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R65_CLOCK_ENABLE_0 (0x7F)");
		}
		return XST_FAILURE;
	}
	//Turns on CLK0 and CLK1
	Status = fnAudioWriteToReg(R66_CLOCK_ENABLE_1, 0x03);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R66_CLOCK_ENABLE_1 (0x03)");
		}
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


/******************************************************************************
 * Initialize PLL and Audio controller over the I2C bus
 *
 * @param	none
 *
 * @return	none.
 *****************************************************************************/
XStatus GenCodecSetConfig()
{
	int Status;

	//Set the PLL and wait for Lock
  //Status = fnAudioPllConfig();

	//Set COREN
	/*0b00000001 for mclk=12.288MHz and Fs=48kHz; 0b00000011 for mclk=24.576 and Fs=48kHz
	  ! NOT TESTED ! 0b00000001 for mclk=24.576MHz and Fs=96kHz; ! NOT TESTED !
	*/
	Status = fnAudioWriteToReg(R0_CLOCK_CONTROL, 0b00000011);
	if (Status == XST_FAILURE)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: could not write R0_CLOCK_CONTROL (0x01)");
		}
		return XST_FAILURE;
	}

	//Configure the ADAU registers
	Status = fnAudioStartupConfig();
	if (Status != XST_SUCCESS)
	{
		if (DEBUG)
		{
			xil_printf("\r\nError: Failed I2C Configuration");
		}
	}

	return XST_SUCCESS;
}
/************************************************************************/
