#include <syfala/arm/spi.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/utilities.hpp>
#include <xspips.h>
#include <xparameters.h>

namespace xspips {   
    using handle = XSpiPs;
    using config = XSpiPs_Config;
    constexpr auto lookup_config      = XSpiPs_LookupConfig;
    constexpr auto initialize_config  = XSpiPs_CfgInitialize;
    constexpr auto set_options        = XSpiPs_SetOptions;
    constexpr auto set_clk_prescaler  = XSpiPs_SetClkPrescaler;
    constexpr auto reset              = XSpiPs_Reset;
    constexpr auto reset_hw           = XSpiPs_ResetHw;
    constexpr auto in32               = XSpiPs_In32;
}

using namespace Syfala;
static xspips::handle x;

void SPI::reset(SPI::data& d) {
    xspips::reset(&x);
    xspips::reset_hw(XPAR_XSPIPS_0_BASEADDR);
}

static __always_inline void read(SPI::data& d, int nbytes) {
    u32 status;
    do {
        status = Xil_In32(x.Config.BaseAddress + XSPIPS_SR_OFFSET);
    } while (!(status & XSPIPS_IXR_RXNEMPTY_MASK));
    for (int n = 0; n < nbytes; ++n)
         d.rw[n] = xspips::in32(XPAR_XSPIPS_0_BASEADDR + XSPIPS_RXD_OFFSET);
}

static __always_inline void write(SPI::data& d, int nbytes) {
    for (int n = 0; n < nbytes && n < XSPIPS_FIFO_DEPTH; ++n)
         Xil_Out32(x.Config.BaseAddress + XSPIPS_TXD_OFFSET, d.rw[n]);
}

static __always_inline void wait_for_transfer(SPI::data& d) {
    int status = 0;
    do {
        status = Xil_In32(x.Config.BaseAddress + XSPIPS_SR_OFFSET);
    } while ((status & XSPIPS_IXR_TXOW_MASK) == 0);
}

static inline unsigned short poll_channel(SPI::data& d, char channel) {
    d.rw[0] = 0b00000001;
    d.rw[1] = (channel | 0x18) << 4;
    d.rw[2] = 0;
    write(d, 3);
    wait_for_transfer(d);
    read(d, 3);
    return ((d.rw[1] & 0b00000011) << 8) | d.rw[2];
}

void SPI::poll(SPI::data& d) {
    for (int n = 0; n < 8; ++n) {
         unsigned short tmp = poll_channel(d, n);
         d.change[n] = (tmp != d.values[n]);
         d.values[n] = tmp;
    }
}

void SPI::initialize(SPI::data& d) {
    xspips::config* c = xspips::lookup_config(XPAR_XSPIPS_0_DEVICE_ID);
    if (c == nullptr) {
        Status::fatal(RN("Could not retrieve XSPIPS configuration"));
    }
    if (xspips::initialize_config(&x, c, c->BaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("Could not initialize XSPIPS configuration"));
    }
    /* The SPI device is a slave by default and the clock phase
     * have to be set according to its master. In this example, CPOL is set
     * to quiescent high and CPHA is set to 1. */
    if (xspips::set_options(&x, XSPIPS_MASTER_OPTION) != XST_SUCCESS) {
        Status::fatal(RN("Could not set XSPIPS options"));
    }
    if (xspips::set_clk_prescaler(&x, XSPIPS_CLK_PRESCALE_64) != XST_SUCCESS) {
        Status::fatal(RN("Could not set XSPIPS clock prescaler"));
    }
    XSpiPs_Enable(&x);
    memset(d.values, 0, sizeof(d.values));
    memset(d.change, 0, sizeof(d.change));
    poll(d);
    sy_printf("XSPIPS successfully initialized.");
}
