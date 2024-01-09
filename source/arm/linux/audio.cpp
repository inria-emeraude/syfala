#include <linux/i2c-dev.h>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/codecs/ADAU17xx.hpp>
#include <syfala/arm/codecs/SSM2603.hpp>
#include <syfala/utilities.hpp>

#include <fcntl.h>
#include <sys/ioctl.h>
#include <cstdio>
#include <cassert>

#define IIC_CODEC_INTERNAL  "/dev/i2c-0"
#define IIC_CODEC_EXTERNAL  "/dev/i2c-1"

using namespace Syfala;

int SSM2603::regwrite(uint8_t fd, uint16_t offset, uint16_t data){
    byte_t buffer[2];
    buffer[0] = offset << 1;
    buffer[0] = buffer[0] | ((data >> 8) & 0b1);
    buffer[1] = data & 0xff;
    if (write(fd, buffer, sizeof(buffer)) != sizeof(buffer)) {
        perror("[SSM2603] Failed to write to bus");
        Status::fatal("[i2c] Register write failed, aborting");
    } else {
        return 0;
    };
    assert(false);
}

int ADAU17xx::regwrite(int busno,
                  unsigned long codec_addr,
                   unsigned int addr,
                   unsigned int data,
                   unsigned int offset
){
    int status;
    int fd = open(IIC_CODEC_INTERNAL, O_RDWR);
    unsigned char tx_data[3];
    if (fd < 0) {
        perror("[i2c] Could not open device");
        Status::warning("[I2C] Register write failed");
        return 1;
    } else {
        printf("[i2c] Device (%d) succesfully opened\r\n", busno);
    }
    if (ioctl(fd, 0, 0) < 0) {
        perror("[i2c] Failed to acquire bus access and/or talk to slave");
        Status::warning("[I2C] Register write failed");
        return 1;
    } else {
        printf("[i2c] Bus access succesfully acquired\n");
    }
    // register subaddress high byte
    // (0x40 for ADAU1761, 0xc0 for ADAU1787)
    tx_data[0] = addr >> 8 & 0xff;
    tx_data[1] = addr & 0xff;
    tx_data[2] = data;
    if (write(fd, tx_data, sizeof(tx_data)) < 3) {
        perror("[i2c] Failed to write to bus");
        Status::warning("[i2c] Register write failed");
        return 1;
    } else {
        return 0;
    }
}

void Audio::initialize() {
    int fd = open(IIC_CODEC_INTERNAL, O_RDWR);
    if (fd < 0) {
        perror("[i2c] Could not open device");
        Status::fatal("[i2c] Aborting");
    } else {
        printf("[i2c] Device (%d) succesfully opened\r\n", fd);
    }
    if (ioctl(fd, I2C_SLAVE, IIC_SSM_SLAVE_ADDR) < 0) {
        perror("[i2c] Failed to acquire bus access and/or talk to slave");
        Status::fatal("[i2c] Aborting");
    } else {
        printf("[i2c] Bus access succesfully acquired\n");
    }
#if SYFALA_BOARD_ZYBO
    SSM2603::initialize(fd);
#elif SYFALA_BOARD_GENESYS
    ADAU1761::initialize();
#endif
    close(fd);
}
