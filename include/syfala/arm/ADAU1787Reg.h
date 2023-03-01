/*
 * File:           C:\Users\Maxime\Documents\ADAU Firmware\ADAU1787_3_noDSP\adau1787_noDSP_IC_1_SIGMA_REG.h
 *
 * Created:        Wednesday, October 5, 2022 10:35:48 PM
 * Description:    adau1787_noDSP:IC 1-Sigma control register definitions.
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
 * Copyright ©2022 Analog Devices, Inc. All rights reserved.
 */
#ifndef __ADAU1787_NODSP_IC_1_SIGMA_REG_H__
#define __ADAU1787_NODSP_IC_1_SIGMA_REG_H__


/* VENDOR_ID  - Registers (IC 1_Sigma) */
#define REG_VENDOR_ID_IC_1_Sigma_ADDR             0xC000
#define REG_VENDOR_ID_IC_1_Sigma_BYTE             0
#define REG_VENDOR_ID_IC_1_Sigma_VALUE            0x41

/* DEVICE_ID1  - Registers (IC 1_Sigma) */
#define REG_DEVICE_ID1_IC_1_Sigma_ADDR            0xC001
#define REG_DEVICE_ID1_IC_1_Sigma_BYTE            0
#define REG_DEVICE_ID1_IC_1_Sigma_VALUE           0x17

/* DEVICE_ID2  - Registers (IC 1_Sigma) */
#define REG_DEVICE_ID2_IC_1_Sigma_ADDR            0xC002
#define REG_DEVICE_ID2_IC_1_Sigma_BYTE            0
#define REG_DEVICE_ID2_IC_1_Sigma_VALUE           0x87

/* REVISION  - Registers (IC 1_Sigma) */
#define REG_REVISION_IC_1_Sigma_ADDR              0xC003
#define REG_REVISION_IC_1_Sigma_BYTE              0
#define REG_REVISION_IC_1_Sigma_VALUE             0x0

/* ADC_DAC_HP_PWR  - Registers (IC 1_Sigma) */
#define REG_ADC_DAC_HP_PWR_IC_1_Sigma_ADDR        0xC004
#define REG_ADC_DAC_HP_PWR_IC_1_Sigma_BYTE        1
#define REG_ADC_DAC_HP_PWR_IC_1_Sigma_VALUE       0x3F

/* PLL_MB_PGA_PWR  - Registers (IC 1_Sigma) */
#define REG_PLL_MB_PGA_PWR_IC_1_Sigma_ADDR        0xC005
#define REG_PLL_MB_PGA_PWR_IC_1_Sigma_BYTE        1
#define REG_PLL_MB_PGA_PWR_IC_1_Sigma_VALUE       0x0

/* DMIC_PWR  - Registers (IC 1_Sigma) */
#define REG_DMIC_PWR_IC_1_Sigma_ADDR              0xC006
#define REG_DMIC_PWR_IC_1_Sigma_BYTE              1
#define REG_DMIC_PWR_IC_1_Sigma_VALUE             0x0

/* SAI_CLK_PWR  - Registers (IC 1_Sigma) */
#define REG_SAI_CLK_PWR_IC_1_Sigma_ADDR           0xC007
#define REG_SAI_CLK_PWR_IC_1_Sigma_BYTE           1
#define REG_SAI_CLK_PWR_IC_1_Sigma_VALUE          0x3

/* DSP_PWR  - Registers (IC 1_Sigma) */
#define REG_DSP_PWR_IC_1_Sigma_ADDR               0xC008
#define REG_DSP_PWR_IC_1_Sigma_BYTE               1
#define REG_DSP_PWR_IC_1_Sigma_VALUE              0x0

/* ASRC_PWR  - Registers (IC 1_Sigma) */
#define REG_ASRC_PWR_IC_1_Sigma_ADDR              0xC009
#define REG_ASRC_PWR_IC_1_Sigma_BYTE              1
#define REG_ASRC_PWR_IC_1_Sigma_VALUE             0x0

/* FINT_PWR  - Registers (IC 1_Sigma) */
#define REG_FINT_PWR_IC_1_Sigma_ADDR              0xC00A
#define REG_FINT_PWR_IC_1_Sigma_BYTE              1
#define REG_FINT_PWR_IC_1_Sigma_VALUE             0x0

/* FDEC_PWR  - Registers (IC 1_Sigma) */
#define REG_FDEC_PWR_IC_1_Sigma_ADDR              0xC00B
#define REG_FDEC_PWR_IC_1_Sigma_BYTE              1
#define REG_FDEC_PWR_IC_1_Sigma_VALUE             0x0

/* KEEPS  - Registers (IC 1_Sigma) */
#define REG_KEEPS_IC_1_Sigma_ADDR                 0xC00C
#define REG_KEEPS_IC_1_Sigma_BYTE                 1
#define REG_KEEPS_IC_1_Sigma_VALUE                0x11

/* CHIP_PWR  - Registers (IC 1_Sigma) */
#define REG_CHIP_PWR_IC_1_Sigma_ADDR              0xC00D
#define REG_CHIP_PWR_IC_1_Sigma_BYTE              1
#define REG_CHIP_PWR_IC_1_Sigma_VALUE             0x17

/* CLK_CTRL1  - Registers (IC 1_Sigma) */
#define REG_CLK_CTRL1_IC_1_Sigma_ADDR             0xC00E
#define REG_CLK_CTRL1_IC_1_Sigma_BYTE             1
#define REG_CLK_CTRL1_IC_1_Sigma_VALUE            0x20

/* CLK_CTRL2  - Registers (IC 1_Sigma) */
#define REG_CLK_CTRL2_IC_1_Sigma_ADDR             0xC00F
#define REG_CLK_CTRL2_IC_1_Sigma_BYTE             1
#define REG_CLK_CTRL2_IC_1_Sigma_VALUE            0x0

/* CLK_CTRL3  - Registers (IC 1_Sigma) */
#define REG_CLK_CTRL3_IC_1_Sigma_ADDR             0xC010
#define REG_CLK_CTRL3_IC_1_Sigma_BYTE             2
#define REG_CLK_CTRL3_IC_1_Sigma_VALUE            0x2

/* CLK_CTRL5  - Registers (IC 1_Sigma) */
#define REG_CLK_CTRL5_IC_1_Sigma_ADDR             0xC012
#define REG_CLK_CTRL5_IC_1_Sigma_BYTE             2
#define REG_CLK_CTRL5_IC_1_Sigma_VALUE            0x0

/* CLK_CTRL7  - Registers (IC 1_Sigma) */
#define REG_CLK_CTRL7_IC_1_Sigma_ADDR             0xC014
#define REG_CLK_CTRL7_IC_1_Sigma_BYTE             2
#define REG_CLK_CTRL7_IC_1_Sigma_VALUE            0x0

/* CLK_CTRL9  - Registers (IC 1_Sigma) */
#define REG_CLK_CTRL9_IC_1_Sigma_ADDR             0xC016
#define REG_CLK_CTRL9_IC_1_Sigma_BYTE             1
#define REG_CLK_CTRL9_IC_1_Sigma_VALUE            0x0

/* ADC_CTRL1  - Registers (IC 1_Sigma) */
#define REG_ADC_CTRL1_IC_1_Sigma_ADDR             0xC017
#define REG_ADC_CTRL1_IC_1_Sigma_BYTE             1
#define REG_ADC_CTRL1_IC_1_Sigma_VALUE            0x60

/* ADC_CTRL2  - Registers (IC 1_Sigma) */
#define REG_ADC_CTRL2_IC_1_Sigma_ADDR             0xC018
#define REG_ADC_CTRL2_IC_1_Sigma_BYTE             1
#define REG_ADC_CTRL2_IC_1_Sigma_VALUE            0x0

/* ADC_CTRL3  - Registers (IC 1_Sigma) */
#define REG_ADC_CTRL3_IC_1_Sigma_ADDR             0xC019
#define REG_ADC_CTRL3_IC_1_Sigma_BYTE             1
#define REG_ADC_CTRL3_IC_1_Sigma_VALUE            0x0

/* ADC_CTRL4  - Registers (IC 1_Sigma) */
#define REG_ADC_CTRL4_IC_1_Sigma_ADDR             0xC01A
#define REG_ADC_CTRL4_IC_1_Sigma_BYTE             1
#define REG_ADC_CTRL4_IC_1_Sigma_VALUE            0x40

/* ADC_CTRL5  - Registers (IC 1_Sigma) */
#define REG_ADC_CTRL5_IC_1_Sigma_ADDR             0xC01B
#define REG_ADC_CTRL5_IC_1_Sigma_BYTE             1
#define REG_ADC_CTRL5_IC_1_Sigma_VALUE            0x20

/* ADC_MUTES  - Registers (IC 1_Sigma) */
#define REG_ADC_MUTES_IC_1_Sigma_ADDR             0xC01C
#define REG_ADC_MUTES_IC_1_Sigma_BYTE             1
#define REG_ADC_MUTES_IC_1_Sigma_VALUE            0x0

/* ADC0_VOL  - Registers (IC 1_Sigma) */
#define REG_ADC0_VOL_IC_1_Sigma_ADDR              0xC01D
#define REG_ADC0_VOL_IC_1_Sigma_BYTE              1
#define REG_ADC0_VOL_IC_1_Sigma_VALUE             0x40

/* ADC1_VOL  - Registers (IC 1_Sigma) */
#define REG_ADC1_VOL_IC_1_Sigma_ADDR              0xC01E
#define REG_ADC1_VOL_IC_1_Sigma_BYTE              1
#define REG_ADC1_VOL_IC_1_Sigma_VALUE             0x40

/* ADC2_VOL  - Registers (IC 1_Sigma) */
#define REG_ADC2_VOL_IC_1_Sigma_ADDR              0xC01F
#define REG_ADC2_VOL_IC_1_Sigma_BYTE              1
#define REG_ADC2_VOL_IC_1_Sigma_VALUE             0x40

/* ADC3_VOL  - Registers (IC 1_Sigma) */
#define REG_ADC3_VOL_IC_1_Sigma_ADDR              0xC020
#define REG_ADC3_VOL_IC_1_Sigma_BYTE              1
#define REG_ADC3_VOL_IC_1_Sigma_VALUE             0x40

/* PGA0_CTRL1  - Registers (IC 1_Sigma) */
#define REG_PGA0_CTRL1_IC_1_Sigma_ADDR            0xC021
#define REG_PGA0_CTRL1_IC_1_Sigma_BYTE            1
#define REG_PGA0_CTRL1_IC_1_Sigma_VALUE           0x0

/* PGA0_CTRL2  - Registers (IC 1_Sigma) */
#define REG_PGA0_CTRL2_IC_1_Sigma_ADDR            0xC022
#define REG_PGA0_CTRL2_IC_1_Sigma_BYTE            1
#define REG_PGA0_CTRL2_IC_1_Sigma_VALUE           0x0

/* PGA1_CTRL1  - Registers (IC 1_Sigma) */
#define REG_PGA1_CTRL1_IC_1_Sigma_ADDR            0xC023
#define REG_PGA1_CTRL1_IC_1_Sigma_BYTE            1
#define REG_PGA1_CTRL1_IC_1_Sigma_VALUE           0x0

/* PGA1_CTRL2  - Registers (IC 1_Sigma) */
#define REG_PGA1_CTRL2_IC_1_Sigma_ADDR            0xC024
#define REG_PGA1_CTRL2_IC_1_Sigma_BYTE            1
#define REG_PGA1_CTRL2_IC_1_Sigma_VALUE           0x0

/* PGA2_CTRL1  - Registers (IC 1_Sigma) */
#define REG_PGA2_CTRL1_IC_1_Sigma_ADDR            0xC025
#define REG_PGA2_CTRL1_IC_1_Sigma_BYTE            1
#define REG_PGA2_CTRL1_IC_1_Sigma_VALUE           0x0

/* PGA2_CTRL2  - Registers (IC 1_Sigma) */
#define REG_PGA2_CTRL2_IC_1_Sigma_ADDR            0xC026
#define REG_PGA2_CTRL2_IC_1_Sigma_BYTE            1
#define REG_PGA2_CTRL2_IC_1_Sigma_VALUE           0x0

/* PGA3_CTRL1  - Registers (IC 1_Sigma) */
#define REG_PGA3_CTRL1_IC_1_Sigma_ADDR            0xC027
#define REG_PGA3_CTRL1_IC_1_Sigma_BYTE            1
#define REG_PGA3_CTRL1_IC_1_Sigma_VALUE           0x0

/* PGA3_CTRL2  - Registers (IC 1_Sigma) */
#define REG_PGA3_CTRL2_IC_1_Sigma_ADDR            0xC028
#define REG_PGA3_CTRL2_IC_1_Sigma_BYTE            1
#define REG_PGA3_CTRL2_IC_1_Sigma_VALUE           0x0

/* PGA_CTRL  - Registers (IC 1_Sigma) */
#define REG_PGA_CTRL_IC_1_Sigma_ADDR              0xC029
#define REG_PGA_CTRL_IC_1_Sigma_BYTE              1
#define REG_PGA_CTRL_IC_1_Sigma_VALUE             0x0

/* MBIAS_CTRL  - Registers (IC 1_Sigma) */
#define REG_MBIAS_CTRL_IC_1_Sigma_ADDR            0xC02A
#define REG_MBIAS_CTRL_IC_1_Sigma_BYTE            1
#define REG_MBIAS_CTRL_IC_1_Sigma_VALUE           0x0

/* DMIC_CTRL1  - Registers (IC 1_Sigma) */
#define REG_DMIC_CTRL1_IC_1_Sigma_ADDR            0xC02B
#define REG_DMIC_CTRL1_IC_1_Sigma_BYTE            1
#define REG_DMIC_CTRL1_IC_1_Sigma_VALUE           0x33

/* DMIC_CTRL2  - Registers (IC 1_Sigma) */
#define REG_DMIC_CTRL2_IC_1_Sigma_ADDR            0xC02C
#define REG_DMIC_CTRL2_IC_1_Sigma_BYTE            1
#define REG_DMIC_CTRL2_IC_1_Sigma_VALUE           0x1

/* DMIC_CTRL3  - Registers (IC 1_Sigma) */
#define REG_DMIC_CTRL3_IC_1_Sigma_ADDR            0xC02D
#define REG_DMIC_CTRL3_IC_1_Sigma_BYTE            1
#define REG_DMIC_CTRL3_IC_1_Sigma_VALUE           0x1

/* DMIC_CTRL4  - Registers (IC 1_Sigma) */
#define REG_DMIC_CTRL4_IC_1_Sigma_ADDR            0xC02E
#define REG_DMIC_CTRL4_IC_1_Sigma_BYTE            1
#define REG_DMIC_CTRL4_IC_1_Sigma_VALUE           0x1

/* DMIC_CTRL5  - Registers (IC 1_Sigma) */
#define REG_DMIC_CTRL5_IC_1_Sigma_ADDR            0xC02F
#define REG_DMIC_CTRL5_IC_1_Sigma_BYTE            1
#define REG_DMIC_CTRL5_IC_1_Sigma_VALUE           0x1

/* DMIC_CTRL6  - Registers (IC 1_Sigma) */
#define REG_DMIC_CTRL6_IC_1_Sigma_ADDR            0xC030
#define REG_DMIC_CTRL6_IC_1_Sigma_BYTE            1
#define REG_DMIC_CTRL6_IC_1_Sigma_VALUE           0x4

/* DMIC_MUTES  - Registers (IC 1_Sigma) */
#define REG_DMIC_MUTES_IC_1_Sigma_ADDR            0xC031
#define REG_DMIC_MUTES_IC_1_Sigma_BYTE            1
#define REG_DMIC_MUTES_IC_1_Sigma_VALUE           0x0

/* DMIC_VOL0  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL0_IC_1_Sigma_ADDR             0xC032
#define REG_DMIC_VOL0_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL0_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL1  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL1_IC_1_Sigma_ADDR             0xC033
#define REG_DMIC_VOL1_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL1_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL2  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL2_IC_1_Sigma_ADDR             0xC034
#define REG_DMIC_VOL2_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL2_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL3  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL3_IC_1_Sigma_ADDR             0xC035
#define REG_DMIC_VOL3_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL3_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL4  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL4_IC_1_Sigma_ADDR             0xC036
#define REG_DMIC_VOL4_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL4_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL5  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL5_IC_1_Sigma_ADDR             0xC037
#define REG_DMIC_VOL5_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL5_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL6  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL6_IC_1_Sigma_ADDR             0xC038
#define REG_DMIC_VOL6_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL6_IC_1_Sigma_VALUE            0x40

/* DMIC_VOL7  - Registers (IC 1_Sigma) */
#define REG_DMIC_VOL7_IC_1_Sigma_ADDR             0xC039
#define REG_DMIC_VOL7_IC_1_Sigma_BYTE             1
#define REG_DMIC_VOL7_IC_1_Sigma_VALUE            0x40

/* DAC_CTRL1  - Registers (IC 1_Sigma) */
#define REG_DAC_CTRL1_IC_1_Sigma_ADDR             0xC03A
#define REG_DAC_CTRL1_IC_1_Sigma_BYTE             1
#define REG_DAC_CTRL1_IC_1_Sigma_VALUE            0x86

/* DAC_CTRL2  - Registers (IC 1_Sigma) */
#define REG_DAC_CTRL2_IC_1_Sigma_ADDR             0xC03B
#define REG_DAC_CTRL2_IC_1_Sigma_BYTE             1
#define REG_DAC_CTRL2_IC_1_Sigma_VALUE            0x0

/* DAC_VOL0  - Registers (IC 1_Sigma) */
#define REG_DAC_VOL0_IC_1_Sigma_ADDR              0xC03C
#define REG_DAC_VOL0_IC_1_Sigma_BYTE              1
#define REG_DAC_VOL0_IC_1_Sigma_VALUE             0x80

/* DAC_VOL1  - Registers (IC 1_Sigma) */
#define REG_DAC_VOL1_IC_1_Sigma_ADDR              0xC03D
#define REG_DAC_VOL1_IC_1_Sigma_BYTE              1
#define REG_DAC_VOL1_IC_1_Sigma_VALUE             0x80

/* DAC_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_DAC_ROUTE0_IC_1_Sigma_ADDR            0xC03E
#define REG_DAC_ROUTE0_IC_1_Sigma_BYTE            1
#define REG_DAC_ROUTE0_IC_1_Sigma_VALUE           0x0

/* DAC_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_DAC_ROUTE1_IC_1_Sigma_ADDR            0xC03F
#define REG_DAC_ROUTE1_IC_1_Sigma_BYTE            1
#define REG_DAC_ROUTE1_IC_1_Sigma_VALUE           0x1

/* HP_CTRL  - Registers (IC 1_Sigma) */
#define REG_HP_CTRL_IC_1_Sigma_ADDR               0xC040
#define REG_HP_CTRL_IC_1_Sigma_BYTE               1
#define REG_HP_CTRL_IC_1_Sigma_VALUE              0x0

/* FDEC_CTRL1  - Registers (IC 1_Sigma) */
#define REG_FDEC_CTRL1_IC_1_Sigma_ADDR            0xC041
#define REG_FDEC_CTRL1_IC_1_Sigma_BYTE            1
#define REG_FDEC_CTRL1_IC_1_Sigma_VALUE           0x44

/* FDEC_CTRL2  - Registers (IC 1_Sigma) */
#define REG_FDEC_CTRL2_IC_1_Sigma_ADDR            0xC042
#define REG_FDEC_CTRL2_IC_1_Sigma_BYTE            1
#define REG_FDEC_CTRL2_IC_1_Sigma_VALUE           0x25

/* FDEC_CTRL3  - Registers (IC 1_Sigma) */
#define REG_FDEC_CTRL3_IC_1_Sigma_ADDR            0xC043
#define REG_FDEC_CTRL3_IC_1_Sigma_BYTE            1
#define REG_FDEC_CTRL3_IC_1_Sigma_VALUE           0x25

/* FDEC_CTRL4  - Registers (IC 1_Sigma) */
#define REG_FDEC_CTRL4_IC_1_Sigma_ADDR            0xC044
#define REG_FDEC_CTRL4_IC_1_Sigma_BYTE            1
#define REG_FDEC_CTRL4_IC_1_Sigma_VALUE           0x25

/* FDEC_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE0_IC_1_Sigma_ADDR           0xC045
#define REG_FDEC_ROUTE0_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE0_IC_1_Sigma_VALUE          0x26

/* FDEC_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE1_IC_1_Sigma_ADDR           0xC046
#define REG_FDEC_ROUTE1_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE1_IC_1_Sigma_VALUE          0x27

/* FDEC_ROUTE2  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE2_IC_1_Sigma_ADDR           0xC047
#define REG_FDEC_ROUTE2_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE2_IC_1_Sigma_VALUE          0x0

/* FDEC_ROUTE3  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE3_IC_1_Sigma_ADDR           0xC048
#define REG_FDEC_ROUTE3_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE3_IC_1_Sigma_VALUE          0x0

/* FDEC_ROUTE4  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE4_IC_1_Sigma_ADDR           0xC049
#define REG_FDEC_ROUTE4_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE4_IC_1_Sigma_VALUE          0x0

/* FDEC_ROUTE5  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE5_IC_1_Sigma_ADDR           0xC04A
#define REG_FDEC_ROUTE5_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE5_IC_1_Sigma_VALUE          0x0

/* FDEC_ROUTE6  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE6_IC_1_Sigma_ADDR           0xC04B
#define REG_FDEC_ROUTE6_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE6_IC_1_Sigma_VALUE          0x0

/* FDEC_ROUTE7  - Registers (IC 1_Sigma) */
#define REG_FDEC_ROUTE7_IC_1_Sigma_ADDR           0xC04C
#define REG_FDEC_ROUTE7_IC_1_Sigma_BYTE           1
#define REG_FDEC_ROUTE7_IC_1_Sigma_VALUE          0x0

/* FINT_CTRL1  - Registers (IC 1_Sigma) */
#define REG_FINT_CTRL1_IC_1_Sigma_ADDR            0xC04D
#define REG_FINT_CTRL1_IC_1_Sigma_BYTE            1
#define REG_FINT_CTRL1_IC_1_Sigma_VALUE           0x65

/* FINT_CTRL2  - Registers (IC 1_Sigma) */
#define REG_FINT_CTRL2_IC_1_Sigma_ADDR            0xC04E
#define REG_FINT_CTRL2_IC_1_Sigma_BYTE            1
#define REG_FINT_CTRL2_IC_1_Sigma_VALUE           0x64

/* FINT_CTRL3  - Registers (IC 1_Sigma) */
#define REG_FINT_CTRL3_IC_1_Sigma_ADDR            0xC04F
#define REG_FINT_CTRL3_IC_1_Sigma_BYTE            1
#define REG_FINT_CTRL3_IC_1_Sigma_VALUE           0x52

/* FINT_CTRL4  - Registers (IC 1_Sigma) */
#define REG_FINT_CTRL4_IC_1_Sigma_ADDR            0xC050
#define REG_FINT_CTRL4_IC_1_Sigma_BYTE            1
#define REG_FINT_CTRL4_IC_1_Sigma_VALUE           0x52

/* FINT_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE0_IC_1_Sigma_ADDR           0xC051
#define REG_FINT_ROUTE0_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE0_IC_1_Sigma_VALUE          0x0

/* FINT_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE1_IC_1_Sigma_ADDR           0xC052
#define REG_FINT_ROUTE1_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE1_IC_1_Sigma_VALUE          0x1

/* FINT_ROUTE2  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE2_IC_1_Sigma_ADDR           0xC053
#define REG_FINT_ROUTE2_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE2_IC_1_Sigma_VALUE          0x0

/* FINT_ROUTE3  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE3_IC_1_Sigma_ADDR           0xC054
#define REG_FINT_ROUTE3_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE3_IC_1_Sigma_VALUE          0x0

/* FINT_ROUTE4  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE4_IC_1_Sigma_ADDR           0xC055
#define REG_FINT_ROUTE4_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE4_IC_1_Sigma_VALUE          0x0

/* FINT_ROUTE5  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE5_IC_1_Sigma_ADDR           0xC056
#define REG_FINT_ROUTE5_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE5_IC_1_Sigma_VALUE          0x0

/* FINT_ROUTE6  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE6_IC_1_Sigma_ADDR           0xC057
#define REG_FINT_ROUTE6_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE6_IC_1_Sigma_VALUE          0x0

/* FINT_ROUTE7  - Registers (IC 1_Sigma) */
#define REG_FINT_ROUTE7_IC_1_Sigma_ADDR           0xC058
#define REG_FINT_ROUTE7_IC_1_Sigma_BYTE           1
#define REG_FINT_ROUTE7_IC_1_Sigma_VALUE          0x0

/* ASRCI_CTRL  - Registers (IC 1_Sigma) */
#define REG_ASRCI_CTRL_IC_1_Sigma_ADDR            0xC059
#define REG_ASRCI_CTRL_IC_1_Sigma_BYTE            1
#define REG_ASRCI_CTRL_IC_1_Sigma_VALUE           0x4

/* ASRCI_ROUTE01  - Registers (IC 1_Sigma) */
#define REG_ASRCI_ROUTE01_IC_1_Sigma_ADDR         0xC05A
#define REG_ASRCI_ROUTE01_IC_1_Sigma_BYTE         1
#define REG_ASRCI_ROUTE01_IC_1_Sigma_VALUE        0x10

/* ASRCI_ROUTE23  - Registers (IC 1_Sigma) */
#define REG_ASRCI_ROUTE23_IC_1_Sigma_ADDR         0xC05B
#define REG_ASRCI_ROUTE23_IC_1_Sigma_BYTE         1
#define REG_ASRCI_ROUTE23_IC_1_Sigma_VALUE        0x0

/* ASRCO_CTRL  - Registers (IC 1_Sigma) */
#define REG_ASRCO_CTRL_IC_1_Sigma_ADDR            0xC05C
#define REG_ASRCO_CTRL_IC_1_Sigma_BYTE            1
#define REG_ASRCO_CTRL_IC_1_Sigma_VALUE           0x4

/* ASRCO_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_ASRCO_ROUTE0_IC_1_Sigma_ADDR          0xC05D
#define REG_ASRCO_ROUTE0_IC_1_Sigma_BYTE          1
#define REG_ASRCO_ROUTE0_IC_1_Sigma_VALUE         0x2C

/* ASRCO_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_ASRCO_ROUTE1_IC_1_Sigma_ADDR          0xC05E
#define REG_ASRCO_ROUTE1_IC_1_Sigma_BYTE          1
#define REG_ASRCO_ROUTE1_IC_1_Sigma_VALUE         0x2D

/* ASRCO_ROUTE2  - Registers (IC 1_Sigma) */
#define REG_ASRCO_ROUTE2_IC_1_Sigma_ADDR          0xC05F
#define REG_ASRCO_ROUTE2_IC_1_Sigma_BYTE          1
#define REG_ASRCO_ROUTE2_IC_1_Sigma_VALUE         0x0

/* ASRCO_ROUTE3  - Registers (IC 1_Sigma) */
#define REG_ASRCO_ROUTE3_IC_1_Sigma_ADDR          0xC060
#define REG_ASRCO_ROUTE3_IC_1_Sigma_BYTE          1
#define REG_ASRCO_ROUTE3_IC_1_Sigma_VALUE         0x0

/* FDSP_RUN  - Registers (IC 1_Sigma) */
#define REG_FDSP_RUN_IC_1_Sigma_ADDR              0xC061
#define REG_FDSP_RUN_IC_1_Sigma_BYTE              1
#define REG_FDSP_RUN_IC_1_Sigma_VALUE             0x0

