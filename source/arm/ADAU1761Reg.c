/******************************************************************************
 * @file ADAU1761Reg.c
 * Based on audio.c find in Genesys-2-DMA Digilent project.
 * Registers configuration for ADAU1761 (Genesys onboard)
 *
 * @authors M.POPOFF
 *
 * @date 2022-sept
 *
 * Syfala:
 * I didn't do a lot of experiment for now, but this is the registrer that an be
 * changed to optimize latency:
 *  R17_CONVERTER_CONTROL_0 (ADC/DAC frequency) and R67_DEJITTER_CONTROL to add interpolator
 *  R57 (DSP frequency), DSP is not used, shouldn't change anything.
 *  R29, R30, R31 and R32 to swap headphone/line
 *****************************************************************************/

#include <syfala/arm/iic_config.h>
#include <syfala/arm/utils.h>

 /******************************************************************************
  * Initialize PLL and Audio controller over the I2C bus. Then all the registers.

  * Syfala:  Based on audio.c find in Genesys-2-DMA Digilent project.
  * I didn't do a lot of experiment for now, but this is the registrer that an be
  * changed to optimize latency:
  *  R17_CONVERTER_CONTROL_0 (ADC/DAC frequency) and R67_DEJITTER_CONTROL to add interpolator
  *  R57 (DSP frequency), DSP is not used, shouldn't change anything.
  *  R29, R30, R31 and R32 to swap headphone/line
  * -----
	* the internal ADAU1761 is on IIC_0
	*
  * @param	none.
  *
  * @return	XST_SUCCESS if the configuration is successful
  *****************************************************************************/
XStatus ADAU1761SetConfig()
{
	int Status;
	//Set the PLL and wait for Lock
  //Status = fnAudioPllConfig();

	//Set COREN
	/* THIS FUNCTION HAS TO BE CALLED FIRST */
	Status = ADAU17XXRegWrite(R0_CLOCK_CONTROL_ADDR, R0_CLOCK_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R0_CLOCK_CONTROL\r\n");
		return XST_FAILURE;
	}

	//Configure the ADAU registers
	Status = ADAU17XXRegWrite(R15_SERIAL_PORT_CONTROL_0_ADDR, R15_SERIAL_PORT_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R15_SERIAL_PORT_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R4_RECORD_MIXER_LEFT_CONTROL_0_ADDR, R4_RECORD_MIXER_LEFT_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R4_RECORD_MIXER_LEFT_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R5_RECORD_MIXER_LEFT_CONTROL_1_ADDR, R5_RECORD_MIXER_LEFT_CONTROL_1_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R5_RECORD_MIXER_LEFT_CONTROL_1\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R6_RECORD_MIXER_RIGHT_CONTROL_0_ADDR, R6_RECORD_MIXER_RIGHT_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R6_RECORD_MIXER_RIGHT_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R7_RECORD_MIXER_RIGHT_CONTROL_1_ADDR, R7_RECORD_MIXER_RIGHT_CONTROL_1_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R7_RECORD_MIXER_RIGHT_CONTROL_1\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_ADDR, R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_ADDR, R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL\r\n");
		return XST_FAILURE;
	}
	/*Status = ADAU17XXRegWrite(R10_RECORD_MICROPHONE_BIAS_CONTROL_ADDR, R10_RECORD_MICROPHONE_BIAS_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R10_RECORD_MICROPHONE_BIAS_CONTROL (0x01)\r\n");
		return XST_FAILURE;
	}*/

	Status = ADAU17XXRegWrite(R16_SERIAL_PORT_CONTROL_1_ADDR, R16_SERIAL_PORT_CONTROL_1_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R16_SERIAL_PORT_CONTROL_1\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R17_CONVERTER_CONTROL_0_ADDR, R17_CONVERTER_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R17_CONVERTER_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R19_ADC_CONTROL_ADDR, R19_ADC_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R19_ADC_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R22_PLAYBACK_MIXER_LEFT_CONTROL_0_ADDR, R22_PLAYBACK_MIXER_LEFT_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R22_PLAYBACK_MIXER_LEFT_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R23_PLAYBACK_MIXER_LEFT_CONTROL_1_ADDR, R23_PLAYBACK_MIXER_LEFT_CONTROL_1_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R23_PLAYBACK_MIXER_LEFT_CONTROL_1\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R24_PLAYBACK_MIXER_RIGHT_CONTROL_0_ADDR, R24_PLAYBACK_MIXER_RIGHT_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R24_PLAYBACK_MIXER_RIGHT_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R25_PLAYBACK_MIXER_RIGHT_CONTROL_1_ADDR, R25_PLAYBACK_MIXER_RIGHT_CONTROL_1_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R25_PLAYBACK_MIXER_RIGHT_CONTROL_1\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL_ADDR, R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL_ADDR, R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL_ADDR, R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL_ADDR, R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL_ADDR, R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL_ADDR, R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL_ADDR, R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R33_PLAYBACK_MONO_OUTPUT_CONTROL_ADDR, R33_PLAYBACK_MONO_OUTPUT_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R33_PLAYBACK_MONO_OUTPUT_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R34_PLAYBACK_POP_CLICK_SUPPRESSION_ADDR, R34_PLAYBACK_POP_CLICK_SUPPRESSION_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R34_PLAYBACK_POP_CLICK_SUPPRESSION\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R35_PLAYBACK_POWER_MANAGEMENT_ADDR, R35_PLAYBACK_POWER_MANAGEMENT_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R35_PLAYBACK_POWER_MANAGEMENT\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R36_DAC_CONTROL_0_ADDR, R36_DAC_CONTROL_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R36_DAC_CONTROL_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R58_SERIAL_INPUT_ROUTE_CONTROL_ADDR, R58_SERIAL_INPUT_ROUTE_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R58_SERIAL_INPUT_ROUTE_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R59_SERIAL_OUTPUT_ROUTE_CONTROL_ADDR, R59_SERIAL_OUTPUT_ROUTE_CONTROL_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R59_SERIAL_OUTPUT_ROUTE_CONTROL\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R60_SERIAL_DATA_GPIO_CONGIURATION_ADDR, R60_SERIAL_DATA_GPIO_CONGIURATION_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R60_SERIAL_DATA_GPIO_CONGIURATION\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R64_SERIAL_PORT_SAMPLING_RATE_ADDR, R64_SERIAL_PORT_SAMPLING_RATE_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R64_SERIAL_PORT_SAMPLING_RATE\r\n");
		return XST_FAILURE;
	}
	//Dejitter (interpolator?). Add for syfala
/*	Status = ADAU17XXRegWrite(R67_DEJITTER_CONTROL_ADDR, 0b00000101);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R67_DEJITTER_CONTROL (0b00000101)\r\n");
		return XST_FAILURE;
	} */

	Status = ADAU17XXRegWrite(R65_CLOCK_ENABLE_0_ADDR, R65_CLOCK_ENABLE_0_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R65_CLOCK_ENABLE_0\r\n");
		return XST_FAILURE;
	}

	Status = ADAU17XXRegWrite(R66_CLOCK_ENABLE_1_ADDR, R66_CLOCK_ENABLE_1_VALUE,&Iic0);
	if (Status == XST_FAILURE)
	{
		PRINT_DEBUG(" >[ADAU1761]Error: could not write R66_CLOCK_ENABLE_1\r\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
