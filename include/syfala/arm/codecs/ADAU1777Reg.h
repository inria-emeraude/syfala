/*
 * File:           C:\Users\Maxime\Documents\ADAU Firmware\ADAU1777\ConfigSTDpatched_IC_1_REG.h
 *
 * Created:        Tuesday, January 10, 2023 2:32:29 PM
 * Description:    ConfigSTD:IC 1 control register definitions.
 *
 * This software is distributed in the hope that it will be useful,
 * but is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * This software may only be used to program products purchased from
 * Analog Devices for incorporation by you into audio products that
 * are intended for resale to audio product end users. This software
 * may not be distributed whole or in any part to third parties.
 *
 * Copyright ©2023 Analog Devices, Inc. All rights reserved.
 */
#ifndef __CONFIGSTDPATCHED_IC_1_REG_H__
#define __CONFIGSTDPATCHED_IC_1_REG_H__


/* CLK_CONTROL  - Registers (IC 1) */
#define REG_CLK_CONTROL_IC_1_ADDR                 0x0
#define REG_CLK_CONTROL_IC_1_BYTE                 1
#define REG_CLK_CONTROL_IC_1_VALUE                0x11

/* PLL_CTRL0  - Registers (IC 1) */
#define REG_PLL_CTRL0_IC_1_ADDR                   0x1
#define REG_PLL_CTRL0_IC_1_BYTE                   1
#define REG_PLL_CTRL0_IC_1_VALUE                  0x0

/* PLL_CTRL1  - Registers (IC 1) */
#define REG_PLL_CTRL1_IC_1_ADDR                   0x2
#define REG_PLL_CTRL1_IC_1_BYTE                   1
#define REG_PLL_CTRL1_IC_1_VALUE                  0x1

/* PLL_CTRL2  - Registers (IC 1) */
#define REG_PLL_CTRL2_IC_1_ADDR                   0x3
#define REG_PLL_CTRL2_IC_1_BYTE                   1
#define REG_PLL_CTRL2_IC_1_VALUE                  0x0

/* PLL_CTRL3  - Registers (IC 1) */
#define REG_PLL_CTRL3_IC_1_ADDR                   0x4
#define REG_PLL_CTRL3_IC_1_BYTE                   1
#define REG_PLL_CTRL3_IC_1_VALUE                  0x0

/* PLL_CTRL4  - Registers (IC 1) */
#define REG_PLL_CTRL4_IC_1_ADDR                   0x5
#define REG_PLL_CTRL4_IC_1_BYTE                   1
#define REG_PLL_CTRL4_IC_1_VALUE                  0x10

/* PLL_CTRL5  - Registers (IC 1) */
#define REG_PLL_CTRL5_IC_1_ADDR                   0x6
#define REG_PLL_CTRL5_IC_1_BYTE                   0
#define REG_PLL_CTRL5_IC_1_VALUE                  0x0

/* CLKOUT_SEL  - Registers (IC 1) */
#define REG_CLKOUT_SEL_IC_1_ADDR                  0x7
#define REG_CLKOUT_SEL_IC_1_BYTE                  1
#define REG_CLKOUT_SEL_IC_1_VALUE                 0x7

/* REGULATOR  - Registers (IC 1) */
#define REG_REGULATOR_IC_1_ADDR                   0x8
#define REG_REGULATOR_IC_1_BYTE                   1
#define REG_REGULATOR_IC_1_VALUE                  0x1

/* CORE_CONTROL  - Registers (IC 1) */
#define REG_CORE_CONTROL_IC_1_ADDR                0x9
#define REG_CORE_CONTROL_IC_1_BYTE                1
#define REG_CORE_CONTROL_IC_1_VALUE               0x6

/* SLEEP_INST  - Registers (IC 1) */
#define REG_SLEEP_INST_IC_1_ADDR                  0xA
#define REG_SLEEP_INST_IC_1_BYTE                  1
#define REG_SLEEP_INST_IC_1_VALUE                 0x0

/* CORE_ENABLE  - Registers (IC 1) */
#define REG_CORE_ENABLE_IC_1_ADDR                 0xB
#define REG_CORE_ENABLE_IC_1_BYTE                 1
#define REG_CORE_ENABLE_IC_1_VALUE                0x0

/* DBREG0  - Registers (IC 1) */
#define REG_DBREG0_IC_1_ADDR                      0xC
#define REG_DBREG0_IC_1_BYTE                      0
#define REG_DBREG0_IC_1_VALUE                     0x0

/* DBREG1  - Registers (IC 1) */
#define REG_DBREG1_IC_1_ADDR                      0xD
#define REG_DBREG1_IC_1_BYTE                      0
#define REG_DBREG1_IC_1_VALUE                     0x0

/* DBREG2  - Registers (IC 1) */
#define REG_DBREG2_IC_1_ADDR                      0xE
#define REG_DBREG2_IC_1_BYTE                      0
#define REG_DBREG2_IC_1_VALUE                     0x0

/* CORE_IN_MUX_0_1  - Registers (IC 1) */
#define REG_CORE_IN_MUX_0_1_IC_1_ADDR             0xF
#define REG_CORE_IN_MUX_0_1_IC_1_BYTE             1
#define REG_CORE_IN_MUX_0_1_IC_1_VALUE            0x10

/* CORE_IN_MUX_2_3  - Registers (IC 1) */
#define REG_CORE_IN_MUX_2_3_IC_1_ADDR             0x10
#define REG_CORE_IN_MUX_2_3_IC_1_BYTE             1
#define REG_CORE_IN_MUX_2_3_IC_1_VALUE            0x32

/* DAC_SOURCE_0_1  - Registers (IC 1) */
#define REG_DAC_SOURCE_0_1_IC_1_ADDR              0x11
#define REG_DAC_SOURCE_0_1_IC_1_BYTE              1
#define REG_DAC_SOURCE_0_1_IC_1_VALUE             0xDC

/* PDM_SOURCE_0_1  - Registers (IC 1) */
#define REG_PDM_SOURCE_0_1_IC_1_ADDR              0x12
#define REG_PDM_SOURCE_0_1_IC_1_BYTE              1
#define REG_PDM_SOURCE_0_1_IC_1_VALUE             0x22

/* SOUT_SOURCE_0_1  - Registers (IC 1) */
#define REG_SOUT_SOURCE_0_1_IC_1_ADDR             0x13
#define REG_SOUT_SOURCE_0_1_IC_1_BYTE             1
#define REG_SOUT_SOURCE_0_1_IC_1_VALUE            0x76

/* SOUT_SOURCE_2_3  - Registers (IC 1) */
#define REG_SOUT_SOURCE_2_3_IC_1_ADDR             0x14
#define REG_SOUT_SOURCE_2_3_IC_1_BYTE             1
#define REG_SOUT_SOURCE_2_3_IC_1_VALUE            0x44

/* SOUT_SOURCE_4_5  - Registers (IC 1) */
#define REG_SOUT_SOURCE_4_5_IC_1_ADDR             0x15
#define REG_SOUT_SOURCE_4_5_IC_1_BYTE             1
#define REG_SOUT_SOURCE_4_5_IC_1_VALUE            0x54

/* SOUT_SOURCE_6_7  - Registers (IC 1) */
#define REG_SOUT_SOURCE_6_7_IC_1_ADDR             0x16
#define REG_SOUT_SOURCE_6_7_IC_1_BYTE             1
#define REG_SOUT_SOURCE_6_7_IC_1_VALUE            0x76

/* ADC_SDATA_CH  - Registers (IC 1) */
#define REG_ADC_SDATA_CH_IC_1_ADDR                0x17
#define REG_ADC_SDATA_CH_IC_1_BYTE                1
#define REG_ADC_SDATA_CH_IC_1_VALUE               0x0

/* ASRCO_SOURCE_0_1  - Registers (IC 1) */
#define REG_ASRCO_SOURCE_0_1_IC_1_ADDR            0x18
#define REG_ASRCO_SOURCE_0_1_IC_1_BYTE            1
#define REG_ASRCO_SOURCE_0_1_IC_1_VALUE           0x44

/* ASRCO_SOURCE_2_3  - Registers (IC 1) */
#define REG_ASRCO_SOURCE_2_3_IC_1_ADDR            0x19
#define REG_ASRCO_SOURCE_2_3_IC_1_BYTE            1
#define REG_ASRCO_SOURCE_2_3_IC_1_VALUE           0x76

/* ASRC_MODE  - Registers (IC 1) */
#define REG_ASRC_MODE_IC_1_ADDR                   0x1A
#define REG_ASRC_MODE_IC_1_BYTE                   1
#define REG_ASRC_MODE_IC_1_VALUE                  0x3

/* ADC_CONTROL0  - Registers (IC 1) */
#define REG_ADC_CONTROL0_IC_1_ADDR                0x1B
#define REG_ADC_CONTROL0_IC_1_BYTE                1
#define REG_ADC_CONTROL0_IC_1_VALUE               0x2

/* ADC_CONTROL1  - Registers (IC 1) */
#define REG_ADC_CONTROL1_IC_1_ADDR                0x1C
#define REG_ADC_CONTROL1_IC_1_BYTE                1
#define REG_ADC_CONTROL1_IC_1_VALUE               0x22

/* ADC_CONTROL2  - Registers (IC 1) */
#define REG_ADC_CONTROL2_IC_1_ADDR                0x1D
#define REG_ADC_CONTROL2_IC_1_BYTE                1
#define REG_ADC_CONTROL2_IC_1_VALUE               0x3

/* ADC_CONTROL3  - Registers (IC 1) */
#define REG_ADC_CONTROL3_IC_1_ADDR                0x1E
#define REG_ADC_CONTROL3_IC_1_BYTE                1
#define REG_ADC_CONTROL3_IC_1_VALUE               0x3

/* ADC0_VOLUME  - Registers (IC 1) */
#define REG_ADC0_VOLUME_IC_1_ADDR                 0x1F
#define REG_ADC0_VOLUME_IC_1_BYTE                 1
#define REG_ADC0_VOLUME_IC_1_VALUE                0x0

