#pragma once

#include <syfala/config.hpp>

#ifdef __linux__
    #include <unistd.h>
#else
    #include <sleep.h>
#endif

namespace SSM2603 {

   /**
    * @brief regwrite SSM2603 codec register write function
    * (implementation is platform-dependent, either located in
    * baremetal/audio.cpp or in linux/audio.cpp)
    */
    extern int
    regwrite(int bus, unsigned int addr, unsigned int data);

    inline void
    initialize(int bus) {
        /* Write to the SSM2603 audio codec registers to configure the device. Refer to the
         * SSM2603 Audio Codec data sheet for information on what these writes do. */
        SSM2603::regwrite(bus, 15, 0b000000000);
        usleep(75000);
        SSM2603::regwrite(bus, 6, 0b010011111);
        SSM2603::regwrite(bus, 0, 0b000010111);
        SSM2603::regwrite(bus, 1, 0b000010111);
        SSM2603::regwrite(bus, 2, SYFALA_SSM_VOLUME);
        SSM2603::regwrite(bus, 3, SYFALA_SSM_VOLUME);
        SSM2603::regwrite(bus, 4, 0b000010010);
        SSM2603::regwrite(bus, 5, 0b000000000);
        SSM2603::regwrite(bus, 7, SSM_R07);
        SSM2603::regwrite(bus, 8, SSM_R08);
        usleep(75000);
        SSM2603::regwrite(bus, 9, 0b000000001);
        SSM2603::regwrite(bus, 6, 0b000100000);
    }
}