/* FDSP_CTRL1  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL1_IC_1_Sigma_ADDR            0xC062
#define REG_FDSP_CTRL1_IC_1_Sigma_BYTE            1
#define REG_FDSP_CTRL1_IC_1_Sigma_VALUE           0x70

/* FDSP_CTRL2  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL2_IC_1_Sigma_ADDR            0xC063
#define REG_FDSP_CTRL2_IC_1_Sigma_BYTE            1
#define REG_FDSP_CTRL2_IC_1_Sigma_VALUE           0x3F

/* FDSP_CTRL3  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL3_IC_1_Sigma_ADDR            0xC064
#define REG_FDSP_CTRL3_IC_1_Sigma_BYTE            1
#define REG_FDSP_CTRL3_IC_1_Sigma_VALUE           0x0

/* FDSP_CTRL4  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL4_IC_1_Sigma_ADDR            0xC065
#define REG_FDSP_CTRL4_IC_1_Sigma_BYTE            1
#define REG_FDSP_CTRL4_IC_1_Sigma_VALUE           0x1

/* FDSP_CTRL5  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL5_IC_1_Sigma_ADDR            0xC066
#define REG_FDSP_CTRL5_IC_1_Sigma_BYTE            2
#define REG_FDSP_CTRL5_IC_1_Sigma_VALUE           0x7F

/* FDSP_CTRL7  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL7_IC_1_Sigma_ADDR            0xC068
#define REG_FDSP_CTRL7_IC_1_Sigma_BYTE            1
#define REG_FDSP_CTRL7_IC_1_Sigma_VALUE           0x0

/* FDSP_CTRL8  - Registers (IC 1_Sigma) */
#define REG_FDSP_CTRL8_IC_1_Sigma_ADDR            0xC069
#define REG_FDSP_CTRL8_IC_1_Sigma_BYTE            1
#define REG_FDSP_CTRL8_IC_1_Sigma_VALUE           0x0

/* FDSP_SL_ADDR  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_ADDR_IC_1_Sigma_ADDR          0xC06A
#define REG_FDSP_SL_ADDR_IC_1_Sigma_BYTE          1
#define REG_FDSP_SL_ADDR_IC_1_Sigma_VALUE         0x0

/* FDSP_SL_P0  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_P0_IC_1_Sigma_ADDR            0xC06B
#define REG_FDSP_SL_P0_IC_1_Sigma_BYTE            4
#define REG_FDSP_SL_P0_IC_1_Sigma_VALUE           0x0

/* FDSP_SL_P1  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_P1_IC_1_Sigma_ADDR            0xC06F
#define REG_FDSP_SL_P1_IC_1_Sigma_BYTE            4
#define REG_FDSP_SL_P1_IC_1_Sigma_VALUE           0x0

/* FDSP_SL_P2  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_P2_IC_1_Sigma_ADDR            0xC073
#define REG_FDSP_SL_P2_IC_1_Sigma_BYTE            4
#define REG_FDSP_SL_P2_IC_1_Sigma_VALUE           0x0

/* FDSP_SL_P3  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_P3_IC_1_Sigma_ADDR            0xC077
#define REG_FDSP_SL_P3_IC_1_Sigma_BYTE            4
#define REG_FDSP_SL_P3_IC_1_Sigma_VALUE           0x0

/* FDSP_SL_P4  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_P4_IC_1_Sigma_ADDR            0xC07B
#define REG_FDSP_SL_P4_IC_1_Sigma_BYTE            4
#define REG_FDSP_SL_P4_IC_1_Sigma_VALUE           0x0

/* FDSP_SL_UPDATE  - Registers (IC 1_Sigma) */
#define REG_FDSP_SL_UPDATE_IC_1_Sigma_ADDR        0xC07F
#define REG_FDSP_SL_UPDATE_IC_1_Sigma_BYTE        1
#define REG_FDSP_SL_UPDATE_IC_1_Sigma_VALUE       0x0

/* SDSP_CTRL1  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL1_IC_1_Sigma_ADDR            0xC080
#define REG_SDSP_CTRL1_IC_1_Sigma_BYTE            1
#define REG_SDSP_CTRL1_IC_1_Sigma_VALUE           0x0

/* SDSP_CTRL2  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL2_IC_1_Sigma_ADDR            0xC081
#define REG_SDSP_CTRL2_IC_1_Sigma_BYTE            1
#define REG_SDSP_CTRL2_IC_1_Sigma_VALUE           0x0

/* SDSP_CTRL3  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL3_IC_1_Sigma_ADDR            0xC082
#define REG_SDSP_CTRL3_IC_1_Sigma_BYTE            1
#define REG_SDSP_CTRL3_IC_1_Sigma_VALUE           0x0

/* SDSP_CTRL4  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL4_IC_1_Sigma_ADDR            0xC083
#define REG_SDSP_CTRL4_IC_1_Sigma_BYTE            3
#define REG_SDSP_CTRL4_IC_1_Sigma_VALUE           0x0

/* SDSP_CTRL7  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL7_IC_1_Sigma_ADDR            0xC086
#define REG_SDSP_CTRL7_IC_1_Sigma_BYTE            2
#define REG_SDSP_CTRL7_IC_1_Sigma_VALUE           0x7F4

/* SDSP_CTRL9  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL9_IC_1_Sigma_ADDR            0xC088
#define REG_SDSP_CTRL9_IC_1_Sigma_BYTE            2
#define REG_SDSP_CTRL9_IC_1_Sigma_VALUE           0x7FF

/* SDSP_CTRL11  - Registers (IC 1_Sigma) */
#define REG_SDSP_CTRL11_IC_1_Sigma_ADDR           0xC08A
#define REG_SDSP_CTRL11_IC_1_Sigma_BYTE           1
#define REG_SDSP_CTRL11_IC_1_Sigma_VALUE          0x0

/* MP_CTRL1  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL1_IC_1_Sigma_ADDR              0xC08B
#define REG_MP_CTRL1_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL1_IC_1_Sigma_VALUE             0x0

/* MP_CTRL2  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL2_IC_1_Sigma_ADDR              0xC08C
#define REG_MP_CTRL2_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL2_IC_1_Sigma_VALUE             0x0

/* MP_CTRL3  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL3_IC_1_Sigma_ADDR              0xC08D
#define REG_MP_CTRL3_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL3_IC_1_Sigma_VALUE             0x0

/* MP_CTRL4  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL4_IC_1_Sigma_ADDR              0xC08E
#define REG_MP_CTRL4_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL4_IC_1_Sigma_VALUE             0x0

/* MP_CTRL5  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL5_IC_1_Sigma_ADDR              0xC08F
#define REG_MP_CTRL5_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL5_IC_1_Sigma_VALUE             0x0

/* MP_CTRL6  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL6_IC_1_Sigma_ADDR              0xC090
#define REG_MP_CTRL6_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL6_IC_1_Sigma_VALUE             0x0

/* MP_CTRL7  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL7_IC_1_Sigma_ADDR              0xC091
#define REG_MP_CTRL7_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL7_IC_1_Sigma_VALUE             0x0

/* MP_CTRL8  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL8_IC_1_Sigma_ADDR              0xC092
#define REG_MP_CTRL8_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL8_IC_1_Sigma_VALUE             0x0

/* MP_CTRL9  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL9_IC_1_Sigma_ADDR              0xC093
#define REG_MP_CTRL9_IC_1_Sigma_BYTE              1
#define REG_MP_CTRL9_IC_1_Sigma_VALUE             0x0

/* FSYNC0_CTRL  - Registers (IC 1_Sigma) */
#define REG_FSYNC0_CTRL_IC_1_Sigma_ADDR           0xC094
#define REG_FSYNC0_CTRL_IC_1_Sigma_BYTE           1
#define REG_FSYNC0_CTRL_IC_1_Sigma_VALUE          0x5

/* BCLK0_CTRL  - Registers (IC 1_Sigma) */
#define REG_BCLK0_CTRL_IC_1_Sigma_ADDR            0xC095
#define REG_BCLK0_CTRL_IC_1_Sigma_BYTE            1
#define REG_BCLK0_CTRL_IC_1_Sigma_VALUE           0x5

/* SDATAO0_CTRL  - Registers (IC 1_Sigma) */
#define REG_SDATAO0_CTRL_IC_1_Sigma_ADDR          0xC096
#define REG_SDATAO0_CTRL_IC_1_Sigma_BYTE          1
#define REG_SDATAO0_CTRL_IC_1_Sigma_VALUE         0x4

/* SDATAI0_CTRL  - Registers (IC 1_Sigma) */
#define REG_SDATAI0_CTRL_IC_1_Sigma_ADDR          0xC097
#define REG_SDATAI0_CTRL_IC_1_Sigma_BYTE          1
#define REG_SDATAI0_CTRL_IC_1_Sigma_VALUE         0x5

/* FSYNC1_CTRL  - Registers (IC 1_Sigma) */
#define REG_FSYNC1_CTRL_IC_1_Sigma_ADDR           0xC098
#define REG_FSYNC1_CTRL_IC_1_Sigma_BYTE           1
#define REG_FSYNC1_CTRL_IC_1_Sigma_VALUE          0x5

/* BCLK1_CTRL  - Registers (IC 1_Sigma) */
#define REG_BCLK1_CTRL_IC_1_Sigma_ADDR            0xC099
#define REG_BCLK1_CTRL_IC_1_Sigma_BYTE            1
#define REG_BCLK1_CTRL_IC_1_Sigma_VALUE           0x5

/* SDATAO1_CTRL  - Registers (IC 1_Sigma) */
#define REG_SDATAO1_CTRL_IC_1_Sigma_ADDR          0xC09A
#define REG_SDATAO1_CTRL_IC_1_Sigma_BYTE          1
#define REG_SDATAO1_CTRL_IC_1_Sigma_VALUE         0x5

/* SDATAI1_CTRL  - Registers (IC 1_Sigma) */
#define REG_SDATAI1_CTRL_IC_1_Sigma_ADDR          0xC09B
#define REG_SDATAI1_CTRL_IC_1_Sigma_BYTE          1
#define REG_SDATAI1_CTRL_IC_1_Sigma_VALUE         0x4

/* DMIC_CLK0_CTRL  - Registers (IC 1_Sigma) */
#define REG_DMIC_CLK0_CTRL_IC_1_Sigma_ADDR        0xC09C
#define REG_DMIC_CLK0_CTRL_IC_1_Sigma_BYTE        1
#define REG_DMIC_CLK0_CTRL_IC_1_Sigma_VALUE       0x5

/* DMIC_CLK1_CTRL  - Registers (IC 1_Sigma) */
#define REG_DMIC_CLK1_CTRL_IC_1_Sigma_ADDR        0xC09D
#define REG_DMIC_CLK1_CTRL_IC_1_Sigma_BYTE        1
#define REG_DMIC_CLK1_CTRL_IC_1_Sigma_VALUE       0x5

/* DMIC01_CTRL  - Registers (IC 1_Sigma) */
#define REG_DMIC01_CTRL_IC_1_Sigma_ADDR           0xC09E
#define REG_DMIC01_CTRL_IC_1_Sigma_BYTE           1
#define REG_DMIC01_CTRL_IC_1_Sigma_VALUE          0x5

/* DMIC23_CTRL  - Registers (IC 1_Sigma) */
#define REG_DMIC23_CTRL_IC_1_Sigma_ADDR           0xC09F
#define REG_DMIC23_CTRL_IC_1_Sigma_BYTE           1
#define REG_DMIC23_CTRL_IC_1_Sigma_VALUE          0x5

/* I2C_SPI_CTRL  - Registers (IC 1_Sigma) */
#define REG_I2C_SPI_CTRL_IC_1_Sigma_ADDR          0xC0A0
#define REG_I2C_SPI_CTRL_IC_1_Sigma_BYTE          1
#define REG_I2C_SPI_CTRL_IC_1_Sigma_VALUE         0x0

/* IRQ_CTRL1  - Registers (IC 1_Sigma) */
#define REG_IRQ_CTRL1_IC_1_Sigma_ADDR             0xC0A1
#define REG_IRQ_CTRL1_IC_1_Sigma_BYTE             1
#define REG_IRQ_CTRL1_IC_1_Sigma_VALUE            0x0

/* IRQ1_MASK1  - Registers (IC 1_Sigma) */
#define REG_IRQ1_MASK1_IC_1_Sigma_ADDR            0xC0A2
#define REG_IRQ1_MASK1_IC_1_Sigma_BYTE            1
#define REG_IRQ1_MASK1_IC_1_Sigma_VALUE           0xF3

/* IRQ1_MASK2  - Registers (IC 1_Sigma) */
#define REG_IRQ1_MASK2_IC_1_Sigma_ADDR            0xC0A3
#define REG_IRQ1_MASK2_IC_1_Sigma_BYTE            1
#define REG_IRQ1_MASK2_IC_1_Sigma_VALUE           0xFF

/* IRQ1_MASK3  - Registers (IC 1_Sigma) */
#define REG_IRQ1_MASK3_IC_1_Sigma_ADDR            0xC0A4
#define REG_IRQ1_MASK3_IC_1_Sigma_BYTE            1
#define REG_IRQ1_MASK3_IC_1_Sigma_VALUE           0x1F

/* IRQ2_MASK1  - Registers (IC 1_Sigma) */
#define REG_IRQ2_MASK1_IC_1_Sigma_ADDR            0xC0A5
#define REG_IRQ2_MASK1_IC_1_Sigma_BYTE            1
#define REG_IRQ2_MASK1_IC_1_Sigma_VALUE           0xF3

/* IRQ2_MASK2  - Registers (IC 1_Sigma) */
#define REG_IRQ2_MASK2_IC_1_Sigma_ADDR            0xC0A6
#define REG_IRQ2_MASK2_IC_1_Sigma_BYTE            1
#define REG_IRQ2_MASK2_IC_1_Sigma_VALUE           0xFF

/* IRQ2_MASK3  - Registers (IC 1_Sigma) */
#define REG_IRQ2_MASK3_IC_1_Sigma_ADDR            0xC0A7
#define REG_IRQ2_MASK3_IC_1_Sigma_BYTE            1
#define REG_IRQ2_MASK3_IC_1_Sigma_VALUE           0x1F

/* RESETS  - Registers (IC 1_Sigma) */
#define REG_RESETS_IC_1_Sigma_ADDR                0xC0A8
#define REG_RESETS_IC_1_Sigma_BYTE                1
#define REG_RESETS_IC_1_Sigma_VALUE               0x0

/* READ_LAMBDA  - Registers (IC 1_Sigma) */
#define REG_READ_LAMBDA_IC_1_Sigma_ADDR           0xC0A9
#define REG_READ_LAMBDA_IC_1_Sigma_BYTE           0
#define REG_READ_LAMBDA_IC_1_Sigma_VALUE          0x3F

/* STATUS1  - Registers (IC 1_Sigma) */
#define REG_STATUS1_IC_1_Sigma_ADDR               0xC0AA
#define REG_STATUS1_IC_1_Sigma_BYTE               0
#define REG_STATUS1_IC_1_Sigma_VALUE              0x0

/* STATUS2  - Registers (IC 1_Sigma) */
#define REG_STATUS2_IC_1_Sigma_ADDR               0xC0AB
#define REG_STATUS2_IC_1_Sigma_BYTE               0
#define REG_STATUS2_IC_1_Sigma_VALUE              0x0

/* GPI1  - Registers (IC 1_Sigma) */
#define REG_GPI1_IC_1_Sigma_ADDR                  0xC0AC
#define REG_GPI1_IC_1_Sigma_BYTE                  0
#define REG_GPI1_IC_1_Sigma_VALUE                 0x0

/* GPI2  - Registers (IC 1_Sigma) */
#define REG_GPI2_IC_1_Sigma_ADDR                  0xC0AD
#define REG_GPI2_IC_1_Sigma_BYTE                  0
#define REG_GPI2_IC_1_Sigma_VALUE                 0x0

/* DSP_STATUS  - Registers (IC 1_Sigma) */
#define REG_DSP_STATUS_IC_1_Sigma_ADDR            0xC0AE
#define REG_DSP_STATUS_IC_1_Sigma_BYTE            0
#define REG_DSP_STATUS_IC_1_Sigma_VALUE           0x0

/* IRQ1_STATUS1  - Registers (IC 1_Sigma) */
#define REG_IRQ1_STATUS1_IC_1_Sigma_ADDR          0xC0AF
#define REG_IRQ1_STATUS1_IC_1_Sigma_BYTE          0
#define REG_IRQ1_STATUS1_IC_1_Sigma_VALUE         0x0

/* IRQ1_STATUS2  - Registers (IC 1_Sigma) */
#define REG_IRQ1_STATUS2_IC_1_Sigma_ADDR          0xC0B0
#define REG_IRQ1_STATUS2_IC_1_Sigma_BYTE          0
#define REG_IRQ1_STATUS2_IC_1_Sigma_VALUE         0x0

/* IRQ1_STATUS3  - Registers (IC 1_Sigma) */
#define REG_IRQ1_STATUS3_IC_1_Sigma_ADDR          0xC0B1
#define REG_IRQ1_STATUS3_IC_1_Sigma_BYTE          0
#define REG_IRQ1_STATUS3_IC_1_Sigma_VALUE         0x0

/* IRQ2_STATUS1  - Registers (IC 1_Sigma) */
#define REG_IRQ2_STATUS1_IC_1_Sigma_ADDR          0xC0B2
#define REG_IRQ2_STATUS1_IC_1_Sigma_BYTE          0
#define REG_IRQ2_STATUS1_IC_1_Sigma_VALUE         0x0

/* IRQ2_STATUS2  - Registers (IC 1_Sigma) */
#define REG_IRQ2_STATUS2_IC_1_Sigma_ADDR          0xC0B3
#define REG_IRQ2_STATUS2_IC_1_Sigma_BYTE          0
#define REG_IRQ2_STATUS2_IC_1_Sigma_VALUE         0x0

/* IRQ2_STATUS3  - Registers (IC 1_Sigma) */
#define REG_IRQ2_STATUS3_IC_1_Sigma_ADDR          0xC0B4
#define REG_IRQ2_STATUS3_IC_1_Sigma_BYTE          0
#define REG_IRQ2_STATUS3_IC_1_Sigma_VALUE         0x0

/* SPT0_CTRL1  - Registers (IC 1_Sigma) */
#define REG_SPT0_CTRL1_IC_1_Sigma_ADDR            0xC0B5
#define REG_SPT0_CTRL1_IC_1_Sigma_BYTE            1
#define REG_SPT0_CTRL1_IC_1_Sigma_VALUE           0x20

/* SPT0_CTRL2  - Registers (IC 1_Sigma) */
#define REG_SPT0_CTRL2_IC_1_Sigma_ADDR            0xC0B6
#define REG_SPT0_CTRL2_IC_1_Sigma_BYTE            1
#define REG_SPT0_CTRL2_IC_1_Sigma_VALUE           0x0

/* SPT0_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE0_IC_1_Sigma_ADDR           0xC0B7
#define REG_SPT0_ROUTE0_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE0_IC_1_Sigma_VALUE          0x26

/* SPT0_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE1_IC_1_Sigma_ADDR           0xC0B8
#define REG_SPT0_ROUTE1_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE1_IC_1_Sigma_VALUE          0x27

/* SPT0_ROUTE2  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE2_IC_1_Sigma_ADDR           0xC0B9
#define REG_SPT0_ROUTE2_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE2_IC_1_Sigma_VALUE          0x3F

/* SPT0_ROUTE3  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE3_IC_1_Sigma_ADDR           0xC0BA
#define REG_SPT0_ROUTE3_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE3_IC_1_Sigma_VALUE          0x3F

/* SPT0_ROUTE4  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE4_IC_1_Sigma_ADDR           0xC0BB
#define REG_SPT0_ROUTE4_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE4_IC_1_Sigma_VALUE          0x3E

/* SPT0_ROUTE5  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE5_IC_1_Sigma_ADDR           0xC0BC
#define REG_SPT0_ROUTE5_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE5_IC_1_Sigma_VALUE          0x3F

/* SPT0_ROUTE6  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE6_IC_1_Sigma_ADDR           0xC0BD
#define REG_SPT0_ROUTE6_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE6_IC_1_Sigma_VALUE          0x3F

/* SPT0_ROUTE7  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE7_IC_1_Sigma_ADDR           0xC0BE
#define REG_SPT0_ROUTE7_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE7_IC_1_Sigma_VALUE          0x3F

/* SPT0_ROUTE8  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE8_IC_1_Sigma_ADDR           0xC0BF
#define REG_SPT0_ROUTE8_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE8_IC_1_Sigma_VALUE          0x3E

/* SPT0_ROUTE9  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE9_IC_1_Sigma_ADDR           0xC0C0
#define REG_SPT0_ROUTE9_IC_1_Sigma_BYTE           1
#define REG_SPT0_ROUTE9_IC_1_Sigma_VALUE          0x3F

/* SPT0_ROUTE10  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE10_IC_1_Sigma_ADDR          0xC0C1
#define REG_SPT0_ROUTE10_IC_1_Sigma_BYTE          1
#define REG_SPT0_ROUTE10_IC_1_Sigma_VALUE         0x3F

/* SPT0_ROUTE11  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE11_IC_1_Sigma_ADDR          0xC0C2
#define REG_SPT0_ROUTE11_IC_1_Sigma_BYTE          1
#define REG_SPT0_ROUTE11_IC_1_Sigma_VALUE         0x3F

/* SPT0_ROUTE12  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE12_IC_1_Sigma_ADDR          0xC0C3
#define REG_SPT0_ROUTE12_IC_1_Sigma_BYTE          1
#define REG_SPT0_ROUTE12_IC_1_Sigma_VALUE         0x3F

/* SPT0_ROUTE13  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE13_IC_1_Sigma_ADDR          0xC0C4
#define REG_SPT0_ROUTE13_IC_1_Sigma_BYTE          1
#define REG_SPT0_ROUTE13_IC_1_Sigma_VALUE         0x3F

/* SPT0_ROUTE14  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE14_IC_1_Sigma_ADDR          0xC0C5
#define REG_SPT0_ROUTE14_IC_1_Sigma_BYTE          1
#define REG_SPT0_ROUTE14_IC_1_Sigma_VALUE         0x3F

/* SPT0_ROUTE15  - Registers (IC 1_Sigma) */
#define REG_SPT0_ROUTE15_IC_1_Sigma_ADDR          0xC0C6
#define REG_SPT0_ROUTE15_IC_1_Sigma_BYTE          1
#define REG_SPT0_ROUTE15_IC_1_Sigma_VALUE         0x3F

/* SPT1_CTRL1  - Registers (IC 1_Sigma) */
#define REG_SPT1_CTRL1_IC_1_Sigma_ADDR            0xC0C7
#define REG_SPT1_CTRL1_IC_1_Sigma_BYTE            1
#define REG_SPT1_CTRL1_IC_1_Sigma_VALUE           0x20

/* SPT1_CTRL2  - Registers (IC 1_Sigma) */
#define REG_SPT1_CTRL2_IC_1_Sigma_ADDR            0xC0C8
#define REG_SPT1_CTRL2_IC_1_Sigma_BYTE            1
#define REG_SPT1_CTRL2_IC_1_Sigma_VALUE           0x0

/* SPT1_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE0_IC_1_Sigma_ADDR           0xC0C9
#define REG_SPT1_ROUTE0_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE0_IC_1_Sigma_VALUE          0x10

/* SPT1_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE1_IC_1_Sigma_ADDR           0xC0CA
#define REG_SPT1_ROUTE1_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE1_IC_1_Sigma_VALUE          0x11

/* SPT1_ROUTE2  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE2_IC_1_Sigma_ADDR           0xC0CB
#define REG_SPT1_ROUTE2_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE2_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE3  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE3_IC_1_Sigma_ADDR           0xC0CC
#define REG_SPT1_ROUTE3_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE3_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE4  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE4_IC_1_Sigma_ADDR           0xC0CD
#define REG_SPT1_ROUTE4_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE4_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE5  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE5_IC_1_Sigma_ADDR           0xC0CE
#define REG_SPT1_ROUTE5_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE5_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE6  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE6_IC_1_Sigma_ADDR           0xC0CF
#define REG_SPT1_ROUTE6_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE6_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE7  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE7_IC_1_Sigma_ADDR           0xC0D0
#define REG_SPT1_ROUTE7_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE7_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE8  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE8_IC_1_Sigma_ADDR           0xC0D1
#define REG_SPT1_ROUTE8_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE8_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE9  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE9_IC_1_Sigma_ADDR           0xC0D2
#define REG_SPT1_ROUTE9_IC_1_Sigma_BYTE           1
#define REG_SPT1_ROUTE9_IC_1_Sigma_VALUE          0x3F

/* SPT1_ROUTE10  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE10_IC_1_Sigma_ADDR          0xC0D3
#define REG_SPT1_ROUTE10_IC_1_Sigma_BYTE          1
#define REG_SPT1_ROUTE10_IC_1_Sigma_VALUE         0x3F

/* SPT1_ROUTE11  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE11_IC_1_Sigma_ADDR          0xC0D4
#define REG_SPT1_ROUTE11_IC_1_Sigma_BYTE          1
#define REG_SPT1_ROUTE11_IC_1_Sigma_VALUE         0x3F

/* SPT1_ROUTE12  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE12_IC_1_Sigma_ADDR          0xC0D5
#define REG_SPT1_ROUTE12_IC_1_Sigma_BYTE          1
#define REG_SPT1_ROUTE12_IC_1_Sigma_VALUE         0x3F

/* SPT1_ROUTE13  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE13_IC_1_Sigma_ADDR          0xC0D6
#define REG_SPT1_ROUTE13_IC_1_Sigma_BYTE          1
#define REG_SPT1_ROUTE13_IC_1_Sigma_VALUE         0x3F

/* SPT1_ROUTE14  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE14_IC_1_Sigma_ADDR          0xC0D7
#define REG_SPT1_ROUTE14_IC_1_Sigma_BYTE          1
#define REG_SPT1_ROUTE14_IC_1_Sigma_VALUE         0x3F

/* SPT1_ROUTE15  - Registers (IC 1_Sigma) */
#define REG_SPT1_ROUTE15_IC_1_Sigma_ADDR          0xC0D8
#define REG_SPT1_ROUTE15_IC_1_Sigma_BYTE          1
#define REG_SPT1_ROUTE15_IC_1_Sigma_VALUE         0x3F

/* MP_CTRL10  - Registers (IC 1_Sigma) */
#define REG_MP_CTRL10_IC_1_Sigma_ADDR             0xC0D9
#define REG_MP_CTRL10_IC_1_Sigma_BYTE             1
#define REG_MP_CTRL10_IC_1_Sigma_VALUE            0x0

/* SELFBOOT_CTRL  - Registers (IC 1_Sigma) */
#define REG_SELFBOOT_CTRL_IC_1_Sigma_ADDR         0xC0DA
#define REG_SELFBOOT_CTRL_IC_1_Sigma_BYTE         1
#define REG_SELFBOOT_CTRL_IC_1_Sigma_VALUE        0x41

/* SW_EN_CTRL  - Registers (IC 1_Sigma) */
#define REG_SW_EN_CTRL_IC_1_Sigma_ADDR            0xC0DB
#define REG_SW_EN_CTRL_IC_1_Sigma_BYTE            1
#define REG_SW_EN_CTRL_IC_1_Sigma_VALUE           0x41