/* ADC1_VOLUME  - Registers (IC 1) */
#define REG_ADC1_VOLUME_IC_1_ADDR                 0x20
#define REG_ADC1_VOLUME_IC_1_BYTE                 1
#define REG_ADC1_VOLUME_IC_1_VALUE                0x0

/* ADC2_VOLUME  - Registers (IC 1) */
#define REG_ADC2_VOLUME_IC_1_ADDR                 0x21
#define REG_ADC2_VOLUME_IC_1_BYTE                 1
#define REG_ADC2_VOLUME_IC_1_VALUE                0x0

/* ADC3_VOLUME  - Registers (IC 1) */
#define REG_ADC3_VOLUME_IC_1_ADDR                 0x22
#define REG_ADC3_VOLUME_IC_1_BYTE                 1
#define REG_ADC3_VOLUME_IC_1_VALUE                0x0

/* PGA_CONTROL_0  - Registers (IC 1) */
#define REG_PGA_CONTROL_0_IC_1_ADDR               0x23
#define REG_PGA_CONTROL_0_IC_1_BYTE               1
#define REG_PGA_CONTROL_0_IC_1_VALUE              0x40

/* PGA_CONTROL_1  - Registers (IC 1) */
#define REG_PGA_CONTROL_1_IC_1_ADDR               0x24
#define REG_PGA_CONTROL_1_IC_1_BYTE               1
#define REG_PGA_CONTROL_1_IC_1_VALUE              0x40

/* PGA_CONTROL_2  - Registers (IC 1) */
#define REG_PGA_CONTROL_2_IC_1_ADDR               0x25
#define REG_PGA_CONTROL_2_IC_1_BYTE               1
#define REG_PGA_CONTROL_2_IC_1_VALUE              0x40

/* PGA_CONTROL_3  - Registers (IC 1) */
#define REG_PGA_CONTROL_3_IC_1_ADDR               0x26
#define REG_PGA_CONTROL_3_IC_1_BYTE               1
#define REG_PGA_CONTROL_3_IC_1_VALUE              0x40

/* PGA_STEP_CONTROL  - Registers (IC 1) */
#define REG_PGA_STEP_CONTROL_IC_1_ADDR            0x27
#define REG_PGA_STEP_CONTROL_IC_1_BYTE            1
#define REG_PGA_STEP_CONTROL_IC_1_VALUE           0x0

/* PGA_10DB_BOOST  - Registers (IC 1) */
#define REG_PGA_10DB_BOOST_IC_1_ADDR              0x28
#define REG_PGA_10DB_BOOST_IC_1_BYTE              1
#define REG_PGA_10DB_BOOST_IC_1_VALUE             0x0

/* POP_SUPPRESS  - Registers (IC 1) */
#define REG_POP_SUPPRESS_IC_1_ADDR                0x29
#define REG_POP_SUPPRESS_IC_1_BYTE                1
#define REG_POP_SUPPRESS_IC_1_VALUE               0x3F

/* TALKTHRU  - Registers (IC 1) */
#define REG_TALKTHRU_IC_1_ADDR                    0x2A
#define REG_TALKTHRU_IC_1_BYTE                    1
#define REG_TALKTHRU_IC_1_VALUE                   0x0

/* TALKTHRU_GAIN0  - Registers (IC 1) */
#define REG_TALKTHRU_GAIN0_IC_1_ADDR              0x2B
#define REG_TALKTHRU_GAIN0_IC_1_BYTE              1
#define REG_TALKTHRU_GAIN0_IC_1_VALUE             0x0

/* TALKTHRU_GAIN1  - Registers (IC 1) */
#define REG_TALKTHRU_GAIN1_IC_1_ADDR              0x2C
#define REG_TALKTHRU_GAIN1_IC_1_BYTE              1
#define REG_TALKTHRU_GAIN1_IC_1_VALUE             0x0

/* MIC_BIAS  - Registers (IC 1) */
#define REG_MIC_BIAS_IC_1_ADDR                    0x2D
#define REG_MIC_BIAS_IC_1_BYTE                    1
#define REG_MIC_BIAS_IC_1_VALUE                   0x0

/* DAC_CONTROL1  - Registers (IC 1) */
#define REG_DAC_CONTROL1_IC_1_ADDR                0x2E
#define REG_DAC_CONTROL1_IC_1_BYTE                1
#define REG_DAC_CONTROL1_IC_1_VALUE               0x3

/* DAC0_VOLUME  - Registers (IC 1) */
#define REG_DAC0_VOLUME_IC_1_ADDR                 0x2F
#define REG_DAC0_VOLUME_IC_1_BYTE                 1
#define REG_DAC0_VOLUME_IC_1_VALUE                0x0

/* DAC1_VOLUME  - Registers (IC 1) */
#define REG_DAC1_VOLUME_IC_1_ADDR                 0x30
#define REG_DAC1_VOLUME_IC_1_BYTE                 1
#define REG_DAC1_VOLUME_IC_1_VALUE                0x0

/* OP_STAGE_MUTES  - Registers (IC 1) */
#define REG_OP_STAGE_MUTES_IC_1_ADDR              0x31
#define REG_OP_STAGE_MUTES_IC_1_BYTE              1
#define REG_OP_STAGE_MUTES_IC_1_VALUE             0x0

/* SAI_0  - Registers (IC 1) */
#define REG_SAI_0_IC_1_ADDR                       0x32
#define REG_SAI_0_IC_1_BYTE                       1
#define REG_SAI_0_IC_1_VALUE                      0x7 //Maybe change this to 0x4 for 24kHz or 0x3 for 16kHz

/* SAI_1  - Registers (IC 1) */
#define REG_SAI_1_IC_1_ADDR                       0x33
#define REG_SAI_1_IC_1_BYTE                       1
#define REG_SAI_1_IC_1_VALUE                      0x0

/* SOUT_CONTROL0  - Registers (IC 1) */
#define REG_SOUT_CONTROL0_IC_1_ADDR               0x34
#define REG_SOUT_CONTROL0_IC_1_BYTE               1
#define REG_SOUT_CONTROL0_IC_1_VALUE              0x0

/* SOUT_CONTROL1  - Registers (IC 1) */
#define REG_SOUT_CONTROL1_IC_1_ADDR               0x35
#define REG_SOUT_CONTROL1_IC_1_BYTE               1
#define REG_SOUT_CONTROL1_IC_1_VALUE              0x0

/* PDM_OUT  - Registers (IC 1) */
#define REG_PDM_OUT_IC_1_ADDR                     0x36
#define REG_PDM_OUT_IC_1_BYTE                     1
#define REG_PDM_OUT_IC_1_VALUE                    0x0

/* PDM_PATTERN  - Registers (IC 1) */
#define REG_PDM_PATTERN_IC_1_ADDR                 0x37
#define REG_PDM_PATTERN_IC_1_BYTE                 1
#define REG_PDM_PATTERN_IC_1_VALUE                0x0

/* MODE_MP0  - Registers (IC 1) */
#define REG_MODE_MP0_IC_1_ADDR                    0x38
#define REG_MODE_MP0_IC_1_BYTE                    1
#define REG_MODE_MP0_IC_1_VALUE                   0x0

/* MODE_MP1  - Registers (IC 1) */
#define REG_MODE_MP1_IC_1_ADDR                    0x39
#define REG_MODE_MP1_IC_1_BYTE                    1
#define REG_MODE_MP1_IC_1_VALUE                   0x0

/* MODE_MP2  - Registers (IC 1) */
#define REG_MODE_MP2_IC_1_ADDR                    0x3A
#define REG_MODE_MP2_IC_1_BYTE                    1
#define REG_MODE_MP2_IC_1_VALUE                   0x0

/* MODE_MP3  - Registers (IC 1) */
#define REG_MODE_MP3_IC_1_ADDR                    0x3B
#define REG_MODE_MP3_IC_1_BYTE                    1
#define REG_MODE_MP3_IC_1_VALUE                   0x0

/* MODE_MP4  - Registers (IC 1) */
#define REG_MODE_MP4_IC_1_ADDR                    0x3C
#define REG_MODE_MP4_IC_1_BYTE                    1
#define REG_MODE_MP4_IC_1_VALUE                   0x0

/* MODE_MP5  - Registers (IC 1) */
#define REG_MODE_MP5_IC_1_ADDR                    0x3D
#define REG_MODE_MP5_IC_1_BYTE                    1
#define REG_MODE_MP5_IC_1_VALUE                   0x0

/* MODE_MP6  - Registers (IC 1) */
#define REG_MODE_MP6_IC_1_ADDR                    0x3E
#define REG_MODE_MP6_IC_1_BYTE                    1
#define REG_MODE_MP6_IC_1_VALUE                   0x0

/* PB_VOL_SET  - Registers (IC 1) */
#define REG_PB_VOL_SET_IC_1_ADDR                  0x3F
#define REG_PB_VOL_SET_IC_1_BYTE                  1
#define REG_PB_VOL_SET_IC_1_VALUE                 0x0

/* PB_VOL_CONV  - Registers (IC 1) */
#define REG_PB_VOL_CONV_IC_1_ADDR                 0x40
#define REG_PB_VOL_CONV_IC_1_BYTE                 1
#define REG_PB_VOL_CONV_IC_1_VALUE                0x87

/* DEBOUNCE_MODE  - Registers (IC 1) */
#define REG_DEBOUNCE_MODE_IC_1_ADDR               0x41
#define REG_DEBOUNCE_MODE_IC_1_BYTE               1
#define REG_DEBOUNCE_MODE_IC_1_VALUE              0x5

/* RESERVED  - Registers (IC 1) */
#define REG_RESERVED_IC_1_ADDR                    0x42
#define REG_RESERVED_IC_1_BYTE                    1
#define REG_RESERVED_IC_1_VALUE                   0x0

/* OP_STAGE_CTRL  - Registers (IC 1) */
#define REG_OP_STAGE_CTRL_IC_1_ADDR               0x43
#define REG_OP_STAGE_CTRL_IC_1_BYTE               1
#define REG_OP_STAGE_CTRL_IC_1_VALUE              0x30

/* DECIM_PWR_MODES  - Registers (IC 1) */
#define REG_DECIM_PWR_MODES_IC_1_ADDR             0x44
#define REG_DECIM_PWR_MODES_IC_1_BYTE             1
#define REG_DECIM_PWR_MODES_IC_1_VALUE            0xCC

