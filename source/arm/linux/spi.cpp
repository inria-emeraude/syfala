#include <linux/spi/spidev.h>
#include "config.hpp"
#include <syfala/arm/spi.hpp>
/**
 * Note: the way spi-cadence.c driver sets the prescaler is the following:
 * It fetches master's 'speed_hz' property, compares it with the slave's.
 * If it is different, it will add automatically add an appropriate
 * prescaler to get master's frequency below the slave's max-frequency.
 * We don't have to set it ourselves. But there still seems like we have
 * some sort of clocking issues at play here...
 */
#define SPI_MASTER_CLOCK_BASE_HZ  166666666
#define SPI_SLAVE0_SPEED_MAX_HZ   1000000
#define SPI_SLAVE0_DEV_ID         "/dev/spidev0.0"

using namespace Syfala;

static int fd;

static int poll_channel(int fd, int channel) {
    spi_ioc_transfer xfer;
    unsigned char data[3];
    int value, r;
    // Full-duplex mode:
    // we set both tx & rx buffers on the same 'transfer'
    memset(&xfer, 0, sizeof(xfer));
    data[0] = 0b00000001; // start bit
    data[1] = 0b10000000 | ((channel & 7) << 4); // channel request
    data[2] = 0; // don't care byte
    xfer.tx_buf = (__u64) data;
    xfer.rx_buf = (__u64) data;
    xfer.len = sizeof(data);
    r = ioctl(fd, SPI_IOC_MESSAGE(1), &xfer);
    if (r != sizeof(data)) {
        perror("[SPI] R/W failed");
        exit(1);
    }
//    printf("[SPI] byte 0: %d\n", data[0]);
//    printf("[SPI] byte 1: %d\n", data[1]);
//    printf("[SPI] byte 2: %d\n", data[2]);
    // merge data[1] & data[2] to get proper result
    value  = (data[1] << 8) & 0b1100000000;
    value |= (data[2] & 0xff);
//    printf("[SPI] channel %d value: %d\n", channel, value);
    return value;
}

void SPI::poll(SPI::data& d) {
    for (int n = 0; n < 8; ++n) {
         unsigned short tmp = poll_channel(fd, n);
         d.change[n] = (tmp != d.values[n]);
         d.values[n] = tmp;
    }
}

 void SPI::initialize(SPI::data& d) {
    int mode   = SPI_MODE_0;
    int speed  = SPI_SLAVE0_SPEED_MAX_HZ;
    int bpw    = 8;

    fd = open(SPI_SLAVE0_DEV_ID, O_RDWR);
    if (fd < 0) {
        perror("[SPI] Could not open device");
        exit(fd);
    } else {
        printf("[SPI] Device succesfully opened\n");
    }
    if (ioctl(fd, SPI_IOC_WR_MODE, &mode) < 0) {
        perror("[SPI] Could not set bus mode");
        exit(1);
    }
    if (ioctl(fd, SPI_IOC_RD_MODE, &mode) < 0) {
        perror("[SPI] Could not get bus mode");
        exit(1);
    } else {
        printf("[SPI] Mode: %d\n", mode);
    }
    if (ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bpw) < 0) {
        perror("[SPI] Could not set bits per word");
        exit(fd);
    }
    if (ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bpw) < 0) {
        perror("[SPI] Could not get bits per word");
        exit(fd);
    } else {
        printf("[SPI] Bits per word: %d\n", bpw);
    }
    if (ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) < 0) {
        perror("[SPI] Could not set spi-max-frequency");
        exit(fd);
    }
    if (ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed) < 0) {
        perror("[SPI] Could not get spi-max-frequency");
        exit(fd);
    } else {
        printf("[SPI] Set speed to %d Hz\n", speed);
    }
    memset(d.values, 0, sizeof(d.values));
    memset(d.change, 0, sizeof(d.change));
    poll(d);
    printf("[SPI] Successfully initialized device\n");    
}
