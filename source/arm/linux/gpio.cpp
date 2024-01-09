#include <linux/gpio.h>
#include <syfala/arm/gpio.hpp>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>
#include <gpiod.h>

#define SYFALA_GPIO_AXI_LED_DEVICE  "gpiochip0"
#define SYFALA_GPIO_AXI_SW_DEVICE   "gpiochip1"
#define SYFALA_GPIO_AXI_SW_DEVICE_NLINES    4
#define SYFALA_GPIO_AXI_LED_DEVICE_NLINES   7

#define SYFALA_GPIO_AXI_LED_SW0_LINENO      0
#define SYFALA_GPIO_AXI_LED_SW1_LINENO      1
#define SYFALA_GPIO_AXI_LED_SW2_LINENO      2
#define SYFALA_GPIO_AXI_LED_SW3_LINENO      3

#define SYFALA_GPIO_AXI_LED_RGB_R_LINENO    6
#define SYFALA_GPIO_AXI_LED_RGB_G_LINENO    5
#define SYFALA_GPIO_AXI_LED_RGB_B_LINENO    4

#ifndef CONSUMER
    #define CONSUMER "Consumer"
#endif

#define RGB_LED_WAITING   0, 0, 1
#define RGB_LED_WARNING   1, 1, 0
#define RGB_LED_OK        0, 1, 0
#define RGB_LED_ERROR     1, 0, 0

using namespace Syfala;

static void set_rgb_led(int R, int G, int B) {
    struct gpiod_chip* chip = gpiod_chip_open_by_name(SYFALA_GPIO_AXI_LED_DEVICE);
    if (chip == nullptr) {
        perror("[gpio] couldn't set RBG LED");
    } else {
        unsigned int lines[3] = {
            SYFALA_GPIO_AXI_LED_RGB_R_LINENO,
            SYFALA_GPIO_AXI_LED_RGB_G_LINENO,
            SYFALA_GPIO_AXI_LED_RGB_B_LINENO
        };
        const int values[3] = {R, G, B};
        gpiod_line_bulk bk;
        gpiod_chip_get_lines(chip, lines, 3, &bk);
        gpiod_line_request_bulk_output(&bk, CONSUMER, values);
        gpiod_line_release_bulk(&bk);
    }
    gpiod_chip_close(chip);
}

static void initialize_rgb_led() {
    set_rgb_led(RGB_LED_WAITING);
}

void GPIO::write_sw_led(int sw0, int sw1, int sw2, int sw3) {
    struct gpiod_chip* chip = gpiod_chip_open_by_name(SYFALA_GPIO_AXI_LED_DEVICE);
    unsigned int lines[4] = {
        SYFALA_GPIO_AXI_LED_SW0_LINENO,
        SYFALA_GPIO_AXI_LED_SW1_LINENO,
        SYFALA_GPIO_AXI_LED_SW2_LINENO,
        SYFALA_GPIO_AXI_LED_SW3_LINENO
    };
    const int values[4] = {sw0, sw1, sw2, sw3};
    gpiod_line_bulk bk;
    gpiod_chip_get_lines(chip, lines, 4, &bk);
    gpiod_line_request_bulk_output(&bk, CONSUMER, values);
    gpiod_line_release_bulk(&bk);
    gpiod_chip_close(chip);
}

void GPIO::write_ld5(int r, int g, int b) {
    set_rgb_led(r, g, b);
}

bool GPIO::read_sw(int n) {
    struct gpiod_chip* chip = gpiod_chip_open_by_name(SYFALA_GPIO_AXI_SW_DEVICE);
    if (chip == nullptr) {
        perror("[gpio] couldn't get SW gpio");
        exit(1);
    } else {
        struct gpiod_line* line = gpiod_chip_get_line(chip, n);
        if (line == nullptr) {
            fprintf(stderr, "[gpio] couldn't get SW line %d\n", n);
            gpiod_chip_close(chip);
            exit(1);
        } else {
            gpiod_line_request_input(line, CONSUMER);
            int r = gpiod_line_get_value(line);
            gpiod_line_release(line);
            gpiod_chip_close(chip);
            return r;
        }
    }
}

void GPIO::initialize() {
    initialize_rgb_led();
}

void Status::waiting(const char* message) {
    set_rgb_led(0, 0, 1);
    printf("%s\r\n", message);
}

void Status::warning(const char* message) {
    set_rgb_led(1, 1, 0);
    printf("%s\r\n", message);
}

void Status::error(const char* message) {
    set_rgb_led(1, 0, 0);
    printf("%s\r\n", message);
}

void Status::fatal(const char* message, int err) {
    error(message);
    exit(err);
}

void Status::ok(const char* message) {
    set_rgb_led(0, 1, 0);
    printf("%s\r\n", message);
}