/* INTERP_PWR_MODES  - Registers (IC 1) */
#define REG_INTERP_PWR_MODES_IC_1_ADDR            0x45
#define REG_INTERP_PWR_MODES_IC_1_BYTE            1
#define REG_INTERP_PWR_MODES_IC_1_VALUE           0xF

/* BIAS_CONTROL0  - Registers (IC 1) */
#define REG_BIAS_CONTROL0_IC_1_ADDR               0x46
#define REG_BIAS_CONTROL0_IC_1_BYTE               1
#define REG_BIAS_CONTROL0_IC_1_VALUE              0x0

/* BIAS_CONTROL1  - Registers (IC 1) */
#define REG_BIAS_CONTROL1_IC_1_ADDR               0x47
#define REG_BIAS_CONTROL1_IC_1_BYTE               1
#define REG_BIAS_CONTROL1_IC_1_VALUE              0x0

/* PAD_CONTROL0  - Registers (IC 1) */
#define REG_PAD_CONTROL0_IC_1_ADDR                0x48
#define REG_PAD_CONTROL0_IC_1_BYTE                1
#define REG_PAD_CONTROL0_IC_1_VALUE               0x7F

/* PAD_CONTROL1  - Registers (IC 1) */
#define REG_PAD_CONTROL1_IC_1_ADDR                0x49
#define REG_PAD_CONTROL1_IC_1_BYTE                1
#define REG_PAD_CONTROL1_IC_1_VALUE               0x1F

/* PAD_CONTROL2  - Registers (IC 1) */
#define REG_PAD_CONTROL2_IC_1_ADDR                0x4A
#define REG_PAD_CONTROL2_IC_1_BYTE                1
#define REG_PAD_CONTROL2_IC_1_VALUE               0x0

/* PAD_CONTROL3  - Registers (IC 1) */
#define REG_PAD_CONTROL3_IC_1_ADDR                0x4B
#define REG_PAD_CONTROL3_IC_1_BYTE                1
#define REG_PAD_CONTROL3_IC_1_VALUE               0x0

/* PAD_CONTROL4  - Registers (IC 1) */
#define REG_PAD_CONTROL4_IC_1_ADDR                0x4C
#define REG_PAD_CONTROL4_IC_1_BYTE                1
#define REG_PAD_CONTROL4_IC_1_VALUE               0x0

/* PAD_CONTROL5  - Registers (IC 1) */
#define REG_PAD_CONTROL5_IC_1_ADDR                0x4D
#define REG_PAD_CONTROL5_IC_1_BYTE                1
#define REG_PAD_CONTROL5_IC_1_VALUE               0x0

/* FAST_RATE  - Registers (IC 1) */
#define REG_FAST_RATE_IC_1_ADDR                   0x4E
#define REG_FAST_RATE_IC_1_BYTE                   1
#define REG_FAST_RATE_IC_1_VALUE                  0x0

/* DAC_CONTROL0  - Registers (IC 1) */
#define REG_DAC_CONTROL0_IC_1_ADDR                0x4F
#define REG_DAC_CONTROL0_IC_1_BYTE                1
#define REG_DAC_CONTROL0_IC_1_VALUE               0x0

/* VOL_BYPASS  - Registers (IC 1) */
#define REG_VOL_BYPASS_IC_1_ADDR                  0x54
#define REG_VOL_BYPASS_IC_1_BYTE                  1
#define REG_VOL_BYPASS_IC_1_VALUE                 0x0

/* ADC OPER  - Registers (IC 1) */
#define REG_ADC_OPER_IC_1_ADDR                    0x60
#define REG_ADC_OPER_IC_1_BYTE                    1
#define REG_ADC_OPER_IC_1_VALUE                   0xA0


/*
 *
 * Control register's field descriptions
 *
 */

/* CLK_CONTROL (IC 1) */
#define R0_COREN_IC_1                             0x1    /* 1b	[0] */
#define R0_CC_MDIV_IC_1                           0x0    /* 0b	[1] */
#define R0_CC_CDIV_IC_1                           0x0    /* 0b	[2] */
#define R0_CLKSRC_IC_1                            0x0    /* 0b	[3] */
#define R0_XTAL_DIS_IC_1                          0x1    /* 1b	[4] */
#define R0_SPK_FLT_DIS_IC_1                       0x0    /* 0b	[5] */
#define R0_PLL_EN_IC_1                            0x0    /* 0b	[7] */
#define R0_COREN_IC_1_MASK                        0x1
#define R0_COREN_IC_1_SHIFT                       0
#define R0_CC_MDIV_IC_1_MASK                      0x2
#define R0_CC_MDIV_IC_1_SHIFT                     1
#define R0_CC_CDIV_IC_1_MASK                      0x4
#define R0_CC_CDIV_IC_1_SHIFT                     2
#define R0_CLKSRC_IC_1_MASK                       0x8
#define R0_CLKSRC_IC_1_SHIFT                      3
#define R0_XTAL_DIS_IC_1_MASK                     0x10
#define R0_XTAL_DIS_IC_1_SHIFT                    4
#define R0_SPK_FLT_DIS_IC_1_MASK                  0x20
#define R0_SPK_FLT_DIS_IC_1_SHIFT                 5
#define R0_PLL_EN_IC_1_MASK                       0x80
#define R0_PLL_EN_IC_1_SHIFT                      7

/* PLL_CTRL0 (IC 1) */
#define R1_M_MSB_IC_1                             0x00   /* 00000000b	[7:0] */
#define R1_M_MSB_IC_1_MASK                        0xFF
#define R1_M_MSB_IC_1_SHIFT                       0

/* PLL_CTRL1 (IC 1) */
#define R2_M_LSB_IC_1                             0x01   /* 00000001b	[7:0] */
#define R2_M_LSB_IC_1_MASK                        0xFF
#define R2_M_LSB_IC_1_SHIFT                       0

/* PLL_CTRL2 (IC 1) */
#define R3_N_MSB_IC_1                             0x00   /* 00000000b	[7:0] */
#define R3_N_MSB_IC_1_MASK                        0xFF
#define R3_N_MSB_IC_1_SHIFT                       0

/* PLL_CTRL3 (IC 1) */
#define R4_N_LSB_IC_1                             0x00   /* 00000000b	[7:0] */
#define R4_N_LSB_IC_1_MASK                        0xFF
#define R4_N_LSB_IC_1_SHIFT                       0

/* PLL_CTRL4 (IC 1) */
#define R5_PLL_TYPE_IC_1                          0x0    /* 0b	[0] */
#define R5_X_IC_1                                 0x0    /* 00b	[2:1] */
#define R5_R_IC_1                                 0x2    /* 0010b	[6:3] */
#define R5_PLL_TYPE_IC_1_MASK                     0x1
#define R5_PLL_TYPE_IC_1_SHIFT                    0
#define R5_X_IC_1_MASK                            0x6
#define R5_X_IC_1_SHIFT                           1
#define R5_R_IC_1_MASK                            0x78
#define R5_R_IC_1_SHIFT                           3

/* PLL_CTRL5 (IC 1) */
#define R6_LOCK_IC_1                              0x0    /* 0b	[0] */
#define R6_LOCK_IC_1_MASK                         0x1
#define R6_LOCK_IC_1_SHIFT                        0

/* CLKOUT_SEL (IC 1) */
#define R7_CLKOUT_FREQ_IC_1                       0x7    /* 111b	[2:0] */
#define R7_CLKOUT_FREQ_IC_1_MASK                  0x7
#define R7_CLKOUT_FREQ_IC_1_SHIFT                 0

/* REGULATOR (IC 1) */
#define R8_REGV_IC_1                              0x1    /* 01b	[1:0] */
#define R8_REG_PD_IC_1                            0x0    /* 0b	[2] */
#define R8_REGV_IC_1_MASK                         0x3
#define R8_REGV_IC_1_SHIFT                        0
#define R8_REG_PD_IC_1_MASK                       0x4
#define R8_REG_PD_IC_1_SHIFT                      2

/* CORE_CONTROL (IC 1) */
#define R9_CORE_RUN_IC_1                          0x0    /* 0b	[0] */
#define R9_CORE_FS_IC_1                           0x3    /* 11b	[2:1] */
#define R9_FAST_SLOW_RATE_IC_1                    0x0    /* 00b	[4:3] */
#define R9_BANK_SL_IC_1                           0x0    /* 00b	[6:5] */
#define R9_ZERO_STATE_IC_1                        0x0    /* 0b	[7] */
#define R9_CORE_RUN_IC_1_MASK                     0x1
#define R9_CORE_RUN_IC_1_SHIFT                    0
#define R9_CORE_FS_IC_1_MASK                      0x6
#define R9_CORE_FS_IC_1_SHIFT                     1
#define R9_FAST_SLOW_RATE_IC_1_MASK               0x18
#define R9_FAST_SLOW_RATE_IC_1_SHIFT              3
#define R9_BANK_SL_IC_1_MASK                      0x60
#define R9_BANK_SL_IC_1_SHIFT                     5
#define R9_ZERO_STATE_IC_1_MASK                   0x80
#define R9_ZERO_STATE_IC_1_SHIFT                  7

/* SLEEP_INST (IC 1) */
#define R10_SLEEP_IC_1                            0x0    /* 00000b	[4:0] */
#define R10_SLEEP_IC_1_MASK                       0x1F
#define R10_SLEEP_IC_1_SHIFT                      0

/* CORE_ENABLE (IC 1) */
#define R11_DSP_CLK_EN_IC_1                       0x0    /* 0b	[0] */
#define R11_LIM_EN_IC_1                           0x0    /* 0b	[1] */
#define R11_DSP_CLK_EN_IC_1_MASK                  0x1
#define R11_DSP_CLK_EN_IC_1_SHIFT                 0
#define R11_LIM_EN_IC_1_MASK                      0x2
#define R11_LIM_EN_IC_1_SHIFT                     1

/* DBREG0 (IC 1) */
#define R12_ABSVAL0_IC_1                          0x00   /* 00000000b	[7:0] */
#define R12_ABSVAL0_IC_1_MASK                     0xFF
#define R12_ABSVAL0_IC_1_SHIFT                    0

