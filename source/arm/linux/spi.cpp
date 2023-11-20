
#include <cstring>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <syfala/arm/spi.hpp>
#include <iio.h>
#include <syfala/arm/gpio.hpp>

using namespace Syfala;

static iio_device* dev = nullptr;
static iio_buffer* buf = nullptr;
static iio_channel* channels[8];

static int poll_channel(int channel) {
    int rx = 0;
    iio_buffer_refill(buf);
    iio_channel_read(channels[0], buf, &rx, sizeof(rx));
    return rx;
}

void SPI::poll(SPI::data& d) {
    for (int n = 0; n < 1; ++n) {
         unsigned short tmp = poll_channel(n);
         d.change[n] = (tmp != d.values[n]);
         d.values[n] = tmp/1023.f;
    }
}

 void SPI::initialize(SPI::data& d, int ncontrols) {
    iio_context* ctx = iio_create_local_context();
    if (ctx == nullptr) {
        Status::fatal("Could not create IIO local context");
    }
    dev = iio_context_find_device(ctx, "mcp3008");
    if (dev == nullptr) {
        Status::fatal("Could not get IIO device (0)");
    }
    channels[0] = iio_device_get_channel(dev, 0);
    iio_channel_enable(channels[0]);
    buf = iio_device_create_buffer(dev, 4096, false);
    if (buf == nullptr) {
        perror("IIO: could not create RX buffer");
    }
    printf("[spi] Successfully initialized device\n");
}
