#pragma once

#include <algorithm>
#include <cstdint>
#include <syfala/config_arm.hpp>
#include <limits>

namespace Syfala::SPI {

// Select SPI slave (value verified with oscilloscope)
#define SS0_SPI_SELECT      0x00
#define SPI_NCONTROLS_MAX   128

using byte_t = unsigned char;

// Note: Ideally, this would be handled in config_arm.hpp
enum class Controller {
    PCB, Teensy
};

static constexpr SPI::Controller controller() {
#if (SYFALA_CONTROLLER_TYPE == TEENSY)
    return SPI::Controller::Teensy;
#else
    return SPI::Controller::PCB;
#endif
}

/**
 * @brief Returns the number of available controls for the
 * current Hardware controller.
 * @return 8 for Syfala PCB controllers, SPI_NCONTROLS_MAX for the
 * Teensy controller.
 */
static constexpr int capacity() {
    if constexpr (controller() == SPI::Controller::PCB) {
        return 8;
    } else {
        return SPI_NCONTROLS_MAX;
    }
}

struct data {
    byte_t rw[64];
     float values[SPI_NCONTROLS_MAX];
       int change[SPI_NCONTROLS_MAX];
       int ncontrols = 0;
};

extern void reset(data& d);
extern void poll(data& d);
extern void initialize(data& d, int ncontrols);
extern void slow_transfer(data& d, int nbytes);

/**
 * Awesome SPI-Teensy-based controller
 * TODO: documentation on the controller itself
 */
namespace Teensy {
extern void initialize(const char* label,
                               int channel,
                             float cinit,
                             float cmin,
                             float cmax,
                             float cstep
);

extern float read(SPI::data& d, int channel);

}

}
