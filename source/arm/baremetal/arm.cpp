
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

#include <string.h>
#include <math.h>
#include <iostream>
#include <functional>
#include <xtime_l.h>
#include <sleep.h>

#include <syfala/arm/spi.hpp>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/memory.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/faust/control.hpp>
#include <syfala/arm/tui.hpp>

using namespace Syfala::ARM;
using namespace Syfala::ARM::Faust;

namespace Syfala::ARM::Control {
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
                 UART::data& uart,
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
        // Poll one Message from the UART module.
        // If Message is valid, update it's matching faust controller accordingly
        Result<UART::Message> rmsg = UART::poll(uart);
        if (rmsg.valid) {
            UART::Message& m = rmsg.data;
            Faust::update(faust.control, m.index, m.value);
            vreturn = true;
        }
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
        DSP::write_control_f(&ip, v);
    #elif (FAUST_REAL_CONTROLS > 1)
        DSP::write_control_f(
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
static void send(Faust::data& faust, UART::data& uart, Control::Type ctrl_t) {
    switch (ctrl_t) {
    case Control::Type::Hardware: {
        // TODO with Teensy.
        break;
    }
    case Control::Type::Software: {
        // iterate over all passive controllers
        // send back values
        int n = 0;
        for (auto const& ctrl : faust.control.controllers) {
             if (ctrl.io == Faust::Passive) {
                 UART::Message m = {
                    .index = n,
                    .value = *ctrl.zone
                 };
                 UART::send(uart, m);
             }
             n++;
        }
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
                        XSyfala& dsp,
                     UART::data& uart,
                      SPI::data& spi,
                   Memory::data& mem,
            const Control::Type ctrl_t,
                           bool force = false
){
    // If DSP IP is ready to receive new control values
    if (DSP::get_control_block(&dsp) == SYFALA_CONTROL_RELEASE) {
            // 1. Block control buffers.
            // 2. Poll controllers (UART/SPI).
        DSP::set_control_block(&dsp, SYFALA_CONTROL_BLOCK_HOST);
        if (poll(faust, uart, spi, ctrl_t) || force) {
            // 3. Compute int & float control expressions from controller inputs.
            // 4. Send updated values to IP.
            // 5. Allow DSP IP to read the control values once everything is written.
        #if FAUSTMINORVERSION > 72
            faust.dsp.control();
        #else
            faust.dsp.control(
                faust.control.i,
                faust.control.f,
                mem.i_zone,
                mem.f_zone
            );
        #endif
            write(faust, dsp);
            DSP::set_control_block(&dsp, SYFALA_CONTROL_RELEASE);
        } else {
            DSP::set_control_block(&dsp, SYFALA_CONTROL_RELEASE);
      }
    }
    // If there are 'passive' controllers (bargraphs)
    if constexpr (Faust::npassives() > 0) {
    // Read and send back 'passive' control values.
       read(faust, dsp);
       send(faust, uart, ctrl_t);
    }
}

namespace xtime {

using hdl = XTime;
constexpr auto get_time = XTime_GetTime;

static inline double get_elapsed_time(hdl& start, hdl& end) {
    get_time(&end);
    return (end-start) * 1000 / COUNTS_PER_SECOND;
}

static void print_elapsed_time(hdl& start, hdl& end) {
    double ms = get_elapsed_time(start, end);
    Syfala::ARM::debug("[bench] Control-loop time: %f milliseconds", ms);
}
}

#define RGB_LED_OK 0b010
#define RGB_LED_FLASH_TIME_MS 500

/**
 * @brief Process SW0-SW3 and LD0-LD3 states
 */
static void process_sw() {
    static xtime::hdl start = 0, end = 0;
    static double t = 0;
    static bool flash = true;
    static int sw[4];
    bool flash_update = false;
    bool warning = false;
    int value = 0;

    if (start == 0) {
        xtime::get_time(&start);
    }
    if (t >= RGB_LED_FLASH_TIME_MS) {
        t -= RGB_LED_FLASH_TIME_MS;
        xtime::get_time(&start);
        flash_update = true;
        flash = !flash;
    }
    if (GPIO::read_sw(0)) {
        // Mute (SW0) is enabled,
        // LD5: Warning
        // LD0: Flashing
        warning = true;
        if (flash_update) {
            Status::warning("[warning] Mute enabled");
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
            Status::warning("[warning] Bypass enabled: no audio inputs");
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
                Status::error("[status] SSM2603: Sample rate not supported");
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
        t = xtime::get_elapsed_time(start, end);
    }
}

namespace Teensy {
/**
 * @brief Initialize the Teensy controller by sending it,
 * through the proper SPI channels, a list of the Faust controllers
 * to display. For details on implementation, see 'source/arm/baremetal/spi.cpp'
 * @param controllers: Faust controller array.
 * @param ncontrollers: Number of Faust controllers.
 */
static void initialize(std::vector<Faust::controller> const& controllers) {
    int n = 0;
    for (Faust::controller const& c : controllers) {
        Syfala::ARM::info("[arduino] Adding controller %d (%s) (%f, %f, %f, %f)",
               n, c.id.c_str(), c.init, c.min, c.max, c.step);
        SPI::Teensy::initialize(c.id.c_str(), n, c.init, c.min, c.max, c.step);
        n++;
    }
}
}

using namespace Syfala;

int main(int argc, char* argv[])
{
    UART::data uart;
    Memory::data mem;
    Faust::data faust;
    SPI::data spi;
    XSyfala dsp;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on LEDs & stdout (ttyPS).
    // QUICK FIX (Genesys): pour le moment on desactive l'init de l'uart (qui est automatique de toutes façon),
    // sinon on arrive pas à afficher correctement l'initialisation.
#if (SYFALA_BOARD_ZYBO) // --
    UART::initialize(uart);
#endif // -------------------
    GPIO::initialize();
    Control::Type ctrl_t = Control::Type::Undefined;
    // Wait for all peripherals to be initialized
    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    // First thing to do is to initialize the Syfala IP and tell it
    // not to compute anything until all ARM-side modules
    // are initialized and ready.
    DSP::initialize(dsp);
    Memory::initialize(dsp, mem, FAUST_INT_ZONE, FAUST_FLOAT_ZONE);
    Faust::initialize(faust, mem.i_zone, mem.f_zone);
    SPI::initialize(spi, faust.control.ncontrollers());
    // Compute/initialize first control values to be written
    // on the axilite adapter.
    control(faust, dsp, uart, spi, mem, ctrl_t, true);
    // From this point, we can tell the DSP IP to start processing samples
    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");

#if (SYFALA_BOARD_GENESYS)
    TUI::initialize();
#endif

    // Main event loop:
    while (true) {
    #if (SYFALA_BOARD_GENESYS)
        TUI::updateUserInput();
    #endif
        if constexpr (SYFALA_ARM_BENCHMARK) {
            static xtime::hdl start = 0, end = 0;
            xtime::print_elapsed_time(start, end);
            xtime::get_time(&start);
        }
        // Check if controller-type switch value has changed
        Control::Type t = Control::get_current_controller_type();
        if (ctrl_t != t) {
            // If changed, reinitialize the proper peripherals.
            Syfala::ARM::info("[control] controller changed");
            ctrl_t = t;
            if constexpr (SPI::controller() == SPI::Controller::Teensy) {
                Syfala::ARM::info("[control] Teensy controller");
                Teensy::initialize(faust.control.controllers);
            }
        }
        // Poll, update & send back control data.
        control(faust, dsp, uart, spi, mem, ctrl_t);
        process_sw();
    #if SYFALA_DEBUG_AUDIO //--------------------------------------
        float outputs[FAUST_OUTPUTS];
        DSP::read_arm_debug(&ip, 0, (u32*)(outputs), FAUST_OUTPUTS);
        for (int n = 0; n < FAUST_OUTPUTS; ++n) {
             Syfala::ARM::debug("[xsyfala] audio_out_%d: %f\n", n, outputs[0]);
        }
    #endif //------------------------------------------------------
    }
    return 0;
}