/* PDM_CTRL1  - Registers (IC 1_Sigma) */
#define REG_PDM_CTRL1_IC_1_Sigma_ADDR             0xC0DC
#define REG_PDM_CTRL1_IC_1_Sigma_BYTE             1
#define REG_PDM_CTRL1_IC_1_Sigma_VALUE            0x2

/* PDM_CTRL2  - Registers (IC 1_Sigma) */
#define REG_PDM_CTRL2_IC_1_Sigma_ADDR             0xC0DD
#define REG_PDM_CTRL2_IC_1_Sigma_BYTE             1
#define REG_PDM_CTRL2_IC_1_Sigma_VALUE            0xC4

/* PDM_VOL0  - Registers (IC 1_Sigma) */
#define REG_PDM_VOL0_IC_1_Sigma_ADDR              0xC0DE
#define REG_PDM_VOL0_IC_1_Sigma_BYTE              1
#define REG_PDM_VOL0_IC_1_Sigma_VALUE             0x40

/* PDM_VOL1  - Registers (IC 1_Sigma) */
#define REG_PDM_VOL1_IC_1_Sigma_ADDR              0xC0DF
#define REG_PDM_VOL1_IC_1_Sigma_BYTE              1
#define REG_PDM_VOL1_IC_1_Sigma_VALUE             0x40

/* PDM_ROUTE0  - Registers (IC 1_Sigma) */
#define REG_PDM_ROUTE0_IC_1_Sigma_ADDR            0xC0E0
#define REG_PDM_ROUTE0_IC_1_Sigma_BYTE            1
#define REG_PDM_ROUTE0_IC_1_Sigma_VALUE           0x0

/* PDM_ROUTE1  - Registers (IC 1_Sigma) */
#define REG_PDM_ROUTE1_IC_1_Sigma_ADDR            0xC0E1
#define REG_PDM_ROUTE1_IC_1_Sigma_BYTE            1
#define REG_PDM_ROUTE1_IC_1_Sigma_VALUE           0x1

/* SDSP_MEM_SPEED_CTRL  - Registers (IC 1_Sigma) */
#define REG_SDSP_MEM_SPEED_CTRL_IC_1_Sigma_ADDR   0xCC20
#define REG_SDSP_MEM_SPEED_CTRL_IC_1_Sigma_BYTE   1
#define REG_SDSP_MEM_SPEED_CTRL_IC_1_Sigma_VALUE  0x0

/* SDSP_MEM_SLEEP_CTRL  - Registers (IC 1_Sigma) */
#define REG_SDSP_MEM_SLEEP_CTRL_IC_1_Sigma_ADDR   0xCC21
#define REG_SDSP_MEM_SLEEP_CTRL_IC_1_Sigma_BYTE   1
#define REG_SDSP_MEM_SLEEP_CTRL_IC_1_Sigma_VALUE  0x0

/* FDSP_MEM_SPEED_CTRL  - Registers (IC 1_Sigma) */
#define REG_FDSP_MEM_SPEED_CTRL_IC_1_Sigma_ADDR   0xCC22
#define REG_FDSP_MEM_SPEED_CTRL_IC_1_Sigma_BYTE   1
#define REG_FDSP_MEM_SPEED_CTRL_IC_1_Sigma_VALUE  0x0

/* FDSP_MEM_SLEEP_CTRL  - Registers (IC 1_Sigma) */
#define REG_FDSP_MEM_SLEEP_CTRL_IC_1_Sigma_ADDR   0xCC23
#define REG_FDSP_MEM_SLEEP_CTRL_IC_1_Sigma_BYTE   1
#define REG_FDSP_MEM_SLEEP_CTRL_IC_1_Sigma_VALUE  0x0

/* I2C_PAD_CTRL  - Registers (IC 1_Sigma) */
#define REG_I2C_PAD_CTRL_IC_1_Sigma_ADDR          0xCC24
#define REG_I2C_PAD_CTRL_IC_1_Sigma_BYTE          1
#define REG_I2C_PAD_CTRL_IC_1_Sigma_VALUE         0x0

/* TEST_PAD0_CTRL  - Registers (IC 1_Sigma) */
#define REG_TEST_PAD0_CTRL_IC_1_Sigma_ADDR        0xCC25
#define REG_TEST_PAD0_CTRL_IC_1_Sigma_BYTE        1
#define REG_TEST_PAD0_CTRL_IC_1_Sigma_VALUE       0x0

/* TEST_PAD1_CTRL  - Registers (IC 1_Sigma) */
#define REG_TEST_PAD1_CTRL_IC_1_Sigma_ADDR        0xCC26
#define REG_TEST_PAD1_CTRL_IC_1_Sigma_BYTE        1
#define REG_TEST_PAD1_CTRL_IC_1_Sigma_VALUE       0x0

/* ADC01_BIAS_OVERRIDE  - Registers (IC 1_Sigma) */
#define REG_ADC01_BIAS_OVERRIDE_IC_1_Sigma_ADDR   0xCC27
#define REG_ADC01_BIAS_OVERRIDE_IC_1_Sigma_BYTE   1
#define REG_ADC01_BIAS_OVERRIDE_IC_1_Sigma_VALUE  0x0

/* ADC23_BIAS_OVERRIDE  - Registers (IC 1_Sigma) */
#define REG_ADC23_BIAS_OVERRIDE_IC_1_Sigma_ADDR   0xCC28
#define REG_ADC23_BIAS_OVERRIDE_IC_1_Sigma_BYTE   1
#define REG_ADC23_BIAS_OVERRIDE_IC_1_Sigma_VALUE  0x0

/* TEMP_ADC_BIAS  - Registers (IC 1_Sigma) */
#define REG_TEMP_ADC_BIAS_IC_1_Sigma_ADDR         0xCC29
#define REG_TEMP_ADC_BIAS_IC_1_Sigma_BYTE         1
#define REG_TEMP_ADC_BIAS_IC_1_Sigma_VALUE        0x0

/* MBIAS_TEST  - Registers (IC 1_Sigma) */
#define REG_MBIAS_TEST_IC_1_Sigma_ADDR            0xCC2A
#define REG_MBIAS_TEST_IC_1_Sigma_BYTE            1
#define REG_MBIAS_TEST_IC_1_Sigma_VALUE           0x0

/* FDSP_TEST_MODES  - Registers (IC 1_Sigma) */
#define REG_FDSP_TEST_MODES_IC_1_Sigma_ADDR       0xCC30
#define REG_FDSP_TEST_MODES_IC_1_Sigma_BYTE       1
#define REG_FDSP_TEST_MODES_IC_1_Sigma_VALUE      0x0

/* FAULT_DISABLE  - Registers (IC 1_Sigma) */
#define REG_FAULT_DISABLE_IC_1_Sigma_ADDR         0xCC31
#define REG_FAULT_DISABLE_IC_1_Sigma_BYTE         1
#define REG_FAULT_DISABLE_IC_1_Sigma_VALUE        0x0

/* ALDO_CTRL  - Registers (IC 1_Sigma) */
#define REG_ALDO_CTRL_IC_1_Sigma_ADDR             0xCC32
#define REG_ALDO_CTRL_IC_1_Sigma_BYTE             1
#define REG_ALDO_CTRL_IC_1_Sigma_VALUE            0x0

/* PMU_TEST  - Registers (IC 1_Sigma) */
#define REG_PMU_TEST_IC_1_Sigma_ADDR              0xCC33
#define REG_PMU_TEST_IC_1_Sigma_BYTE              1
#define REG_PMU_TEST_IC_1_Sigma_VALUE             0x0

/* DUMMY_SPI_ENABLE  - Registers (IC 1_Sigma) */
#define REG_DUMMY_SPI_ENABLE_IC_1_Sigma_ADDR      0xCCFF
#define REG_DUMMY_SPI_ENABLE_IC_1_Sigma_BYTE      1
#define REG_DUMMY_SPI_ENABLE_IC_1_Sigma_VALUE     0x0

/* PLLCalculator  - Registers (IC 1_Sigma) */
#define REG_PLLCALCULATOR_IC_1_Sigma_ADDR         0xCD00
#define REG_PLLCALCULATOR_IC_1_Sigma_BYTE         4
#define REG_PLLCALCULATOR_IC_1_Sigma_VALUE        0x189374BC


/*
 *
 * Control register's field descriptions
 *
 */

/* VENDOR_ID (IC 1_Sigma) */
#define R0_VENDOR_IC_1_Sigma                      0x41   /* 01000001b	[7:0] */
#define R0_VENDOR_IC_1_Sigma_MASK                 0xFF
#define R0_VENDOR_IC_1_Sigma_SHIFT                0

/* DEVICE_ID1 (IC 1_Sigma) */
#define R1_DEVICE1_IC_1_Sigma                     0x17   /* 00010111b	[7:0] */
#define R1_DEVICE1_IC_1_Sigma_MASK                0xFF
#define R1_DEVICE1_IC_1_Sigma_SHIFT               0

/* DEVICE_ID2 (IC 1_Sigma) */
#define R2_DEVICE2_IC_1_Sigma                     0x87   /* 10000111b	[7:0] */
#define R2_DEVICE2_IC_1_Sigma_MASK                0xFF
#define R2_DEVICE2_IC_1_Sigma_SHIFT               0

/* REVISION (IC 1_Sigma) */
#define R3_REV_IC_1_Sigma                         0x00   /* 00000000b	[7:0] */
#define R3_REV_IC_1_Sigma_MASK                    0xFF
#define R3_REV_IC_1_Sigma_SHIFT                   0

/* ADC_DAC_HP_PWR (IC 1_Sigma) */
#define R4_ADC0_EN_IC_1_Sigma                     0x1    /* 1b	[0] */
#define R4_ADC1_EN_IC_1_Sigma                     0x1    /* 1b	[1] */
#define R4_ADC2_EN_IC_1_Sigma                     0x1    /* 1b	[2] */
#define R4_ADC3_EN_IC_1_Sigma                     0x1    /* 1b	[3] */
#define R4_PB0_EN_IC_1_Sigma                      0x1    /* 1b	[4] */
#define R4_PB1_EN_IC_1_Sigma                      0x1    /* 1b	[5] */
#define R4_ADC0_EN_IC_1_Sigma_MASK                0x1
#define R4_ADC0_EN_IC_1_Sigma_SHIFT               0
#define R4_ADC1_EN_IC_1_Sigma_MASK                0x2
#define R4_ADC1_EN_IC_1_Sigma_SHIFT               1
#define R4_ADC2_EN_IC_1_Sigma_MASK                0x4
#define R4_ADC2_EN_IC_1_Sigma_SHIFT               2
#define R4_ADC3_EN_IC_1_Sigma_MASK                0x8
#define R4_ADC3_EN_IC_1_Sigma_SHIFT               3
#define R4_PB0_EN_IC_1_Sigma_MASK                 0x10
#define R4_PB0_EN_IC_1_Sigma_SHIFT                4
#define R4_PB1_EN_IC_1_Sigma_MASK                 0x20
#define R4_PB1_EN_IC_1_Sigma_SHIFT                5

/* PLL_MB_PGA_PWR (IC 1_Sigma) */
#define R5_PLL_EN_IC_1_Sigma                      0x0    /* 0b	[0] */
#define R5_XTAL_EN_IC_1_Sigma                     0x0    /* 0b	[1] */
#define R5_MBIAS0_EN_IC_1_Sigma                   0x0    /* 0b	[2] */
#define R5_MBIAS1_EN_IC_1_Sigma                   0x0    /* 0b	[3] */
#define R5_PGA0_EN_IC_1_Sigma                     0x0    /* 0b	[4] */
#define R5_PGA1_EN_IC_1_Sigma                     0x0    /* 0b	[5] */
#define R5_PGA2_EN_IC_1_Sigma                     0x0    /* 0b	[6] */
#define R5_PGA3_EN_IC_1_Sigma                     0x0    /* 0b	[7] */
#define R5_PLL_EN_IC_1_Sigma_MASK                 0x1
#define R5_PLL_EN_IC_1_Sigma_SHIFT                0
#define R5_XTAL_EN_IC_1_Sigma_MASK                0x2
#define R5_XTAL_EN_IC_1_Sigma_SHIFT               1
#define R5_MBIAS0_EN_IC_1_Sigma_MASK              0x4
#define R5_MBIAS0_EN_IC_1_Sigma_SHIFT             2
#define R5_MBIAS1_EN_IC_1_Sigma_MASK              0x8
#define R5_MBIAS1_EN_IC_1_Sigma_SHIFT             3
#define R5_PGA0_EN_IC_1_Sigma_MASK                0x10
#define R5_PGA0_EN_IC_1_Sigma_SHIFT               4
#define R5_PGA1_EN_IC_1_Sigma_MASK                0x20
#define R5_PGA1_EN_IC_1_Sigma_SHIFT               5
#define R5_PGA2_EN_IC_1_Sigma_MASK                0x40
#define R5_PGA2_EN_IC_1_Sigma_SHIFT               6
#define R5_PGA3_EN_IC_1_Sigma_MASK                0x80
#define R5_PGA3_EN_IC_1_Sigma_SHIFT               7

/* DMIC_PWR (IC 1_Sigma) */
#define R6_DMIC0_EN_IC_1_Sigma                    0x0    /* 0b	[0] */
#define R6_DMIC1_EN_IC_1_Sigma                    0x0    /* 0b	[1] */
#define R6_DMIC2_EN_IC_1_Sigma                    0x0    /* 0b	[2] */
#define R6_DMIC3_EN_IC_1_Sigma                    0x0    /* 0b	[3] */
#define R6_DMIC4_EN_IC_1_Sigma                    0x0    /* 0b	[4] */
#define R6_DMIC5_EN_IC_1_Sigma                    0x0    /* 0b	[5] */
#define R6_DMIC6_EN_IC_1_Sigma                    0x0    /* 0b	[6] */
#define R6_DMIC7_EN_IC_1_Sigma                    0x0    /* 0b	[7] */
#define R6_DMIC0_EN_IC_1_Sigma_MASK               0x1
#define R6_DMIC0_EN_IC_1_Sigma_SHIFT              0
#define R6_DMIC1_EN_IC_1_Sigma_MASK               0x2
#define R6_DMIC1_EN_IC_1_Sigma_SHIFT              1
#define R6_DMIC2_EN_IC_1_Sigma_MASK               0x4
#define R6_DMIC2_EN_IC_1_Sigma_SHIFT              2
#define R6_DMIC3_EN_IC_1_Sigma_MASK               0x8
#define R6_DMIC3_EN_IC_1_Sigma_SHIFT              3
#define R6_DMIC4_EN_IC_1_Sigma_MASK               0x10
#define R6_DMIC4_EN_IC_1_Sigma_SHIFT              4
#define R6_DMIC5_EN_IC_1_Sigma_MASK               0x20
#define R6_DMIC5_EN_IC_1_Sigma_SHIFT              5
#define R6_DMIC6_EN_IC_1_Sigma_MASK               0x40
#define R6_DMIC6_EN_IC_1_Sigma_SHIFT              6
#define R6_DMIC7_EN_IC_1_Sigma_MASK               0x80
#define R6_DMIC7_EN_IC_1_Sigma_SHIFT              7

/* SAI_CLK_PWR (IC 1_Sigma) */
#define R7_SPT0_IN_EN_IC_1_Sigma                  0x1    /* 1b	[0] */
#define R7_SPT0_OUT_EN_IC_1_Sigma                 0x1    /* 1b	[1] */
#define R7_SPT1_IN_EN_IC_1_Sigma                  0x0    /* 0b	[2] */
#define R7_SPT1_OUT_EN_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R7_DMIC_CLK0_EN_IC_1_Sigma                0x0    /* 0b	[4] */
#define R7_DMIC_CLK1_EN_IC_1_Sigma                0x0    /* 0b	[5] */
#define R7_PDM0_EN_IC_1_Sigma                     0x0    /* 0b	[6] */
#define R7_PDM1_EN_IC_1_Sigma                     0x0    /* 0b	[7] */
#define R7_SPT0_IN_EN_IC_1_Sigma_MASK             0x1
#define R7_SPT0_IN_EN_IC_1_Sigma_SHIFT            0
#define R7_SPT0_OUT_EN_IC_1_Sigma_MASK            0x2
#define R7_SPT0_OUT_EN_IC_1_Sigma_SHIFT           1
#define R7_SPT1_IN_EN_IC_1_Sigma_MASK             0x4
#define R7_SPT1_IN_EN_IC_1_Sigma_SHIFT            2
#define R7_SPT1_OUT_EN_IC_1_Sigma_MASK            0x8
#define R7_SPT1_OUT_EN_IC_1_Sigma_SHIFT           3
#define R7_DMIC_CLK0_EN_IC_1_Sigma_MASK           0x10
#define R7_DMIC_CLK0_EN_IC_1_Sigma_SHIFT          4
#define R7_DMIC_CLK1_EN_IC_1_Sigma_MASK           0x20
#define R7_DMIC_CLK1_EN_IC_1_Sigma_SHIFT          5
#define R7_PDM0_EN_IC_1_Sigma_MASK                0x40
#define R7_PDM0_EN_IC_1_Sigma_SHIFT               6
#define R7_PDM1_EN_IC_1_Sigma_MASK                0x80
#define R7_PDM1_EN_IC_1_Sigma_SHIFT               7

/* DSP_PWR (IC 1_Sigma) */
#define R8_FDSP_EN_IC_1_Sigma                     0x0    /* 0b	[0] */
#define R8_SDSP_EN_IC_1_Sigma                     0x0    /* 0b	[4] */
#define R8_FDSP_EN_IC_1_Sigma_MASK                0x1
#define R8_FDSP_EN_IC_1_Sigma_SHIFT               0
#define R8_SDSP_EN_IC_1_Sigma_MASK                0x10
#define R8_SDSP_EN_IC_1_Sigma_SHIFT               4

/* ASRC_PWR (IC 1_Sigma) */
#define R9_ASRCI0_EN_IC_1_Sigma                   0x0    /* 0b	[0] */
#define R9_ASRCI1_EN_IC_1_Sigma                   0x0    /* 0b	[1] */
#define R9_ASRCI2_EN_IC_1_Sigma                   0x0    /* 0b	[2] */
#define R9_ASRCI3_EN_IC_1_Sigma                   0x0    /* 0b	[3] */
#define R9_ASRCO0_EN_IC_1_Sigma                   0x0    /* 0b	[4] */
#define R9_ASRCO1_EN_IC_1_Sigma                   0x0    /* 0b	[5] */
#define R9_ASRCO2_EN_IC_1_Sigma                   0x0    /* 0b	[6] */
#define R9_ASRCO3_EN_IC_1_Sigma                   0x0    /* 0b	[7] */
#define R9_ASRCI0_EN_IC_1_Sigma_MASK              0x1
#define R9_ASRCI0_EN_IC_1_Sigma_SHIFT             0
#define R9_ASRCI1_EN_IC_1_Sigma_MASK              0x2
#define R9_ASRCI1_EN_IC_1_Sigma_SHIFT             1
#define R9_ASRCI2_EN_IC_1_Sigma_MASK              0x4
#define R9_ASRCI2_EN_IC_1_Sigma_SHIFT             2
#define R9_ASRCI3_EN_IC_1_Sigma_MASK              0x8
#define R9_ASRCI3_EN_IC_1_Sigma_SHIFT             3
#define R9_ASRCO0_EN_IC_1_Sigma_MASK              0x10
#define R9_ASRCO0_EN_IC_1_Sigma_SHIFT             4
#define R9_ASRCO1_EN_IC_1_Sigma_MASK              0x20
#define R9_ASRCO1_EN_IC_1_Sigma_SHIFT             5
#define R9_ASRCO2_EN_IC_1_Sigma_MASK              0x40
#define R9_ASRCO2_EN_IC_1_Sigma_SHIFT             6
#define R9_ASRCO3_EN_IC_1_Sigma_MASK              0x80
#define R9_ASRCO3_EN_IC_1_Sigma_SHIFT             7

/* FINT_PWR (IC 1_Sigma) */
#define R10_FINT0_EN_IC_1_Sigma                   0x0    /* 0b	[0] */
#define R10_FINT1_EN_IC_1_Sigma                   0x0    /* 0b	[1] */
#define R10_FINT2_EN_IC_1_Sigma                   0x0    /* 0b	[2] */
#define R10_FINT3_EN_IC_1_Sigma                   0x0    /* 0b	[3] */
#define R10_FINT4_EN_IC_1_Sigma                   0x0    /* 0b	[4] */
#define R10_FINT5_EN_IC_1_Sigma                   0x0    /* 0b	[5] */
#define R10_FINT6_EN_IC_1_Sigma                   0x0    /* 0b	[6] */
#define R10_FINT7_EN_IC_1_Sigma                   0x0    /* 0b	[7] */
#define R10_FINT0_EN_IC_1_Sigma_MASK              0x1
#define R10_FINT0_EN_IC_1_Sigma_SHIFT             0
#define R10_FINT1_EN_IC_1_Sigma_MASK              0x2
#define R10_FINT1_EN_IC_1_Sigma_SHIFT             1
#define R10_FINT2_EN_IC_1_Sigma_MASK              0x4
#define R10_FINT2_EN_IC_1_Sigma_SHIFT             2
#define R10_FINT3_EN_IC_1_Sigma_MASK              0x8
#define R10_FINT3_EN_IC_1_Sigma_SHIFT             3
#define R10_FINT4_EN_IC_1_Sigma_MASK              0x10
#define R10_FINT4_EN_IC_1_Sigma_SHIFT             4
#define R10_FINT5_EN_IC_1_Sigma_MASK              0x20
#define R10_FINT5_EN_IC_1_Sigma_SHIFT             5
#define R10_FINT6_EN_IC_1_Sigma_MASK              0x40
#define R10_FINT6_EN_IC_1_Sigma_SHIFT             6
#define R10_FINT7_EN_IC_1_Sigma_MASK              0x80
#define R10_FINT7_EN_IC_1_Sigma_SHIFT             7

/* FDEC_PWR (IC 1_Sigma) */
#define R11_FDEC0_EN_IC_1_Sigma                   0x0    /* 0b	[0] */
#define R11_FDEC1_EN_IC_1_Sigma                   0x0    /* 0b	[1] */
#define R11_FDEC2_EN_IC_1_Sigma                   0x0    /* 0b	[2] */
#define R11_FDEC3_EN_IC_1_Sigma                   0x0    /* 0b	[3] */
#define R11_FDEC4_EN_IC_1_Sigma                   0x0    /* 0b	[4] */
#define R11_FDEC5_EN_IC_1_Sigma                   0x0    /* 0b	[5] */
#define R11_FDEC6_EN_IC_1_Sigma                   0x0    /* 0b	[6] */
#define R11_FDEC7_EN_IC_1_Sigma                   0x0    /* 0b	[7] */
#define R11_FDEC0_EN_IC_1_Sigma_MASK              0x1
#define R11_FDEC0_EN_IC_1_Sigma_SHIFT             0
#define R11_FDEC1_EN_IC_1_Sigma_MASK              0x2
#define R11_FDEC1_EN_IC_1_Sigma_SHIFT             1
#define R11_FDEC2_EN_IC_1_Sigma_MASK              0x4
#define R11_FDEC2_EN_IC_1_Sigma_SHIFT             2
#define R11_FDEC3_EN_IC_1_Sigma_MASK              0x8
#define R11_FDEC3_EN_IC_1_Sigma_SHIFT             3
#define R11_FDEC4_EN_IC_1_Sigma_MASK              0x10
#define R11_FDEC4_EN_IC_1_Sigma_SHIFT             4
#define R11_FDEC5_EN_IC_1_Sigma_MASK              0x20
#define R11_FDEC5_EN_IC_1_Sigma_SHIFT             5
#define R11_FDEC6_EN_IC_1_Sigma_MASK              0x40
#define R11_FDEC6_EN_IC_1_Sigma_SHIFT             6
#define R11_FDEC7_EN_IC_1_Sigma_MASK              0x80
#define R11_FDEC7_EN_IC_1_Sigma_SHIFT             7

/* KEEPS (IC 1_Sigma) */
#define R12_KEEP_FDSP_IC_1_Sigma                  0x1    /* 1b	[0] */
#define R12_KEEP_SDSP_IC_1_Sigma                  0x0    /* 0b	[1] */
#define R12_CM_KEEP_ALIVE_IC_1_Sigma              0x1    /* 1b	[4] */
#define R12_KEEP_FDSP_IC_1_Sigma_MASK             0x1
#define R12_KEEP_FDSP_IC_1_Sigma_SHIFT            0
#define R12_KEEP_SDSP_IC_1_Sigma_MASK             0x2
#define R12_KEEP_SDSP_IC_1_Sigma_SHIFT            1
#define R12_CM_KEEP_ALIVE_IC_1_Sigma_MASK         0x10
#define R12_CM_KEEP_ALIVE_IC_1_Sigma_SHIFT        4

/* CHIP_PWR (IC 1_Sigma) */
#define R13_POWER_EN_IC_1_Sigma                   0x1    /* 1b	[0] */
#define R13_MASTER_BLOCK_EN_IC_1_Sigma            0x1    /* 1b	[1] */
#define R13_CM_STARTUP_OVER_IC_1_Sigma            0x1    /* 1b	[2] */
#define R13_DLDO_CTRL_IC_1_Sigma                  0x1    /* 01b	[5:4] */
#define R13_POWER_EN_IC_1_Sigma_MASK              0x1
#define R13_POWER_EN_IC_1_Sigma_SHIFT             0
#define R13_MASTER_BLOCK_EN_IC_1_Sigma_MASK       0x2
#define R13_MASTER_BLOCK_EN_IC_1_Sigma_SHIFT      1
#define R13_CM_STARTUP_OVER_IC_1_Sigma_MASK       0x4
#define R13_CM_STARTUP_OVER_IC_1_Sigma_SHIFT      2
#define R13_DLDO_CTRL_IC_1_Sigma_MASK             0x30
#define R13_DLDO_CTRL_IC_1_Sigma_SHIFT            4

/* CLK_CTRL1 (IC 1_Sigma) */
#define R14_PLL_SOURCE_IC_1_Sigma                 0x0    /* 000b	[2:0] */
#define R14_XTAL_MODE_IC_1_Sigma                  0x0    /* 0b	[3] */
#define R14_PLL_TYPE_IC_1_Sigma                   0x0    /* 0b	[4] */
#define R14_PLL_BYPASS_IC_1_Sigma                 0x1    /* 1b	[5] */
#define R14_SYNC_SOURCE_IC_1_Sigma                0x0    /* 00b	[7:6] */
#define R14_PLL_SOURCE_IC_1_Sigma_MASK            0x7
#define R14_PLL_SOURCE_IC_1_Sigma_SHIFT           0
#define R14_XTAL_MODE_IC_1_Sigma_MASK             0x8
#define R14_XTAL_MODE_IC_1_Sigma_SHIFT            3
#define R14_PLL_TYPE_IC_1_Sigma_MASK              0x10
#define R14_PLL_TYPE_IC_1_Sigma_SHIFT             4
#define R14_PLL_BYPASS_IC_1_Sigma_MASK            0x20
#define R14_PLL_BYPASS_IC_1_Sigma_SHIFT           5
#define R14_SYNC_SOURCE_IC_1_Sigma_MASK           0xC0
#define R14_SYNC_SOURCE_IC_1_Sigma_SHIFT          6

