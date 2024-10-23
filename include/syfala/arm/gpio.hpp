#pragma once

#include <stdint.h>

namespace Syfala::ARM::GPIO {
/**
 * @brief Initialize General Purpose I/Os,
 * including on-board LEDs & switches.
 */
extern void initialize();
/**
 * @brief Reads and returns current value of SW(index)
 */

extern bool read_sw(int index);
/**
 * @brief Reads and returns current value of all buttons
 */
extern uint32_t read_btn(void);

/**
 * @brief Writes 'value' to LD0-LD3
 * @param index 0-3
 * @param value 0 or >0
 */
extern void write_sw_led(int sw0, int sw1, int sw2, int sw3);

/**
 * @brief Writes 'value' to LD5 (RGB)
 * @param value bitmap
 */
extern void write_ld5(int value);
extern void write_ld5(int r, int g, int b);
}

namespace Syfala::ARM::Status {
/**
 * @brief Sets the status LED (LD5 on Zybo boards)
 * as 'waiting' (blue color), prints 'message' to stdout (ttyPS0).
 */
extern void waiting(const char* message);
/**
 * @brief Sets the status LED (LD5 on Zybo boards)
 * as 'warning' (yellow color), prints 'message to stdout (ttyPS0).
 */
extern void warning(const char* message);
/**
 * @brief Sets the status LED (LD5 on Zybo boards)
 * as 'error' (red color), prints error 'message to stdout (ttyPS0).
 * The program keeps running.
 */
extern void error(const char* message);
/**
 * @brief Sets the status LED (LD5 on Zybo boards)
 * as 'error' (redcolor), AND terminates program with a fatal error.
 */
extern void fatal(const char* message, int err = 1);

/**
 * @brief Sets the status LED (LD5 on Zybo boards)
 * as 'ok' (green color), prints 'message to stdout (ttyPS0).
 * Program is running, no issue has been encountered during initialization.
 */
extern void ok(const char* message);
}
