#pragma once

#include <syfala/utilities.hpp>
#include <memory>
#include <atomic>

namespace Syfala::UART {

#define UART_RW_BUFFER_LEN 1024U

struct Message { int index = 0; float value = 0.f; };

struct data {
    byte_t buffer[UART_RW_BUFFER_LEN];
    int r = 0;
    int w = 0;
};

/** Initialize the UART driver so that it's ready to use
  * Look up the configuration in the config table and then initialize it. */
extern void initialize(data& d);
extern void send(data& d, UART::Message& m);
extern Result<UART::Message> poll(data& d);
}
