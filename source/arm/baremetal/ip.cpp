#include <syfala/arm/ip.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/utilities.hpp>
#include <xparameters.h>

using namespace Syfala;

void IP::initialize(XSyfala& x) {
    auto config = XSyfala_LookupConfig(XPAR_XSYFALA_0_DEVICE_ID);
    if (config == nullptr)
        Status::fatal(RN("ERROR: Syfala IP configuration could not be found."));

    // Initialize the device
    if (XSyfala_CfgInitialize(&x, config) != XST_SUCCESS) {
        Status::fatal(RN("ERROR: Could not initialize Syfala IP configuration"));
    }
    // Initialize with other function (not sure if it's useful)
    if (XSyfala_Initialize(&x, XPAR_XSYFALA_0_DEVICE_ID) != XST_SUCCESS) {
        Status::fatal(RN("ERROR: Could not initialize Syfala IP"));
    }
    IP::set_control_block(&x, 1);
    IP::set_arm_ok(&x, false);
    sy_printf("XSyfala IP intercom successfully initialized.");
}