/* CLK_CTRL2 (IC 1_Sigma) */
#define R15_PLL_INPUT_PRESCALER_IC_1_Sigma        0x0    /* 000b	[2:0] */
#define R15_PLL_INPUT_PRESCALER_IC_1_Sigma_MASK   0x7
#define R15_PLL_INPUT_PRESCALER_IC_1_Sigma_SHIFT  0

/* CLK_CTRL3 (IC 1_Sigma) */
#define R16_PLL_INTEGER_DIVIDER_IC_1_Sigma        0x002  /* 0000000000010b	[12:0] */
#define R16_PLL_INTEGER_DIVIDER_IC_1_Sigma_MASK   0x1FFF
#define R16_PLL_INTEGER_DIVIDER_IC_1_Sigma_SHIFT  0

/* CLK_CTRL5 (IC 1_Sigma) */
#define R17_PLL_NUMERATOR_IC_1_Sigma              0x0000 /* 0000000000000000b	[15:0] */
#define R17_PLL_NUMERATOR_IC_1_Sigma_MASK         0xFFFF
#define R17_PLL_NUMERATOR_IC_1_Sigma_SHIFT        0

/* CLK_CTRL7 (IC 1_Sigma) */
#define R18_PLL_DENOMINATOR_IC_1_Sigma            0x0000 /* 0000000000000000b	[15:0] */
#define R18_PLL_DENOMINATOR_IC_1_Sigma_MASK       0xFFFF
#define R18_PLL_DENOMINATOR_IC_1_Sigma_SHIFT      0

/* CLK_CTRL9 (IC 1_Sigma) */
#define R19_PLL_UPDATE_IC_1_Sigma                 0x0    /* 0b	[0] */
#define R19_PLL_UPDATE_IC_1_Sigma_MASK            0x1
#define R19_PLL_UPDATE_IC_1_Sigma_SHIFT           0

/* ADC_CTRL1 (IC 1_Sigma) */
#define R20_ADC01_FS_IC_1_Sigma                   0x0    /* 000b	[2:0] */
#define R20_ADC01_DEC_ORDER_IC_1_Sigma            0x0    /* 0b	[3] */
#define R20_ADC23_FS_IC_1_Sigma                   0x6    /* 110b	[6:4] */
#define R20_ADC23_DEC_ORDER_IC_1_Sigma            0x0    /* 0b	[7] */
#define R20_ADC01_FS_IC_1_Sigma_MASK              0x7
#define R20_ADC01_FS_IC_1_Sigma_SHIFT             0
#define R20_ADC01_DEC_ORDER_IC_1_Sigma_MASK       0x8
#define R20_ADC01_DEC_ORDER_IC_1_Sigma_SHIFT      3
#define R20_ADC23_FS_IC_1_Sigma_MASK              0x70
#define R20_ADC23_FS_IC_1_Sigma_SHIFT             4
#define R20_ADC23_DEC_ORDER_IC_1_Sigma_MASK       0x80
#define R20_ADC23_DEC_ORDER_IC_1_Sigma_SHIFT      7

/* ADC_CTRL2 (IC 1_Sigma) */
#define R21_ADC01_IBIAS_IC_1_Sigma                0x0    /* 000b	[2:0] */
#define R21_ADC23_IBIAS_IC_1_Sigma                0x0    /* 000b	[6:4] */
#define R21_ADC01_IBIAS_IC_1_Sigma_MASK           0x7
#define R21_ADC01_IBIAS_IC_1_Sigma_SHIFT          0
#define R21_ADC23_IBIAS_IC_1_Sigma_MASK           0x70
#define R21_ADC23_IBIAS_IC_1_Sigma_SHIFT          4

/* ADC_CTRL3 (IC 1_Sigma) */
#define R22_ADC0_HPF_EN_IC_1_Sigma                0x0    /* 0b	[0] */
#define R22_ADC1_HPF_EN_IC_1_Sigma                0x0    /* 0b	[1] */
#define R22_ADC2_HPF_EN_IC_1_Sigma                0x0    /* 0b	[2] */
#define R22_ADC3_HPF_EN_IC_1_Sigma                0x0    /* 0b	[3] */
#define R22_ADC0_HPF_EN_IC_1_Sigma_MASK           0x1
#define R22_ADC0_HPF_EN_IC_1_Sigma_SHIFT          0
#define R22_ADC1_HPF_EN_IC_1_Sigma_MASK           0x2
#define R22_ADC1_HPF_EN_IC_1_Sigma_SHIFT          1
#define R22_ADC2_HPF_EN_IC_1_Sigma_MASK           0x4
#define R22_ADC2_HPF_EN_IC_1_Sigma_SHIFT          2
#define R22_ADC3_HPF_EN_IC_1_Sigma_MASK           0x8
#define R22_ADC3_HPF_EN_IC_1_Sigma_SHIFT          3

/* ADC_CTRL4 (IC 1_Sigma) */
#define R23_ADC01_FCOMP_IC_1_Sigma                0x0    /* 0b	[0] */
#define R23_ADC23_FCOMP_IC_1_Sigma                0x0    /* 0b	[1] */
#define R23_ADC_HARD_VOL_IC_1_Sigma               0x0    /* 0b	[4] */
#define R23_ADC_VOL_LINK_IC_1_Sigma               0x0    /* 0b	[5] */
#define R23_ADC_VOL_ZC_IC_1_Sigma                 0x1    /* 1b	[6] */
#define R23_ADC01_FCOMP_IC_1_Sigma_MASK           0x1
#define R23_ADC01_FCOMP_IC_1_Sigma_SHIFT          0
#define R23_ADC23_FCOMP_IC_1_Sigma_MASK           0x2
#define R23_ADC23_FCOMP_IC_1_Sigma_SHIFT          1
#define R23_ADC_HARD_VOL_IC_1_Sigma_MASK          0x10
#define R23_ADC_HARD_VOL_IC_1_Sigma_SHIFT         4
#define R23_ADC_VOL_LINK_IC_1_Sigma_MASK          0x20
#define R23_ADC_VOL_LINK_IC_1_Sigma_SHIFT         5
#define R23_ADC_VOL_ZC_IC_1_Sigma_MASK            0x40
#define R23_ADC_VOL_ZC_IC_1_Sigma_SHIFT           6

/* ADC_CTRL5 (IC 1_Sigma) */
#define R24_ADC_AIN_CHRG_TIME_IC_1_Sigma          0x0    /* 0000b	[3:0] */
#define R24_DIFF_INPUT_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R24_ADC_CHOP_EN_IC_1_Sigma                0x1    /* 1b	[5] */
#define R24_ADC_AIN_CHRG_TIME_IC_1_Sigma_MASK     0xF
#define R24_ADC_AIN_CHRG_TIME_IC_1_Sigma_SHIFT    0
#define R24_DIFF_INPUT_IC_1_Sigma_MASK            0x10
#define R24_DIFF_INPUT_IC_1_Sigma_SHIFT           4
#define R24_ADC_CHOP_EN_IC_1_Sigma_MASK           0x20
#define R24_ADC_CHOP_EN_IC_1_Sigma_SHIFT          5

/* ADC_MUTES (IC 1_Sigma) */
#define R25_ADC0_MUTE_IC_1_Sigma                  0x0    /* 0b	[0] */
#define R25_ADC1_MUTE_IC_1_Sigma                  0x0    /* 0b	[1] */
#define R25_ADC2_MUTE_IC_1_Sigma                  0x0    /* 0b	[2] */
#define R25_ADC3_MUTE_IC_1_Sigma                  0x0    /* 0b	[3] */
#define R25_ADC0_MUTE_IC_1_Sigma_MASK             0x1
#define R25_ADC0_MUTE_IC_1_Sigma_SHIFT            0
#define R25_ADC1_MUTE_IC_1_Sigma_MASK             0x2
#define R25_ADC1_MUTE_IC_1_Sigma_SHIFT            1
#define R25_ADC2_MUTE_IC_1_Sigma_MASK             0x4
#define R25_ADC2_MUTE_IC_1_Sigma_SHIFT            2
#define R25_ADC3_MUTE_IC_1_Sigma_MASK             0x8
#define R25_ADC3_MUTE_IC_1_Sigma_SHIFT            3

/* ADC0_VOL (IC 1_Sigma) */
#define R26_ADC0_VOL_IC_1_Sigma                   0x40   /* 01000000b	[7:0] */
#define R26_ADC0_VOL_IC_1_Sigma_MASK              0xFF
#define R26_ADC0_VOL_IC_1_Sigma_SHIFT             0

/* ADC1_VOL (IC 1_Sigma) */
#define R27_ADC1_VOL_IC_1_Sigma                   0x40   /* 01000000b	[7:0] */
#define R27_ADC1_VOL_IC_1_Sigma_MASK              0xFF
#define R27_ADC1_VOL_IC_1_Sigma_SHIFT             0

/* ADC2_VOL (IC 1_Sigma) */
#define R28_ADC2_VOL_IC_1_Sigma                   0x40   /* 01000000b	[7:0] */
#define R28_ADC2_VOL_IC_1_Sigma_MASK              0xFF
#define R28_ADC2_VOL_IC_1_Sigma_SHIFT             0

/* ADC3_VOL (IC 1_Sigma) */
#define R29_ADC3_VOL_IC_1_Sigma                   0x40   /* 01000000b	[7:0] */
#define R29_ADC3_VOL_IC_1_Sigma_MASK              0xFF
#define R29_ADC3_VOL_IC_1_Sigma_SHIFT             0

/* PGA0_CTRL1 (IC 1_Sigma) */
#define R30_PGA0_GAIN_COARSE_IC_1_Sigma           0x0    /* 000000b	[5:0] */
#define R30_PGA0_BOOST_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R30_PGA0_SLEW_DIS_IC_1_Sigma              0x0    /* 0b	[7] */
#define R30_PGA0_GAIN_COARSE_IC_1_Sigma_MASK      0x3F
#define R30_PGA0_GAIN_COARSE_IC_1_Sigma_SHIFT     0
#define R30_PGA0_BOOST_IC_1_Sigma_MASK            0x40
#define R30_PGA0_BOOST_IC_1_Sigma_SHIFT           6
#define R30_PGA0_SLEW_DIS_IC_1_Sigma_MASK         0x80
#define R30_PGA0_SLEW_DIS_IC_1_Sigma_SHIFT        7

/* PGA0_CTRL2 (IC 1_Sigma) */
#define R31_PGA0_GAIN_FINE_IC_1_Sigma             0x0    /* 00000b	[4:0] */
#define R31_PGA0_GAIN_FINE_IC_1_Sigma_MASK        0x1F
#define R31_PGA0_GAIN_FINE_IC_1_Sigma_SHIFT       0

/* PGA1_CTRL1 (IC 1_Sigma) */
#define R32_PGA1_GAIN_COARSE_IC_1_Sigma           0x0    /* 000000b	[5:0] */
#define R32_PGA1_BOOST_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R32_PGA1_SLEW_DIS_IC_1_Sigma              0x0    /* 0b	[7] */
#define R32_PGA1_GAIN_COARSE_IC_1_Sigma_MASK      0x3F
#define R32_PGA1_GAIN_COARSE_IC_1_Sigma_SHIFT     0
#define R32_PGA1_BOOST_IC_1_Sigma_MASK            0x40
#define R32_PGA1_BOOST_IC_1_Sigma_SHIFT           6
#define R32_PGA1_SLEW_DIS_IC_1_Sigma_MASK         0x80
#define R32_PGA1_SLEW_DIS_IC_1_Sigma_SHIFT        7

/* PGA1_CTRL2 (IC 1_Sigma) */
#define R33_PGA1_GAIN_FINE_IC_1_Sigma             0x0    /* 00000b	[4:0] */
#define R33_PGA1_GAIN_FINE_IC_1_Sigma_MASK        0x1F
#define R33_PGA1_GAIN_FINE_IC_1_Sigma_SHIFT       0

/* PGA2_CTRL1 (IC 1_Sigma) */
#define R34_PGA2_GAIN_COARSE_IC_1_Sigma           0x0    /* 000000b	[5:0] */
#define R34_PGA2_BOOST_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R34_PGA2_SLEW_DIS_IC_1_Sigma              0x0    /* 0b	[7] */
#define R34_PGA2_GAIN_COARSE_IC_1_Sigma_MASK      0x3F
#define R34_PGA2_GAIN_COARSE_IC_1_Sigma_SHIFT     0
#define R34_PGA2_BOOST_IC_1_Sigma_MASK            0x40
#define R34_PGA2_BOOST_IC_1_Sigma_SHIFT           6
#define R34_PGA2_SLEW_DIS_IC_1_Sigma_MASK         0x80
#define R34_PGA2_SLEW_DIS_IC_1_Sigma_SHIFT        7

/* PGA2_CTRL2 (IC 1_Sigma) */
#define R35_PGA2_GAIN_FINE_IC_1_Sigma             0x0    /* 00000b	[4:0] */
#define R35_PGA2_GAIN_FINE_IC_1_Sigma_MASK        0x1F
#define R35_PGA2_GAIN_FINE_IC_1_Sigma_SHIFT       0

/* PGA3_CTRL1 (IC 1_Sigma) */
#define R36_PGA3_GAIN_COARSE_IC_1_Sigma           0x0    /* 000000b	[5:0] */
#define R36_PGA3_BOOST_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R36_PGA3_SLEW_DIS_IC_1_Sigma              0x0    /* 0b	[7] */
#define R36_PGA3_GAIN_COARSE_IC_1_Sigma_MASK      0x3F
#define R36_PGA3_GAIN_COARSE_IC_1_Sigma_SHIFT     0
#define R36_PGA3_BOOST_IC_1_Sigma_MASK            0x40
#define R36_PGA3_BOOST_IC_1_Sigma_SHIFT           6
#define R36_PGA3_SLEW_DIS_IC_1_Sigma_MASK         0x80
#define R36_PGA3_SLEW_DIS_IC_1_Sigma_SHIFT        7

/* PGA3_CTRL2 (IC 1_Sigma) */
#define R37_PGA3_GAIN_FINE_IC_1_Sigma             0x0    /* 00000b	[4:0] */
#define R37_PGA3_GAIN_FINE_IC_1_Sigma_MASK        0x1F
#define R37_PGA3_GAIN_FINE_IC_1_Sigma_SHIFT       0

/* PGA_CTRL (IC 1_Sigma) */
#define R38_PGA_SLEW_RATE_IC_1_Sigma              0x0    /* 00b	[1:0] */
#define R38_PGA_GAIN_LINK_IC_1_Sigma              0x0    /* 0b	[4] */
#define R38_PGA_SLEW_RATE_IC_1_Sigma_MASK         0x3
#define R38_PGA_SLEW_RATE_IC_1_Sigma_SHIFT        0
#define R38_PGA_GAIN_LINK_IC_1_Sigma_MASK         0x10
#define R38_PGA_GAIN_LINK_IC_1_Sigma_SHIFT        4

/* MBIAS_CTRL (IC 1_Sigma) */
#define R39_MBIAS0_LEVEL_IC_1_Sigma               0x0    /* 0b	[0] */
#define R39_MBIAS1_LEVEL_IC_1_Sigma               0x0    /* 0b	[1] */
#define R39_MBIAS_IBIAS_IC_1_Sigma                0x0    /* 00b	[5:4] */
#define R39_MBIAS0_LEVEL_IC_1_Sigma_MASK          0x1
#define R39_MBIAS0_LEVEL_IC_1_Sigma_SHIFT         0
#define R39_MBIAS1_LEVEL_IC_1_Sigma_MASK          0x2
#define R39_MBIAS1_LEVEL_IC_1_Sigma_SHIFT         1
#define R39_MBIAS_IBIAS_IC_1_Sigma_MASK           0x30
#define R39_MBIAS_IBIAS_IC_1_Sigma_SHIFT          4

/* DMIC_CTRL1 (IC 1_Sigma) */
#define R40_DMIC_CLK0_RATE_IC_1_Sigma             0x3    /* 011b	[2:0] */
#define R40_DMIC_CLK1_RATE_IC_1_Sigma             0x3    /* 011b	[6:4] */
#define R40_DMIC_CLK0_RATE_IC_1_Sigma_MASK        0x7
#define R40_DMIC_CLK0_RATE_IC_1_Sigma_SHIFT       0
#define R40_DMIC_CLK1_RATE_IC_1_Sigma_MASK        0x70
#define R40_DMIC_CLK1_RATE_IC_1_Sigma_SHIFT       4

/* DMIC_CTRL2 (IC 1_Sigma) */
#define R41_DMIC01_FS_IC_1_Sigma                  0x1    /* 001b	[2:0] */
#define R41_DMIC01_HPF_EN_IC_1_Sigma              0x0    /* 0b	[3] */
#define R41_DMIC01_DEC_ORDER_IC_1_Sigma           0x0    /* 0b	[4] */
#define R41_DMIC01_FCOMP_IC_1_Sigma               0x0    /* 0b	[5] */
#define R41_DMIC01_EDGE_IC_1_Sigma                0x0    /* 0b	[6] */
#define R41_DMIC01_MAP_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R41_DMIC01_FS_IC_1_Sigma_MASK             0x7
#define R41_DMIC01_FS_IC_1_Sigma_SHIFT            0
#define R41_DMIC01_HPF_EN_IC_1_Sigma_MASK         0x8
#define R41_DMIC01_HPF_EN_IC_1_Sigma_SHIFT        3
#define R41_DMIC01_DEC_ORDER_IC_1_Sigma_MASK      0x10
#define R41_DMIC01_DEC_ORDER_IC_1_Sigma_SHIFT     4
#define R41_DMIC01_FCOMP_IC_1_Sigma_MASK          0x20
#define R41_DMIC01_FCOMP_IC_1_Sigma_SHIFT         5
#define R41_DMIC01_EDGE_IC_1_Sigma_MASK           0x40
#define R41_DMIC01_EDGE_IC_1_Sigma_SHIFT          6
#define R41_DMIC01_MAP_IC_1_Sigma_MASK            0x80
#define R41_DMIC01_MAP_IC_1_Sigma_SHIFT           7

/* DMIC_CTRL3 (IC 1_Sigma) */
#define R42_DMIC23_FS_IC_1_Sigma                  0x1    /* 001b	[2:0] */
#define R42_DMIC23_HPF_EN_IC_1_Sigma              0x0    /* 0b	[3] */
#define R42_DMIC23_DEC_ORDER_IC_1_Sigma           0x0    /* 0b	[4] */
#define R42_DMIC23_FCOMP_IC_1_Sigma               0x0    /* 0b	[5] */
#define R42_DMIC23_EDGE_IC_1_Sigma                0x0    /* 0b	[6] */
#define R42_DMIC23_MAP_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R42_DMIC23_FS_IC_1_Sigma_MASK             0x7
#define R42_DMIC23_FS_IC_1_Sigma_SHIFT            0
#define R42_DMIC23_HPF_EN_IC_1_Sigma_MASK         0x8
#define R42_DMIC23_HPF_EN_IC_1_Sigma_SHIFT        3
#define R42_DMIC23_DEC_ORDER_IC_1_Sigma_MASK      0x10
#define R42_DMIC23_DEC_ORDER_IC_1_Sigma_SHIFT     4
#define R42_DMIC23_FCOMP_IC_1_Sigma_MASK          0x20
#define R42_DMIC23_FCOMP_IC_1_Sigma_SHIFT         5
#define R42_DMIC23_EDGE_IC_1_Sigma_MASK           0x40
#define R42_DMIC23_EDGE_IC_1_Sigma_SHIFT          6
#define R42_DMIC23_MAP_IC_1_Sigma_MASK            0x80
#define R42_DMIC23_MAP_IC_1_Sigma_SHIFT           7

/* DMIC_CTRL4 (IC 1_Sigma) */
#define R43_DMIC45_FS_IC_1_Sigma                  0x1    /* 001b	[2:0] */
#define R43_DMIC45_HPF_EN_IC_1_Sigma              0x0    /* 0b	[3] */
#define R43_DMIC45_DEC_ORDER_IC_1_Sigma           0x0    /* 0b	[4] */
#define R43_DMIC45_FCOMP_IC_1_Sigma               0x0    /* 0b	[5] */
#define R43_DMIC45_EDGE_IC_1_Sigma                0x0    /* 0b	[6] */
#define R43_DMIC45_MAP_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R43_DMIC45_FS_IC_1_Sigma_MASK             0x7
#define R43_DMIC45_FS_IC_1_Sigma_SHIFT            0
#define R43_DMIC45_HPF_EN_IC_1_Sigma_MASK         0x8
#define R43_DMIC45_HPF_EN_IC_1_Sigma_SHIFT        3
#define R43_DMIC45_DEC_ORDER_IC_1_Sigma_MASK      0x10
#define R43_DMIC45_DEC_ORDER_IC_1_Sigma_SHIFT     4
#define R43_DMIC45_FCOMP_IC_1_Sigma_MASK          0x20
#define R43_DMIC45_FCOMP_IC_1_Sigma_SHIFT         5
#define R43_DMIC45_EDGE_IC_1_Sigma_MASK           0x40
#define R43_DMIC45_EDGE_IC_1_Sigma_SHIFT          6
#define R43_DMIC45_MAP_IC_1_Sigma_MASK            0x80
#define R43_DMIC45_MAP_IC_1_Sigma_SHIFT           7

/* DMIC_CTRL5 (IC 1_Sigma) */
#define R44_DMIC67_FS_IC_1_Sigma                  0x1    /* 001b	[2:0] */
#define R44_DMIC67_HPF_EN_IC_1_Sigma              0x0    /* 0b	[3] */
#define R44_DMIC67_DEC_ORDER_IC_1_Sigma           0x0    /* 0b	[4] */
#define R44_DMIC67_FCOMP_IC_1_Sigma               0x0    /* 0b	[5] */
#define R44_DMIC67_EDGE_IC_1_Sigma                0x0    /* 0b	[6] */
#define R44_DMIC67_MAP_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R44_DMIC67_FS_IC_1_Sigma_MASK             0x7
#define R44_DMIC67_FS_IC_1_Sigma_SHIFT            0
#define R44_DMIC67_HPF_EN_IC_1_Sigma_MASK         0x8
#define R44_DMIC67_HPF_EN_IC_1_Sigma_SHIFT        3
#define R44_DMIC67_DEC_ORDER_IC_1_Sigma_MASK      0x10
#define R44_DMIC67_DEC_ORDER_IC_1_Sigma_SHIFT     4
#define R44_DMIC67_FCOMP_IC_1_Sigma_MASK          0x20
#define R44_DMIC67_FCOMP_IC_1_Sigma_SHIFT         5
#define R44_DMIC67_EDGE_IC_1_Sigma_MASK           0x40
#define R44_DMIC67_EDGE_IC_1_Sigma_SHIFT          6
#define R44_DMIC67_MAP_IC_1_Sigma_MASK            0x80
#define R44_DMIC67_MAP_IC_1_Sigma_SHIFT           7

/* DMIC_CTRL6 (IC 1_Sigma) */
#define R45_DMIC_HARD_VOL_IC_1_Sigma              0x0    /* 0b	[0] */
#define R45_DMIC_VOL_LINK_IC_1_Sigma              0x0    /* 0b	[1] */
#define R45_DMIC_VOL_ZC_IC_1_Sigma                0x1    /* 1b	[2] */
#define R45_DMIC_HARD_VOL_IC_1_Sigma_MASK         0x1
#define R45_DMIC_HARD_VOL_IC_1_Sigma_SHIFT        0
#define R45_DMIC_VOL_LINK_IC_1_Sigma_MASK         0x2
#define R45_DMIC_VOL_LINK_IC_1_Sigma_SHIFT        1
#define R45_DMIC_VOL_ZC_IC_1_Sigma_MASK           0x4
#define R45_DMIC_VOL_ZC_IC_1_Sigma_SHIFT          2

/* DMIC_MUTES (IC 1_Sigma) */
#define R46_DMIC0_MUTE_IC_1_Sigma                 0x0    /* 0b	[0] */
#define R46_DMIC1_MUTE_IC_1_Sigma                 0x0    /* 0b	[1] */
#define R46_DMIC2_MUTE_IC_1_Sigma                 0x0    /* 0b	[2] */
#define R46_DMIC3_MUTE_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R46_DMIC4_MUTE_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R46_DMIC5_MUTE_IC_1_Sigma                 0x0    /* 0b	[5] */
#define R46_DMIC6_MUTE_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R46_DMIC7_MUTE_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R46_DMIC0_MUTE_IC_1_Sigma_MASK            0x1
#define R46_DMIC0_MUTE_IC_1_Sigma_SHIFT           0
#define R46_DMIC1_MUTE_IC_1_Sigma_MASK            0x2
#define R46_DMIC1_MUTE_IC_1_Sigma_SHIFT           1
#define R46_DMIC2_MUTE_IC_1_Sigma_MASK            0x4
#define R46_DMIC2_MUTE_IC_1_Sigma_SHIFT           2
#define R46_DMIC3_MUTE_IC_1_Sigma_MASK            0x8
#define R46_DMIC3_MUTE_IC_1_Sigma_SHIFT           3
#define R46_DMIC4_MUTE_IC_1_Sigma_MASK            0x10
#define R46_DMIC4_MUTE_IC_1_Sigma_SHIFT           4
#define R46_DMIC5_MUTE_IC_1_Sigma_MASK            0x20
#define R46_DMIC5_MUTE_IC_1_Sigma_SHIFT           5
#define R46_DMIC6_MUTE_IC_1_Sigma_MASK            0x40
#define R46_DMIC6_MUTE_IC_1_Sigma_SHIFT           6
#define R46_DMIC7_MUTE_IC_1_Sigma_MASK            0x80
#define R46_DMIC7_MUTE_IC_1_Sigma_SHIFT           7

/* DMIC_VOL0 (IC 1_Sigma) */
#define R47_DMIC0_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R47_DMIC0_VOL_IC_1_Sigma_MASK             0xFF
#define R47_DMIC0_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL1 (IC 1_Sigma) */
#define R48_DMIC1_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R48_DMIC1_VOL_IC_1_Sigma_MASK             0xFF
#define R48_DMIC1_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL2 (IC 1_Sigma) */
#define R49_DMIC2_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R49_DMIC2_VOL_IC_1_Sigma_MASK             0xFF
#define R49_DMIC2_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL3 (IC 1_Sigma) */
#define R50_DMIC3_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R50_DMIC3_VOL_IC_1_Sigma_MASK             0xFF
#define R50_DMIC3_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL4 (IC 1_Sigma) */
#define R51_DMIC4_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R51_DMIC4_VOL_IC_1_Sigma_MASK             0xFF
#define R51_DMIC4_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL5 (IC 1_Sigma) */
#define R52_DMIC5_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R52_DMIC5_VOL_IC_1_Sigma_MASK             0xFF
#define R52_DMIC5_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL6 (IC 1_Sigma) */
#define R53_DMIC6_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R53_DMIC6_VOL_IC_1_Sigma_MASK             0xFF
#define R53_DMIC6_VOL_IC_1_Sigma_SHIFT            0

/* DMIC_VOL7 (IC 1_Sigma) */
#define R54_DMIC7_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R54_DMIC7_VOL_IC_1_Sigma_MASK             0xFF
#define R54_DMIC7_VOL_IC_1_Sigma_SHIFT            0

