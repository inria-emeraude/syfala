#include <stdio.h>
#include <xgpio.h>
#include <stdlib.h>
#include <syfala/arm/gpio.hpp>

namespace xgpio {
    constexpr auto initialize          = XGpio_Initialize;
    constexpr auto set_data_direction  = XGpio_SetDataDirection;
    constexpr auto discrete_read       = XGpio_DiscreteRead;
    constexpr auto discrete_write      = XGpio_DiscreteWrite;
}

using namespace Syfala;

namespace Syfala::GPIO {
static struct data { XGpio led, sw; } x;
}

#define WAITING_LED   0b001
#define WARNING_LED   0b110
#define OK_LED        0b010
#define ERROR_LED     0b100

void GPIO::initialize() {
    //initialize input XGpio variable
    xgpio::initialize(&x.led, XPAR_AXI_GPIO_LED_DEVICE_ID);
    xgpio::initialize(&x.sw, XPAR_AXI_GPIO_SW_DEVICE_ID);
    //set first channel tristate buffer to output (RGB led)
    xgpio::set_data_direction(&x.led, 1, 0x0);
    //set second channel tristate buffer to output (LED)
    xgpio::set_data_direction(&x.led, 2, 0x0);
    //set first channel tristate buffer to input (switch)
    xgpio::set_data_direction(&x.sw, 1, 0xF);
}

int GPIO::read_sw3() {
    return (xgpio::discrete_read(&x.sw, 1) & (1 << 3)) >> 3;
}

void Status::waiting(const char* message) {
    xgpio::discrete_write(&GPIO::x.led, 2, WAITING_LED);
    xil_printf(message);
}

void Status::warning(const char* message) {
    xgpio::discrete_write(&GPIO::x.led, 2, WARNING_LED);
    xil_printf(message);
}

void Status::error(const char* message) {
    xgpio::discrete_write(&GPIO::x.led, 2, ERROR_LED);
    xil_printf(message);
}

void Status::fatal(const char* message, int err) {
    error(message);
    exit(err);
}

void Status::ok(const char* message) {
    xgpio::discrete_write(&GPIO::x.led, 2, OK_LED);
    xil_printf(message);
}
