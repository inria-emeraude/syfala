#include <syfala/arm/spi.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/utilities.hpp>
#include <xspips.h>
#include <xparameters.h>
#include <sleep.h>
#include <cassert>

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
    constexpr auto polled_transfer    = XSpiPs_PolledTransfer;
    constexpr auto set_slave_select   = XSpiPs_SetSlaveSelect;
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
    xspips::polled_transfer(&x, d.rw, d.rw, nbytes);
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
    xspips::polled_transfer(&x, d.rw, d.rw, sizeof(d.rw));
    return ((d.rw[1] & 0b00000011) << 8) | d.rw[2];
}

void SPI::poll(SPI::data& d) {
    for (int n = 0; n < d.ncontrols; ++n) {
        float tmp;
        if constexpr (controller() == Controller::Teensy) {
            tmp = SPI::Teensy::read(d, n);
        } else {
            tmp = poll_channel(d, n)/1023.f;
        }
         d.change[n] = (tmp != d.values[n]);
         d.values[n] = tmp;
    }
}

void SPI::slow_transfer(SPI::data& d, int nbytes) {
    u32 status;
    u32 config;
    u32 ntransfers;
    u32 check_transfer;
    s32 status_polled;
    byte_t tmp_data;

    x.IsBusy = true;
    XSpiPs_Enable(&x);

    /* If manual chip select mode, initialize the slave select value. */
    if (XSpiPs_IsManualChipSelect(&x)) {
        config = XSpiPs_ReadReg(x.Config.BaseAddress, XSPIPS_CR_OFFSET);
        /* Set the slave select value */
        config &= (u32)(~XSPIPS_CR_SSCTRL_MASK);
        config |= x.SlaveSelect;
        XSpiPs_WriteReg(x.Config.BaseAddress, XSPIPS_CR_OFFSET, config);
    }

    for (int n = 0; n < nbytes; ++n) {
         write(d, 1);
         read(d, 1);
         usleep(100);
    }
    /* Clear the slave select now, before terminating the transfer. */
    if (XSpiPs_IsManualChipSelect(&x)) {
        config = XSpiPs_ReadReg(x.Config.BaseAddress, XSPIPS_CR_OFFSET);
        config |= XSPIPS_CR_SSCTRL_MASK;
        XSpiPs_WriteReg(x.Config.BaseAddress, XSPIPS_CR_OFFSET, config);
    }
    /* Clear the busy flag */
    x.IsBusy = false;
    /* Disable the device. */
    XSpiPs_Disable(&x);

}

void SPI::initialize(SPI::data& d, int ncontrols) {
    xspips::config* c = xspips::lookup_config(XPAR_XSPIPS_0_DEVICE_ID);
    if (c == nullptr) {
        Status::fatal(RN("[spi] Could not retrieve XSPIPS configuration"));
    }
    if (xspips::initialize_config(&x, c, c->BaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("[spi] Could not initialize XSPIPS configuration"));
    }
    /* The SPI device is a slave by default and the clock phase
     * have to be set according to its master. In this example, CPOL is set
     * to quiescent high and CPHA is set to 1. */
    if (xspips::set_options(&x, XSPIPS_MASTER_OPTION | XSPIPS_FORCE_SSELECT_OPTION) != XST_SUCCESS) {
        Status::fatal(RN("[spi] Could not set XSPIPS options"));
    }
    if (xspips::set_clk_prescaler(&x, XSPIPS_CLK_PRESCALE_256) != XST_SUCCESS) { // 64
        Status::fatal(RN("[spi] Could not set XSPIPS clock prescaler"));
    }
    xspips::set_slave_select(&x, SS0_SPI_SELECT);
    XSpiPs_Enable(&x);
    memset(d.values, 0, sizeof(d.values));
    memset(d.change, 0, sizeof(d.change));
    d.ncontrols = std::min(ncontrols, SPI::capacity());
    printf("[spi] Number of available controls: %d\r\n", d.ncontrols);
    poll(d);
    sy_printf("[spi] SPI module successfully initialized.");
}

void SPI::Teensy::initialize(const char* label,
                                     int channel,
                                   float init,
                                   float min,
                                   float max,
                                   float step
){
    byte_t buf[128];
    int n = 0;
    int init_i = *reinterpret_cast<int*>(&init);
    int  min_i = *reinterpret_cast<int*>(&min);
    int  max_i = *reinterpret_cast<int*>(&max);
    int step_i = *reinterpret_cast<int*>(&step);
    // -------------------------------
    buf[0] = 0x02;
    buf[1] = channel;
    buf[2] = init_i >> 24 & 0b11111111;
    buf[3] = init_i >> 16 & 0b11111111;
    buf[4] = init_i >> 8 & 0b11111111;
    buf[5] = init_i & 0b11111111;
    // -------------------------------
    buf[6] = min_i >> 24 & 0b11111111;
    buf[7] = min_i >> 16 & 0b11111111;
    buf[8] = min_i >> 8 & 0b11111111;
    buf[9] = min_i & 0b11111111;
    // -------------------------------
    buf[10] = max_i >> 24 & 0b11111111;
    buf[11] = max_i >> 16 & 0b11111111;
    buf[12] = max_i >> 8 & 0b11111111;
    buf[13] = max_i & 0b11111111;
    // -------------------------------
    buf[14] = step_i >> 24 & 0b11111111;
    buf[15] = step_i >> 16 & 0b11111111;
    buf[16] = step_i >> 8 & 0b11111111;
    buf[17] = step_i & 0b11111111;

    while (label[n]) {
        buf[18+n] = label[n];
        n++;
    }
    if (n%2 != 0) {
        // Ensure an odd number of bytes sent
        buf[18+n++] = ' ';
    }

    xspips::polled_transfer(&x, buf, nullptr, n+18);
}

float SPI::Teensy::read(SPI::data& d, int channel) {
    d.rw[0] = 0x01;
    d.rw[1] = channel;
    d.rw[2] = 0x00;
    d.rw[3] = 0x00;
    d.rw[4] = 0x00;
    d.rw[5] = 0x00;
    /* Don't know why, the send back is 1 transfer behind with Teensy...
	 * So instead of sending 6 bytes in once (2 for info and 4 empty for return),
     * I send the 2 info byte, and then the 4 empty bytes for
     * the return in an other communication. */
    xspips::polled_transfer(&x, d.rw, d.rw, 2);
    xspips::polled_transfer(&x, d.rw+2, d.rw+2, 4);
    int result_i = ((d.rw[2] & 0b11111111) << 24)
                 | ((d.rw[3] & 0b11111111) << 16)
                 | ((d.rw[4] & 0b11111111) << 8)
                 |   d.rw[5];
   // printf("|%f|",*reinterpret_cast<float*>(&result_i));
    return *reinterpret_cast<float*>(&result_i);
}
