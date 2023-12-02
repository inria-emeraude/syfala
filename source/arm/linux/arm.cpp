
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
#include <syfala/arm/faust/control.hpp>
#include <syfala/arm/linux/avahi.hpp>
#include <syfala/utilities.hpp>

#if SYFALA_CONTROL_HTTP
#include <faust/gui/httpdUI.h>
#endif
#if SYFALA_CONTROL_OSC
#include <faust/gui/OSCUI.h>
#endif
#if SYFALA_CONTROL_MIDI
#include <faust/gui/MidiUI.h>
#include <faust/midi/rt-midi.h>
#include <faust/midi/RtMidi.cpp>
#endif

#if (SYFALA_CONTROL_HTTP | SYFALA_CONTROL_OSC | SYFALA_CONTROL_MIDI)
std::list<GUI*> GUI::fGuiList;
ztimedmap GUI::gTimedZoneMap;
#endif

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

using namespace Syfala;
using namespace Syfala::Faust;

static inline void write(Control::data& d, XSyfala& x) {
    #if FAUST_REAL_CONTROLS
        IP::write_control_f(&x, 0, (u32*) d.control.f, FAUST_REAL_CONTROLS);
    #endif
    #if FAUST_INT_CONTROLS
        IP::write_control_i(&x, 0, (u32*) d.control.i, FAUST_INT_CONTROLS);
    #endif
}

#if FAUST_PASSIVES
static inline void read(Control::data& d, XSyfala& x) {
    int field = 0;
    IP::read_control_p(&x, 0, (u32*) d.control.p, FAUST_PASSIVES);
    FAUST_LIST_PASSIVES(ACTIVE_ELEMENT_IN);
}
#endif

static void send(Control::data& d) {
    switch (Control::get_current_controller_type()) {
    case Control::Hardware: {
        break; // no need for it just yet.
    }
    case Control::Software: {
        break;
    }
    }
}

__attribute__((hot)) static void control(
            Faust::Control::data& d,
                         XSyfala& x,
                       SPI::data& s,
                    Memory::data& m
){
    // if IP is ready to receive new control values
    if (IP::get_control_block(&x) == SYFALA_CONTROL_RELEASE) {
            // 1. block control buffers
            // 2. poll controllers (UART/SPI).
        IP::set_control_block(&x, SYFALA_CONTROL_BLOCK_HOST);
        // 3. compute int & float control expressions from controller inputs.
        // 4. send updated values to IP.
        // 5. allow IP to read the control values once everything is written
        d.dsp.control(d.control.i, d.control.f, m.i_zone, m.f_zone);
        write(d, x);
        IP::set_control_block(&x, SYFALA_CONTROL_RELEASE);
    } else {
        sy_printf("Control lock acquired by FPGA");
    }
}

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
    Faust::Control::data ctrl;
    avahi::service avahi_svc;

    signal(SIGINT, sig_hdl);
    signal(SIGKILL, sig_hdl);
    signal(SIGSTOP, sig_hdl);

    GPIO::initialize();
    Status::waiting(RN("Initializing peripherals & modules"));
    IP::initialize(x);
    Memory::initialize(x, mem, FAUST_INT_ZONE, FAUST_FLOAT_ZONE);
    SPI::initialize(spi);

    // if CODEC(s) have already been initialized, do not reset audio
    // otherwise we'll hear its unpleasant sound.
    if (audio_reset(argc, argv)) {
        printf("Initializing Audio Codec(s)\n");
        Audio::initialize();
    }

    Faust::Control::initialize(ctrl, mem.i_zone, mem.f_zone);
#if SYFALA_CONTROL_MIDI // ----------------------------------
    rt_midi rt("MIDI");
    MidiUI midi_ui(&rt);
    ctrl.dsp.buildUserInterface(&midi_ui);
    midi_ui.run();
#endif
#if SYFALA_CONTROL_HTTP // ----------------------------------
    httpdUI http("http", ctrl.dsp.getNumInputs(), ctrl.dsp.getNumOutputs(), 0, 0);
    ctrl.dsp.buildUserInterface(&http);
    http.run();
#endif
#if SYFALA_CONTROL_OSC // -----------------------------------
    OSCUI osc("osc", 0, 0);
    ctrl.dsp.buildUserInterface(&osc);
    osc.run();
#endif

    control(ctrl, x, spi, mem);
    IP::set_arm_ok(&x, true);
    avahi::initialize_run(avahi_svc);
    system("ifconfig | grep 'inet addr'");
    Status::ok(RN("Application ready, now running..."));

    while (running) {
        control(ctrl, x, spi, mem);
#if SYFALA_AUDIO_DEBUG_UART // ---------------------------------------
        float debug[FAUST_OUTPUTS];
        memset(debug, 0, sizeof(debug));
        IP::read_audio_out_arm(&x, 0, (u32*)debug, FAUST_OUTPUTS);
        for (int n = 0; n < FAUST_OUTPUTS; ++n) {
             printf("fpga float output: (%d): %f\r\n", n, debug[n]);
    }
#endif // ------------------------------------------------------------
    }
    Status::waiting(RN("Exiting application\n"));
    XSyfala_Release(&x);
    return 0;
}
