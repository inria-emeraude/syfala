
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

#include <signal.h>
#include <list>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/memory.hpp>
#include <syfala/arm/spi.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/linux/avahi.hpp>
#include <syfala/utilities.hpp>

static bool running = true;

static void sig_hdl (int signo) {
    switch (signo) {
    case SIGINT:
    case SIGKILL:
    case SIGSTOP: {
        printf("Terminating program\n");
        running = false;
    }
    }
}

using namespace Syfala::ARM;


static bool audio_reset(int argc, char* argv[]) {
    for (int n = 0; n < argc; ++n) {
         if (strcmp(argv[n], "--no-reset") == 0) {
             return false;
         }
    }
    return true;
}

int main(int argc, char* argv[])
{
    XSyfala x;
    SPI::data spi;
    Memory::data mem;
    avahi::service avahi_svc;

    signal(SIGINT, sig_hdl);
    signal(SIGKILL, sig_hdl);
    signal(SIGSTOP, sig_hdl);

    GPIO::initialize();
    Status::waiting("[status] Initializing peripherals & modules");
    DSP::initialize(x);
    Memory::initialize(x, mem, 0, 0);
    SPI::initialize(spi, 0);
    // if CODEC(s) have already been initialized, do not reset audio
    // otherwise we'll hear its unpleasant sound.
    if (audio_reset(argc, argv)) {
        printf("[audio] Initializing Audio Codec(s)\n");
        Audio::initialize();
    }
    DSP::set_arm_ok(&x, true);
    avahi::initialize_run(avahi_svc);
    system("ifconfig | grep 'inet addr'");
    Status::ok("[status] Application ready, now running...");

    while (running) {
#if SYFALA_AUDIO_DEBUG_UART
        float debug[2];
        memset(debug, 0, sizeof(debug));
        DSP::read_audio_out_arm(&x, 0, (u32*)debug, 2);
        for (int n = 0; n < 2; ++n) {
             printf("fpga float output: (%d): %f\r\n", n, debug[n]);
    }
#endif
        sleep(1);
    }
    Status::waiting("[status] Exiting application");
    XSyfala_Release(&x);
    return 0;
}