/* DBREG1 (IC 1) */
#define R13_ABSVAL1_IC_1                          0x00   /* 00000000b	[7:0] */
#define R13_ABSVAL1_IC_1_MASK                     0xFF
#define R13_ABSVAL1_IC_1_SHIFT                    0

/* DBREG2 (IC 1) */
#define R14_ABSVAL2_IC_1                          0x00   /* 00000000b	[7:0] */
#define R14_ABSVAL2_IC_1_MASK                     0xFF
#define R14_ABSVAL2_IC_1_SHIFT                    0

/* CORE_IN_MUX_0_1 (IC 1) */
#define R15_CORE_IN_MUX_SEL_0_IC_1                0x0    /* 0000b	[3:0] */
#define R15_CORE_IN_MUX_SEL_1_IC_1                0x1    /* 0001b	[7:4] */
#define R15_CORE_IN_MUX_SEL_0_IC_1_MASK           0xF
#define R15_CORE_IN_MUX_SEL_0_IC_1_SHIFT          0
#define R15_CORE_IN_MUX_SEL_1_IC_1_MASK           0xF0
#define R15_CORE_IN_MUX_SEL_1_IC_1_SHIFT          4

/* CORE_IN_MUX_2_3 (IC 1) */
#define R16_CORE_IN_MUX_SEL_2_IC_1                0x2    /* 0010b	[3:0] */
#define R16_CORE_IN_MUX_SEL_3_IC_1                0x3    /* 0011b	[7:4] */
#define R16_CORE_IN_MUX_SEL_2_IC_1_MASK           0xF
#define R16_CORE_IN_MUX_SEL_2_IC_1_SHIFT          0
#define R16_CORE_IN_MUX_SEL_3_IC_1_MASK           0xF0
#define R16_CORE_IN_MUX_SEL_3_IC_1_SHIFT          4

/* DAC_SOURCE_0_1 (IC 1) */
#define R17_DAC_SOURCE0_IC_1                      0xC    /* 1100b	[3:0] */
#define R17_DAC_SOURCE1_IC_1                      0xD    /* 1101b	[7:4] */
#define R17_DAC_SOURCE0_IC_1_MASK                 0xF
#define R17_DAC_SOURCE0_IC_1_SHIFT                0
#define R17_DAC_SOURCE1_IC_1_MASK                 0xF0
#define R17_DAC_SOURCE1_IC_1_SHIFT                4

/* PDM_SOURCE_0_1 (IC 1) */
#define R18_PDM_SOURCE0_IC_1                      0x2    /* 0010b	[3:0] */
#define R18_PDM_SOURCE1_IC_1                      0x2    /* 0010b	[7:4] */
#define R18_PDM_SOURCE0_IC_1_MASK                 0xF
#define R18_PDM_SOURCE0_IC_1_SHIFT                0
#define R18_PDM_SOURCE1_IC_1_MASK                 0xF0
#define R18_PDM_SOURCE1_IC_1_SHIFT                4

/* SOUT_SOURCE_0_1 (IC 1) */
#define R19_SOUT_SOURCE0_IC_1                     0x6    /* 0110b	[3:0] */
#define R19_SOUT_SOURCE1_IC_1                     0x7    /* 0111b	[7:4] */
#define R19_SOUT_SOURCE0_IC_1_MASK                0xF
#define R19_SOUT_SOURCE0_IC_1_SHIFT               0
#define R19_SOUT_SOURCE1_IC_1_MASK                0xF0
#define R19_SOUT_SOURCE1_IC_1_SHIFT               4

/* SOUT_SOURCE_2_3 (IC 1) */
#define R20_SOUT_SOURCE2_IC_1                     0x4    /* 0100b	[3:0] */
#define R20_SOUT_SOURCE3_IC_1                     0x4    /* 0100b	[7:4] */
#define R20_SOUT_SOURCE2_IC_1_MASK                0xF
#define R20_SOUT_SOURCE2_IC_1_SHIFT               0
#define R20_SOUT_SOURCE3_IC_1_MASK                0xF0
#define R20_SOUT_SOURCE3_IC_1_SHIFT               4

/* SOUT_SOURCE_4_5 (IC 1) */
#define R21_SOUT_SOURCE4_IC_1                     0x4    /* 0100b	[3:0] */
#define R21_SOUT_SOURCE5_IC_1                     0x5    /* 0101b	[7:4] */
#define R21_SOUT_SOURCE4_IC_1_MASK                0xF
#define R21_SOUT_SOURCE4_IC_1_SHIFT               0
#define R21_SOUT_SOURCE5_IC_1_MASK                0xF0
#define R21_SOUT_SOURCE5_IC_1_SHIFT               4

/* SOUT_SOURCE_6_7 (IC 1) */
#define R22_SOUT_SOURCE6_IC_1                     0x6    /* 0110b	[3:0] */
#define R22_SOUT_SOURCE7_IC_1                     0x7    /* 0111b	[7:4] */
#define R22_SOUT_SOURCE6_IC_1_MASK                0xF
#define R22_SOUT_SOURCE6_IC_1_SHIFT               0
#define R22_SOUT_SOURCE7_IC_1_MASK                0xF0
#define R22_SOUT_SOURCE7_IC_1_SHIFT               4

/* ADC_SDATA_CH (IC 1) */
#define R23_ADC_SDATA0_ST_IC_1                    0x0    /* 00b	[1:0] */
#define R23_ADC_SDATA1_ST_IC_1                    0x0    /* 00b	[3:2] */
#define R23_ADC_SDATA0_ST_IC_1_MASK               0x3
#define R23_ADC_SDATA0_ST_IC_1_SHIFT              0
#define R23_ADC_SDATA1_ST_IC_1_MASK               0xC
#define R23_ADC_SDATA1_ST_IC_1_SHIFT              2

/* ASRCO_SOURCE_0_1 (IC 1) */
#define R24_ASRC_OUT_SOURCE0_IC_1                 0x4    /* 0100b	[3:0] */
#define R24_ASRC_OUT_SOURCE1_IC_1                 0x4    /* 0100b	[7:4] */
#define R24_ASRC_OUT_SOURCE0_IC_1_MASK            0xF
#define R24_ASRC_OUT_SOURCE0_IC_1_SHIFT           0
#define R24_ASRC_OUT_SOURCE1_IC_1_MASK            0xF0
#define R24_ASRC_OUT_SOURCE1_IC_1_SHIFT           4

/* ASRCO_SOURCE_2_3 (IC 1) */
#define R25_ASRC_OUT_SOURCE2_IC_1                 0x6    /* 0110b	[3:0] */
#define R25_ASRC_OUT_SOURCE3_IC_1                 0x7    /* 0111b	[7:4] */
#define R25_ASRC_OUT_SOURCE2_IC_1_MASK            0xF
#define R25_ASRC_OUT_SOURCE2_IC_1_SHIFT           0
#define R25_ASRC_OUT_SOURCE3_IC_1_MASK            0xF0
#define R25_ASRC_OUT_SOURCE3_IC_1_SHIFT           4

/* ASRC_MODE (IC 1) */
#define R26_ASRC_IN_EN_IC_1                       0x1    /* 1b	[0] */
#define R26_ASRC_OUT_EN_IC_1                      0x1    /* 1b	[1] */
#define R26_ASRC_IN_CH_IC_1                       0x0    /* 00b	[3:2] */
#define R26_ASRC_IN_EN_IC_1_MASK                  0x1
#define R26_ASRC_IN_EN_IC_1_SHIFT                 0
#define R26_ASRC_OUT_EN_IC_1_MASK                 0x2
#define R26_ASRC_OUT_EN_IC_1_SHIFT                1
#define R26_ASRC_IN_CH_IC_1_MASK                  0xC
#define R26_ASRC_IN_CH_IC_1_SHIFT                 2

/* ADC_CONTROL0 (IC 1) */
#define R27_ADC_0_1_FS_IC_1                       0x2    /* 10b	[1:0] */
#define R27_ADC0_MUTE_IC_1                        0x0    /* 0b	[3] */
#define R27_ADC1_MUTE_IC_1                        0x0    /* 0b	[4] */
#define R27_ADC_0_1_SINC_IC_1                     0x0    /* 0b	[5] */
#define R27_ADC_0_1_FS_IC_1_MASK                  0x3
#define R27_ADC_0_1_FS_IC_1_SHIFT                 0
#define R27_ADC0_MUTE_IC_1_MASK                   0x8
#define R27_ADC0_MUTE_IC_1_SHIFT                  3
#define R27_ADC1_MUTE_IC_1_MASK                   0x10
#define R27_ADC1_MUTE_IC_1_SHIFT                  4
#define R27_ADC_0_1_SINC_IC_1_MASK                0x20
#define R27_ADC_0_1_SINC_IC_1_SHIFT               5

/* ADC_CONTROL1 (IC 1) */
#define R28_ADC_2_3_FS_IC_1                       0x2    /* 10b	[1:0] */
#define R28_ADC2_MUTE_IC_1                        0x0    /* 0b	[3] */
#define R28_ADC3_MUTE_IC_1                        0x0    /* 0b	[4] */
#define R28_ADC_2_3_SINC_IC_1                     0x1    /* 1b	[5] */
#define R28_ADC_2_3_FS_IC_1_MASK                  0x3
#define R28_ADC_2_3_FS_IC_1_SHIFT                 0
#define R28_ADC2_MUTE_IC_1_MASK                   0x8
#define R28_ADC2_MUTE_IC_1_SHIFT                  3
#define R28_ADC3_MUTE_IC_1_MASK                   0x10
#define R28_ADC3_MUTE_IC_1_SHIFT                  4
#define R28_ADC_2_3_SINC_IC_1_MASK                0x20
#define R28_ADC_2_3_SINC_IC_1_SHIFT               5

