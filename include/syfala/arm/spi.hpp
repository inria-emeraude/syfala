#pragma once

namespace Syfala::SPI {

using byte_t = unsigned char;

struct data {
    byte_t rw[3];
    unsigned short values[8];
    unsigned short change[8];
};

extern void reset(data& d);
extern void poll(data& d);
extern void initialize(data& d);

}
