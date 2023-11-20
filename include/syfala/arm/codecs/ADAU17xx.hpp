#pragma once

#include <stdio.h>
#include <cstdint>

#ifdef __linux__
    #include <unistd.h>
#else
    #include <sleep.h>
#endif

namespace ADAU17xx {

#define IIC_ADAU1761_SLAVE_ADDR_0   0x3B

#define IIC_ADAU1761_BUS 0
#define IIC_ADAU1777_BUS 1


//IIC addresses of the ADAU1777 audio controller
#define IIC_ADAU1777_SLAVE_ADDR_0			0x3C
#define IIC_ADAU1777_SLAVE_ADDR_1			0x3D
#define IIC_ADAU1777_SLAVE_ADDR_2			0x3E
#define IIC_ADAU1777_SLAVE_ADDR_3			0x3F

//IIC addresses of the ADAU1787 audio controller
#define IIC_ADAU1787_SLAVE_ADDR_0			0x28
#define IIC_ADAU1787_SLAVE_ADDR_1			0x29
#define IIC_ADAU1787_SLAVE_ADDR_2			0x2A
#define IIC_ADAU1787_SLAVE_ADDR_3			0x2B

#define IIC_MOTHERBOARD_BUS 1

//Mux
#define IIC_MOTHERBOARD_TCA9548A_ADDR_CUSTOM_1    0x75
#define IIC_MOTHERBOARD_TCA9548A_ADDR_DEFAULT     0x70 // Default

#define IIC_MOTHERBOARD_TCA9548A_ADDR IIC_MOTHERBOARD_TCA9548A_ADDR_DEFAULT
#define IIC_MOTHERBOARD_TCA9548A_BUS IIC_MOTHERBOARD_BUS

//Led driver
// WARNING: because of the Vcc error on the motherboard (the LED driver was wrongly powered with 1.8v), the Vcc pad of the jumpers for the address selection are also wrongly connect to 1.8V (and it's hard to fix)
// For now, don't use the vcc pad!. If you want more addresses, use a resistor between gnd and the middle pad to have a pull down state.
#define IIC_MOTHERBOARD_PCA9956_ADDR_CUSTOM_1    0x0B
#define IIC_MOTHERBOARD_PCA9956_ADDR_DEFAULT     0x3F // Default

#define IIC_MOTHERBOARD_PCA9956_ADDR IIC_MOTHERBOARD_PCA9956_ADDR_DEFAULT
#define IIC_MOTHERBOARD_PCA9956_BUS IIC_MOTHERBOARD_BUS




//PCA9956 registor addresses
#define MODE1 0x00
#define MODE1_SETTING_NO_INCREMENT 0x00
#define AUTO_INCREMENT_BIT 0b10000000
#define MODE1_SETTING_AUTO_INCREMENT_BRIGHTNESS 0b10100000
#define MODE1_SETTING_AUTO_INCREMENT_IREF 0b11000000
#define MODE2 0x01
#define MODE2_OVERTEMPERATURE 0b10000000
#define MODE2_LED_ERROR 0b1000000
#define MODE2_CLEARERROR 0b10000
#define MODE2_DMBLINK_BLINKING 0b100000
#define ERROR_LED0_3 0x41
#define ERROR_LED4_7 0x42
#define ERROR_LED8_11 0x43
#define ERROR_LED12_15 0x44
#define ERROR_LED16_19 0x45
#define ERROR_LED20_23 0x46
#define ERROR_OPEN_CIRCUIT 0b10101010
#define ERROR_SHORT_CIRCUIT 0b01010101
#define PCA9956_I2C_GENERAL_CALL 0x0
#define PCA9956_RESET_ALL 0x6

#define PWM0 0x0A
#define PWMALL 0x3F

#define GRPPWM 0x08
#define GRPFREQ 0x09
#define LEDOUT0 0x02
#define IREF0 0x22

#define LEDMODE_FULLOFF 0x00      //full off
#define LEDMODE_FULLON 0b01010101 //full on
#define LEDMODE_PWM 0b10101010    //control over pwm
#define LEDMODE_GROUP_DIMMING 0b11111111 // pwm + group dimming / blinking

#define PCA9965_NUM_LEDS 24 // Fixed value

#define DIMMING_LEVEL 10 //From 1 (full brightness) to 10 (low) [or less, it's a divider factor...]
/*
 * @brief regwrite ADAU17xx codecs register write function
 * (implementation is platform-dependent, either located in
 * baremetal/audio.cpp or in linux/audio.cpp)
 */
extern int regwrite(int busno, unsigned long codec_addr,
                    unsigned int addr, unsigned int data,
                    unsigned int offset);
}

/**
 * The following initialization functions are implemented in
 * source/arm/codecs, in their auto-generated respective .cpp files:
 */
namespace ADAU1761 {
    extern int initialize(int bus, unsigned long codec_addr);
}

namespace ADAU1777 {
    extern int initialize(int bus, unsigned long codec_addr);
}

namespace ADAU1787 {
    extern int boot_sequence(int bus, unsigned long codec_addr);
    extern int initialize(int bus, unsigned long codec_addr);
}

/*
 * Lib for the TCA9548A I2C mux
 * All these functions are largely inspired by this sparkfun lib:
 * https://github.com/sparkfun/SparkFun_I2C_Mux_Arduino_Library/blob/master/src/SparkFun_I2C_Mux_Arduino_Library.cpp
 */
namespace IICMUX {
    extern int setPort(uint8_t portBits);
    extern uint8_t getPort(void);
    extern int isConnected(void);
}


/*
 * Lib for the PCA9956 LED driver
 * All these functions are largely inspired by this arduino lib:
 * https://github.com/yuskegoto/PCA9956/tree/main
 */
namespace LEDdriver {
    extern int regwrite(uint8_t,uint8_t);
    extern uint8_t regread();
    extern int initialize();
    extern int ledOn(uint8_t LEDNo);
    extern int ledOff(uint8_t LEDNo);
    extern int ledBlink(uint8_t LEDNo);
    extern int setBlink(uint8_t freq);
}


namespace motherBoard {
    extern int initializeUI(void);
    extern void searchIIC(void);
    extern void printADAUTab(uint8_t *);


}