/* ADC_CONTROL2 (IC 1) */
#define R29_ADC_0_EN_IC_1                         0x1    /* 1b	[0] */
#define R29_ADC_1_EN_IC_1                         0x1    /* 1b	[1] */
#define R29_DCM_0_1_IC_1                          0x0    /* 0b	[2] */
#define R29_DMIC_SW0_IC_1                         0x0    /* 0b	[3] */
#define R29_DMIC_POL0_IC_1                        0x0    /* 0b	[4] */
#define R29_HP_0_1_EN_IC_1                        0x0    /* 00b	[6:5] */
#define R29_ADC_0_EN_IC_1_MASK                    0x1
#define R29_ADC_0_EN_IC_1_SHIFT                   0
#define R29_ADC_1_EN_IC_1_MASK                    0x2
#define R29_ADC_1_EN_IC_1_SHIFT                   1
#define R29_DCM_0_1_IC_1_MASK                     0x4
#define R29_DCM_0_1_IC_1_SHIFT                    2
#define R29_DMIC_SW0_IC_1_MASK                    0x8
#define R29_DMIC_SW0_IC_1_SHIFT                   3
#define R29_DMIC_POL0_IC_1_MASK                   0x10
#define R29_DMIC_POL0_IC_1_SHIFT                  4
#define R29_HP_0_1_EN_IC_1_MASK                   0x60
#define R29_HP_0_1_EN_IC_1_SHIFT                  5

/* ADC_CONTROL3 (IC 1) */
#define R30_ADC_2_EN_IC_1                         0x1    /* 1b	[0] */
#define R30_ADC_3_EN_IC_1                         0x1    /* 1b	[1] */
#define R30_DCM_2_3_IC_1                          0x0    /* 0b	[2] */
#define R30_DMIC_SW1_IC_1                         0x0    /* 0b	[3] */
#define R30_DMIC_POL1_IC_1                        0x0    /* 0b	[4] */
#define R30_HP_2_3_EN_IC_1                        0x0    /* 00b	[6:5] */
#define R30_ADC_2_EN_IC_1_MASK                    0x1
#define R30_ADC_2_EN_IC_1_SHIFT                   0
#define R30_ADC_3_EN_IC_1_MASK                    0x2
#define R30_ADC_3_EN_IC_1_SHIFT                   1
#define R30_DCM_2_3_IC_1_MASK                     0x4
#define R30_DCM_2_3_IC_1_SHIFT                    2
#define R30_DMIC_SW1_IC_1_MASK                    0x8
#define R30_DMIC_SW1_IC_1_SHIFT                   3
#define R30_DMIC_POL1_IC_1_MASK                   0x10
#define R30_DMIC_POL1_IC_1_SHIFT                  4
#define R30_HP_2_3_EN_IC_1_MASK                   0x60
#define R30_HP_2_3_EN_IC_1_SHIFT                  5

/* ADC0_VOLUME (IC 1) */
#define R31_ADC_0_VOL_IC_1                        0x00   /* 00000000b	[7:0] */
#define R31_ADC_0_VOL_IC_1_MASK                   0xFF
#define R31_ADC_0_VOL_IC_1_SHIFT                  0

/* ADC1_VOLUME (IC 1) */
#define R32_ADC_1_VOL_IC_1                        0x00   /* 00000000b	[7:0] */
#define R32_ADC_1_VOL_IC_1_MASK                   0xFF
#define R32_ADC_1_VOL_IC_1_SHIFT                  0

/* ADC2_VOLUME (IC 1) */
#define R33_ADC_2_VOL_IC_1                        0x00   /* 00000000b	[7:0] */
#define R33_ADC_2_VOL_IC_1_MASK                   0xFF
#define R33_ADC_2_VOL_IC_1_SHIFT                  0

/* ADC3_VOLUME (IC 1) */
#define R34_ADC_3_VOL_IC_1                        0x00   /* 00000000b	[7:0] */
#define R34_ADC_3_VOL_IC_1_MASK                   0xFF
#define R34_ADC_3_VOL_IC_1_SHIFT                  0

/* PGA_CONTROL_0 (IC 1) */
#define R35_PGA_GAIN0_IC_1                        0x0    /* 000000b	[5:0] */
#define R35_PGA_MUTE0_IC_1                        0x1    /* 1b	[6] */
#define R35_PGA_EN0_IC_1                          0x0    /* 0b	[7] */
#define R35_PGA_GAIN0_IC_1_MASK                   0x3F
#define R35_PGA_GAIN0_IC_1_SHIFT                  0
#define R35_PGA_MUTE0_IC_1_MASK                   0x40
#define R35_PGA_MUTE0_IC_1_SHIFT                  6
#define R35_PGA_EN0_IC_1_MASK                     0x80
#define R35_PGA_EN0_IC_1_SHIFT                    7

/* PGA_CONTROL_1 (IC 1) */
#define R36_PGA_GAIN1_IC_1                        0x0    /* 000000b	[5:0] */
#define R36_PGA_MUTE1_IC_1                        0x1    /* 1b	[6] */
#define R36_PGA_EN1_IC_1                          0x0    /* 0b	[7] */
#define R36_PGA_GAIN1_IC_1_MASK                   0x3F
#define R36_PGA_GAIN1_IC_1_SHIFT                  0
#define R36_PGA_MUTE1_IC_1_MASK                   0x40
#define R36_PGA_MUTE1_IC_1_SHIFT                  6
#define R36_PGA_EN1_IC_1_MASK                     0x80
#define R36_PGA_EN1_IC_1_SHIFT                    7

/* PGA_CONTROL_2 (IC 1) */
#define R37_PGA_GAIN2_IC_1                        0x0    /* 000000b	[5:0] */
#define R37_PGA_MUTE2_IC_1                        0x1    /* 1b	[6] */
#define R37_PGA_EN2_IC_1                          0x0    /* 0b	[7] */
#define R37_PGA_GAIN2_IC_1_MASK                   0x3F
#define R37_PGA_GAIN2_IC_1_SHIFT                  0
#define R37_PGA_MUTE2_IC_1_MASK                   0x40
#define R37_PGA_MUTE2_IC_1_SHIFT                  6
#define R37_PGA_EN2_IC_1_MASK                     0x80
#define R37_PGA_EN2_IC_1_SHIFT                    7

/* PGA_CONTROL_3 (IC 1) */
#define R38_PGA_GAIN3_IC_1                        0x0    /* 000000b	[5:0] */
#define R38_PGA_MUTE3_IC_1                        0x1    /* 1b	[6] */
#define R38_PGA_EN3_IC_1                          0x0    /* 0b	[7] */
#define R38_PGA_GAIN3_IC_1_MASK                   0x3F
#define R38_PGA_GAIN3_IC_1_SHIFT                  0
#define R38_PGA_MUTE3_IC_1_MASK                   0x40
#define R38_PGA_MUTE3_IC_1_SHIFT                  6
#define R38_PGA_EN3_IC_1_MASK                     0x80
#define R38_PGA_EN3_IC_1_SHIFT                    7

/* PGA_STEP_CONTROL (IC 1) */
#define R39_SLEW_PD0_IC_1                         0x0    /* 0b	[0] */
#define R39_SLEW_PD1_IC_1                         0x0    /* 0b	[1] */
#define R39_SLEW_PD2_IC_1                         0x0    /* 0b	[2] */
#define R39_SLEW_PD3_IC_1                         0x0    /* 0b	[3] */
#define R39_SLEW_RATE_IC_1                        0x0    /* 00b	[5:4] */
#define R39_SLEW_PD0_IC_1_MASK                    0x1
#define R39_SLEW_PD0_IC_1_SHIFT                   0
#define R39_SLEW_PD1_IC_1_MASK                    0x2
#define R39_SLEW_PD1_IC_1_SHIFT                   1
#define R39_SLEW_PD2_IC_1_MASK                    0x4
#define R39_SLEW_PD2_IC_1_SHIFT                   2
#define R39_SLEW_PD3_IC_1_MASK                    0x8
#define R39_SLEW_PD3_IC_1_SHIFT                   3
#define R39_SLEW_RATE_IC_1_MASK                   0x30
#define R39_SLEW_RATE_IC_1_SHIFT                  4

/* PGA_10DB_BOOST (IC 1) */
#define R40_PGA_0_BOOST_IC_1                      0x0    /* 0b	[0] */
#define R40_PGA_1_BOOST_IC_1                      0x0    /* 0b	[1] */
#define R40_PGA_2_BOOST_IC_1                      0x0    /* 0b	[2] */
#define R40_PGA_3_BOOST_IC_1                      0x0    /* 0b	[3] */
#define R40_PGA_0_BOOST_IC_1_MASK                 0x1
#define R40_PGA_0_BOOST_IC_1_SHIFT                0
#define R40_PGA_1_BOOST_IC_1_MASK                 0x2
#define R40_PGA_1_BOOST_IC_1_SHIFT                1
#define R40_PGA_2_BOOST_IC_1_MASK                 0x4
#define R40_PGA_2_BOOST_IC_1_SHIFT                2
#define R40_PGA_3_BOOST_IC_1_MASK                 0x8
#define R40_PGA_3_BOOST_IC_1_SHIFT                3

/* POP_SUPPRESS (IC 1) */
#define R41_PGA_POP_DIS0_IC_1                     0x1    /* 1b	[0] */
#define R41_PGA_POP_DIS1_IC_1                     0x1    /* 1b	[1] */
#define R41_PGA_POP_DIS2_IC_1                     0x1    /* 1b	[2] */
#define R41_PGA_POP_DIS3_IC_1                     0x1    /* 1b	[3] */
#define R41_HP_POP_DIS0_IC_1                      0x1    /* 1b	[4] */
#define R41_HP_POP_DIS1_IC_1                      0x1    /* 1b	[5] */
#define R41_PGA_POP_DIS0_IC_1_MASK                0x1
#define R41_PGA_POP_DIS0_IC_1_SHIFT               0
#define R41_PGA_POP_DIS1_IC_1_MASK                0x2
#define R41_PGA_POP_DIS1_IC_1_SHIFT               1
#define R41_PGA_POP_DIS2_IC_1_MASK                0x4
#define R41_PGA_POP_DIS2_IC_1_SHIFT               2
#define R41_PGA_POP_DIS3_IC_1_MASK                0x8
#define R41_PGA_POP_DIS3_IC_1_SHIFT               3
#define R41_HP_POP_DIS0_IC_1_MASK                 0x10
#define R41_HP_POP_DIS0_IC_1_SHIFT                4
#define R41_HP_POP_DIS1_IC_1_MASK                 0x20
#define R41_HP_POP_DIS1_IC_1_SHIFT                5

