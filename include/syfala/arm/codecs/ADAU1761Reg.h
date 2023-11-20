/******************************************************************************
 * @file ADAU1761Reg.h
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

#ifndef ADAU1761REG_H_
#define ADAU1761REG_H_


/************************** Constant Definitions *****************************/

//ADAU internal register addresses

//Set COREN
/*0b00000001 for mclk=12.288MHz and Fs=48kHz; 0b00000011 for mclk=24.576 and Fs=48kHz
	! NOT TESTED ! 0b00000001 for mclk=24.576MHz and Fs=96kHz; ! NOT TESTED !
*/
#define	R0_CLOCK_CONTROL_ADDR                               0x4000
#define	R0_CLOCK_CONTROL_VALUE								0b00000011

#define	R1_PLL_CONTROL_ADDR                                 0x4002
#define	R1_PLL_CONTROL_VALUE                                NC

#define	R2_DIGITAL_MIC_JACK_DETECTION_CONTROL_ADDR          0x4008
#define	R2_DIGITAL_MIC_JACK_DETECTION_CONTROL_VALUE         NC

#define	R3_RECORD_POWER_MANAGEMENT_ADDR                     0x4009
#define	R3_RECORD_POWER_MANAGEMENT_VALUE                    NC

//enable Mixer1, mute left single ended: LINPG and LINNG muted, we don't use the pink In Jack
#define	R4_RECORD_MIXER_LEFT_CONTROL_0_ADDR                 0x400A
#define	R4_RECORD_MIXER_LEFT_CONTROL_0_VALUE                0x01

//Mixer 1 (Record mixer left): enable MixerAux1; input=Left single-ended auxiliary input; mute left differential input
//(SYFALA: Changed 0x0D to 0x05)
#define	R5_RECORD_MIXER_LEFT_CONTROL_1_ADDR                 0x400B
#define	R5_RECORD_MIXER_LEFT_CONTROL_1_VALUE                0x05

//Mixer 2 (Record mixer right): mute right single ended: RINPG and RINNG muted, we don't use the pink In Jack
#define	R6_RECORD_MIXER_RIGHT_CONTROL_0_ADDR                0x400C
#define	R6_RECORD_MIXER_RIGHT_CONTROL_0_VALUE 				0x01

//Mixer 2 (Record mixer right): enable MixerAux2, input=Right single-ended auxiliary input; mute right differential input
#define	R7_RECORD_MIXER_RIGHT_CONTROL_1_ADDR                0x400D
#define	R7_RECORD_MIXER_RIGHT_CONTROL_1_VALUE 				0x05

//disable Left differential input (SYFALA: changed 0x03 to 0x0 to truly disable the differential input)
#define	R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_ADDR      0x400E
#define	R8_LEFT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_VALUE     0x00

//disable right differential input (SYFALA: changed 0x03 to 0x0 to truly disable the differential input)
#define	R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_ADDR     0x400F
#define	R9_RIGHT_DIFFERENTIAL_INPUT_VOLUME_CONTROL_VALUE    0x00

//Mic bias 90%
#define	R10_RECORD_MICROPHONE_BIAS_CONTROL_ADDR             0x4010
#define	R10_RECORD_MICROPHONE_BIAS_CONTROL_VALUE            0x01

#define	R11_ALC_CONTROL_0_ADDR                              0x4011
#define	R11_ALC_CONTROL_0_VALUE                             NC

#define	R12_ALC_CONTROL_1_ADDR                              0x4012
#define	R12_ALC_CONTROL_1_VALUE                             NC

#define	R13_ALC_CONTROL_2_ADDR                              0x4013
#define	R13_ALC_CONTROL_2_VALUE                             NC

#define	R14_ALC_CONTROL_3_ADDR                              0x4014
#define	R14_ALC_CONTROL_3_VALUE                             NC

//ADAU I2S: slave (syfala: 0x01 to 0x00)
#define	R15_SERIAL_PORT_CONTROL_0_ADDR                      0x4015
#define	R15_SERIAL_PORT_CONTROL_0_VALUE                     0b00000000

