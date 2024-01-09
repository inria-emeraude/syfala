
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

int isTUI = false;

static bool running = true;

/**
 * @brief Terminates program when we receive a
 * SIGINT(2), SIGKILL(9) or SIGSTOP(19) signal.
 */
static void sig_hdl (int signo) {
    switch (signo) {
    case SIGINT:
    case SIGKILL:
    case SIGSTOP: {
        printf("[syfala] Terminating program\n");
        running = false;
    }
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

using namespace Syfala;

namespace Syfala::Control {
enum Type {
    Software,
    Hardware,
    Undefined
};

/**
 * @brief Read data from GPIO switch 3:
 * 0 (down) - means Software control.
 * 1 (up) - means Hardware control.
 * @return
 */
static inline Type get_current_controller_type() {
    return static_cast<Type>(GPIO::read_sw(3));
}
}

/**
 * @brief Poll data from control peripherals (UART/SPI)
 * and update Faust control data.
 * @param d: A reference to the Faust control data.
 * @param u: A reference to the UART control data.
 * @param s: A reference to the SPI control data.
 * @param ctrl_t: Current controller type (Hardware/Software)
 * @return
 */
static bool poll(Faust::data& faust,
                 SPI::data& spi,
                 const Control::Type ctrl_t
) {
    // For each control data poll, check if we're in
    // 'hardware' (SPI) or 'software' (UART) mode
    // This is managed by 'SW3' on Zybo boards
    bool vreturn = false;
    switch (ctrl_t) {
    case Control::Type::Hardware: {
        // Retrieve the number of Faust controllers (sliders/buttons/etc.)
        // Limit this number by the number of available Hardware controls.
        // i.e. for the Syfala PCB controllers: the limit is 8.
        int ncontrols = faust.control.ncontrollers();
        ncontrols = std::min(ncontrols, SPI::capacity());
        // Poll SPI controller
        SPI::poll(spi);
        for (int n = 0; n < ncontrols; ++n) {
            // If value has changed, update the matching faust controller.
             if (spi.change[n]) {
                 float v = spi.values[n];
                 if constexpr (SPI::controller() == SPI::Controller::PCB) {
                    // 'PCB' controller values are normalized from 0.f to 1.f
                    // We have to call Faust update function with 'scale = true'.
                    // We can also set the 'map' option to true, which will allow
                    // us to use the controller metadata mappings, if set in the .dsp file.
                    Faust::update(faust.control, n, v, true, true);
                 } else {
                    // For other controllers, update values normally.
                    Faust::update(faust.control, n, v);
                 }
                 vreturn = true;
             }
        }
    }
    case Control::Type::Software: {
        // (?)
        break;
    }
    }
    return vreturn;
}

/**
 * @brief Writes int/float controller values in AXI-Lite shared memory
 * to be retrieved by the Syfala DSP IP.
 * @param d: A reference to the Faust control data.
 * @param x A reference to the Syfala DSP IP data.
 */
static inline void write(Faust::data& faust, XSyfala& ip) {
    // Note: we can't use 'constexpr if' in that case,
    // because the functions write_control_f and write_control_i
    // don't exist if the matching macros are equal to 0.
    #if (FAUST_REAL_CONTROLS == 1)
        u32 v = *reinterpret_cast<u32*>(faust.control.f);
        IP::write_control_f(&ip, v);
    #elif (FAUST_REAL_CONTROLS > 1)
        IP::write_control_f(
            &ip, 0, reinterpret_cast<u32*>(faust.control.f),
            Faust::ncontrols_f()
        );
    #endif
    #if (FAUST_INT_CONTROLS == 1)
        IP::write_control_i(&ip, *faust.control.i);
    #elif (FAUST_INT_CONTROLS > 1)
        IP::write_control_i(
            &ip, 0, reinterpret_cast<u32*>(faust.control.i),
            Faust::ncontrols_i()
        );
    #endif
}
/**
 * @brief Read passive controller values written by the DSP IP
 * through the AXI-Lite bus.
 * @param d: A reference to the Faust control data.
 * @param x A reference to the Syfala DSP IP data.
 */
static inline void read(Faust::data& faust, XSyfala& ip) {
    int field = 0;
#if (FAUST_PASSIVES == 1)
    faust.control.p[0] = IP::read_control_p(&ip);
#elif (FAUST_PASSIVES > 1)
    IP::read_control_p(
        &ip, 0, reinterpret_cast<u32*>(faust.control.p),
        Faust::npassives()
    );
    FAUST_LIST_PASSIVES(ACTIVE_ELEMENT_IN);
#endif
}

/**
 * @brief Send back Faust control data to the
 * control Peripheral (UART/SPI).
 * @param d: A reference to the Faust control data.
 * @param u A reference to the UART control data.
 * @param ctrl_t: The current controller type (Hardware/Software).
 */
static void send(Faust::data& faust, Control::Type ctrl_t) {
    switch (ctrl_t) {
    case Control::Type::Hardware: {
        // TODO with Teensy.
        break;
    }
    case Control::Type::Software: {
        break;
    }
    }
}

// --------------------------------------------------------------------------------
/**
 * @brief Main control procedure, which is called at each 'control' loop
 * iteration.
 * @param faust: A reference to the Faust control data.
 * @param ip: A reference to the Syfala DSP IP control data.
 * @param uart: A reference to the UART module data.
 * @param spi: A reference to the SPI module data.
 * @param mem: A reference to the Memory module data.
 * @param ctrl_t The current controller type (Hardware/Software)
 * @param force Force the writing of control values, even if control
 * values have not changed
 */
// --------------------------------------------------------------------------------
__attribute__((hot))
static void control(Faust::data& faust,
                        XSyfala& ip,
                      SPI::data& spi,
                   Memory::data& mem,
            const Control::Type ctrl_t,
                           bool force = false
){
    // If DSP IP is ready to receive new control values
    if (IP::get_control_block(&ip) == SYFALA_CONTROL_RELEASE) {
            // 1. Block control buffers.
            // 2. Poll controllers (UART/SPI).
        IP::set_control_block(&ip, SYFALA_CONTROL_BLOCK_HOST);
        if (poll(faust, spi, ctrl_t) || force) {
            // 3. Compute int & float control expressions from controller inputs.
            // 4. Send updated values to IP.
            // 5. Allow DSP IP to read the control values once everything is written.
            faust.dsp.control (
                faust.control.i,
                faust.control.f,
                mem.i_zone, mem.f_zone
            );
            write(faust, ip);
            IP::set_control_block(&ip, SYFALA_CONTROL_RELEASE);
        } else {
            IP::set_control_block(&ip, SYFALA_CONTROL_RELEASE);
      }
    }
    // If there are 'passive' controllers (bargraphs)
    if constexpr (Faust::npassives() > 0) {
    // Read and send back 'passive' control values.
       read(faust, ip);
       send(faust, ctrl_t);
    }
}

#include <ctime>

static inline time_t get_time_ms() {
    using namespace std::chrono;
    struct timeval t = {};
    gettimeofday(&t, nullptr);
    return t.tv_usec * 1000;
}

static inline time_t get_elapsed_time(time_t start) {
    using namespace std::chrono;
    time_t end = get_time_ms();
    return end-start;
}

#define RGB_LED_OK 0, 1, 0
#define RGB_LED_FLASH_TIME_MS 500

/**
 * @brief Process SW0-SW3 and LD0-LD3 states
 */
static void process_sw() {
    static time_t start = 0, end = 0;
    static time_t t = 0;
    static bool flash = true;
    static int sw[4];
    bool flash_update = false;
    bool warning = false;
    int value = 0;

    if (start == 0) {
        start = get_time_ms();
    }
    if (t >= RGB_LED_FLASH_TIME_MS) {
        t -= RGB_LED_FLASH_TIME_MS;
        start = get_time_ms();
        flash_update = true;
        flash = !flash;
    }
    if (GPIO::read_sw(0)) {
        // Mute (SW0) is enabled,
        // LD5: Warning
        // LD0: Flashing
        warning = true;
        if (flash_update) {
            Status::warning(RN("[warning] Mute enabled"));
            sw[0] = flash;
        }
    } else {
        sw[0] = 0;
    }
    if (GPIO::read_sw(1) && Faust::inputs() == 0) {
        // Bypass (SW1) enabled, no inputs:
        // Warning LED
        warning = true;
        if (flash_update) {
            Status::warning(RN("[warning] Bypass enabled: no audio inputs"));
            sw[1] = flash;
        }
    } else {
        sw[1] = GPIO::read_sw(1);
    }
    if (SYFALA_BOARD_ZYBO && (GPIO::read_sw(2) == 0)) {
        // SSM2603 selected (SW2) on incompatible config
        if (SYFALA_SAMPLE_RATE > 96000) {
            warning = true;
            if (flash_update) {
                sw[2] = flash;
                Status::error(RN("[status] SSM2603: Sample rate not supported"));
            }
        } else {
            sw[2] = GPIO::read_sw(2);
        }
    } else {
        sw[2] = GPIO::read_sw(2);
    }
    sw[3] = GPIO::read_sw(3);
    GPIO::write_sw_led(sw[0], sw[1], sw[2], sw[3]);
    flash_update = false;

    if (warning == false) {
        GPIO::write_ld5(RGB_LED_OK);
    } else {
        t = get_elapsed_time(start);
    }
}

int main(int argc, char* argv[])
{
    XSyfala ip;
    SPI::data spi;
    Memory::data mem;
    Faust::data faust;
    avahi::service avahi_svc;
    Control::Type ctrl_t = Control::Type::Undefined;

    signal(SIGINT,  sig_hdl);
    signal(SIGKILL, sig_hdl);
    signal(SIGSTOP, sig_hdl);

    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on LEDs & stdout (ttyPS).
    GPIO::initialize();
    Status::waiting("[status] Initializing peripherals & modules");
    IP::initialize(ip);
    Memory::initialize(ip, mem, FAUST_INT_ZONE, FAUST_FLOAT_ZONE);
    Faust::initialize(faust, mem.i_zone, mem.f_zone);
    SPI::initialize(spi, faust.control.ncontrollers());

    // if CODEC(s) have already been initialized, do not reset audio
    // otherwise we'll hear its unpleasant sound.
    if (audio_reset(argc, argv)) {
        printf("[audio] Initializing Audio Codec(s)\n");
        Audio::initialize();
    }
    // Initializes MIDI control (RtMidi backend) if application
    // has been compiled with the '--midi' flag.
#if (SYFALA_CONTROL_MIDI)
    rt_midi rt("MIDI");
    MidiUI midi_ui(&rt);
    faust.dsp.buildUserInterface(&midi_ui);
    midi_ui.run();
#endif
    // Initializes Faust HTTP control if application
    // has been compiled with the '--http' flag.
#if (SYFALA_CONTROL_HTTP)
    httpdUI http("http", faust.dsp.getNumInputs(), faust.dsp.getNumOutputs(), 0, 0);
    faust.dsp.buildUserInterface(&http);
    http.run();
#endif
    // Initializes Faust OSC control (liblo backend) if application
    // has been compiled with the '--osc' flag.
#if (SYFALA_CONTROL_OSC)
    OSCUI osc("osc", 0, 0);
    faust.dsp.buildUserInterface(&osc);
    osc.run();
#endif

    control(faust, ip, spi, mem, ctrl_t, true);
    IP::set_arm_ok(&ip, true);
    avahi::initialize_run(avahi_svc);
    system("ifconfig | grep 'inet addr'");
    Status::ok("[status] Application ready, now running...");

    while (running) {
        Control::Type t = Control::get_current_controller_type();
        if (ctrl_t != t) {
            // TODO: handle controller type change here.
            ctrl_t = t;
        }
        control(faust, ip, spi, mem, ctrl_t, true);
        process_sw();

    #if (SYFALA_DEBUG_AUDIO)
        float debug[FAUST_OUTPUTS];
        memset(debug, 0, sizeof(debug));
        IP::read_audio_out_arm(&ip, 0, (u32*)debug, FAUST_OUTPUTS);
        for (int n = 0; n < FAUST_OUTPUTS; ++n) {
             printf("fpga float output: (%d): %f\r\n", n, debug[n]);
    }
    #endif
    }
    Status::waiting("[status] Exiting application");
    XSyfala_Release(&ip);
    return 0;
}
