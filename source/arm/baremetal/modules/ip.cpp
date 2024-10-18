#include <syfala/arm/ip.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/utilities.hpp>
#include <xparameters.h>

using namespace Syfala::ARM;

void DSP::initialize(XSyfala& x) {
    auto config = XSyfala_LookupConfig(XPAR_XSYFALA_0_DEVICE_ID);
    if (config == nullptr)
        Status::fatal("ERROR: Syfala IP configuration could not be found.");

    // Initialize the device
    if (XSyfala_CfgInitialize(&x, config) != XST_SUCCESS) {
        Status::fatal("ERROR: Could not initialize Syfala IP configuration");
    }
    // Initialize with other function (not sure if it's useful)
    if (XSyfala_Initialize(&x, XPAR_XSYFALA_0_DEVICE_ID) != XST_SUCCESS) {
        Status::fatal("ERROR: Could not initialize Syfala IP");
    }
#if SYFALA_CONTROL_BLOCK
    DSP::set_control_block(&x, 1);
#endif
    DSP::set_arm_ok(&x, false);
    println("[xsyfala] XSyfala IP intercom successfully initialized.");
}