/* DAC_CTRL1 (IC 1_Sigma) */
#define R55_DAC_FS_IC_1_Sigma                     0x6    /* 110b	[2:0] */
#define R55_DAC_FCOMP_IC_1_Sigma                  0x0    /* 0b	[3] */
#define R55_DAC_IBIAS_IC_1_Sigma                  0x0    /* 00b	[5:4] */
#define R55_DAC_LPM_IC_1_Sigma                    0x0    /* 0b	[6] */
#define R55_DAC_MORE_FILT_IC_1_Sigma              0x1    /* 1b	[7] */
#define R55_DAC_FS_IC_1_Sigma_MASK                0x7
#define R55_DAC_FS_IC_1_Sigma_SHIFT               0
#define R55_DAC_FCOMP_IC_1_Sigma_MASK             0x8
#define R55_DAC_FCOMP_IC_1_Sigma_SHIFT            3
#define R55_DAC_IBIAS_IC_1_Sigma_MASK             0x30
#define R55_DAC_IBIAS_IC_1_Sigma_SHIFT            4
#define R55_DAC_LPM_IC_1_Sigma_MASK               0x40
#define R55_DAC_LPM_IC_1_Sigma_SHIFT              6
#define R55_DAC_MORE_FILT_IC_1_Sigma_MASK         0x80
#define R55_DAC_MORE_FILT_IC_1_Sigma_SHIFT        7

/* DAC_CTRL2 (IC 1_Sigma) */
#define R56_DAC_VOL_LINK_IC_1_Sigma               0x0    /* 0b	[0] */
#define R56_DAC_HARD_VOL_IC_1_Sigma               0x0    /* 0b	[1] */
#define R56_DAC_VOL_ZC_IC_1_Sigma                 0x0    /* 0b	[2] */
#define R56_DAC_LPM_II_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R56_DAC0_HPF_EN_IC_1_Sigma                0x0    /* 0b	[4] */
#define R56_DAC1_HPF_EN_IC_1_Sigma                0x0    /* 0b	[5] */
#define R56_DAC0_MUTE_IC_1_Sigma                  0x0    /* 0b	[6] */
#define R56_DAC1_MUTE_IC_1_Sigma                  0x0    /* 0b	[7] */
#define R56_DAC_VOL_LINK_IC_1_Sigma_MASK          0x1
#define R56_DAC_VOL_LINK_IC_1_Sigma_SHIFT         0
#define R56_DAC_HARD_VOL_IC_1_Sigma_MASK          0x2
#define R56_DAC_HARD_VOL_IC_1_Sigma_SHIFT         1
#define R56_DAC_VOL_ZC_IC_1_Sigma_MASK            0x4
#define R56_DAC_VOL_ZC_IC_1_Sigma_SHIFT           2
#define R56_DAC_LPM_II_IC_1_Sigma_MASK            0x8
#define R56_DAC_LPM_II_IC_1_Sigma_SHIFT           3
#define R56_DAC0_HPF_EN_IC_1_Sigma_MASK           0x10
#define R56_DAC0_HPF_EN_IC_1_Sigma_SHIFT          4
#define R56_DAC1_HPF_EN_IC_1_Sigma_MASK           0x20
#define R56_DAC1_HPF_EN_IC_1_Sigma_SHIFT          5
#define R56_DAC0_MUTE_IC_1_Sigma_MASK             0x40
#define R56_DAC0_MUTE_IC_1_Sigma_SHIFT            6
#define R56_DAC1_MUTE_IC_1_Sigma_MASK             0x80
#define R56_DAC1_MUTE_IC_1_Sigma_SHIFT            7

/* DAC_VOL0 (IC 1_Sigma) */
#define R57_DAC0_VOL_IC_1_Sigma                   0x40   /* 01000000b	[7:0] */
#define R57_DAC0_VOL_IC_1_Sigma_MASK              0xFF
#define R57_DAC0_VOL_IC_1_Sigma_SHIFT             0

/* DAC_VOL1 (IC 1_Sigma) */
#define R58_DAC1_VOL_IC_1_Sigma                   0x40   /* 01000000b	[7:0] */
#define R58_DAC1_VOL_IC_1_Sigma_MASK              0xFF
#define R58_DAC1_VOL_IC_1_Sigma_SHIFT             0

/* DAC_ROUTE0 (IC 1_Sigma) */
#define R59_DAC0_ROUTE_IC_1_Sigma                 0x0    /* 0000000b	[6:0] */
#define R59_DAC0_ROUTE_IC_1_Sigma_MASK            0x7F
#define R59_DAC0_ROUTE_IC_1_Sigma_SHIFT           0

/* DAC_ROUTE1 (IC 1_Sigma) */
#define R60_DAC1_ROUTE_IC_1_Sigma                 0x1    /* 0000001b	[6:0] */
#define R60_DAC1_ROUTE_IC_1_Sigma_MASK            0x7F
#define R60_DAC1_ROUTE_IC_1_Sigma_SHIFT           0

/* HP_CTRL (IC 1_Sigma) */
#define R61_HP0_MODE_IC_1_Sigma                   0x0    /* 0b	[0] */
#define R61_HP1_MODE_IC_1_Sigma                   0x0    /* 0b	[4] */
#define R61_HP0_MODE_IC_1_Sigma_MASK              0x1
#define R61_HP0_MODE_IC_1_Sigma_SHIFT             0
#define R61_HP1_MODE_IC_1_Sigma_MASK              0x10
#define R61_HP1_MODE_IC_1_Sigma_SHIFT             4

/* FDEC_CTRL1 (IC 1_Sigma) */
#define R62_FDEC01_IN_FS_IC_1_Sigma               0x4    /* 100b	[2:0] */
#define R62_FDEC01_OUT_FS_IC_1_Sigma              0x4    /* 100b	[6:4] */
#define R62_FDEC01_IN_FS_IC_1_Sigma_MASK          0x7
#define R62_FDEC01_IN_FS_IC_1_Sigma_SHIFT         0
#define R62_FDEC01_OUT_FS_IC_1_Sigma_MASK         0x70
#define R62_FDEC01_OUT_FS_IC_1_Sigma_SHIFT        4

/* FDEC_CTRL2 (IC 1_Sigma) */
#define R63_FDEC23_IN_FS_IC_1_Sigma               0x5    /* 101b	[2:0] */
#define R63_FDEC23_OUT_FS_IC_1_Sigma              0x2    /* 010b	[6:4] */
#define R63_FDEC23_IN_FS_IC_1_Sigma_MASK          0x7
#define R63_FDEC23_IN_FS_IC_1_Sigma_SHIFT         0
#define R63_FDEC23_OUT_FS_IC_1_Sigma_MASK         0x70
#define R63_FDEC23_OUT_FS_IC_1_Sigma_SHIFT        4

/* FDEC_CTRL3 (IC 1_Sigma) */
#define R64_FDEC45_IN_FS_IC_1_Sigma               0x5    /* 101b	[2:0] */
#define R64_FDEC45_OUT_FS_IC_1_Sigma              0x2    /* 010b	[6:4] */
#define R64_FDEC45_IN_FS_IC_1_Sigma_MASK          0x7
#define R64_FDEC45_IN_FS_IC_1_Sigma_SHIFT         0
#define R64_FDEC45_OUT_FS_IC_1_Sigma_MASK         0x70
#define R64_FDEC45_OUT_FS_IC_1_Sigma_SHIFT        4

/* FDEC_CTRL4 (IC 1_Sigma) */
#define R65_FDEC67_IN_FS_IC_1_Sigma               0x5    /* 101b	[2:0] */
#define R65_FDEC67_OUT_FS_IC_1_Sigma              0x2    /* 010b	[6:4] */
#define R65_FDEC67_IN_FS_IC_1_Sigma_MASK          0x7
#define R65_FDEC67_IN_FS_IC_1_Sigma_SHIFT         0
#define R65_FDEC67_OUT_FS_IC_1_Sigma_MASK         0x70
#define R65_FDEC67_OUT_FS_IC_1_Sigma_SHIFT        4

/* FDEC_ROUTE0 (IC 1_Sigma) */
#define R66_FDEC0_ROUTE_IC_1_Sigma                0x26   /* 100110b	[5:0] */
#define R66_FDEC0_ROUTE_IC_1_Sigma_MASK           0x3F
#define R66_FDEC0_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE1 (IC 1_Sigma) */
#define R67_FDEC1_ROUTE_IC_1_Sigma                0x27   /* 100111b	[5:0] */
#define R67_FDEC1_ROUTE_IC_1_Sigma_MASK           0x3F
#define R67_FDEC1_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE2 (IC 1_Sigma) */
#define R68_FDEC2_ROUTE_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R68_FDEC2_ROUTE_IC_1_Sigma_MASK           0x3F
#define R68_FDEC2_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE3 (IC 1_Sigma) */
#define R69_FDEC3_ROUTE_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R69_FDEC3_ROUTE_IC_1_Sigma_MASK           0x3F
#define R69_FDEC3_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE4 (IC 1_Sigma) */
#define R70_FDEC4_ROUTE_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R70_FDEC4_ROUTE_IC_1_Sigma_MASK           0x3F
#define R70_FDEC4_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE5 (IC 1_Sigma) */
#define R71_FDEC5_ROUTE_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R71_FDEC5_ROUTE_IC_1_Sigma_MASK           0x3F
#define R71_FDEC5_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE6 (IC 1_Sigma) */
#define R72_FDEC6_ROUTE_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R72_FDEC6_ROUTE_IC_1_Sigma_MASK           0x3F
#define R72_FDEC6_ROUTE_IC_1_Sigma_SHIFT          0

/* FDEC_ROUTE7 (IC 1_Sigma) */
#define R73_FDEC7_ROUTE_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R73_FDEC7_ROUTE_IC_1_Sigma_MASK           0x3F
#define R73_FDEC7_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_CTRL1 (IC 1_Sigma) */
#define R74_FINT01_IN_FS_IC_1_Sigma               0x5    /* 101b	[2:0] */
#define R74_FINT01_OUT_FS_IC_1_Sigma              0x6    /* 110b	[6:4] */
#define R74_FINT01_IN_FS_IC_1_Sigma_MASK          0x7
#define R74_FINT01_IN_FS_IC_1_Sigma_SHIFT         0
#define R74_FINT01_OUT_FS_IC_1_Sigma_MASK         0x70
#define R74_FINT01_OUT_FS_IC_1_Sigma_SHIFT        4

/* FINT_CTRL2 (IC 1_Sigma) */
#define R75_FINT23_IN_FS_IC_1_Sigma               0x4    /* 100b	[2:0] */
#define R75_FINT23_OUT_FS_IC_1_Sigma              0x6    /* 110b	[6:4] */
#define R75_FINT23_IN_FS_IC_1_Sigma_MASK          0x7
#define R75_FINT23_IN_FS_IC_1_Sigma_SHIFT         0
#define R75_FINT23_OUT_FS_IC_1_Sigma_MASK         0x70
#define R75_FINT23_OUT_FS_IC_1_Sigma_SHIFT        4

/* FINT_CTRL3 (IC 1_Sigma) */
#define R76_FINT45_IN_FS_IC_1_Sigma               0x2    /* 010b	[2:0] */
#define R76_FINT45_OUT_FS_IC_1_Sigma              0x5    /* 101b	[6:4] */
#define R76_FINT45_IN_FS_IC_1_Sigma_MASK          0x7
#define R76_FINT45_IN_FS_IC_1_Sigma_SHIFT         0
#define R76_FINT45_OUT_FS_IC_1_Sigma_MASK         0x70
#define R76_FINT45_OUT_FS_IC_1_Sigma_SHIFT        4

/* FINT_CTRL4 (IC 1_Sigma) */
#define R77_FINT67_IN_FS_IC_1_Sigma               0x2    /* 010b	[2:0] */
#define R77_FINT67_OUT_FS_IC_1_Sigma              0x5    /* 101b	[6:4] */
#define R77_FINT67_IN_FS_IC_1_Sigma_MASK          0x7
#define R77_FINT67_IN_FS_IC_1_Sigma_SHIFT         0
#define R77_FINT67_OUT_FS_IC_1_Sigma_MASK         0x70
#define R77_FINT67_OUT_FS_IC_1_Sigma_SHIFT        4

/* FINT_ROUTE0 (IC 1_Sigma) */
#define R78_FINT0_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R78_FINT0_ROUTE_IC_1_Sigma_MASK           0x7F
#define R78_FINT0_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE1 (IC 1_Sigma) */
#define R79_FINT1_ROUTE_IC_1_Sigma                0x1    /* 0000001b	[6:0] */
#define R79_FINT1_ROUTE_IC_1_Sigma_MASK           0x7F
#define R79_FINT1_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE2 (IC 1_Sigma) */
#define R80_FINT2_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R80_FINT2_ROUTE_IC_1_Sigma_MASK           0x7F
#define R80_FINT2_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE3 (IC 1_Sigma) */
#define R81_FINT3_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R81_FINT3_ROUTE_IC_1_Sigma_MASK           0x7F
#define R81_FINT3_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE4 (IC 1_Sigma) */
#define R82_FINT4_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R82_FINT4_ROUTE_IC_1_Sigma_MASK           0x7F
#define R82_FINT4_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE5 (IC 1_Sigma) */
#define R83_FINT5_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R83_FINT5_ROUTE_IC_1_Sigma_MASK           0x7F
#define R83_FINT5_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE6 (IC 1_Sigma) */
#define R84_FINT6_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R84_FINT6_ROUTE_IC_1_Sigma_MASK           0x7F
#define R84_FINT6_ROUTE_IC_1_Sigma_SHIFT          0

/* FINT_ROUTE7 (IC 1_Sigma) */
#define R85_FINT7_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R85_FINT7_ROUTE_IC_1_Sigma_MASK           0x7F
#define R85_FINT7_ROUTE_IC_1_Sigma_SHIFT          0

/* ASRCI_CTRL (IC 1_Sigma) */
#define R86_ASRCI_OUT_FS_IC_1_Sigma               0x4    /* 100b	[2:0] */
#define R86_ASRCI_LPM_II_IC_1_Sigma               0x0    /* 0b	[3] */
#define R86_ASRCI_SOURCE_IC_1_Sigma               0x0    /* 0b	[4] */
#define R86_ASRCI_LPM_IC_1_Sigma                  0x0    /* 0b	[5] */
#define R86_ASRCI_VFILT_IC_1_Sigma                0x0    /* 0b	[6] */
#define R86_ASRCI_MORE_FILT_IC_1_Sigma            0x0    /* 0b	[7] */
#define R86_ASRCI_OUT_FS_IC_1_Sigma_MASK          0x7
#define R86_ASRCI_OUT_FS_IC_1_Sigma_SHIFT         0
#define R86_ASRCI_LPM_II_IC_1_Sigma_MASK          0x8
#define R86_ASRCI_LPM_II_IC_1_Sigma_SHIFT         3
#define R86_ASRCI_SOURCE_IC_1_Sigma_MASK          0x10
#define R86_ASRCI_SOURCE_IC_1_Sigma_SHIFT         4
#define R86_ASRCI_LPM_IC_1_Sigma_MASK             0x20
#define R86_ASRCI_LPM_IC_1_Sigma_SHIFT            5
#define R86_ASRCI_VFILT_IC_1_Sigma_MASK           0x40
#define R86_ASRCI_VFILT_IC_1_Sigma_SHIFT          6
#define R86_ASRCI_MORE_FILT_IC_1_Sigma_MASK       0x80
#define R86_ASRCI_MORE_FILT_IC_1_Sigma_SHIFT      7

/* ASRCI_ROUTE01 (IC 1_Sigma) */
#define R87_ASRCI0_ROUTE_IC_1_Sigma               0x0    /* 0000b	[3:0] */
#define R87_ASRCI1_ROUTE_IC_1_Sigma               0x1    /* 0001b	[7:4] */
#define R87_ASRCI0_ROUTE_IC_1_Sigma_MASK          0xF
#define R87_ASRCI0_ROUTE_IC_1_Sigma_SHIFT         0
#define R87_ASRCI1_ROUTE_IC_1_Sigma_MASK          0xF0
#define R87_ASRCI1_ROUTE_IC_1_Sigma_SHIFT         4

/* ASRCI_ROUTE23 (IC 1_Sigma) */
#define R88_ASRCI2_ROUTE_IC_1_Sigma               0x0    /* 0000b	[3:0] */
#define R88_ASRCI3_ROUTE_IC_1_Sigma               0x0    /* 0000b	[7:4] */
#define R88_ASRCI2_ROUTE_IC_1_Sigma_MASK          0xF
#define R88_ASRCI2_ROUTE_IC_1_Sigma_SHIFT         0
#define R88_ASRCI3_ROUTE_IC_1_Sigma_MASK          0xF0
#define R88_ASRCI3_ROUTE_IC_1_Sigma_SHIFT         4

/* ASRCO_CTRL (IC 1_Sigma) */
#define R89_ASRCO_IN_FS_IC_1_Sigma                0x4    /* 100b	[2:0] */
#define R89_ASRCO_LPM_II_IC_1_Sigma               0x0    /* 0b	[3] */
#define R89_ASRCO_SAI_SEL_IC_1_Sigma              0x0    /* 0b	[4] */
#define R89_ASRCO_LPM_IC_1_Sigma                  0x0    /* 0b	[5] */
#define R89_ASRCO_VFILT_IC_1_Sigma                0x0    /* 0b	[6] */
#define R89_ASRCO_MORE_FILT_IC_1_Sigma            0x0    /* 0b	[7] */
#define R89_ASRCO_IN_FS_IC_1_Sigma_MASK           0x7
#define R89_ASRCO_IN_FS_IC_1_Sigma_SHIFT          0
#define R89_ASRCO_LPM_II_IC_1_Sigma_MASK          0x8
#define R89_ASRCO_LPM_II_IC_1_Sigma_SHIFT         3
#define R89_ASRCO_SAI_SEL_IC_1_Sigma_MASK         0x10
#define R89_ASRCO_SAI_SEL_IC_1_Sigma_SHIFT        4
#define R89_ASRCO_LPM_IC_1_Sigma_MASK             0x20
#define R89_ASRCO_LPM_IC_1_Sigma_SHIFT            5
#define R89_ASRCO_VFILT_IC_1_Sigma_MASK           0x40
#define R89_ASRCO_VFILT_IC_1_Sigma_SHIFT          6
#define R89_ASRCO_MORE_FILT_IC_1_Sigma_MASK       0x80
#define R89_ASRCO_MORE_FILT_IC_1_Sigma_SHIFT      7

/* ASRCO_ROUTE0 (IC 1_Sigma) */
#define R90_ASRCO0_ROUTE_IC_1_Sigma               0x2C   /* 101100b	[5:0] */
#define R90_ASRCO0_ROUTE_IC_1_Sigma_MASK          0x3F
#define R90_ASRCO0_ROUTE_IC_1_Sigma_SHIFT         0

/* ASRCO_ROUTE1 (IC 1_Sigma) */
#define R91_ASRCO1_ROUTE_IC_1_Sigma               0x2D   /* 101101b	[5:0] */
#define R91_ASRCO1_ROUTE_IC_1_Sigma_MASK          0x3F
#define R91_ASRCO1_ROUTE_IC_1_Sigma_SHIFT         0

/* ASRCO_ROUTE2 (IC 1_Sigma) */
#define R92_ASRCO2_ROUTE_IC_1_Sigma               0x0    /* 000000b	[5:0] */
#define R92_ASRCO2_ROUTE_IC_1_Sigma_MASK          0x3F
#define R92_ASRCO2_ROUTE_IC_1_Sigma_SHIFT         0

/* ASRCO_ROUTE3 (IC 1_Sigma) */
#define R93_ASRCO3_ROUTE_IC_1_Sigma               0x0    /* 000000b	[5:0] */
#define R93_ASRCO3_ROUTE_IC_1_Sigma_MASK          0x3F
#define R93_ASRCO3_ROUTE_IC_1_Sigma_SHIFT         0

/* FDSP_RUN (IC 1_Sigma) */
#define R94_FDSP_RUN_IC_1_Sigma                   0x0    /* 0b	[0] */
#define R94_FDSP_RUN_IC_1_Sigma_MASK              0x1
#define R94_FDSP_RUN_IC_1_Sigma_SHIFT             0

/* FDSP_CTRL1 (IC 1_Sigma) */
#define R95_FDSP_BANK_SEL_IC_1_Sigma              0x0    /* 00b	[1:0] */
#define R95_FDSP_RAMP_MODE_IC_1_Sigma             0x0    /* 0b	[2] */
#define R95_FDSP_ZERO_STATE_IC_1_Sigma            0x0    /* 0b	[3] */
#define R95_FDSP_RAMP_RATE_IC_1_Sigma             0x7    /* 0111b	[7:4] */
#define R95_FDSP_BANK_SEL_IC_1_Sigma_MASK         0x3
#define R95_FDSP_BANK_SEL_IC_1_Sigma_SHIFT        0
#define R95_FDSP_RAMP_MODE_IC_1_Sigma_MASK        0x4
#define R95_FDSP_RAMP_MODE_IC_1_Sigma_SHIFT       2
#define R95_FDSP_ZERO_STATE_IC_1_Sigma_MASK       0x8
#define R95_FDSP_ZERO_STATE_IC_1_Sigma_SHIFT      3
#define R95_FDSP_RAMP_RATE_IC_1_Sigma_MASK        0xF0
#define R95_FDSP_RAMP_RATE_IC_1_Sigma_SHIFT       4

/* FDSP_CTRL2 (IC 1_Sigma) */
#define R96_FDSP_LAMBDA_IC_1_Sigma                0x3F   /* 111111b	[5:0] */
#define R96_FDSP_LAMBDA_IC_1_Sigma_MASK           0x3F
#define R96_FDSP_LAMBDA_IC_1_Sigma_SHIFT          0

/* FDSP_CTRL3 (IC 1_Sigma) */
#define R97_FDSP_COPY_AB_IC_1_Sigma               0x0    /* 0b	[0] */
#define R97_FDSP_COPY_AC_IC_1_Sigma               0x0    /* 0b	[1] */
#define R97_FDSP_COPY_BA_IC_1_Sigma               0x0    /* 0b	[2] */
#define R97_FDSP_COPY_BC_IC_1_Sigma               0x0    /* 0b	[3] */
#define R97_FDSP_COPY_CA_IC_1_Sigma               0x0    /* 0b	[4] */
#define R97_FDSP_COPY_CB_IC_1_Sigma               0x0    /* 0b	[5] */
#define R97_FDSP_COPY_AB_IC_1_Sigma_MASK          0x1
#define R97_FDSP_COPY_AB_IC_1_Sigma_SHIFT         0
#define R97_FDSP_COPY_AC_IC_1_Sigma_MASK          0x2
#define R97_FDSP_COPY_AC_IC_1_Sigma_SHIFT         1
#define R97_FDSP_COPY_BA_IC_1_Sigma_MASK          0x4
#define R97_FDSP_COPY_BA_IC_1_Sigma_SHIFT         2
#define R97_FDSP_COPY_BC_IC_1_Sigma_MASK          0x8
#define R97_FDSP_COPY_BC_IC_1_Sigma_SHIFT         3
#define R97_FDSP_COPY_CA_IC_1_Sigma_MASK          0x10
#define R97_FDSP_COPY_CA_IC_1_Sigma_SHIFT         4
#define R97_FDSP_COPY_CB_IC_1_Sigma_MASK          0x20
#define R97_FDSP_COPY_CB_IC_1_Sigma_SHIFT         5

/* FDSP_CTRL4 (IC 1_Sigma) */
#define R98_FDSP_RATE_SOURCE_IC_1_Sigma           0x1    /* 0001b	[3:0] */
#define R98_FDSP_EXP_ATK_SPEED_IC_1_Sigma         0x0    /* 0b	[4] */
#define R98_FDSP_RATE_SOURCE_IC_1_Sigma_MASK      0xF
#define R98_FDSP_RATE_SOURCE_IC_1_Sigma_SHIFT     0
#define R98_FDSP_EXP_ATK_SPEED_IC_1_Sigma_MASK    0x10
#define R98_FDSP_EXP_ATK_SPEED_IC_1_Sigma_SHIFT   4

/* FDSP_CTRL5 (IC 1_Sigma) */
#define R99_FDSP_RATE_DIV_IC_1_Sigma              0x007F /* 0000000001111111b	[15:0] */
#define R99_FDSP_RATE_DIV_IC_1_Sigma_MASK         0xFFFF
#define R99_FDSP_RATE_DIV_IC_1_Sigma_SHIFT        0

/* FDSP_CTRL7 (IC 1_Sigma) */
#define R100_FDSP_MOD_N_IC_1_Sigma                0x0    /* 000000b	[5:0] */
#define R100_FDSP_MOD_N_IC_1_Sigma_MASK           0x3F
#define R100_FDSP_MOD_N_IC_1_Sigma_SHIFT          0

/* FDSP_CTRL8 (IC 1_Sigma) */
#define R101_FDSP_REG_COND0_IC_1_Sigma            0x0    /* 0b	[0] */
#define R101_FDSP_REG_COND1_IC_1_Sigma            0x0    /* 0b	[1] */
#define R101_FDSP_REG_COND2_IC_1_Sigma            0x0    /* 0b	[2] */
#define R101_FDSP_REG_COND3_IC_1_Sigma            0x0    /* 0b	[3] */
#define R101_FDSP_REG_COND4_IC_1_Sigma            0x0    /* 0b	[4] */
#define R101_FDSP_REG_COND5_IC_1_Sigma            0x0    /* 0b	[5] */
#define R101_FDSP_REG_COND6_IC_1_Sigma            0x0    /* 0b	[6] */
#define R101_FDSP_REG_COND7_IC_1_Sigma            0x0    /* 0b	[7] */
#define R101_FDSP_REG_COND0_IC_1_Sigma_MASK       0x1
#define R101_FDSP_REG_COND0_IC_1_Sigma_SHIFT      0
#define R101_FDSP_REG_COND1_IC_1_Sigma_MASK       0x2
#define R101_FDSP_REG_COND1_IC_1_Sigma_SHIFT      1
#define R101_FDSP_REG_COND2_IC_1_Sigma_MASK       0x4
#define R101_FDSP_REG_COND2_IC_1_Sigma_SHIFT      2
#define R101_FDSP_REG_COND3_IC_1_Sigma_MASK       0x8
#define R101_FDSP_REG_COND3_IC_1_Sigma_SHIFT      3
#define R101_FDSP_REG_COND4_IC_1_Sigma_MASK       0x10
#define R101_FDSP_REG_COND4_IC_1_Sigma_SHIFT      4
#define R101_FDSP_REG_COND5_IC_1_Sigma_MASK       0x20
#define R101_FDSP_REG_COND5_IC_1_Sigma_SHIFT      5
#define R101_FDSP_REG_COND6_IC_1_Sigma_MASK       0x40
#define R101_FDSP_REG_COND6_IC_1_Sigma_SHIFT      6
#define R101_FDSP_REG_COND7_IC_1_Sigma_MASK       0x80
#define R101_FDSP_REG_COND7_IC_1_Sigma_SHIFT      7

/* FDSP_SL_ADDR (IC 1_Sigma) */
#define R102_FDSP_SL_ADDR_IC_1_Sigma              0x0    /* 000000b	[5:0] */
#define R102_FDSP_SL_ADDR_IC_1_Sigma_MASK         0x3F
#define R102_FDSP_SL_ADDR_IC_1_Sigma_SHIFT        0

/* FDSP_SL_P0 (IC 1_Sigma) */
#define R103_FDSP_SL_P0_IC_1_Sigma                0x00000000 /* 00000000000000000000000000000000b	[31:0] */
#define R103_FDSP_SL_P0_IC_1_Sigma_MASK           0xFFFFFFFF
#define R103_FDSP_SL_P0_IC_1_Sigma_SHIFT          0

