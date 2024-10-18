
/************************************************************************
 ************************************************************************
    Syfala compilation flow
    Copyright (C) 2022 INSA-LYON, INRIA, GRAME-CNCM
---------------------------------------------------------------------
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ************************************************************************
 ************************************************************************/

#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/memory.hpp>
#include <lo/lo.h>
#include <cmath>
#include <signal.h>

static bool running = true;
using namespace Syfala::ARM;

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

#define WAVETABLE_LEN 16384

static void error_hdl(int no, const char* m, const char* path) {
    fprintf(stderr, "Error starting OSC client: %d, %s, %s\n", no, m, path);
}

static lo_server_thread osc;
static float frequency = 440.f, gain = 0.25f;

static int osc_frequency_hdl (
        const char* path,
        const char* types,
           lo_arg** argv, int argc,
         lo_message data, void* udata
){
    XSyfala* dsp = static_cast<XSyfala*>(udata);
    frequency = argv[0]->f;
    printf("[OSC] Updating /osc/frequency with value: %f\n", frequency);
    XSyfala_Set_frequency(dsp, *reinterpret_cast<u32*>(&frequency));
    return 0;
}

static int osc_gain_hdl (
        const char* path,
        const char* types,
           lo_arg** argv, int argc,
         lo_message data, void* udata
){
    XSyfala* dsp = static_cast<XSyfala*>(udata);
    gain = argv[0]->f;
    printf("[OSC] Updating /osc/gain with value: %f\n", gain);
    XSyfala_Set_gain(dsp, *reinterpret_cast<u32*>(&gain));
    return 0;
}

static void initialize_osc(XSyfala& dsp) {
    osc = lo_server_thread_new("8888", error_hdl);
    lo_server_thread_add_method(osc, "/osc/frequency", "f", osc_frequency_hdl, &dsp);
    lo_server_thread_add_method(osc, "/osc/gain", "f", osc_gain_hdl, &dsp);
    lo_server_thread_start(osc);
}

static void initialize_wavetables(float* mem) {
    static constexpr int w = WAVETABLE_LEN;
    for (int n = 0; n < w; ++n) {
         mem[n] = std::sin((float)(n)/w * M_PI * 2);
    }
}

static void initialize_default_values(XSyfala& dsp) {
    XSyfala_Set_frequency(&dsp, *reinterpret_cast<u32*>(&frequency));
    XSyfala_Set_gain(&dsp, *reinterpret_cast<u32*>(&gain));
}

int main(int argc, char* argv[])
{
    XSyfala dsp;
    Memory::data mem;
    signal(SIGINT, sig_hdl);
    signal(SIGKILL, sig_hdl);
    signal(SIGSTOP, sig_hdl);
    // GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    // Wait for all peripherals to be initialized
    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    DSP::initialize(dsp);
    // ------------------------------------------------------------------------
    Memory::initialize(dsp, mem, 0, WAVETABLE_LEN);
    initialize_default_values(dsp);
    initialize_wavetables(mem.f_zone);
    initialize_osc(dsp);
    // ------------------------------------------------------------------------
    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");

    // main event loop:
    while (running) {
        usleep(5000);
    }
    lo_server_thread_free(osc);
    return 0;
}
