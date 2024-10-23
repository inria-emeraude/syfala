#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/memory.hpp>
#include <signal.h>
#include <string>
#include <unistd.h>

#include "grid_config.h"

// This program is built on the ARM micro processor to initialise the mem_zone_f in the FDPlate_hls_.cpp files

#define INPUTS 0
#define OUTPUTS 2

using namespace Syfala;

static bool running = true;
int isTUI = false;

static void sig_hdl (int signo) {
    switch (signo) {
    case SIGINT:
    case SIGKILL:
    case SIGSTOP: {
        printf("Terminating program\n");
        running = false;
        break;
    }
    }
}

int main(int argc, char **argv) {

    XSyfala dsp;
    Memory::data mem;
    UART::data uart;
    
    signal(SIGINT, sig_hdl);
    signal(SIGKILL, sig_hdl);
    signal(SIGSTOP, sig_hdl);
    
    GPIO::initialize();
    UART::initialize(uart);
    
    Status::waiting(RN("[status] Initializing peripherals & modules"));
    Audio::initialize();
    IP::initialize(dsp);
    
    Memory::initialize(dsp, mem, 0, 3*grid_length*sizeof(float));
    
    IP::set_arm_ok(&dsp, true);
    Status::ok(RN("[status] Application ready, now running..."));

    while (running) {
        sleep(1);
    }
    
    Status::waiting(RN("[status] Exiting Program"));
    
    return 0;
}