/* FDSP_SL_P1 (IC 1_Sigma) */
#define R104_FDSP_SL_P1_IC_1_Sigma                0x00000000 /* 00000000000000000000000000000000b	[31:0] */
#define R104_FDSP_SL_P1_IC_1_Sigma_MASK           0xFFFFFFFF
#define R104_FDSP_SL_P1_IC_1_Sigma_SHIFT          0

/* FDSP_SL_P2 (IC 1_Sigma) */
#define R105_FDSP_SL_P2_IC_1_Sigma                0x00000000 /* 00000000000000000000000000000000b	[31:0] */
#define R105_FDSP_SL_P2_IC_1_Sigma_MASK           0xFFFFFFFF
#define R105_FDSP_SL_P2_IC_1_Sigma_SHIFT          0

/* FDSP_SL_P3 (IC 1_Sigma) */
#define R106_FDSP_SL_P3_IC_1_Sigma                0x00000000 /* 00000000000000000000000000000000b	[31:0] */
#define R106_FDSP_SL_P3_IC_1_Sigma_MASK           0xFFFFFFFF
#define R106_FDSP_SL_P3_IC_1_Sigma_SHIFT          0

/* FDSP_SL_P4 (IC 1_Sigma) */
#define R107_FDSP_SL_P4_IC_1_Sigma                0x00000000 /* 00000000000000000000000000000000b	[31:0] */
#define R107_FDSP_SL_P4_IC_1_Sigma_MASK           0xFFFFFFFF
#define R107_FDSP_SL_P4_IC_1_Sigma_SHIFT          0

/* FDSP_SL_UPDATE (IC 1_Sigma) */
#define R108_FDSP_SL_UPDATE_IC_1_Sigma            0x0    /* 0b	[0] */
#define R108_FDSP_SL_UPDATE_IC_1_Sigma_MASK       0x1
#define R108_FDSP_SL_UPDATE_IC_1_Sigma_SHIFT      0

/* SDSP_CTRL1 (IC 1_Sigma) */
#define R109_SDSP_RATE_SOURCE_IC_1_Sigma          0x0    /* 0000b	[3:0] */
#define R109_SDSP_SPEED_IC_1_Sigma                0x0    /* 0b	[4] */
#define R109_SDSP_RATE_SOURCE_IC_1_Sigma_MASK     0xF
#define R109_SDSP_RATE_SOURCE_IC_1_Sigma_SHIFT    0
#define R109_SDSP_SPEED_IC_1_Sigma_MASK           0x10
#define R109_SDSP_SPEED_IC_1_Sigma_SHIFT          4

/* SDSP_CTRL2 (IC 1_Sigma) */
#define R110_SDSP_RUN_IC_1_Sigma                  0x0    /* 0b	[0] */
#define R110_SDSP_RUN_IC_1_Sigma_MASK             0x1
#define R110_SDSP_RUN_IC_1_Sigma_SHIFT            0

/* SDSP_CTRL3 (IC 1_Sigma) */
#define R111_SDSP_WDOG_EN_IC_1_Sigma              0x0    /* 0b	[0] */
#define R111_SDSP_WDOG_MUTE_IC_1_Sigma            0x0    /* 0b	[4] */
#define R111_SDSP_WDOG_EN_IC_1_Sigma_MASK         0x1
#define R111_SDSP_WDOG_EN_IC_1_Sigma_SHIFT        0
#define R111_SDSP_WDOG_MUTE_IC_1_Sigma_MASK       0x10
#define R111_SDSP_WDOG_MUTE_IC_1_Sigma_SHIFT      4

/* SDSP_CTRL4 (IC 1_Sigma) */
#define R112_SDSP_WDOG_VAL_IC_1_Sigma             0x000000 /* 000000000000000000000000b	[23:0] */
#define R112_SDSP_WDOG_VAL_IC_1_Sigma_MASK        0xFFFFFF
#define R112_SDSP_WDOG_VAL_IC_1_Sigma_SHIFT       0

/* SDSP_CTRL7 (IC 1_Sigma) */
#define R113_SDSP_MOD_DATA_MEM_IC_1_Sigma         0x7F4  /* 011111110100b	[11:0] */
#define R113_SDSP_MOD_DATA_MEM_IC_1_Sigma_MASK    0xFFF
#define R113_SDSP_MOD_DATA_MEM_IC_1_Sigma_SHIFT   0

/* SDSP_CTRL9 (IC 1_Sigma) */
#define R114_SDSP_RATE_DIV_IC_1_Sigma             0x07FF /* 0000011111111111b	[15:0] */
#define R114_SDSP_RATE_DIV_IC_1_Sigma_MASK        0xFFFF
#define R114_SDSP_RATE_DIV_IC_1_Sigma_SHIFT       0

/* SDSP_CTRL11 (IC 1_Sigma) */
#define R115_SDSP_INT0_IC_1_Sigma                 0x0    /* 0b	[0] */
#define R115_SDSP_INT1_IC_1_Sigma                 0x0    /* 0b	[1] */
#define R115_SDSP_INT2_IC_1_Sigma                 0x0    /* 0b	[2] */
#define R115_SDSP_INT3_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R115_SDSP_INT0_IC_1_Sigma_MASK            0x1
#define R115_SDSP_INT0_IC_1_Sigma_SHIFT           0
#define R115_SDSP_INT1_IC_1_Sigma_MASK            0x2
#define R115_SDSP_INT1_IC_1_Sigma_SHIFT           1
#define R115_SDSP_INT2_IC_1_Sigma_MASK            0x4
#define R115_SDSP_INT2_IC_1_Sigma_SHIFT           2
#define R115_SDSP_INT3_IC_1_Sigma_MASK            0x8
#define R115_SDSP_INT3_IC_1_Sigma_SHIFT           3

/* MP_CTRL1 (IC 1_Sigma) */
#define R116_MP0_MODE_IC_1_Sigma                  0x0    /* 0000b	[3:0] */
#define R116_MP1_MODE_IC_1_Sigma                  0x0    /* 0000b	[7:4] */
#define R116_MP0_MODE_IC_1_Sigma_MASK             0xF
#define R116_MP0_MODE_IC_1_Sigma_SHIFT            0
#define R116_MP1_MODE_IC_1_Sigma_MASK             0xF0
#define R116_MP1_MODE_IC_1_Sigma_SHIFT            4

/* MP_CTRL2 (IC 1_Sigma) */
#define R117_MP2_MODE_IC_1_Sigma                  0x0    /* 0000b	[3:0] */
#define R117_MP3_MODE_IC_1_Sigma                  0x0    /* 0000b	[7:4] */
#define R117_MP2_MODE_IC_1_Sigma_MASK             0xF
#define R117_MP2_MODE_IC_1_Sigma_SHIFT            0
#define R117_MP3_MODE_IC_1_Sigma_MASK             0xF0
#define R117_MP3_MODE_IC_1_Sigma_SHIFT            4

/* MP_CTRL3 (IC 1_Sigma) */
#define R118_MP4_MODE_IC_1_Sigma                  0x0    /* 0000b	[3:0] */
#define R118_MP5_MODE_IC_1_Sigma                  0x0    /* 0000b	[7:4] */
#define R118_MP4_MODE_IC_1_Sigma_MASK             0xF
#define R118_MP4_MODE_IC_1_Sigma_SHIFT            0
#define R118_MP5_MODE_IC_1_Sigma_MASK             0xF0
#define R118_MP5_MODE_IC_1_Sigma_SHIFT            4

/* MP_CTRL4 (IC 1_Sigma) */
#define R119_MP6_MODE_IC_1_Sigma                  0x0    /* 0000b	[3:0] */
#define R119_MP7_MODE_IC_1_Sigma                  0x0    /* 0000b	[7:4] */
#define R119_MP6_MODE_IC_1_Sigma_MASK             0xF
#define R119_MP6_MODE_IC_1_Sigma_SHIFT            0
#define R119_MP7_MODE_IC_1_Sigma_MASK             0xF0
#define R119_MP7_MODE_IC_1_Sigma_SHIFT            4

/* MP_CTRL5 (IC 1_Sigma) */
#define R120_MP8_MODE_IC_1_Sigma                  0x0    /* 0000b	[3:0] */
#define R120_MP9_MODE_IC_1_Sigma                  0x0    /* 0000b	[7:4] */
#define R120_MP8_MODE_IC_1_Sigma_MASK             0xF
#define R120_MP8_MODE_IC_1_Sigma_SHIFT            0
#define R120_MP9_MODE_IC_1_Sigma_MASK             0xF0
#define R120_MP9_MODE_IC_1_Sigma_SHIFT            4

/* MP_CTRL6 (IC 1_Sigma) */
#define R121_MP10_MODE_IC_1_Sigma                 0x0    /* 0000b	[3:0] */
#define R121_MP11_MODE_IC_1_Sigma                 0x0    /* 0000b	[7:4] */
#define R121_MP10_MODE_IC_1_Sigma_MASK            0xF
#define R121_MP10_MODE_IC_1_Sigma_SHIFT           0
#define R121_MP11_MODE_IC_1_Sigma_MASK            0xF0
#define R121_MP11_MODE_IC_1_Sigma_SHIFT           4

/* MP_CTRL7 (IC 1_Sigma) */
#define R122_GPI_DB_IC_1_Sigma                    0x0    /* 000b	[2:0] */
#define R122_MCLKO_RATE_IC_1_Sigma                0x0    /* 000b	[6:4] */
#define R122_GPI_DB_IC_1_Sigma_MASK               0x7
#define R122_GPI_DB_IC_1_Sigma_SHIFT              0
#define R122_MCLKO_RATE_IC_1_Sigma_MASK           0x70
#define R122_MCLKO_RATE_IC_1_Sigma_SHIFT          4

/* MP_CTRL8 (IC 1_Sigma) */
#define R123_GPIO0_OUT_IC_1_Sigma                 0x0    /* 0b	[0] */
#define R123_GPIO1_OUT_IC_1_Sigma                 0x0    /* 0b	[1] */
#define R123_GPIO2_OUT_IC_1_Sigma                 0x0    /* 0b	[2] */
#define R123_GPIO3_OUT_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R123_GPIO4_OUT_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R123_GPIO5_OUT_IC_1_Sigma                 0x0    /* 0b	[5] */
#define R123_GPIO6_OUT_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R123_GPIO7_OUT_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R123_GPIO0_OUT_IC_1_Sigma_MASK            0x1
#define R123_GPIO0_OUT_IC_1_Sigma_SHIFT           0
#define R123_GPIO1_OUT_IC_1_Sigma_MASK            0x2
#define R123_GPIO1_OUT_IC_1_Sigma_SHIFT           1
#define R123_GPIO2_OUT_IC_1_Sigma_MASK            0x4
#define R123_GPIO2_OUT_IC_1_Sigma_SHIFT           2
#define R123_GPIO3_OUT_IC_1_Sigma_MASK            0x8
#define R123_GPIO3_OUT_IC_1_Sigma_SHIFT           3
#define R123_GPIO4_OUT_IC_1_Sigma_MASK            0x10
#define R123_GPIO4_OUT_IC_1_Sigma_SHIFT           4
#define R123_GPIO5_OUT_IC_1_Sigma_MASK            0x20
#define R123_GPIO5_OUT_IC_1_Sigma_SHIFT           5
#define R123_GPIO6_OUT_IC_1_Sigma_MASK            0x40
#define R123_GPIO6_OUT_IC_1_Sigma_SHIFT           6
#define R123_GPIO7_OUT_IC_1_Sigma_MASK            0x80
#define R123_GPIO7_OUT_IC_1_Sigma_SHIFT           7

/* MP_CTRL9 (IC 1_Sigma) */
#define R124_GPIO8_OUT_IC_1_Sigma                 0x0    /* 0b	[0] */
#define R124_GPIO9_OUT_IC_1_Sigma                 0x0    /* 0b	[1] */
#define R124_GPIO10_OUT_IC_1_Sigma                0x0    /* 0b	[2] */
#define R124_GPIO11_OUT_IC_1_Sigma                0x0    /* 0b	[3] */
#define R124_GPIO12_OUT_IC_1_Sigma                0x0    /* 0b	[4] */
#define R124_GPIO8_OUT_IC_1_Sigma_MASK            0x1
#define R124_GPIO8_OUT_IC_1_Sigma_SHIFT           0
#define R124_GPIO9_OUT_IC_1_Sigma_MASK            0x2
#define R124_GPIO9_OUT_IC_1_Sigma_SHIFT           1
#define R124_GPIO10_OUT_IC_1_Sigma_MASK           0x4
#define R124_GPIO10_OUT_IC_1_Sigma_SHIFT          2
#define R124_GPIO11_OUT_IC_1_Sigma_MASK           0x8
#define R124_GPIO11_OUT_IC_1_Sigma_SHIFT          3
#define R124_GPIO12_OUT_IC_1_Sigma_MASK           0x10
#define R124_GPIO12_OUT_IC_1_Sigma_SHIFT          4

/* FSYNC0_CTRL (IC 1_Sigma) */
#define R125_FSYNC0_DRIVE_IC_1_Sigma              0x1    /* 01b	[1:0] */
#define R125_FSYNC0_SLEW_IC_1_Sigma               0x1    /* 1b	[2] */
#define R125_FSYNC0_PULL_EN_IC_1_Sigma            0x0    /* 0b	[4] */
#define R125_FSYNC0_PULL_SEL_IC_1_Sigma           0x0    /* 0b	[5] */
#define R125_FSYNC0_DRIVE_IC_1_Sigma_MASK         0x3
#define R125_FSYNC0_DRIVE_IC_1_Sigma_SHIFT        0
#define R125_FSYNC0_SLEW_IC_1_Sigma_MASK          0x4
#define R125_FSYNC0_SLEW_IC_1_Sigma_SHIFT         2
#define R125_FSYNC0_PULL_EN_IC_1_Sigma_MASK       0x10
#define R125_FSYNC0_PULL_EN_IC_1_Sigma_SHIFT      4
#define R125_FSYNC0_PULL_SEL_IC_1_Sigma_MASK      0x20
#define R125_FSYNC0_PULL_SEL_IC_1_Sigma_SHIFT     5

/* BCLK0_CTRL (IC 1_Sigma) */
#define R126_BCLK0_DRIVE_IC_1_Sigma               0x1    /* 01b	[1:0] */
#define R126_BCLK0_SLEW_IC_1_Sigma                0x1    /* 1b	[2] */
#define R126_BCLK0_PULL_EN_IC_1_Sigma             0x0    /* 0b	[4] */
#define R126_BCLK0_PULL_SEL_IC_1_Sigma            0x0    /* 0b	[5] */
#define R126_BCLK0_DRIVE_IC_1_Sigma_MASK          0x3
#define R126_BCLK0_DRIVE_IC_1_Sigma_SHIFT         0
#define R126_BCLK0_SLEW_IC_1_Sigma_MASK           0x4
#define R126_BCLK0_SLEW_IC_1_Sigma_SHIFT          2
#define R126_BCLK0_PULL_EN_IC_1_Sigma_MASK        0x10
#define R126_BCLK0_PULL_EN_IC_1_Sigma_SHIFT       4
#define R126_BCLK0_PULL_SEL_IC_1_Sigma_MASK       0x20
#define R126_BCLK0_PULL_SEL_IC_1_Sigma_SHIFT      5

/* SDATAO0_CTRL (IC 1_Sigma) */
#define R127_SDATAO0_DRIVE_IC_1_Sigma             0x0    /* 0b	[0] */
#define R127_SDATAO0_SLEW_IC_1_Sigma              0x1    /* 1b	[2] */
#define R127_SDATAO0_DRIVE_IC_1_Sigma_MASK        0x1
#define R127_SDATAO0_DRIVE_IC_1_Sigma_SHIFT       0
#define R127_SDATAO0_SLEW_IC_1_Sigma_MASK         0x4
#define R127_SDATAO0_SLEW_IC_1_Sigma_SHIFT        2

/* SDATAI0_CTRL (IC 1_Sigma) */
#define R128_SDATAI0_DRIVE_IC_1_Sigma             0x1    /* 01b	[1:0] */
#define R128_SDATAI0_SLEW_IC_1_Sigma              0x1    /* 1b	[2] */
#define R128_SDATAI0_PULL_EN_IC_1_Sigma           0x0    /* 0b	[4] */
#define R128_SDATAI0_PULL_SEL_IC_1_Sigma          0x0    /* 0b	[5] */
#define R128_SDATAI0_DRIVE_IC_1_Sigma_MASK        0x3
#define R128_SDATAI0_DRIVE_IC_1_Sigma_SHIFT       0
#define R128_SDATAI0_SLEW_IC_1_Sigma_MASK         0x4
#define R128_SDATAI0_SLEW_IC_1_Sigma_SHIFT        2
#define R128_SDATAI0_PULL_EN_IC_1_Sigma_MASK      0x10
#define R128_SDATAI0_PULL_EN_IC_1_Sigma_SHIFT     4
#define R128_SDATAI0_PULL_SEL_IC_1_Sigma_MASK     0x20
#define R128_SDATAI0_PULL_SEL_IC_1_Sigma_SHIFT    5

/* FSYNC1_CTRL (IC 1_Sigma) */
#define R129_FSYNC1_DRIVE_IC_1_Sigma              0x1    /* 01b	[1:0] */
#define R129_FSYNC1_SLEW_IC_1_Sigma               0x1    /* 1b	[2] */
#define R129_FSYNC1_PULL_EN_IC_1_Sigma            0x0    /* 0b	[4] */
#define R129_FSYNC1_PULL_SEL_IC_1_Sigma           0x0    /* 0b	[5] */
#define R129_FSYNC1_DRIVE_IC_1_Sigma_MASK         0x3
#define R129_FSYNC1_DRIVE_IC_1_Sigma_SHIFT        0
#define R129_FSYNC1_SLEW_IC_1_Sigma_MASK          0x4
#define R129_FSYNC1_SLEW_IC_1_Sigma_SHIFT         2
#define R129_FSYNC1_PULL_EN_IC_1_Sigma_MASK       0x10
#define R129_FSYNC1_PULL_EN_IC_1_Sigma_SHIFT      4
#define R129_FSYNC1_PULL_SEL_IC_1_Sigma_MASK      0x20
#define R129_FSYNC1_PULL_SEL_IC_1_Sigma_SHIFT     5

/* BCLK1_CTRL (IC 1_Sigma) */
#define R130_BCLK1_DRIVE_IC_1_Sigma               0x1    /* 01b	[1:0] */
#define R130_BCLK1_SLEW_IC_1_Sigma                0x1    /* 1b	[2] */
#define R130_BCLK1_PULL_EN_IC_1_Sigma             0x0    /* 0b	[4] */
#define R130_BCLK1_PULL_SEL_IC_1_Sigma            0x0    /* 0b	[5] */
#define R130_BCLK1_DRIVE_IC_1_Sigma_MASK          0x3
#define R130_BCLK1_DRIVE_IC_1_Sigma_SHIFT         0
#define R130_BCLK1_SLEW_IC_1_Sigma_MASK           0x4
#define R130_BCLK1_SLEW_IC_1_Sigma_SHIFT          2
#define R130_BCLK1_PULL_EN_IC_1_Sigma_MASK        0x10
#define R130_BCLK1_PULL_EN_IC_1_Sigma_SHIFT       4
#define R130_BCLK1_PULL_SEL_IC_1_Sigma_MASK       0x20
#define R130_BCLK1_PULL_SEL_IC_1_Sigma_SHIFT      5

/* SDATAO1_CTRL (IC 1_Sigma) */
#define R131_SDATAO1_DRIVE_IC_1_Sigma             0x1    /* 01b	[1:0] */
#define R131_SDATAO1_SLEW_IC_1_Sigma              0x1    /* 1b	[2] */
#define R131_SDATAO1_PULL_EN_IC_1_Sigma           0x0    /* 0b	[4] */
#define R131_SDATAO1_PULL_SEL_IC_1_Sigma          0x0    /* 0b	[5] */
#define R131_SDATAO1_DRIVE_IC_1_Sigma_MASK        0x3
#define R131_SDATAO1_DRIVE_IC_1_Sigma_SHIFT       0
#define R131_SDATAO1_SLEW_IC_1_Sigma_MASK         0x4
#define R131_SDATAO1_SLEW_IC_1_Sigma_SHIFT        2
#define R131_SDATAO1_PULL_EN_IC_1_Sigma_MASK      0x10
#define R131_SDATAO1_PULL_EN_IC_1_Sigma_SHIFT     4
#define R131_SDATAO1_PULL_SEL_IC_1_Sigma_MASK     0x20
#define R131_SDATAO1_PULL_SEL_IC_1_Sigma_SHIFT    5

/* SDATAI1_CTRL (IC 1_Sigma) */
#define R132_SDATAI1_DRIVE_IC_1_Sigma             0x0    /* 00b	[1:0] */
#define R132_SDATAI1_SLEW_IC_1_Sigma              0x1    /* 1b	[2] */
#define R132_SDATAI1_PULL_EN_IC_1_Sigma           0x0    /* 0b	[4] */
#define R132_SDATAI1_PULL_SEL_IC_1_Sigma          0x0    /* 0b	[5] */
#define R132_SDATAI1_DRIVE_IC_1_Sigma_MASK        0x3
#define R132_SDATAI1_DRIVE_IC_1_Sigma_SHIFT       0
#define R132_SDATAI1_SLEW_IC_1_Sigma_MASK         0x4
#define R132_SDATAI1_SLEW_IC_1_Sigma_SHIFT        2
#define R132_SDATAI1_PULL_EN_IC_1_Sigma_MASK      0x10
#define R132_SDATAI1_PULL_EN_IC_1_Sigma_SHIFT     4
#define R132_SDATAI1_PULL_SEL_IC_1_Sigma_MASK     0x20
#define R132_SDATAI1_PULL_SEL_IC_1_Sigma_SHIFT    5

/* DMIC_CLK0_CTRL (IC 1_Sigma) */
#define R133_DMIC_CLK0_DRIVE_IC_1_Sigma           0x1    /* 01b	[1:0] */
#define R133_DMIC_CLK0_SLEW_IC_1_Sigma            0x1    /* 1b	[2] */
#define R133_DMIC_CLK0_PULL_EN_IC_1_Sigma         0x0    /* 0b	[4] */
#define R133_DMIC_CLK0_PULL_SEL_IC_1_Sigma        0x0    /* 0b	[5] */
#define R133_DMIC_CLK0_DRIVE_IC_1_Sigma_MASK      0x3
#define R133_DMIC_CLK0_DRIVE_IC_1_Sigma_SHIFT     0
#define R133_DMIC_CLK0_SLEW_IC_1_Sigma_MASK       0x4
#define R133_DMIC_CLK0_SLEW_IC_1_Sigma_SHIFT      2
#define R133_DMIC_CLK0_PULL_EN_IC_1_Sigma_MASK    0x10
#define R133_DMIC_CLK0_PULL_EN_IC_1_Sigma_SHIFT   4
#define R133_DMIC_CLK0_PULL_SEL_IC_1_Sigma_MASK   0x20
#define R133_DMIC_CLK0_PULL_SEL_IC_1_Sigma_SHIFT  5

/* DMIC_CLK1_CTRL (IC 1_Sigma) */
#define R134_DMIC_CLK1_DRIVE_IC_1_Sigma           0x1    /* 01b	[1:0] */
#define R134_DMIC_CLK1_SLEW_IC_1_Sigma            0x1    /* 1b	[2] */
#define R134_DMIC_CLK1_PULL_EN_IC_1_Sigma         0x0    /* 0b	[4] */
#define R134_DMIC_CLK1_PULL_SEL_IC_1_Sigma        0x0    /* 0b	[5] */
#define R134_DMIC_CLK1_DRIVE_IC_1_Sigma_MASK      0x3
#define R134_DMIC_CLK1_DRIVE_IC_1_Sigma_SHIFT     0
#define R134_DMIC_CLK1_SLEW_IC_1_Sigma_MASK       0x4
#define R134_DMIC_CLK1_SLEW_IC_1_Sigma_SHIFT      2
#define R134_DMIC_CLK1_PULL_EN_IC_1_Sigma_MASK    0x10
#define R134_DMIC_CLK1_PULL_EN_IC_1_Sigma_SHIFT   4
#define R134_DMIC_CLK1_PULL_SEL_IC_1_Sigma_MASK   0x20
#define R134_DMIC_CLK1_PULL_SEL_IC_1_Sigma_SHIFT  5

/* DMIC01_CTRL (IC 1_Sigma) */
#define R135_DMIC01_DRIVE_IC_1_Sigma              0x1    /* 01b	[1:0] */
#define R135_DMIC01_SLEW_IC_1_Sigma               0x1    /* 1b	[2] */
#define R135_DMIC01_PULL_EN_IC_1_Sigma            0x0    /* 0b	[4] */
#define R135_DMIC01_PULL_SEL_IC_1_Sigma           0x0    /* 0b	[5] */
#define R135_DMIC01_DRIVE_IC_1_Sigma_MASK         0x3
#define R135_DMIC01_DRIVE_IC_1_Sigma_SHIFT        0
#define R135_DMIC01_SLEW_IC_1_Sigma_MASK          0x4
#define R135_DMIC01_SLEW_IC_1_Sigma_SHIFT         2
#define R135_DMIC01_PULL_EN_IC_1_Sigma_MASK       0x10
#define R135_DMIC01_PULL_EN_IC_1_Sigma_SHIFT      4
#define R135_DMIC01_PULL_SEL_IC_1_Sigma_MASK      0x20
#define R135_DMIC01_PULL_SEL_IC_1_Sigma_SHIFT     5

/* DMIC23_CTRL (IC 1_Sigma) */
#define R136_DMIC23_DRIVE_IC_1_Sigma              0x1    /* 01b	[1:0] */
#define R136_DMIC23_SLEW_IC_1_Sigma               0x1    /* 1b	[2] */
#define R136_DMIC23_PULL_EN_IC_1_Sigma            0x0    /* 0b	[4] */
#define R136_DMIC23_PULL_SEL_IC_1_Sigma           0x0    /* 0b	[5] */
#define R136_DMIC23_DRIVE_IC_1_Sigma_MASK         0x3
#define R136_DMIC23_DRIVE_IC_1_Sigma_SHIFT        0
#define R136_DMIC23_SLEW_IC_1_Sigma_MASK          0x4
#define R136_DMIC23_SLEW_IC_1_Sigma_SHIFT         2
#define R136_DMIC23_PULL_EN_IC_1_Sigma_MASK       0x10
#define R136_DMIC23_PULL_EN_IC_1_Sigma_SHIFT      4
#define R136_DMIC23_PULL_SEL_IC_1_Sigma_MASK      0x20
#define R136_DMIC23_PULL_SEL_IC_1_Sigma_SHIFT     5

/* I2C_SPI_CTRL (IC 1_Sigma) */
#define R137_SDA_MISO_DRIVE_IC_1_Sigma            0x0    /* 0b	[0] */
#define R137_SCL_SCLK_DRIVE_IC_1_Sigma            0x0    /* 0b	[1] */
#define R137_SDA_MISO_DRIVE_IC_1_Sigma_MASK       0x1
#define R137_SDA_MISO_DRIVE_IC_1_Sigma_SHIFT      0
#define R137_SCL_SCLK_DRIVE_IC_1_Sigma_MASK       0x2
#define R137_SCL_SCLK_DRIVE_IC_1_Sigma_SHIFT      1

