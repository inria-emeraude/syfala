#pragma once

#include <stdio.h>
#include <cstdint>

#ifdef __linux__
    #include <unistd.h>
#else
    #include <sleep.h>
#endif


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

namespace Syfala::ADAU17xx {

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
namespace Syfala::ADAU1761 {
    extern int initialize(int bus, unsigned long codec_addr);
}

namespace Syfala::ADAU1777 {
    extern int initialize(int bus, unsigned long codec_addr);
}

namespace Syfala::ADAU1787 {
    extern int boot_sequence(int bus, unsigned long codec_addr);
    extern int initialize(int bus, unsigned long codec_addr);
}
