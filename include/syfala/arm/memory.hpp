#pragma once

#include <syfala/arm/ip.hpp>

namespace Syfala::Memory {

struct data {
    int*    i_zone;
    float*  f_zone;
};

/**
 * @brief Initializes the shared memory (DDR by default) between
 * the Syfala DSP IP and the ARM Host control application.
 * @param ilen The length of the 'integer' memory zone (in number of i32 values, not in bytes),
 * @param flen The length of the 'float' memory zone (in number of f32 values, not in bytes).
 */
extern void initialize(XSyfala& x, data& d, int ilen, int flen);

}
