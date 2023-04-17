#pragma once

#include <stdio.h>

#ifdef __linux__
    #include <unistd.h>
#else
    #include <sleep.h>
#endif

namespace ADAU17xx {

#define IIC_ADAU1761_SLAVE_ADDR_0   0x3B

#define IIC_ADAU1777_SLAVE_ADDR_0   0x3C
#define IIC_ADAU1777_SLAVE_ADDR_1   0x3D
#define IIC_ADAU1777_SLAVE_ADDR_2   0x3E
#define IIC_ADAU1777_SLAVE_ADDR_3   0x3F

#define MAX_EXTERNAL_1787           4
#define IIC_ADAU1787_SLAVE_ADDR_0   0x28

/**
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

#include "ADAU1787Reg.h"
namespace ADAU1787 {
    inline int boot_sequence(int bus, unsigned long codec_addr) {
        if (!ADAU17xx::regwrite(bus, codec_addr, REG_CHIP_PWR_IC_1_Sigma_ADDR, 0x11, 0)) {
            printf("[ADAU1787] Could not initialize ADAU1787 boot sequence");
            return 0;
        }
        usleep(40000);
        if (!ADAU17xx::regwrite(bus, codec_addr, REG_CHIP_PWR_IC_1_Sigma_ADDR, 0x15, 0)) {
            printf("[ADAU1787] Could not initialize ADAU1787 boot sequence");
            return 0;
        }
        usleep(40000);
        if (!ADAU17xx::regwrite(bus, codec_addr, REG_CHIP_PWR_IC_1_Sigma_ADDR, 0x17, 0)) {
            printf("[ADAU1787] Could not initialize ADAU1787 boot sequence");
            return 0;
        }
        return 1;
    }
    extern int initialize(int bus, unsigned long codec_addr);
}