/* TALKTHRU (IC 1) */
#define R42_TALKTHRU_PATH_IC_1                    0x0    /* 00b	[1:0] */
#define R42_TALKTHRU_PATH_IC_1_MASK               0x3
#define R42_TALKTHRU_PATH_IC_1_SHIFT              0

/* TALKTHRU_GAIN0 (IC 1) */
#define R43_TALKTHRU_GAIN0_VAL_IC_1               0x00   /* 00000000b	[7:0] */
#define R43_TALKTHRU_GAIN0_VAL_IC_1_MASK          0xFF
#define R43_TALKTHRU_GAIN0_VAL_IC_1_SHIFT         0

/* TALKTHRU_GAIN1 (IC 1) */
#define R44_TALKTHRU_GAIN1_VAL_IC_1               0x00   /* 00000000b	[7:0] */
#define R44_TALKTHRU_GAIN1_VAL_IC_1_MASK          0xFF
#define R44_TALKTHRU_GAIN1_VAL_IC_1_SHIFT         0

/* MIC_BIAS (IC 1) */
#define R45_MIC_GAIN0_IC_1                        0x0    /* 0b	[0] */
#define R45_MIC_GAIN1_IC_1                        0x0    /* 0b	[1] */
#define R45_MIC_HI_PERF0_IC_1                     0x0    /* 0b	[2] */
#define R45_MIC_HI_PERF1_IC_1                     0x0    /* 0b	[3] */
#define R45_MIC_EN0_IC_1                          0x0    /* 0b	[4] */
#define R45_MIC_EN1_IC_1                          0x0    /* 0b	[5] */
#define R45_MIC_GAIN0_IC_1_MASK                   0x1
#define R45_MIC_GAIN0_IC_1_SHIFT                  0
#define R45_MIC_GAIN1_IC_1_MASK                   0x2
#define R45_MIC_GAIN1_IC_1_SHIFT                  1
#define R45_MIC_HI_PERF0_IC_1_MASK                0x4
#define R45_MIC_HI_PERF0_IC_1_SHIFT               2
#define R45_MIC_HI_PERF1_IC_1_MASK                0x8
#define R45_MIC_HI_PERF1_IC_1_SHIFT               3
#define R45_MIC_EN0_IC_1_MASK                     0x10
#define R45_MIC_EN0_IC_1_SHIFT                    4
#define R45_MIC_EN1_IC_1_MASK                     0x20
#define R45_MIC_EN1_IC_1_SHIFT                    5

/* DAC_CONTROL1 (IC 1) */
#define R46_DAC0_EN_IC_1                          0x1    /* 1b	[0] */
#define R46_DAC1_EN_IC_1                          0x1    /* 1b	[1] */
#define R46_DAC0_MUTE_IC_1                        0x0    /* 0b	[3] */
#define R46_DAC1_MUTE_IC_1                        0x0    /* 0b	[4] */
#define R46_DAC_POL_IC_1                          0x0    /* 0b	[5] */
#define R46_DAC0_EN_IC_1_MASK                     0x1
#define R46_DAC0_EN_IC_1_SHIFT                    0
#define R46_DAC1_EN_IC_1_MASK                     0x2
#define R46_DAC1_EN_IC_1_SHIFT                    1
#define R46_DAC0_MUTE_IC_1_MASK                   0x8
#define R46_DAC0_MUTE_IC_1_SHIFT                  3
#define R46_DAC1_MUTE_IC_1_MASK                   0x10
#define R46_DAC1_MUTE_IC_1_SHIFT                  4
#define R46_DAC_POL_IC_1_MASK                     0x20
#define R46_DAC_POL_IC_1_SHIFT                    5

/* DAC0_VOLUME (IC 1) */
#define R47_DAC_0_VOL_IC_1                        0x00   /* 00000000b	[7:0] */
#define R47_DAC_0_VOL_IC_1_MASK                   0xFF
#define R47_DAC_0_VOL_IC_1_SHIFT                  0

/* DAC1_VOLUME (IC 1) */
#define R48_DAC_1_VOL_IC_1                        0x00   /* 00000000b	[7:0] */
#define R48_DAC_1_VOL_IC_1_MASK                   0xFF
#define R48_DAC_1_VOL_IC_1_SHIFT                  0

/* OP_STAGE_MUTES (IC 1) */
#define R49_HP_MUTE_L_IC_1                        0x0    /* 00b	[1:0] */
#define R49_HP_MUTE_R_IC_1                        0x0    /* 00b	[3:2] */
#define R49_HP_MUTE_L_IC_1_MASK                   0x3
#define R49_HP_MUTE_L_IC_1_SHIFT                  0
#define R49_HP_MUTE_R_IC_1_MASK                   0xC
#define R49_HP_MUTE_R_IC_1_SHIFT                  2

/* SAI_0 (IC 1) */
#define R50_SER_PORT_FS_IC_1                      0x7    /* 0111b	[3:0] */
#define R50_SAI_IC_1                              0x0    /* 00b	[5:4] */
#define R50_SDATA_FMT_IC_1                        0x0    /* 00b	[7:6] */
#define R50_SER_PORT_FS_IC_1_MASK                 0xF
#define R50_SER_PORT_FS_IC_1_SHIFT                0
#define R50_SAI_IC_1_MASK                         0x30
#define R50_SAI_IC_1_SHIFT                        4
#define R50_SDATA_FMT_IC_1_MASK                   0xC0
#define R50_SDATA_FMT_IC_1_SHIFT                  6

/* SAI_1 (IC 1) */
#define R51_SAI_MS_IC_1                           0x0    /* 0b	[0] */
#define R51_BCLKEDGE_IC_1                         0x0    /* 0b	[1] */
#define R51_BCLKRATE_IC_1                         0x0    /* 0b	[2] */
#define R51_SAI_MSB_IC_1                          0x0    /* 0b	[3] */
#define R51_LR_POL_IC_1                           0x0    /* 0b	[4] */
#define R51_LR_MODE_IC_1                          0x0    /* 0b	[5] */
#define R51_BCLK_TDMC_IC_1                        0x0    /* 0b	[6] */
#define R51_TDM_TS_IC_1                           0x0    /* 0b	[7] */
#define R51_SAI_MS_IC_1_MASK                      0x1
#define R51_SAI_MS_IC_1_SHIFT                     0
#define R51_BCLKEDGE_IC_1_MASK                    0x2
#define R51_BCLKEDGE_IC_1_SHIFT                   1
#define R51_BCLKRATE_IC_1_MASK                    0x4
#define R51_BCLKRATE_IC_1_SHIFT                   2
#define R51_SAI_MSB_IC_1_MASK                     0x8
#define R51_SAI_MSB_IC_1_SHIFT                    3
#define R51_LR_POL_IC_1_MASK                      0x10
#define R51_LR_POL_IC_1_SHIFT                     4
#define R51_LR_MODE_IC_1_MASK                     0x20
#define R51_LR_MODE_IC_1_SHIFT                    5
#define R51_BCLK_TDMC_IC_1_MASK                   0x40
#define R51_BCLK_TDMC_IC_1_SHIFT                  6
#define R51_TDM_TS_IC_1_MASK                      0x80
#define R51_TDM_TS_IC_1_SHIFT                     7

/* SOUT_CONTROL0 (IC 1) */
#define R52_TDM0_DIS_IC_1                         0x0    /* 0b	[0] */
#define R52_TDM1_DIS_IC_1                         0x0    /* 0b	[1] */
#define R52_TDM2_DIS_IC_1                         0x0    /* 0b	[2] */
#define R52_TDM3_DIS_IC_1                         0x0    /* 0b	[3] */
#define R52_TDM4_DIS_IC_1                         0x0    /* 0b	[4] */
#define R52_TDM5_DIS_IC_1                         0x0    /* 0b	[5] */
#define R52_TDM6_DIS_IC_1                         0x0    /* 0b	[6] */
#define R52_TDM7_DIS_IC_1                         0x0    /* 0b	[7] */
#define R52_TDM0_DIS_IC_1_MASK                    0x1
#define R52_TDM0_DIS_IC_1_SHIFT                   0
#define R52_TDM1_DIS_IC_1_MASK                    0x2
#define R52_TDM1_DIS_IC_1_SHIFT                   1
#define R52_TDM2_DIS_IC_1_MASK                    0x4
#define R52_TDM2_DIS_IC_1_SHIFT                   2
#define R52_TDM3_DIS_IC_1_MASK                    0x8
#define R52_TDM3_DIS_IC_1_SHIFT                   3
#define R52_TDM4_DIS_IC_1_MASK                    0x10
#define R52_TDM4_DIS_IC_1_SHIFT                   4
#define R52_TDM5_DIS_IC_1_MASK                    0x20
#define R52_TDM5_DIS_IC_1_SHIFT                   5
#define R52_TDM6_DIS_IC_1_MASK                    0x40
#define R52_TDM6_DIS_IC_1_SHIFT                   6
#define R52_TDM7_DIS_IC_1_MASK                    0x80
#define R52_TDM7_DIS_IC_1_SHIFT                   7

/* PDM_OUT (IC 1) */
#define R53_PDM_EN_IC_1                           0x0    /* 00b	[1:0] */
#define R53_PDM_CH_IC_1                           0x0    /* 00b	[3:2] */
#define R53_PDM_CTRL_IC_1                         0x0    /* 0b	[4] */
#define R53_PDM_EN_IC_1_MASK                      0x3
#define R53_PDM_EN_IC_1_SHIFT                     0
#define R53_PDM_CH_IC_1_MASK                      0xC
#define R53_PDM_CH_IC_1_SHIFT                     2
#define R53_PDM_CTRL_IC_1_MASK                    0x10
#define R53_PDM_CTRL_IC_1_SHIFT                   4

/* PDM_PATTERN (IC 1) */
#define R54_PATTERN_IC_1                          0x00   /* 00000000b	[7:0] */
#define R54_PATTERN_IC_1_MASK                     0xFF
#define R54_PATTERN_IC_1_SHIFT                    0

