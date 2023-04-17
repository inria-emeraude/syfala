#include <syfala/arm/ip.hpp>

#define XSYFALA_DEVICE_NAME "syfala"

using namespace Syfala;

void IP::initialize(XSyfala& x) {
    int err = XSyfala_Initialize(&x, XSYFALA_DEVICE_NAME);
    if (err != XST_SUCCESS) {
        perror("[main] Syfala device initialization failed");
        exit(err);
    }
    IP::set_control_block(&x, 1);
    IP::set_arm_ok(&x, false);
}
