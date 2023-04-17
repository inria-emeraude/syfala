#include <linux/gpio.h>
#include <syfala/arm/gpio.hpp>
#include "config.hpp"

#define SYFALA_GPIO_AXI_LED_DEVICE  "/dev/gpiochip0"
#define SYFALA_GPIO_AXI_SW_DEVICE   "/dev/gpiochip1"
#define SYFALA_GPIO_AXI_SW_DEVICE_NLINES    4
#define SYFALA_GPIO_AXI_LED_DEVICE_NLINES   7

#define SYFALA_GPIO_AXI_LED_SW0_LINENO      0
#define SYFALA_GPIO_AXI_LED_SW1_LINENO      1
#define SYFALA_GPIO_AXI_LED_SW2_LINENO      2
#define SYFALA_GPIO_AXI_LED_SW3_LINENO      3
#define SYFALA_GPIO_AXI_LED_RGB_R_LINENO    6
#define SYFALA_GPIO_AXI_LED_RGB_G_LINENO    5
#define SYFALA_GPIO_AXI_LED_RGB_B_LINENO    4

using namespace Syfala;

static int open_device(const char* device, int rw) {
    int fd = open(device, rw);
    if (fd < 0) {
        printf("[GPIO] Could not open %s (%s)\n",
               device, strerror(errno));
        exit(fd);
    }
    return fd;
}

static int write_value(const char* dev,
               gpiohandle_request& req,
                  gpiohandle_data& data
){
    int err, fd = open_device(dev, O_WRONLY);
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    err = ioctl(fd, GPIO_GET_LINEHANDLE_IOCTL, &req);
    close(fd);
    if (err == -1) {
        perror("[GPIO] Unable to get line handle from ioctl");
        exit(err);
    }
    err = ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    if (err == -1) {
        perror("[GPIO] Unable to set line value using ioctl");
        exit(err);
    }
    close(req.fd);
    return err;
}

static int read_value(const char* dev, unsigned char line) {
    int err, fd = open_device(dev, O_RDWR);
    struct gpiohandle_request rq;
    struct gpiohandle_data data;
    rq.flags = GPIOHANDLE_REQUEST_INPUT;
    rq.lineoffsets[0] = line;
    rq.lines = 1;
    err = ioctl(fd, GPIO_GET_LINEHANDLE_IOCTL, &rq);
    close(fd);
    if (err == -1) {
        perror("[GPIO] Unable to get line handle from ioctl");
        exit(err);
    }
    err = ioctl(rq.fd, GPIOHANDLE_GET_LINE_VALUES_IOCTL, &data);
    if (err == -1) {
        perror("[GPIO] Unable to get line value from ioctl");
        exit(err);
    }
    close(rq.fd);
    return (int) data.values[0];
}

static void set_rgb_led(int R, int G, int B) {
    gpiohandle_request req;
    gpiohandle_data data;
    req.lineoffsets[0] = SYFALA_GPIO_AXI_LED_RGB_R_LINENO;
    req.lineoffsets[1] = SYFALA_GPIO_AXI_LED_RGB_G_LINENO;
    req.lineoffsets[2] = SYFALA_GPIO_AXI_LED_RGB_B_LINENO;
    req.lines = 3;
    data.values[0] = R;
    data.values[1] = G;
    data.values[2] = B;
    write_value(SYFALA_GPIO_AXI_LED_DEVICE, req, data);
}

#define WAITING_LED   0, 0, 1
#define WARNING_LED   1, 1, 0
#define OK_LED        0, 1, 0
#define ERROR_LED     1, 0, 0

static void initialize_rgb_led() {
    set_rgb_led(WAITING_LED);
}

int GPIO::read_sw3() {
    return read_value(SYFALA_GPIO_AXI_SW_DEVICE, 3);
}

void GPIO::initialize() {
    initialize_rgb_led();
}

void Status::waiting(const char* message) {
    set_rgb_led(WAITING_LED);
    printf(message);
}

void Status::warning(const char* message) {
    set_rgb_led(WARNING_LED);
    printf(message);
}

void Status::error(const char* message) {
    set_rgb_led(ERROR_LED);
    printf(message);
}

void Status::fatal(const char* message, int err) {
    error(message);
    exit(err);
}

void Status::ok(const char* message) {
    set_rgb_led(OK_LED);
    printf(message);
}