/* MODE_MP0 (IC 1) */
#define R55_MODE_MP0_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R55_MODE_MP0_VAL_IC_1_MASK                0x1F
#define R55_MODE_MP0_VAL_IC_1_SHIFT               0

/* MODE_MP1 (IC 1) */
#define R56_MODE_MP1_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R56_MODE_MP1_VAL_IC_1_MASK                0x1F
#define R56_MODE_MP1_VAL_IC_1_SHIFT               0

/* MODE_MP2 (IC 1) */
#define R57_MODE_MP2_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R57_MODE_MP2_VAL_IC_1_MASK                0x1F
#define R57_MODE_MP2_VAL_IC_1_SHIFT               0

/* MODE_MP3 (IC 1) */
#define R58_MODE_MP3_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R58_MODE_MP3_VAL_IC_1_MASK                0x1F
#define R58_MODE_MP3_VAL_IC_1_SHIFT               0

/* MODE_MP4 (IC 1) */
#define R59_MODE_MP4_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R59_MODE_MP4_VAL_IC_1_MASK                0x1F
#define R59_MODE_MP4_VAL_IC_1_SHIFT               0

/* MODE_MP5 (IC 1) */
#define R60_MODE_MP5_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R60_MODE_MP5_VAL_IC_1_MASK                0x1F
#define R60_MODE_MP5_VAL_IC_1_SHIFT               0

/* MODE_MP6 (IC 1) */
#define R61_MODE_MP6_VAL_IC_1                     0x0    /* 00000b	[4:0] */
#define R61_MODE_MP6_VAL_IC_1_MASK                0x1F
#define R61_MODE_MP6_VAL_IC_1_SHIFT               0

/* PB_VOL_SET (IC 1) */
#define R62_HOLD_IC_1                             0x0    /* 000b	[2:0] */
#define R62_PB_VOL_INIT_VAL_IC_1                  0x0    /* 00000b	[7:3] */
#define R62_HOLD_IC_1_MASK                        0x7
#define R62_HOLD_IC_1_SHIFT                       0
#define R62_PB_VOL_INIT_VAL_IC_1_MASK             0xF8
#define R62_PB_VOL_INIT_VAL_IC_1_SHIFT            3

/* PB_VOL_CONV (IC 1) */
#define R63_PB_VOL_CONV_VAL_IC_1                  0x7    /* 111b	[2:0] */
#define R63_RAMPSPEED_IC_1                        0x0    /* 000b	[5:3] */
#define R63_GAINSTEP_IC_1                         0x2    /* 10b	[7:6] */
#define R63_PB_VOL_CONV_VAL_IC_1_MASK             0x7
#define R63_PB_VOL_CONV_VAL_IC_1_SHIFT            0
#define R63_RAMPSPEED_IC_1_MASK                   0x38
#define R63_RAMPSPEED_IC_1_SHIFT                  3
#define R63_GAINSTEP_IC_1_MASK                    0xC0
#define R63_GAINSTEP_IC_1_SHIFT                   6

/* DEBOUNCE_MODE (IC 1) */
#define R64_DEBOUNCE_IC_1                         0x5    /* 101b	[2:0] */
#define R64_DEBOUNCE_IC_1_MASK                    0x7
#define R64_DEBOUNCE_IC_1_SHIFT                   0

/* OP_STAGE_CTRL (IC 1) */
#define R65_HP_PDN_L_IC_1                         0x0    /* 00b	[1:0] */
#define R65_HP_PDN_R_IC_1                         0x0    /* 00b	[3:2] */
#define R65_HP_EN_L_IC_1                          0x1    /* 1b	[4] */
#define R65_HP_EN_R_IC_1                          0x1    /* 1b	[5] */
#define R65_HP_PDN_L_IC_1_MASK                    0x3
#define R65_HP_PDN_L_IC_1_SHIFT                   0
#define R65_HP_PDN_R_IC_1_MASK                    0xC
#define R65_HP_PDN_R_IC_1_SHIFT                   2
#define R65_HP_EN_L_IC_1_MASK                     0x10
#define R65_HP_EN_L_IC_1_SHIFT                    4
#define R65_HP_EN_R_IC_1_MASK                     0x20
#define R65_HP_EN_R_IC_1_SHIFT                    5

/* DECIM_PWR_MODES (IC 1) */
#define R66_SINC_0_EN_IC_1                        0x0    /* 0b	[0] */
#define R66_SINC_1_EN_IC_1                        0x0    /* 0b	[1] */
#define R66_SINC_2_EN_IC_1                        0x1    /* 1b	[2] */
#define R66_SINC_3_EN_IC_1                        0x1    /* 1b	[3] */
#define R66_DEC_0_EN_IC_1                         0x0    /* 0b	[4] */
#define R66_DEC_1_EN_IC_1                         0x0    /* 0b	[5] */
#define R66_DEC_2_EN_IC_1                         0x1    /* 1b	[6] */
#define R66_DEC_3_EN_IC_1                         0x1    /* 1b	[7] */
#define R66_SINC_0_EN_IC_1_MASK                   0x1
#define R66_SINC_0_EN_IC_1_SHIFT                  0
#define R66_SINC_1_EN_IC_1_MASK                   0x2
#define R66_SINC_1_EN_IC_1_SHIFT                  1
#define R66_SINC_2_EN_IC_1_MASK                   0x4
#define R66_SINC_2_EN_IC_1_SHIFT                  2
#define R66_SINC_3_EN_IC_1_MASK                   0x8
#define R66_SINC_3_EN_IC_1_SHIFT                  3
#define R66_DEC_0_EN_IC_1_MASK                    0x10
#define R66_DEC_0_EN_IC_1_SHIFT                   4
#define R66_DEC_1_EN_IC_1_MASK                    0x20
#define R66_DEC_1_EN_IC_1_SHIFT                   5
#define R66_DEC_2_EN_IC_1_MASK                    0x40
#define R66_DEC_2_EN_IC_1_SHIFT                   6
#define R66_DEC_3_EN_IC_1_MASK                    0x80
#define R66_DEC_3_EN_IC_1_SHIFT                   7

/* INTERP_PWR_MODES (IC 1) */
#define R67_INT_0_EN_IC_1                         0x1    /* 1b	[0] */
#define R67_INT_1_EN_IC_1                         0x1    /* 1b	[1] */
#define R67_MOD_0_EN_IC_1                         0x1    /* 1b	[2] */
#define R67_MOD_1_EN_IC_1                         0x1    /* 1b	[3] */
#define R67_INT_0_EN_IC_1_MASK                    0x1
#define R67_INT_0_EN_IC_1_SHIFT                   0
#define R67_INT_1_EN_IC_1_MASK                    0x2
#define R67_INT_1_EN_IC_1_SHIFT                   1
#define R67_MOD_0_EN_IC_1_MASK                    0x4
#define R67_MOD_0_EN_IC_1_SHIFT                   2
#define R67_MOD_1_EN_IC_1_MASK                    0x8
#define R67_MOD_1_EN_IC_1_SHIFT                   3

/* BIAS_CONTROL0 (IC 1) */
#define R68_ADC_IBIAS01_IC_1                      0x0    /* 00b	[1:0] */
#define R68_ADC_IBIAS23_IC_1                      0x0    /* 00b	[3:2] */
#define R68_AFE_IBIAS01_IC_1                      0x0    /* 00b	[5:4] */
#define R68_HP_IBIAS_IC_1                         0x0    /* 00b	[7:6] */
#define R68_ADC_IBIAS01_IC_1_MASK                 0x3
#define R68_ADC_IBIAS01_IC_1_SHIFT                0
#define R68_ADC_IBIAS23_IC_1_MASK                 0xC
#define R68_ADC_IBIAS23_IC_1_SHIFT                2
#define R68_AFE_IBIAS01_IC_1_MASK                 0x30
#define R68_AFE_IBIAS01_IC_1_SHIFT                4
#define R68_HP_IBIAS_IC_1_MASK                    0xC0
#define R68_HP_IBIAS_IC_1_SHIFT                   6

/* BIAS_CONTROL1 (IC 1) */
#define R69_DAC_IBIAS_IC_1                        0x0    /* 00b	[1:0] */
#define R69_MIC_IBIAS_IC_1                        0x0    /* 00b	[3:2] */
#define R69_AFE_IBIAS23_IC_1                      0x0    /* 00b	[5:4] */
#define R69_CBIAS_DIS_IC_1                        0x0    /* 0b	[6] */
#define R69_DAC_IBIAS_IC_1_MASK                   0x3
#define R69_DAC_IBIAS_IC_1_SHIFT                  0
#define R69_MIC_IBIAS_IC_1_MASK                   0xC
#define R69_MIC_IBIAS_IC_1_SHIFT                  2
#define R69_AFE_IBIAS23_IC_1_MASK                 0x30
#define R69_AFE_IBIAS23_IC_1_SHIFT                4
#define R69_CBIAS_DIS_IC_1_MASK                   0x40
#define R69_CBIAS_DIS_IC_1_SHIFT                  6

/* PAD_CONTROL0 (IC 1) */
#define R70_DAC_SDATA_PU_IC_1                     0x1    /* 1b	[0] */
#define R70_ADC_SDATA0_PU_IC_1                    0x1    /* 1b	[1] */
#define R70_ADC_SDATA1_PU_IC_1                    0x1    /* 1b	[2] */
#define R70_BCLK_PU_IC_1                          0x1    /* 1b	[3] */
#define R70_LRCLK_PU_IC_1                         0x1    /* 1b	[4] */
#define R70_DMIC1_2_PU_IC_1                       0x1    /* 1b	[5] */
#define R70_DMIC3_4_PU_IC_1                       0x1    /* 1b	[6] */
#define R70_DAC_SDATA_PU_IC_1_MASK                0x1
#define R70_DAC_SDATA_PU_IC_1_SHIFT               0
#define R70_ADC_SDATA0_PU_IC_1_MASK               0x2
#define R70_ADC_SDATA0_PU_IC_1_SHIFT              1
#define R70_ADC_SDATA1_PU_IC_1_MASK               0x4
#define R70_ADC_SDATA1_PU_IC_1_SHIFT              2
#define R70_BCLK_PU_IC_1_MASK                     0x8
#define R70_BCLK_PU_IC_1_SHIFT                    3
#define R70_LRCLK_PU_IC_1_MASK                    0x10
#define R70_LRCLK_PU_IC_1_SHIFT                   4
#define R70_DMIC1_2_PU_IC_1_MASK                  0x20
#define R70_DMIC1_2_PU_IC_1_SHIFT                 5
#define R70_DMIC3_4_PU_IC_1_MASK                  0x40
#define R70_DMIC3_4_PU_IC_1_SHIFT                 6