/* IRQ_CTRL1 (IC 1_Sigma) */
#define R138_IRQ1_CLEAR_IC_1_Sigma                0x0    /* 0b	[0] */
#define R138_IRQ2_CLEAR_IC_1_Sigma                0x0    /* 0b	[1] */
#define R138_IRQ1_FUNC_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R138_IRQ2_FUNC_IC_1_Sigma                 0x0    /* 0b	[5] */
#define R138_IRQ1_CLEAR_IC_1_Sigma_MASK           0x1
#define R138_IRQ1_CLEAR_IC_1_Sigma_SHIFT          0
#define R138_IRQ2_CLEAR_IC_1_Sigma_MASK           0x2
#define R138_IRQ2_CLEAR_IC_1_Sigma_SHIFT          1
#define R138_IRQ1_FUNC_IC_1_Sigma_MASK            0x10
#define R138_IRQ1_FUNC_IC_1_Sigma_SHIFT           4
#define R138_IRQ2_FUNC_IC_1_Sigma_MASK            0x20
#define R138_IRQ2_FUNC_IC_1_Sigma_SHIFT           5

/* IRQ1_MASK1 (IC 1_Sigma) */
#define R139_IRQ1_DAC0_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[0] */
#define R139_IRQ1_DAC1_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[1] */
#define R139_IRQ1_ADC0_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[4] */
#define R139_IRQ1_ADC1_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[5] */
#define R139_IRQ1_ADC2_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[6] */
#define R139_IRQ1_ADC3_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[7] */
#define R139_IRQ1_DAC0_CLIP_MASK_IC_1_Sigma_MASK  0x1
#define R139_IRQ1_DAC0_CLIP_MASK_IC_1_Sigma_SHIFT 0
#define R139_IRQ1_DAC1_CLIP_MASK_IC_1_Sigma_MASK  0x2
#define R139_IRQ1_DAC1_CLIP_MASK_IC_1_Sigma_SHIFT 1
#define R139_IRQ1_ADC0_CLIP_MASK_IC_1_Sigma_MASK  0x10
#define R139_IRQ1_ADC0_CLIP_MASK_IC_1_Sigma_SHIFT 4
#define R139_IRQ1_ADC1_CLIP_MASK_IC_1_Sigma_MASK  0x20
#define R139_IRQ1_ADC1_CLIP_MASK_IC_1_Sigma_SHIFT 5
#define R139_IRQ1_ADC2_CLIP_MASK_IC_1_Sigma_MASK  0x40
#define R139_IRQ1_ADC2_CLIP_MASK_IC_1_Sigma_SHIFT 6
#define R139_IRQ1_ADC3_CLIP_MASK_IC_1_Sigma_MASK  0x80
#define R139_IRQ1_ADC3_CLIP_MASK_IC_1_Sigma_SHIFT 7

/* IRQ1_MASK2 (IC 1_Sigma) */
#define R140_IRQ1_PLL_LOCKED_MASK_IC_1_Sigma      0x1    /* 1b	[0] */
#define R140_IRQ1_PLL_UNLOCKED_MASK_IC_1_Sigma    0x1    /* 1b	[1] */
#define R140_IRQ1_AVDD_UVW_MASK_IC_1_Sigma        0x1    /* 1b	[2] */
#define R140_IRQ1_PRAMP_MASK_IC_1_Sigma           0x1    /* 1b	[3] */
#define R140_IRQ1_ASRCI_LOCKED_MASK_IC_1_Sigma    0x1    /* 1b	[4] */
#define R140_IRQ1_ASRCI_UNLOCKED_MASK_IC_1_Sigma  0x1    /* 1b	[5] */
#define R140_IRQ1_ASRCO_LOCKED_MASK_IC_1_Sigma    0x1    /* 1b	[6] */
#define R140_IRQ1_ASRCO_UNLOCKED_MASK_IC_1_Sigma  0x1    /* 1b	[7] */
#define R140_IRQ1_PLL_LOCKED_MASK_IC_1_Sigma_MASK 0x1
#define R140_IRQ1_PLL_LOCKED_MASK_IC_1_Sigma_SHIFT 0
#define R140_IRQ1_PLL_UNLOCKED_MASK_IC_1_Sigma_MASK 0x2
#define R140_IRQ1_PLL_UNLOCKED_MASK_IC_1_Sigma_SHIFT 1
#define R140_IRQ1_AVDD_UVW_MASK_IC_1_Sigma_MASK   0x4
#define R140_IRQ1_AVDD_UVW_MASK_IC_1_Sigma_SHIFT  2
#define R140_IRQ1_PRAMP_MASK_IC_1_Sigma_MASK      0x8
#define R140_IRQ1_PRAMP_MASK_IC_1_Sigma_SHIFT     3
#define R140_IRQ1_ASRCI_LOCKED_MASK_IC_1_Sigma_MASK 0x10
#define R140_IRQ1_ASRCI_LOCKED_MASK_IC_1_Sigma_SHIFT 4
#define R140_IRQ1_ASRCI_UNLOCKED_MASK_IC_1_Sigma_MASK 0x20
#define R140_IRQ1_ASRCI_UNLOCKED_MASK_IC_1_Sigma_SHIFT 5
#define R140_IRQ1_ASRCO_LOCKED_MASK_IC_1_Sigma_MASK 0x40
#define R140_IRQ1_ASRCO_LOCKED_MASK_IC_1_Sigma_SHIFT 6
#define R140_IRQ1_ASRCO_UNLOCKED_MASK_IC_1_Sigma_MASK 0x80
#define R140_IRQ1_ASRCO_UNLOCKED_MASK_IC_1_Sigma_SHIFT 7

/* IRQ1_MASK3 (IC 1_Sigma) */
#define R141_IRQ1_SDSP0_MASK_IC_1_Sigma           0x1    /* 1b	[0] */
#define R141_IRQ1_SDSP1_MASK_IC_1_Sigma           0x1    /* 1b	[1] */
#define R141_IRQ1_SDSP2_MASK_IC_1_Sigma           0x1    /* 1b	[2] */
#define R141_IRQ1_SDSP3_MASK_IC_1_Sigma           0x1    /* 1b	[3] */
#define R141_IRQ1_POWER_UP_COMPLETE_MASK_IC_1_Sigma 0x1  /* 1b	[4] */
#define R141_IRQ1_SDSP0_MASK_IC_1_Sigma_MASK      0x1
#define R141_IRQ1_SDSP0_MASK_IC_1_Sigma_SHIFT     0
#define R141_IRQ1_SDSP1_MASK_IC_1_Sigma_MASK      0x2
#define R141_IRQ1_SDSP1_MASK_IC_1_Sigma_SHIFT     1
#define R141_IRQ1_SDSP2_MASK_IC_1_Sigma_MASK      0x4
#define R141_IRQ1_SDSP2_MASK_IC_1_Sigma_SHIFT     2
#define R141_IRQ1_SDSP3_MASK_IC_1_Sigma_MASK      0x8
#define R141_IRQ1_SDSP3_MASK_IC_1_Sigma_SHIFT     3
#define R141_IRQ1_POWER_UP_COMPLETE_MASK_IC_1_Sigma_MASK 0x10
#define R141_IRQ1_POWER_UP_COMPLETE_MASK_IC_1_Sigma_SHIFT 4

/* IRQ2_MASK1 (IC 1_Sigma) */
#define R142_IRQ2_DAC0_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[0] */
#define R142_IRQ2_DAC1_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[1] */
#define R142_IRQ2_ADC0_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[4] */
#define R142_IRQ2_ADC1_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[5] */
#define R142_IRQ2_ADC2_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[6] */
#define R142_IRQ2_ADC3_CLIP_MASK_IC_1_Sigma       0x1    /* 1b	[7] */
#define R142_IRQ2_DAC0_CLIP_MASK_IC_1_Sigma_MASK  0x1
#define R142_IRQ2_DAC0_CLIP_MASK_IC_1_Sigma_SHIFT 0
#define R142_IRQ2_DAC1_CLIP_MASK_IC_1_Sigma_MASK  0x2
#define R142_IRQ2_DAC1_CLIP_MASK_IC_1_Sigma_SHIFT 1
#define R142_IRQ2_ADC0_CLIP_MASK_IC_1_Sigma_MASK  0x10
#define R142_IRQ2_ADC0_CLIP_MASK_IC_1_Sigma_SHIFT 4
#define R142_IRQ2_ADC1_CLIP_MASK_IC_1_Sigma_MASK  0x20
#define R142_IRQ2_ADC1_CLIP_MASK_IC_1_Sigma_SHIFT 5
#define R142_IRQ2_ADC2_CLIP_MASK_IC_1_Sigma_MASK  0x40
#define R142_IRQ2_ADC2_CLIP_MASK_IC_1_Sigma_SHIFT 6
#define R142_IRQ2_ADC3_CLIP_MASK_IC_1_Sigma_MASK  0x80
#define R142_IRQ2_ADC3_CLIP_MASK_IC_1_Sigma_SHIFT 7

/* IRQ2_MASK2 (IC 1_Sigma) */
#define R143_IRQ2_PLL_LOCKED_MASK_IC_1_Sigma      0x1    /* 1b	[0] */
#define R143_IRQ2_PLL_UNLOCKED_MASK_IC_1_Sigma    0x1    /* 1b	[1] */
#define R143_IRQ2_AVDD_UVW_MASK_IC_1_Sigma        0x1    /* 1b	[2] */
#define R143_IRQ2_PRAMP_MASK_IC_1_Sigma           0x1    /* 1b	[3] */
#define R143_IRQ2_ASRCI_LOCKED_MASK_IC_1_Sigma    0x1    /* 1b	[4] */
#define R143_IRQ2_ASRCI_UNLOCKED_MASK_IC_1_Sigma  0x1    /* 1b	[5] */
#define R143_IRQ2_ASRCO_LOCKED_MASK_IC_1_Sigma    0x1    /* 1b	[6] */
#define R143_IRQ2_ASRCO_UNLOCKED_MASK_IC_1_Sigma  0x1    /* 1b	[7] */
#define R143_IRQ2_PLL_LOCKED_MASK_IC_1_Sigma_MASK 0x1
#define R143_IRQ2_PLL_LOCKED_MASK_IC_1_Sigma_SHIFT 0
#define R143_IRQ2_PLL_UNLOCKED_MASK_IC_1_Sigma_MASK 0x2
#define R143_IRQ2_PLL_UNLOCKED_MASK_IC_1_Sigma_SHIFT 1
#define R143_IRQ2_AVDD_UVW_MASK_IC_1_Sigma_MASK   0x4
#define R143_IRQ2_AVDD_UVW_MASK_IC_1_Sigma_SHIFT  2
#define R143_IRQ2_PRAMP_MASK_IC_1_Sigma_MASK      0x8
#define R143_IRQ2_PRAMP_MASK_IC_1_Sigma_SHIFT     3
#define R143_IRQ2_ASRCI_LOCKED_MASK_IC_1_Sigma_MASK 0x10
#define R143_IRQ2_ASRCI_LOCKED_MASK_IC_1_Sigma_SHIFT 4
#define R143_IRQ2_ASRCI_UNLOCKED_MASK_IC_1_Sigma_MASK 0x20
#define R143_IRQ2_ASRCI_UNLOCKED_MASK_IC_1_Sigma_SHIFT 5
#define R143_IRQ2_ASRCO_LOCKED_MASK_IC_1_Sigma_MASK 0x40
#define R143_IRQ2_ASRCO_LOCKED_MASK_IC_1_Sigma_SHIFT 6
#define R143_IRQ2_ASRCO_UNLOCKED_MASK_IC_1_Sigma_MASK 0x80
#define R143_IRQ2_ASRCO_UNLOCKED_MASK_IC_1_Sigma_SHIFT 7

/* IRQ2_MASK3 (IC 1_Sigma) */
#define R144_IRQ2_SDSP0_MASK_IC_1_Sigma           0x1    /* 1b	[0] */
#define R144_IRQ2_SDSP1_MASK_IC_1_Sigma           0x1    /* 1b	[1] */
#define R144_IRQ2_SDSP2_MASK_IC_1_Sigma           0x1    /* 1b	[2] */
#define R144_IRQ2_SDSP3_MASK_IC_1_Sigma           0x1    /* 1b	[3] */
#define R144_IRQ2_POWER_UP_COMPLETE_MASK_IC_1_Sigma 0x1  /* 1b	[4] */
#define R144_IRQ2_SDSP0_MASK_IC_1_Sigma_MASK      0x1
#define R144_IRQ2_SDSP0_MASK_IC_1_Sigma_SHIFT     0
#define R144_IRQ2_SDSP1_MASK_IC_1_Sigma_MASK      0x2
#define R144_IRQ2_SDSP1_MASK_IC_1_Sigma_SHIFT     1
#define R144_IRQ2_SDSP2_MASK_IC_1_Sigma_MASK      0x4
#define R144_IRQ2_SDSP2_MASK_IC_1_Sigma_SHIFT     2
#define R144_IRQ2_SDSP3_MASK_IC_1_Sigma_MASK      0x8
#define R144_IRQ2_SDSP3_MASK_IC_1_Sigma_SHIFT     3
#define R144_IRQ2_POWER_UP_COMPLETE_MASK_IC_1_Sigma_MASK 0x10
#define R144_IRQ2_POWER_UP_COMPLETE_MASK_IC_1_Sigma_SHIFT 4

/* RESETS (IC 1_Sigma) */
#define R145_SOFT_FULL_RESET_IC_1_Sigma           0x0    /* 0b	[0] */
#define R145_SOFT_RESET_IC_1_Sigma                0x0    /* 0b	[4] */
#define R145_SOFT_FULL_RESET_IC_1_Sigma_MASK      0x1
#define R145_SOFT_FULL_RESET_IC_1_Sigma_SHIFT     0
#define R145_SOFT_RESET_IC_1_Sigma_MASK           0x10
#define R145_SOFT_RESET_IC_1_Sigma_SHIFT          4

/* READ_LAMBDA (IC 1_Sigma) */
#define R146_FDSP_CURRENT_LAMBDA_IC_1_Sigma       0x3F   /* 111111b	[5:0] */
#define R146_FDSP_CURRENT_LAMBDA_IC_1_Sigma_MASK  0x3F
#define R146_FDSP_CURRENT_LAMBDA_IC_1_Sigma_SHIFT 0

/* STATUS1 (IC 1_Sigma) */
#define R147_DAC0_CLIP_IC_1_Sigma                 0x0    /* 0b	[0] */
#define R147_DAC1_CLIP_IC_1_Sigma                 0x0    /* 0b	[1] */
#define R147_ADC0_CLIP_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R147_ADC1_CLIP_IC_1_Sigma                 0x0    /* 0b	[5] */
#define R147_ADC2_CLIP_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R147_ADC3_CLIP_IC_1_Sigma                 0x0    /* 0b	[7] */
#define R147_DAC0_CLIP_IC_1_Sigma_MASK            0x1
#define R147_DAC0_CLIP_IC_1_Sigma_SHIFT           0
#define R147_DAC1_CLIP_IC_1_Sigma_MASK            0x2
#define R147_DAC1_CLIP_IC_1_Sigma_SHIFT           1
#define R147_ADC0_CLIP_IC_1_Sigma_MASK            0x10
#define R147_ADC0_CLIP_IC_1_Sigma_SHIFT           4
#define R147_ADC1_CLIP_IC_1_Sigma_MASK            0x20
#define R147_ADC1_CLIP_IC_1_Sigma_SHIFT           5
#define R147_ADC2_CLIP_IC_1_Sigma_MASK            0x40
#define R147_ADC2_CLIP_IC_1_Sigma_SHIFT           6
#define R147_ADC3_CLIP_IC_1_Sigma_MASK            0x80
#define R147_ADC3_CLIP_IC_1_Sigma_SHIFT           7

/* STATUS2 (IC 1_Sigma) */
#define R148_PLL_LOCK_IC_1_Sigma                  0x0    /* 0b	[0] */
#define R148_AVDD_UVW_IC_1_Sigma                  0x0    /* 0b	[1] */
#define R148_ASRCI_LOCK_IC_1_Sigma                0x0    /* 0b	[2] */
#define R148_ASRCO_LOCK_IC_1_Sigma                0x0    /* 0b	[3] */
#define R148_SPT0_LOCK_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R148_SPT1_LOCK_IC_1_Sigma                 0x0    /* 0b	[5] */
#define R148_SYNC_LOCK_IC_1_Sigma                 0x0    /* 0b	[6] */
#define R148_POWER_UP_COMPLETE_IC_1_Sigma         0x0    /* 0b	[7] */
#define R148_PLL_LOCK_IC_1_Sigma_MASK             0x1
#define R148_PLL_LOCK_IC_1_Sigma_SHIFT            0
#define R148_AVDD_UVW_IC_1_Sigma_MASK             0x2
#define R148_AVDD_UVW_IC_1_Sigma_SHIFT            1
#define R148_ASRCI_LOCK_IC_1_Sigma_MASK           0x4
#define R148_ASRCI_LOCK_IC_1_Sigma_SHIFT          2
#define R148_ASRCO_LOCK_IC_1_Sigma_MASK           0x8
#define R148_ASRCO_LOCK_IC_1_Sigma_SHIFT          3
#define R148_SPT0_LOCK_IC_1_Sigma_MASK            0x10
#define R148_SPT0_LOCK_IC_1_Sigma_SHIFT           4
#define R148_SPT1_LOCK_IC_1_Sigma_MASK            0x20
#define R148_SPT1_LOCK_IC_1_Sigma_SHIFT           5
#define R148_SYNC_LOCK_IC_1_Sigma_MASK            0x40
#define R148_SYNC_LOCK_IC_1_Sigma_SHIFT           6
#define R148_POWER_UP_COMPLETE_IC_1_Sigma_MASK    0x80
#define R148_POWER_UP_COMPLETE_IC_1_Sigma_SHIFT   7

/* GPI1 (IC 1_Sigma) */
#define R149_GPIO0_IN_IC_1_Sigma                  0x0    /* 0b	[0] */
#define R149_GPIO1_IN_IC_1_Sigma                  0x0    /* 0b	[1] */
#define R149_GPIO2_IN_IC_1_Sigma                  0x0    /* 0b	[2] */
#define R149_GPIO3_IN_IC_1_Sigma                  0x0    /* 0b	[3] */
#define R149_GPIO4_IN_IC_1_Sigma                  0x0    /* 0b	[4] */
#define R149_GPIO5_IN_IC_1_Sigma                  0x0    /* 0b	[5] */
#define R149_GPIO6_IN_IC_1_Sigma                  0x0    /* 0b	[6] */
#define R149_GPIO7_IN_IC_1_Sigma                  0x0    /* 0b	[7] */
#define R149_GPIO0_IN_IC_1_Sigma_MASK             0x1
#define R149_GPIO0_IN_IC_1_Sigma_SHIFT            0
#define R149_GPIO1_IN_IC_1_Sigma_MASK             0x2
#define R149_GPIO1_IN_IC_1_Sigma_SHIFT            1
#define R149_GPIO2_IN_IC_1_Sigma_MASK             0x4
#define R149_GPIO2_IN_IC_1_Sigma_SHIFT            2
#define R149_GPIO3_IN_IC_1_Sigma_MASK             0x8
#define R149_GPIO3_IN_IC_1_Sigma_SHIFT            3
#define R149_GPIO4_IN_IC_1_Sigma_MASK             0x10
#define R149_GPIO4_IN_IC_1_Sigma_SHIFT            4
#define R149_GPIO5_IN_IC_1_Sigma_MASK             0x20
#define R149_GPIO5_IN_IC_1_Sigma_SHIFT            5
#define R149_GPIO6_IN_IC_1_Sigma_MASK             0x40
#define R149_GPIO6_IN_IC_1_Sigma_SHIFT            6
#define R149_GPIO7_IN_IC_1_Sigma_MASK             0x80
#define R149_GPIO7_IN_IC_1_Sigma_SHIFT            7

/* GPI2 (IC 1_Sigma) */
#define R150_GPIO8_IN_IC_1_Sigma                  0x0    /* 0b	[0] */
#define R150_GPIO9_IN_IC_1_Sigma                  0x0    /* 0b	[1] */
#define R150_GPIO10_IN_IC_1_Sigma                 0x0    /* 0b	[2] */
#define R150_GPIO11_IN_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R150_GPIO12_IN_IC_1_Sigma                 0x0    /* 0b	[4] */
#define R150_GPIO8_IN_IC_1_Sigma_MASK             0x1
#define R150_GPIO8_IN_IC_1_Sigma_SHIFT            0
#define R150_GPIO9_IN_IC_1_Sigma_MASK             0x2
#define R150_GPIO9_IN_IC_1_Sigma_SHIFT            1
#define R150_GPIO10_IN_IC_1_Sigma_MASK            0x4
#define R150_GPIO10_IN_IC_1_Sigma_SHIFT           2
#define R150_GPIO11_IN_IC_1_Sigma_MASK            0x8
#define R150_GPIO11_IN_IC_1_Sigma_SHIFT           3
#define R150_GPIO12_IN_IC_1_Sigma_MASK            0x10
#define R150_GPIO12_IN_IC_1_Sigma_SHIFT           4

/* DSP_STATUS (IC 1_Sigma) */
#define R151_SDSP_WDOG_ERROR_IC_1_Sigma           0x0    /* 0b	[0] */
#define R151_SDSP_WDOG_ERROR_IC_1_Sigma_MASK      0x1
#define R151_SDSP_WDOG_ERROR_IC_1_Sigma_SHIFT     0

/* IRQ1_STATUS1 (IC 1_Sigma) */
#define R152_IRQ1_DAC0_CLIP_IC_1_Sigma            0x0    /* 0b	[0] */
#define R152_IRQ1_DAC1_CLIP_IC_1_Sigma            0x0    /* 0b	[1] */
#define R152_IRQ1_ADC0_CLIP_IC_1_Sigma            0x0    /* 0b	[4] */
#define R152_IRQ1_ADC1_CLIP_IC_1_Sigma            0x0    /* 0b	[5] */
#define R152_IRQ1_ADC2_CLIP_IC_1_Sigma            0x0    /* 0b	[6] */
#define R152_IRQ1_ADC3_CLIP_IC_1_Sigma            0x0    /* 0b	[7] */
#define R152_IRQ1_DAC0_CLIP_IC_1_Sigma_MASK       0x1
#define R152_IRQ1_DAC0_CLIP_IC_1_Sigma_SHIFT      0
#define R152_IRQ1_DAC1_CLIP_IC_1_Sigma_MASK       0x2
#define R152_IRQ1_DAC1_CLIP_IC_1_Sigma_SHIFT      1
#define R152_IRQ1_ADC0_CLIP_IC_1_Sigma_MASK       0x10
#define R152_IRQ1_ADC0_CLIP_IC_1_Sigma_SHIFT      4
#define R152_IRQ1_ADC1_CLIP_IC_1_Sigma_MASK       0x20
#define R152_IRQ1_ADC1_CLIP_IC_1_Sigma_SHIFT      5
#define R152_IRQ1_ADC2_CLIP_IC_1_Sigma_MASK       0x40
#define R152_IRQ1_ADC2_CLIP_IC_1_Sigma_SHIFT      6
#define R152_IRQ1_ADC3_CLIP_IC_1_Sigma_MASK       0x80
#define R152_IRQ1_ADC3_CLIP_IC_1_Sigma_SHIFT      7

/* IRQ1_STATUS2 (IC 1_Sigma) */
#define R153_IRQ1_PLL_LOCKED_IC_1_Sigma           0x0    /* 0b	[0] */
#define R153_IRQ1_PLL_UNLOCKED_IC_1_Sigma         0x0    /* 0b	[1] */
#define R153_IRQ1_AVDD_UVW_IC_1_Sigma             0x0    /* 0b	[2] */
#define R153_IRQ1_PRAMP_IC_1_Sigma                0x0    /* 0b	[3] */
#define R153_IRQ1_ASRCI_LOCKED_IC_1_Sigma         0x0    /* 0b	[4] */
#define R153_IRQ1_ASRCI_UNLOCKED_IC_1_Sigma       0x0    /* 0b	[5] */
#define R153_IRQ1_ASRCO_LOCKED_IC_1_Sigma         0x0    /* 0b	[6] */
#define R153_IRQ1_ASRCO_UNLOCKED_IC_1_Sigma       0x0    /* 0b	[7] */
#define R153_IRQ1_PLL_LOCKED_IC_1_Sigma_MASK      0x1
#define R153_IRQ1_PLL_LOCKED_IC_1_Sigma_SHIFT     0
#define R153_IRQ1_PLL_UNLOCKED_IC_1_Sigma_MASK    0x2
#define R153_IRQ1_PLL_UNLOCKED_IC_1_Sigma_SHIFT   1
#define R153_IRQ1_AVDD_UVW_IC_1_Sigma_MASK        0x4
#define R153_IRQ1_AVDD_UVW_IC_1_Sigma_SHIFT       2
#define R153_IRQ1_PRAMP_IC_1_Sigma_MASK           0x8
#define R153_IRQ1_PRAMP_IC_1_Sigma_SHIFT          3
#define R153_IRQ1_ASRCI_LOCKED_IC_1_Sigma_MASK    0x10
#define R153_IRQ1_ASRCI_LOCKED_IC_1_Sigma_SHIFT   4
#define R153_IRQ1_ASRCI_UNLOCKED_IC_1_Sigma_MASK  0x20
#define R153_IRQ1_ASRCI_UNLOCKED_IC_1_Sigma_SHIFT 5
#define R153_IRQ1_ASRCO_LOCKED_IC_1_Sigma_MASK    0x40
#define R153_IRQ1_ASRCO_LOCKED_IC_1_Sigma_SHIFT   6
#define R153_IRQ1_ASRCO_UNLOCKED_IC_1_Sigma_MASK  0x80
#define R153_IRQ1_ASRCO_UNLOCKED_IC_1_Sigma_SHIFT 7

/* IRQ1_STATUS3 (IC 1_Sigma) */
#define R154_IRQ1_SDSP0_IC_1_Sigma                0x0    /* 0b	[0] */
#define R154_IRQ1_SDSP1_IC_1_Sigma                0x0    /* 0b	[1] */
#define R154_IRQ1_SDSP2_IC_1_Sigma                0x0    /* 0b	[2] */
#define R154_IRQ1_SDSP3_IC_1_Sigma                0x0    /* 0b	[3] */
#define R154_IRQ1_POWER_UP_COMPLETE_IC_1_Sigma    0x0    /* 0b	[4] */
#define R154_IRQ1_SDSP0_IC_1_Sigma_MASK           0x1
#define R154_IRQ1_SDSP0_IC_1_Sigma_SHIFT          0
#define R154_IRQ1_SDSP1_IC_1_Sigma_MASK           0x2
#define R154_IRQ1_SDSP1_IC_1_Sigma_SHIFT          1
#define R154_IRQ1_SDSP2_IC_1_Sigma_MASK           0x4
#define R154_IRQ1_SDSP2_IC_1_Sigma_SHIFT          2
#define R154_IRQ1_SDSP3_IC_1_Sigma_MASK           0x8
#define R154_IRQ1_SDSP3_IC_1_Sigma_SHIFT          3
#define R154_IRQ1_POWER_UP_COMPLETE_IC_1_Sigma_MASK 0x10
#define R154_IRQ1_POWER_UP_COMPLETE_IC_1_Sigma_SHIFT 4

