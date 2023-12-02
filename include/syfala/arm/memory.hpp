#pragma once

#include <syfala/arm/ip.hpp>

namespace Syfala::Memory {

struct data {
    int*    i_zone;
    float*  f_zone;
};

extern void initialize(XSyfala& x, data& d, int ilen, int flen);

}