/* PAD_CONTROL1 (IC 1) */
#define R71_ADDR0_PU_IC_1                         0x1    /* 1b	[0] */
#define R71_ADDR1_PU_IC_1                         0x1    /* 1b	[1] */
#define R71_SDA_PU_IC_1                           0x1    /* 1b	[2] */
#define R71_SCL_PU_IC_1                           0x1    /* 1b	[3] */
#define R71_SELFBOOT_PU_IC_1                      0x1    /* 1b	[4] */
#define R71_ADDR0_PU_IC_1_MASK                    0x1
#define R71_ADDR0_PU_IC_1_SHIFT                   0
#define R71_ADDR1_PU_IC_1_MASK                    0x2
#define R71_ADDR1_PU_IC_1_SHIFT                   1
#define R71_SDA_PU_IC_1_MASK                      0x4
#define R71_SDA_PU_IC_1_SHIFT                     2
#define R71_SCL_PU_IC_1_MASK                      0x8
#define R71_SCL_PU_IC_1_SHIFT                     3
#define R71_SELFBOOT_PU_IC_1_MASK                 0x10
#define R71_SELFBOOT_PU_IC_1_SHIFT                4

/* PAD_CONTROL2 (IC 1) */
#define R72_DAC_SDATA_PD_IC_1                     0x0    /* 0b	[0] */
#define R72_ADC_SDATA0_PD_IC_1                    0x0    /* 0b	[1] */
#define R72_ADC_SDATA1_PD_IC_1                    0x0    /* 0b	[2] */
#define R72_BCLK_PD_IC_1                          0x0    /* 0b	[3] */
#define R72_LRCLK_PD_IC_1                         0x0    /* 0b	[4] */
#define R72_DMIC0_1_PD_IC_1                       0x0    /* 0b	[5] */
#define R72_DMIC2_3_PD_IC_1                       0x0    /* 0b	[6] */
#define R72_DAC_SDATA_PD_IC_1_MASK                0x1
#define R72_DAC_SDATA_PD_IC_1_SHIFT               0
#define R72_ADC_SDATA0_PD_IC_1_MASK               0x2
#define R72_ADC_SDATA0_PD_IC_1_SHIFT              1
#define R72_ADC_SDATA1_PD_IC_1_MASK               0x4
#define R72_ADC_SDATA1_PD_IC_1_SHIFT              2
#define R72_BCLK_PD_IC_1_MASK                     0x8
#define R72_BCLK_PD_IC_1_SHIFT                    3
#define R72_LRCLK_PD_IC_1_MASK                    0x10
#define R72_LRCLK_PD_IC_1_SHIFT                   4
#define R72_DMIC0_1_PD_IC_1_MASK                  0x20
#define R72_DMIC0_1_PD_IC_1_SHIFT                 5
#define R72_DMIC2_3_PD_IC_1_MASK                  0x40
#define R72_DMIC2_3_PD_IC_1_SHIFT                 6

/* PAD_CONTROL3 (IC 1) */
#define R73_ADDR0_PD_IC_1                         0x0    /* 0b	[0] */
#define R73_ADDR1_PD_IC_1                         0x0    /* 0b	[1] */
#define R73_SDA_PD_IC_1                           0x0    /* 0b	[2] */
#define R73_SCL_PD_IC_1                           0x0    /* 0b	[3] */
#define R73_SELFBOOT_PD_IC_1                      0x0    /* 0b	[4] */
#define R73_ADDR0_PD_IC_1_MASK                    0x1
#define R73_ADDR0_PD_IC_1_SHIFT                   0
#define R73_ADDR1_PD_IC_1_MASK                    0x2
#define R73_ADDR1_PD_IC_1_SHIFT                   1
#define R73_SDA_PD_IC_1_MASK                      0x4
#define R73_SDA_PD_IC_1_SHIFT                     2
#define R73_SCL_PD_IC_1_MASK                      0x8
#define R73_SCL_PD_IC_1_SHIFT                     3
#define R73_SELFBOOT_PD_IC_1_MASK                 0x10
#define R73_SELFBOOT_PD_IC_1_SHIFT                4

/* PAD_CONTROL4 (IC 1) */
#define R74_DAC_SDATA_DRV_IC_1                    0x0    /* 0b	[0] */
#define R74_ADC_SDATA0_DRV_IC_1                   0x0    /* 0b	[1] */
#define R74_ADC_SDATA1_DRV_IC_1                   0x0    /* 0b	[2] */
#define R74_BCLK_DRV_IC_1                         0x0    /* 0b	[3] */
#define R74_LRCLK_DRV_IC_1                        0x0    /* 0b	[4] */
#define R74_DMIC0_1_DRV_IC_1                      0x0    /* 0b	[5] */
#define R74_DMIC2_3_DRV_IC_1                      0x0    /* 0b	[6] */
#define R74_DAC_SDATA_DRV_IC_1_MASK               0x1
#define R74_DAC_SDATA_DRV_IC_1_SHIFT              0
#define R74_ADC_SDATA0_DRV_IC_1_MASK              0x2
#define R74_ADC_SDATA0_DRV_IC_1_SHIFT             1
#define R74_ADC_SDATA1_DRV_IC_1_MASK              0x4
#define R74_ADC_SDATA1_DRV_IC_1_SHIFT             2
#define R74_BCLK_DRV_IC_1_MASK                    0x8
#define R74_BCLK_DRV_IC_1_SHIFT                   3
#define R74_LRCLK_DRV_IC_1_MASK                   0x10
#define R74_LRCLK_DRV_IC_1_SHIFT                  4
#define R74_DMIC0_1_DRV_IC_1_MASK                 0x20
#define R74_DMIC0_1_DRV_IC_1_SHIFT                5
#define R74_DMIC2_3_DRV_IC_1_MASK                 0x40
#define R74_DMIC2_3_DRV_IC_1_SHIFT                6

/* PAD_CONTROL5 (IC 1) */
#define R75_ADDR0_DRV_IC_1                        0x0    /* 0b	[0] */
#define R75_ADDR1_DRV_IC_1                        0x0    /* 0b	[1] */
#define R75_SDA_DRV_IC_1                          0x0    /* 0b	[2] */
#define R75_SCL_DRV_IC_1                          0x0    /* 0b	[3] */
#define R75_SELFBOOT_DRV_IC_1                     0x0    /* 0b	[4] */
#define R75_ADDR0_DRV_IC_1_MASK                   0x1
#define R75_ADDR0_DRV_IC_1_SHIFT                  0
#define R75_ADDR1_DRV_IC_1_MASK                   0x2
#define R75_ADDR1_DRV_IC_1_SHIFT                  1
#define R75_SDA_DRV_IC_1_MASK                     0x4
#define R75_SDA_DRV_IC_1_SHIFT                    2
#define R75_SCL_DRV_IC_1_MASK                     0x8
#define R75_SCL_DRV_IC_1_SHIFT                    3
#define R75_SELFBOOT_DRV_IC_1_MASK                0x10
#define R75_SELFBOOT_DRV_IC_1_SHIFT               4

/* FAST_RATE (IC 1) */
#define R76_RATE_DIV_IC_1                         0x0    /* 000b	[2:0] */
#define R76_RATE_DIV_IC_1_MASK                    0x7
#define R76_RATE_DIV_IC_1_SHIFT                   0

/* DAC_CONTROL0 (IC 1) */
#define R77_DAC_INTP_IC_1                         0x0    /* 000b	[5:3] */
#define R77_DAC_RATE_IC_1                         0x0    /* 00b	[7:6] */
#define R77_DAC_INTP_IC_1_MASK                    0x38
#define R77_DAC_INTP_IC_1_SHIFT                   3
#define R77_DAC_RATE_IC_1_MASK                    0xC0
#define R77_DAC_RATE_IC_1_SHIFT                   6

/* VOL_BYPASS (IC 1) */
#define R78_ADC0VOL_BY_IC_1                       0x0    /* 0b	[0] */
#define R78_ADC1VOL_BY_IC_1                       0x0    /* 0b	[1] */
#define R78_ADC2VOL_BY_IC_1                       0x0    /* 0b	[2] */
#define R78_ADC3VOL_BY_IC_1                       0x0    /* 0b	[3] */
#define R78_DAC0VOL_BY_IC_1                       0x0    /* 0b	[4] */
#define R78_DAC1VOL_BY_IC_1                       0x0    /* 0b	[5] */
#define R78_ADC0VOL_BY_IC_1_MASK                  0x1
#define R78_ADC0VOL_BY_IC_1_SHIFT                 0
#define R78_ADC1VOL_BY_IC_1_MASK                  0x2
#define R78_ADC1VOL_BY_IC_1_SHIFT                 1
#define R78_ADC2VOL_BY_IC_1_MASK                  0x4
#define R78_ADC2VOL_BY_IC_1_SHIFT                 2
#define R78_ADC3VOL_BY_IC_1_MASK                  0x8
#define R78_ADC3VOL_BY_IC_1_SHIFT                 3
#define R78_DAC0VOL_BY_IC_1_MASK                  0x10
#define R78_DAC0VOL_BY_IC_1_SHIFT                 4
#define R78_DAC1VOL_BY_IC_1_MASK                  0x20
#define R78_DAC1VOL_BY_IC_1_SHIFT                 5

/* ADC OPER (IC 1) */
#define R79_ADC_OPER_IC_1                         0xA0   /* 10100000b	[7:0] */
#define R79_ADC_OPER_IC_1_MASK                    0xFF
#define R79_ADC_OPER_IC_1_SHIFT                   0

#endif