//64 bit audio frame(L+R)
#define	R16_SERIAL_PORT_CONTROL_1_ADDR                      0x4016
#define	R16_SERIAL_PORT_CONTROL_1_VALUE                     0x00

//ADC, DAC sampling rate to 48KHz (SYFALA: 0xx00 to -- )
#define	R17_CONVERTER_CONTROL_0_ADDR                        0x4017
#define	R17_CONVERTER_CONTROL_0_VALUE                       0x00

#define	R18_CONVERTER_CONTROL_1_ADDR                        0x4018
#define	R18_CONVERTER_CONTROL_1_VALUE 						NC

//ADC are both connected, normal mic polarity
#define	R19_ADC_CONTROL_ADDR                                0x4019
#define	R19_ADC_CONTROL_VALUE                               0x13

#define	R20_LEFT_INPUT_DIGITAL_VOLUME_ADDR                  0x401A
#define	R20_LEFT_INPUT_DIGITAL_VOLUME_VALUE                 NC

#define	R21_RIGHT_INPUT_DIGITAL_VOLUME_ADDR                 0x401B
#define	R21_RIGHT_INPUT_DIGITAL_VOLUME_VALUE                NC

//Mixer 3 (Playback Mixer Left): Enable Mixer3 and select the left DAC channel as input, don't use LAUX bypass as input: mute MixerAux3 (MX3AUXG)
#define	R22_PLAYBACK_MIXER_LEFT_CONTROL_0_ADDR              0x401C
#define	R22_PLAYBACK_MIXER_LEFT_CONTROL_0_VALUE             0x21

//Mixer 3 (Playback Mixer Left): Don't use right input mixer (mixer1?) and left input mixer (mixer2?) as input for mixer 3
#define	R23_PLAYBACK_MIXER_LEFT_CONTROL_1_ADDR              0x401D
#define	R23_PLAYBACK_MIXER_LEFT_CONTROL_1_VALUE             0x00

//Mixer 4 (Playback Mixer Right): Enable Mixer4 and select the right DAC channel as input don't use RAUX bypass: mute MixerAux4 (MX4AUXG)
#define	R24_PLAYBACK_MIXER_RIGHT_CONTROL_0_ADDR             0x401E
#define	R24_PLAYBACK_MIXER_RIGHT_CONTROL_0_VALUE            0x41

//Mixer 4 (Playback Mixer Right): Don't use right input mixer (mixer1?) and left input mixer (mixer2?) as input for mixer 4
#define	R25_PLAYBACK_MIXER_RIGHT_CONTROL_1_ADDR             0x401F
#define	R25_PLAYBACK_MIXER_RIGHT_CONTROL_1_VALUE            0x00

//Mixer 5 (LINE OUT only Mixer Left) 0dB, input = left channel playback mixer (Mixer 4)
#define	R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL_ADDR     0x4020
#define	R26_PLAYBACK_LR_MIXER_LEFT_LINE_OUTPUT_CONTROL_VALUE    0x03

//Mixer 6 (LINE OUT only Mixer Right) 0dB, input = right channel playback mixer (Mixer 4)
#define	R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL_ADDR    0x4021
#define	R27_PLAYBACK_LR_MIXER_RIGHT_LINE_OUTPUT_CONTROL_VALUE   0x09

//Mixer7 enabled for MONO OUPTUT (syfala: 0x01 to 0x00)
#define	R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL_ADDR          0x4022
#define	R28_PLAYBACK_LR_MIXER_MONO_OUTPUT_CONTROL_VALUE 		0x00

//[HEADPHONE OUTPUT] Left output: 0dB, headĥone mode (syfala: 0x97 to 0xE7)
#define	R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL_ADDR         0x4023
#define	R29_PLAYBACK_HEADPHONE_LEFT_VOLUME_CONTROL_VALUE        0b11100110

//[HEADPHONE OUTPUT] Right output: 0dB, headĥone mode (syfala: 0x97 to 0xE7)
#define	R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL_ADDR        0x4024
#define	R30_PLAYBACK_HEADPHONE_RIGHT_VOLUME_CONTROL_VALUE       0b11100111

//[LINE OUTPUT] Left output: 0db, headphone mode
#define	R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL_ADDR       0x4025
#define	R31_PLAYBACK_LINE_OUTPUT_LEFT_VOLUME_CONTROL_VALUE      0xE7

