#include <syfala/arm/gpio.hpp>
#include <stdio.h>
#include <stdint.h>
#include <xgpio.h>
#include <stdlib.h>
#include <syfala/config_common.hpp>

namespace xgpio {
    constexpr auto initialize          = XGpio_Initialize;
    constexpr auto set_data_direction  = XGpio_SetDataDirection;
    constexpr auto discrete_read       = XGpio_DiscreteRead;
    constexpr auto discrete_write      = XGpio_DiscreteWrite;
}

namespace Syfala::GPIO {

struct data {
    XGpio led;
    XGpio sw;
};

static data x;
}

#define WAITING_LED   0b001
#define WARNING_LED   0b110
#define OK_LED        0b010
#define ERROR_LED     0b100

using namespace Syfala;

void GPIO::initialize() {
    // initialize input XGpio variable
    xgpio::initialize(&x.led, XPAR_AXI_GPIO_LED_DEVICE_ID);
    xgpio::initialize(&x.sw, XPAR_AXI_GPIO_SW_DEVICE_ID);
    // set first channel tristate buffer to output (SW led)
    xgpio::set_data_direction(&x.led, 1, 0x0);
    // set second channel tristate buffer to output (RGB LED)
    xgpio::set_data_direction(&x.led, 2, 0x0);
    // set first channel tristate buffer to input (switch)
    xgpio::set_data_direction(&x.sw, 1, 0xF);
    // set second channel tristate buffer to input (btn)
#if (SYFALA_BOARD_GENESYS)
    xgpio::set_data_direction(&x.sw, 2, 0xF);
#endif
}

void GPIO::write_sw_led(int sw0, int sw1, int sw2, int sw3) {
    u32 mask = 0;
    mask |= sw0 << 0;
    mask |= sw1 << 1;
    mask |= sw2 << 2;
    mask |= sw3 << 3;
    xgpio::discrete_write(&x.led, 1, mask);
}

bool GPIO::read_sw(int index) {
    return xgpio::discrete_read(&x.sw, 1) & (1 << index);
}
/* read_btn
 * return a formatted button vector.
 * Normally, discrete_read return the btn vector as:
 * GENESY=0b000[UP][CENTER][DOWN][LEFT][RIGHT]
 * Zybo=0b000[0][3(UP)][2(DOWN)][1(LEFT)][0(RIGHT)]
 * In order to have something generic, we put the UP on the 5th bit for Zybo.
*/
uint32_t GPIO::read_btn(void) {
    u32 btn_vector=xgpio::discrete_read(&x.sw, 2);
#if (SYFALA_BOARD_ZYBO) // --
    btn_vector|=((btn_vector & 0b00001000)<<1); //Copy the 4th bit one bit higher.
    btn_vector&=0b00010111; //Remove the 4th (old) bit.
#endif // -------------------
    return btn_vector;
}
void GPIO::write_ld5(int value) {
    xgpio::discrete_write(&GPIO::x.led, 2, value);
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
