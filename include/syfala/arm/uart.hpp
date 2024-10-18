#pragma once

#include <syfala/utilities.hpp>
#include <memory>
#include <atomic>

namespace Syfala::ARM::UART {

struct Message {
      int index = 0;
    float value = 0.f;
};

struct data {
    byte_t buffer[16];
    std::atomic<int> nbytes = {0};
};

/**
 *  Initialize the UART driver so that it's ready to use.
  * Look up the configuration in the config table and then initialize it.
  */
extern void initialize(data& d);

/**
 * @brief Poll an UART::Message
 */
extern Result<UART::Message> poll(data& d);

/**
 * @brief Send an UART::Message
 */
extern void send(data& d, UART::Message& m);

}