//[LINE OUTPUT] Right output: 0db, headphone mode
#define	R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL_ADDR      0x4026
#define	R32_PLAYBACK_LINE_OUTPUT_RIGHT_VOLUME_CONTROL_VALUE 	0xE7

//disable mono
#define	R33_PLAYBACK_MONO_OUTPUT_CONTROL_ADDR                   0x4027
#define	R33_PLAYBACK_MONO_OUTPUT_CONTROL_VALUE                  0x00

//enable pop and click suppression
#define	R34_PLAYBACK_POP_CLICK_SUPPRESSION_ADDR                 0x4028
#define	R34_PLAYBACK_POP_CLICK_SUPPRESSION_VALUE                0x00

//Enabling both channels
#define	R35_PLAYBACK_POWER_MANAGEMENT_ADDR                      0x4029
#define	R35_PLAYBACK_POWER_MANAGEMENT_VALUE 					0x03

//DAC are both connected
#define	R36_DAC_CONTROL_0_ADDR                                  0x402A
#define	R36_DAC_CONTROL_0_VALUE 								0x03

#define	R37_DAC_CONTROL_1_ADDR                                  0x402B
#define	R37_DAC_CONTROL_1_VALUE                                 NC

#define	R38_DAC_CONTROL_2_ADDR                                  0x402C
#define	R38_DAC_CONTROL_2_VALUE 								NC

#define	R39_SERIAL_PORT_PAD_CONTROL_ADDR                        0x402D
#define	R39_SERIAL_PORT_PAD_CONTROL_VALUE                       NC

#define	R40_CONTROL_PORT_PAD_CONTROL_0_ADDR                     0x402F
#define	R40_CONTROL_PORT_PAD_CONTROL_0_VALUE                    NC

#define	R41_CONTROL_PORT_PAD_CONTROL_1_ADDR                     0x4030
#define	R41_CONTROL_PORT_PAD_CONTROL_1_VALUE                    NC

#define	R42_JACK_DETECT_PIN_CONTROL_ADDR                        0x4031
#define	R42_JACK_DETECT_PIN_CONTROL_VALUE                       NC

#define	R67_DEJITTER_CONTROL_ADDR                               0x4036
#define	R67_DEJITTER_CONTROL_VALUE                              NC

//Serial input [L0,R0] to DAC
#define	R58_SERIAL_INPUT_ROUTE_CONTROL_ADDR                     0x40F2
#define	R58_SERIAL_INPUT_ROUTE_CONTROL_VALUE					0x01

//Serial output to L0 R0
#define	R59_SERIAL_OUTPUT_ROUTE_CONTROL_ADDR                    0x40F3
#define	R59_SERIAL_OUTPUT_ROUTE_CONTROL_VALUE                   0x01

//Enable LRCLK and BLCK
#define	R60_SERIAL_DATA_GPIO_CONGIURATION_ADDR                  0x40F4
#define	R60_SERIAL_DATA_GPIO_CONGIURATION_VALUE                 0x00

#define	R61_DSP_ENABLE_ADDR                                     0x40F5
#define	R61_DSP_ENABLE_VALUE									NC

#define	R62_DSP_RUN_ADDR                                        0x40F6
#define	R62_DSP_RUN_VALUE                                       NC

#define	R63_DSP_SLEW_MODES_ADDR                                 0x40F7
#define	R63_DSP_SLEW_MODES_VALUE								NC

//ADC, DAC sampling rate to 48KHz
#define	R64_SERIAL_PORT_SAMPLING_RATE_ADDR                      0x40F8
#define	R64_SERIAL_PORT_SAMPLING_RATE_VALUE 					0x00

//Enable all digital circuits except Codec slew
#define	R65_CLOCK_ENABLE_0_ADDR                                 0x40F9
#define	R65_CLOCK_ENABLE_0_VALUE                                0x7F

//Turns on CLK0 and CLK1
#define	R66_CLOCK_ENABLE_1_ADDR                                 0x40FA
#define	R66_CLOCK_ENABLE_1_VALUE								0x03

#endif /* ADAU1761REG_H_ */