/* IRQ2_STATUS1 (IC 1_Sigma) */
#define R155_IRQ2_DAC0_CLIP_IC_1_Sigma            0x0    /* 0b	[0] */
#define R155_IRQ2_DAC1_CLIP_IC_1_Sigma            0x0    /* 0b	[1] */
#define R155_IRQ2_ADC0_CLIP_IC_1_Sigma            0x0    /* 0b	[4] */
#define R155_IRQ2_ADC1_CLIP_IC_1_Sigma            0x0    /* 0b	[5] */
#define R155_IRQ2_ADC2_CLIP_IC_1_Sigma            0x0    /* 0b	[6] */
#define R155_IRQ2_ADC3_CLIP_IC_1_Sigma            0x0    /* 0b	[7] */
#define R155_IRQ2_DAC0_CLIP_IC_1_Sigma_MASK       0x1
#define R155_IRQ2_DAC0_CLIP_IC_1_Sigma_SHIFT      0
#define R155_IRQ2_DAC1_CLIP_IC_1_Sigma_MASK       0x2
#define R155_IRQ2_DAC1_CLIP_IC_1_Sigma_SHIFT      1
#define R155_IRQ2_ADC0_CLIP_IC_1_Sigma_MASK       0x10
#define R155_IRQ2_ADC0_CLIP_IC_1_Sigma_SHIFT      4
#define R155_IRQ2_ADC1_CLIP_IC_1_Sigma_MASK       0x20
#define R155_IRQ2_ADC1_CLIP_IC_1_Sigma_SHIFT      5
#define R155_IRQ2_ADC2_CLIP_IC_1_Sigma_MASK       0x40
#define R155_IRQ2_ADC2_CLIP_IC_1_Sigma_SHIFT      6
#define R155_IRQ2_ADC3_CLIP_IC_1_Sigma_MASK       0x80
#define R155_IRQ2_ADC3_CLIP_IC_1_Sigma_SHIFT      7

/* IRQ2_STATUS2 (IC 1_Sigma) */
#define R156_IRQ2_PLL_LOCKED_IC_1_Sigma           0x0    /* 0b	[0] */
#define R156_IRQ2_PLL_UNLOCKED_IC_1_Sigma         0x0    /* 0b	[1] */
#define R156_IRQ2_AVDD_UVW_IC_1_Sigma             0x0    /* 0b	[2] */
#define R156_IRQ2_PRAMP_IC_1_Sigma                0x0    /* 0b	[3] */
#define R156_IRQ2_ASRCI_LOCKED_IC_1_Sigma         0x0    /* 0b	[4] */
#define R156_IRQ2_ASRCI_UNLOCKED_IC_1_Sigma       0x0    /* 0b	[5] */
#define R156_IRQ2_ASRCO_LOCKED_IC_1_Sigma         0x0    /* 0b	[6] */
#define R156_IRQ2_ASRCO_UNLOCKED_IC_1_Sigma       0x0    /* 0b	[7] */
#define R156_IRQ2_PLL_LOCKED_IC_1_Sigma_MASK      0x1
#define R156_IRQ2_PLL_LOCKED_IC_1_Sigma_SHIFT     0
#define R156_IRQ2_PLL_UNLOCKED_IC_1_Sigma_MASK    0x2
#define R156_IRQ2_PLL_UNLOCKED_IC_1_Sigma_SHIFT   1
#define R156_IRQ2_AVDD_UVW_IC_1_Sigma_MASK        0x4
#define R156_IRQ2_AVDD_UVW_IC_1_Sigma_SHIFT       2
#define R156_IRQ2_PRAMP_IC_1_Sigma_MASK           0x8
#define R156_IRQ2_PRAMP_IC_1_Sigma_SHIFT          3
#define R156_IRQ2_ASRCI_LOCKED_IC_1_Sigma_MASK    0x10
#define R156_IRQ2_ASRCI_LOCKED_IC_1_Sigma_SHIFT   4
#define R156_IRQ2_ASRCI_UNLOCKED_IC_1_Sigma_MASK  0x20
#define R156_IRQ2_ASRCI_UNLOCKED_IC_1_Sigma_SHIFT 5
#define R156_IRQ2_ASRCO_LOCKED_IC_1_Sigma_MASK    0x40
#define R156_IRQ2_ASRCO_LOCKED_IC_1_Sigma_SHIFT   6
#define R156_IRQ2_ASRCO_UNLOCKED_IC_1_Sigma_MASK  0x80
#define R156_IRQ2_ASRCO_UNLOCKED_IC_1_Sigma_SHIFT 7

/* IRQ2_STATUS3 (IC 1_Sigma) */
#define R157_IRQ2_SDSP0_IC_1_Sigma                0x0    /* 0b	[0] */
#define R157_IRQ2_SDSP1_IC_1_Sigma                0x0    /* 0b	[1] */
#define R157_IRQ2_SDSP2_IC_1_Sigma                0x0    /* 0b	[2] */
#define R157_IRQ2_SDSP3_IC_1_Sigma                0x0    /* 0b	[3] */
#define R157_IRQ2_POWER_UP_COMPLETE_IC_1_Sigma    0x0    /* 0b	[4] */
#define R157_IRQ2_SDSP0_IC_1_Sigma_MASK           0x1
#define R157_IRQ2_SDSP0_IC_1_Sigma_SHIFT          0
#define R157_IRQ2_SDSP1_IC_1_Sigma_MASK           0x2
#define R157_IRQ2_SDSP1_IC_1_Sigma_SHIFT          1
#define R157_IRQ2_SDSP2_IC_1_Sigma_MASK           0x4
#define R157_IRQ2_SDSP2_IC_1_Sigma_SHIFT          2
#define R157_IRQ2_SDSP3_IC_1_Sigma_MASK           0x8
#define R157_IRQ2_SDSP3_IC_1_Sigma_SHIFT          3
#define R157_IRQ2_POWER_UP_COMPLETE_IC_1_Sigma_MASK 0x10
#define R157_IRQ2_POWER_UP_COMPLETE_IC_1_Sigma_SHIFT 4

/* SPT0_CTRL1 (IC 1_Sigma) */
#define R158_SPT0_SAI_MODE_IC_1_Sigma             0x0    /* 0b	[0] */
#define R158_SPT0_DATA_FORMAT_IC_1_Sigma          0x0    /* 000b	[3:1] */
#define R158_SPT0_SLOT_WIDTH_IC_1_Sigma           0x2    /* 10b	[5:4] */
#define R158_SPT0_TRI_STATE_IC_1_Sigma            0x0    /* 0b	[6] */
#define R158_SPT0_SAI_MODE_IC_1_Sigma_MASK        0x1
#define R158_SPT0_SAI_MODE_IC_1_Sigma_SHIFT       0
#define R158_SPT0_DATA_FORMAT_IC_1_Sigma_MASK     0xE
#define R158_SPT0_DATA_FORMAT_IC_1_Sigma_SHIFT    1
#define R158_SPT0_SLOT_WIDTH_IC_1_Sigma_MASK      0x30
#define R158_SPT0_SLOT_WIDTH_IC_1_Sigma_SHIFT     4
#define R158_SPT0_TRI_STATE_IC_1_Sigma_MASK       0x40
#define R158_SPT0_TRI_STATE_IC_1_Sigma_SHIFT      6

/* SPT0_CTRL2 (IC 1_Sigma) */
#define R159_SPT0_BCLK_SRC_IC_1_Sigma             0x0    /* 000b	[2:0] */
#define R159_SPT0_BCLK_POL_IC_1_Sigma             0x0    /* 0b	[3] */
#define R159_SPT0_LRCLK_SRC_IC_1_Sigma            0x0    /* 000b	[6:4] */
#define R159_SPT0_LRCLK_POL_IC_1_Sigma            0x0    /* 0b	[7] */
#define R159_SPT0_BCLK_SRC_IC_1_Sigma_MASK        0x7
#define R159_SPT0_BCLK_SRC_IC_1_Sigma_SHIFT       0
#define R159_SPT0_BCLK_POL_IC_1_Sigma_MASK        0x8
#define R159_SPT0_BCLK_POL_IC_1_Sigma_SHIFT       3
#define R159_SPT0_LRCLK_SRC_IC_1_Sigma_MASK       0x70
#define R159_SPT0_LRCLK_SRC_IC_1_Sigma_SHIFT      4
#define R159_SPT0_LRCLK_POL_IC_1_Sigma_MASK       0x80
#define R159_SPT0_LRCLK_POL_IC_1_Sigma_SHIFT      7

/* SPT0_ROUTE0 (IC 1_Sigma) */
#define R160_SPT0_OUT_ROUTE0_IC_1_Sigma           0x26   /* 100110b	[5:0] */
#define R160_SPT0_OUT_ROUTE0_IC_1_Sigma_MASK      0x3F
#define R160_SPT0_OUT_ROUTE0_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE1 (IC 1_Sigma) */
#define R161_SPT0_OUT_ROUTE1_IC_1_Sigma           0x27   /* 100111b	[5:0] */
#define R161_SPT0_OUT_ROUTE1_IC_1_Sigma_MASK      0x3F
#define R161_SPT0_OUT_ROUTE1_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE2 (IC 1_Sigma) */
#define R162_SPT0_OUT_ROUTE2_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R162_SPT0_OUT_ROUTE2_IC_1_Sigma_MASK      0x3F
#define R162_SPT0_OUT_ROUTE2_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE3 (IC 1_Sigma) */
#define R163_SPT0_OUT_ROUTE3_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R163_SPT0_OUT_ROUTE3_IC_1_Sigma_MASK      0x3F
#define R163_SPT0_OUT_ROUTE3_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE4 (IC 1_Sigma) */
#define R164_SPT0_OUT_ROUTE4_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R164_SPT0_OUT_ROUTE4_IC_1_Sigma_MASK      0x3F
#define R164_SPT0_OUT_ROUTE4_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE5 (IC 1_Sigma) */
#define R165_SPT0_OUT_ROUTE5_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R165_SPT0_OUT_ROUTE5_IC_1_Sigma_MASK      0x3F
#define R165_SPT0_OUT_ROUTE5_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE6 (IC 1_Sigma) */
#define R166_SPT0_OUT_ROUTE6_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R166_SPT0_OUT_ROUTE6_IC_1_Sigma_MASK      0x3F
#define R166_SPT0_OUT_ROUTE6_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE7 (IC 1_Sigma) */
#define R167_SPT0_OUT_ROUTE7_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R167_SPT0_OUT_ROUTE7_IC_1_Sigma_MASK      0x3F
#define R167_SPT0_OUT_ROUTE7_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE8 (IC 1_Sigma) */
#define R168_SPT0_OUT_ROUTE8_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R168_SPT0_OUT_ROUTE8_IC_1_Sigma_MASK      0x3F
#define R168_SPT0_OUT_ROUTE8_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE9 (IC 1_Sigma) */
#define R169_SPT0_OUT_ROUTE9_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R169_SPT0_OUT_ROUTE9_IC_1_Sigma_MASK      0x3F
#define R169_SPT0_OUT_ROUTE9_IC_1_Sigma_SHIFT     0

/* SPT0_ROUTE10 (IC 1_Sigma) */
#define R170_SPT0_OUT_ROUTE10_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R170_SPT0_OUT_ROUTE10_IC_1_Sigma_MASK     0x3F
#define R170_SPT0_OUT_ROUTE10_IC_1_Sigma_SHIFT    0

/* SPT0_ROUTE11 (IC 1_Sigma) */
#define R171_SPT0_OUT_ROUTE11_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R171_SPT0_OUT_ROUTE11_IC_1_Sigma_MASK     0x3F
#define R171_SPT0_OUT_ROUTE11_IC_1_Sigma_SHIFT    0

/* SPT0_ROUTE12 (IC 1_Sigma) */
#define R172_SPT0_OUT_ROUTE12_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R172_SPT0_OUT_ROUTE12_IC_1_Sigma_MASK     0x3F
#define R172_SPT0_OUT_ROUTE12_IC_1_Sigma_SHIFT    0

/* SPT0_ROUTE13 (IC 1_Sigma) */
#define R173_SPT0_OUT_ROUTE13_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R173_SPT0_OUT_ROUTE13_IC_1_Sigma_MASK     0x3F
#define R173_SPT0_OUT_ROUTE13_IC_1_Sigma_SHIFT    0

/* SPT0_ROUTE14 (IC 1_Sigma) */
#define R174_SPT0_OUT_ROUTE14_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R174_SPT0_OUT_ROUTE14_IC_1_Sigma_MASK     0x3F
#define R174_SPT0_OUT_ROUTE14_IC_1_Sigma_SHIFT    0

/* SPT0_ROUTE15 (IC 1_Sigma) */
#define R175_SPT0_OUT_ROUTE15_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R175_SPT0_OUT_ROUTE15_IC_1_Sigma_MASK     0x3F
#define R175_SPT0_OUT_ROUTE15_IC_1_Sigma_SHIFT    0

/* SPT1_CTRL1 (IC 1_Sigma) */
#define R176_SPT1_SAI_MODE_IC_1_Sigma             0x0    /* 0b	[0] */
#define R176_SPT1_DATA_FORMAT_IC_1_Sigma          0x0    /* 000b	[3:1] */
#define R176_SPT1_SLOT_WIDTH_IC_1_Sigma           0x2    /* 10b	[5:4] */
#define R176_SPT1_TRI_STATE_IC_1_Sigma            0x0    /* 0b	[6] */
#define R176_SPT1_SAI_MODE_IC_1_Sigma_MASK        0x1
#define R176_SPT1_SAI_MODE_IC_1_Sigma_SHIFT       0
#define R176_SPT1_DATA_FORMAT_IC_1_Sigma_MASK     0xE
#define R176_SPT1_DATA_FORMAT_IC_1_Sigma_SHIFT    1
#define R176_SPT1_SLOT_WIDTH_IC_1_Sigma_MASK      0x30
#define R176_SPT1_SLOT_WIDTH_IC_1_Sigma_SHIFT     4
#define R176_SPT1_TRI_STATE_IC_1_Sigma_MASK       0x40
#define R176_SPT1_TRI_STATE_IC_1_Sigma_SHIFT      6

/* SPT1_CTRL2 (IC 1_Sigma) */
#define R177_SPT1_BCLK_SRC_IC_1_Sigma             0x0    /* 000b	[2:0] */
#define R177_SPT1_BCLK_POL_IC_1_Sigma             0x0    /* 0b	[3] */
#define R177_SPT1_LRCLK_SRC_IC_1_Sigma            0x0    /* 000b	[6:4] */
#define R177_SPT1_LRCLK_POL_IC_1_Sigma            0x0    /* 0b	[7] */
#define R177_SPT1_BCLK_SRC_IC_1_Sigma_MASK        0x7
#define R177_SPT1_BCLK_SRC_IC_1_Sigma_SHIFT       0
#define R177_SPT1_BCLK_POL_IC_1_Sigma_MASK        0x8
#define R177_SPT1_BCLK_POL_IC_1_Sigma_SHIFT       3
#define R177_SPT1_LRCLK_SRC_IC_1_Sigma_MASK       0x70
#define R177_SPT1_LRCLK_SRC_IC_1_Sigma_SHIFT      4
#define R177_SPT1_LRCLK_POL_IC_1_Sigma_MASK       0x80
#define R177_SPT1_LRCLK_POL_IC_1_Sigma_SHIFT      7

/* SPT1_ROUTE0 (IC 1_Sigma) */
#define R178_SPT1_OUT_ROUTE0_IC_1_Sigma           0x10   /* 010000b	[5:0] */
#define R178_SPT1_OUT_ROUTE0_IC_1_Sigma_MASK      0x3F
#define R178_SPT1_OUT_ROUTE0_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE1 (IC 1_Sigma) */
#define R179_SPT1_OUT_ROUTE1_IC_1_Sigma           0x11   /* 010001b	[5:0] */
#define R179_SPT1_OUT_ROUTE1_IC_1_Sigma_MASK      0x3F
#define R179_SPT1_OUT_ROUTE1_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE2 (IC 1_Sigma) */
#define R180_SPT1_OUT_ROUTE2_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R180_SPT1_OUT_ROUTE2_IC_1_Sigma_MASK      0x3F
#define R180_SPT1_OUT_ROUTE2_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE3 (IC 1_Sigma) */
#define R181_SPT1_OUT_ROUTE3_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R181_SPT1_OUT_ROUTE3_IC_1_Sigma_MASK      0x3F
#define R181_SPT1_OUT_ROUTE3_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE4 (IC 1_Sigma) */
#define R182_SPT1_OUT_ROUTE4_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R182_SPT1_OUT_ROUTE4_IC_1_Sigma_MASK      0x3F
#define R182_SPT1_OUT_ROUTE4_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE5 (IC 1_Sigma) */
#define R183_SPT1_OUT_ROUTE5_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R183_SPT1_OUT_ROUTE5_IC_1_Sigma_MASK      0x3F
#define R183_SPT1_OUT_ROUTE5_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE6 (IC 1_Sigma) */
#define R184_SPT1_OUT_ROUTE6_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R184_SPT1_OUT_ROUTE6_IC_1_Sigma_MASK      0x3F
#define R184_SPT1_OUT_ROUTE6_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE7 (IC 1_Sigma) */
#define R185_SPT1_OUT_ROUTE7_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R185_SPT1_OUT_ROUTE7_IC_1_Sigma_MASK      0x3F
#define R185_SPT1_OUT_ROUTE7_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE8 (IC 1_Sigma) */
#define R186_SPT1_OUT_ROUTE8_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R186_SPT1_OUT_ROUTE8_IC_1_Sigma_MASK      0x3F
#define R186_SPT1_OUT_ROUTE8_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE9 (IC 1_Sigma) */
#define R187_SPT1_OUT_ROUTE9_IC_1_Sigma           0x3F   /* 111111b	[5:0] */
#define R187_SPT1_OUT_ROUTE9_IC_1_Sigma_MASK      0x3F
#define R187_SPT1_OUT_ROUTE9_IC_1_Sigma_SHIFT     0

/* SPT1_ROUTE10 (IC 1_Sigma) */
#define R188_SPT1_OUT_ROUTE10_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R188_SPT1_OUT_ROUTE10_IC_1_Sigma_MASK     0x3F
#define R188_SPT1_OUT_ROUTE10_IC_1_Sigma_SHIFT    0

/* SPT1_ROUTE11 (IC 1_Sigma) */
#define R189_SPT1_OUT_ROUTE11_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R189_SPT1_OUT_ROUTE11_IC_1_Sigma_MASK     0x3F
#define R189_SPT1_OUT_ROUTE11_IC_1_Sigma_SHIFT    0

/* SPT1_ROUTE12 (IC 1_Sigma) */
#define R190_SPT1_OUT_ROUTE12_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R190_SPT1_OUT_ROUTE12_IC_1_Sigma_MASK     0x3F
#define R190_SPT1_OUT_ROUTE12_IC_1_Sigma_SHIFT    0

/* SPT1_ROUTE13 (IC 1_Sigma) */
#define R191_SPT1_OUT_ROUTE13_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R191_SPT1_OUT_ROUTE13_IC_1_Sigma_MASK     0x3F
#define R191_SPT1_OUT_ROUTE13_IC_1_Sigma_SHIFT    0

/* SPT1_ROUTE14 (IC 1_Sigma) */
#define R192_SPT1_OUT_ROUTE14_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R192_SPT1_OUT_ROUTE14_IC_1_Sigma_MASK     0x3F
#define R192_SPT1_OUT_ROUTE14_IC_1_Sigma_SHIFT    0

/* SPT1_ROUTE15 (IC 1_Sigma) */
#define R193_SPT1_OUT_ROUTE15_IC_1_Sigma          0x3F   /* 111111b	[5:0] */
#define R193_SPT1_OUT_ROUTE15_IC_1_Sigma_MASK     0x3F
#define R193_SPT1_OUT_ROUTE15_IC_1_Sigma_SHIFT    0

/* MP_CTRL10 (IC 1_Sigma) */
#define R194_MP12_MODE_IC_1_Sigma                 0x0    /* 0000b	[3:0] */
#define R194_MP12_MODE_IC_1_Sigma_MASK            0xF
#define R194_MP12_MODE_IC_1_Sigma_SHIFT           0

/* SELFBOOT_CTRL (IC 1_Sigma) */
#define R195_SELFBOOT_DRIVE_IC_1_Sigma            0x1    /* 01b	[1:0] */
#define R195_SELFBOOT_IS_IC_1_Sigma               0x0    /* 0b	[2] */
#define R195_SELFBOOT_PULL_EN_IC_1_Sigma          0x0    /* 0b	[4] */
#define R195_SELFBOOT_PULL_SEL_IC_1_Sigma         0x0    /* 0b	[5] */
#define R195_SELFBOOT_SLEW_IC_1_Sigma             0x1    /* 1b	[6] */
#define R195_SELFBOOT_DRIVE_IC_1_Sigma_MASK       0x3
#define R195_SELFBOOT_DRIVE_IC_1_Sigma_SHIFT      0
#define R195_SELFBOOT_IS_IC_1_Sigma_MASK          0x4
#define R195_SELFBOOT_IS_IC_1_Sigma_SHIFT         2
#define R195_SELFBOOT_PULL_EN_IC_1_Sigma_MASK     0x10
#define R195_SELFBOOT_PULL_EN_IC_1_Sigma_SHIFT    4
#define R195_SELFBOOT_PULL_SEL_IC_1_Sigma_MASK    0x20
#define R195_SELFBOOT_PULL_SEL_IC_1_Sigma_SHIFT   5
#define R195_SELFBOOT_SLEW_IC_1_Sigma_MASK        0x40
#define R195_SELFBOOT_SLEW_IC_1_Sigma_SHIFT       6

/* SW_EN_CTRL (IC 1_Sigma) */
#define R196_SW_EN_DRIVE_IC_1_Sigma               0x1    /* 01b	[1:0] */
#define R196_SWEN_IS_IC_1_Sigma                   0x0    /* 0b	[2] */
#define R196_SW_PULL_EN_IC_1_Sigma                0x0    /* 0b	[4] */
#define R196_SW_PULL_SEL_IC_1_Sigma               0x0    /* 0b	[5] */
#define R196_SW_SLEW_IC_1_Sigma                   0x1    /* 1b	[6] */
#define R196_SW_EN_DRIVE_IC_1_Sigma_MASK          0x3
#define R196_SW_EN_DRIVE_IC_1_Sigma_SHIFT         0
#define R196_SWEN_IS_IC_1_Sigma_MASK              0x4
#define R196_SWEN_IS_IC_1_Sigma_SHIFT             2
#define R196_SW_PULL_EN_IC_1_Sigma_MASK           0x10
#define R196_SW_PULL_EN_IC_1_Sigma_SHIFT          4
#define R196_SW_PULL_SEL_IC_1_Sigma_MASK          0x20
#define R196_SW_PULL_SEL_IC_1_Sigma_SHIFT         5
#define R196_SW_SLEW_IC_1_Sigma_MASK              0x40
#define R196_SW_SLEW_IC_1_Sigma_SHIFT             6

/* PDM_CTRL1 (IC 1_Sigma) */
#define R197_PDM_FS_IC_1_Sigma                    0x2    /* 010b	[2:0] */
#define R197_PDM_FCOMP_IC_1_Sigma                 0x0    /* 0b	[3] */
#define R197_PDM_RATE_IC_1_Sigma                  0x0    /* 0b	[4] */
#define R197_PDM_MORE_FILT_IC_1_Sigma             0x0    /* 0b	[7] */
#define R197_PDM_FS_IC_1_Sigma_MASK               0x7
#define R197_PDM_FS_IC_1_Sigma_SHIFT              0
#define R197_PDM_FCOMP_IC_1_Sigma_MASK            0x8
#define R197_PDM_FCOMP_IC_1_Sigma_SHIFT           3
#define R197_PDM_RATE_IC_1_Sigma_MASK             0x10
#define R197_PDM_RATE_IC_1_Sigma_SHIFT            4
#define R197_PDM_MORE_FILT_IC_1_Sigma_MASK        0x80
#define R197_PDM_MORE_FILT_IC_1_Sigma_SHIFT       7

/* PDM_CTRL2 (IC 1_Sigma) */
#define R198_PDM_VOL_LINK_IC_1_Sigma              0x0    /* 0b	[0] */
#define R198_PDM_HARD_VOL_IC_1_Sigma              0x0    /* 0b	[1] */
#define R198_PDM_VOL_ZC_IC_1_Sigma                0x1    /* 1b	[2] */
#define R198_PDM0_HPF_EN_IC_1_Sigma               0x0    /* 0b	[4] */
#define R198_PDM1_HPF_EN_IC_1_Sigma               0x0    /* 0b	[5] */
#define R198_PDM0_MUTE_IC_1_Sigma                 0x1    /* 1b	[6] */
#define R198_PDM1_MUTE_IC_1_Sigma                 0x1    /* 1b	[7] */
#define R198_PDM_VOL_LINK_IC_1_Sigma_MASK         0x1
#define R198_PDM_VOL_LINK_IC_1_Sigma_SHIFT        0
#define R198_PDM_HARD_VOL_IC_1_Sigma_MASK         0x2
#define R198_PDM_HARD_VOL_IC_1_Sigma_SHIFT        1
#define R198_PDM_VOL_ZC_IC_1_Sigma_MASK           0x4
#define R198_PDM_VOL_ZC_IC_1_Sigma_SHIFT          2
#define R198_PDM0_HPF_EN_IC_1_Sigma_MASK          0x10
#define R198_PDM0_HPF_EN_IC_1_Sigma_SHIFT         4
#define R198_PDM1_HPF_EN_IC_1_Sigma_MASK          0x20
#define R198_PDM1_HPF_EN_IC_1_Sigma_SHIFT         5
#define R198_PDM0_MUTE_IC_1_Sigma_MASK            0x40
#define R198_PDM0_MUTE_IC_1_Sigma_SHIFT           6
#define R198_PDM1_MUTE_IC_1_Sigma_MASK            0x80
#define R198_PDM1_MUTE_IC_1_Sigma_SHIFT           7

/* PDM_VOL0 (IC 1_Sigma) */
#define R199_PDM0_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R199_PDM0_VOL_IC_1_Sigma_MASK             0xFF
#define R199_PDM0_VOL_IC_1_Sigma_SHIFT            0

/* PDM_VOL1 (IC 1_Sigma) */
#define R200_PDM1_VOL_IC_1_Sigma                  0x40   /* 01000000b	[7:0] */
#define R200_PDM1_VOL_IC_1_Sigma_MASK             0xFF
#define R200_PDM1_VOL_IC_1_Sigma_SHIFT            0

/* PDM_ROUTE0 (IC 1_Sigma) */
#define R201_PDM0_ROUTE_IC_1_Sigma                0x0    /* 0000000b	[6:0] */
#define R201_PDM0_ROUTE_IC_1_Sigma_MASK           0x7F
#define R201_PDM0_ROUTE_IC_1_Sigma_SHIFT          0

/* PDM_ROUTE1 (IC 1_Sigma) */
#define R202_PDM1_ROUTE_IC_1_Sigma                0x1    /* 0000001b	[6:0] */
#define R202_PDM1_ROUTE_IC_1_Sigma_MASK           0x7F
#define R202_PDM1_ROUTE_IC_1_Sigma_SHIFT          0

/* PLLCalculator (IC 1_Sigma) */
#define R203_PLLCALC_IC_1_Sigma                   0x189374BC /* 0011000100100110111010010111100b	[30:0] */
#define R203_PLLCALC_IC_1_Sigma_MASK              0x7FFFFFFF
#define R203_PLLCALC_IC_1_Sigma_SHIFT             0

#endif
