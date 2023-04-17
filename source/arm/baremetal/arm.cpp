
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

using namespace Syfala;
using namespace Syfala::Faust;

static bool poll(Control::data& d, UART::data& u, SPI::data& s) {
    switch (Control::get_current_controller_type()) {
    case Control::type::Hardware: {
        auto ncontrols = std::min(8U, d.control.N);
        SPI::poll(s);
        bool r = false;
        for (int n = 0; n < ncontrols; ++n) {
             if (s.change[n]) {
                 float v = s.values[n]/1023.f;
                 if (controllerBoard[n] == SWITCH) {
                     v = v > 0.f ? 1 : 0;
                 }
                 Control::update_controller_hw(d.control, n, v);
                 r = true;
             }
        }
        return r;
    }
    case Control::type::Software: {
        auto r = UART::poll(u);
        if (r.valid) {
            UART::Message& m = r.data;
            update_controller_sw(d.control, m.index, m.value);
            return true;
        } else {
            return false;
        }
    }
    }
}

static inline void write(Control::data& d, XSyfala& x) {
    #if FAUST_REAL_CONTROLS
        IP::write_control_f(&x, 0, reinterpret_cast<u32*>(d.control.f), FAUST_REAL_CONTROLS);
    #endif
    #if FAUST_INT_CONTROLS
        IP::write_control_i(&x, 0, reinterpret_cast<u32*>(d.control.i), FAUST_INT_CONTROLS);
    #endif
}

static inline void read(Control::data& d, XSyfala& x) {
    int field = 0;
    IP::read_control_p(&x, 0, reinterpret_cast<u32*>(d.control.p), FAUST_PASSIVES);
    FAUST_LIST_PASSIVES(ACTIVE_ELEMENT_IN);
}

static void send(Control::data& d, UART::data& u) {
    switch (Control::get_current_controller_type()) {
    case Control::Hardware: {
        break; // no need for it just yet.
    }
    case Control::Software: {
        // iterate over all passive controllers
        // send back values
        for (int n = 0; n < d.control.N; ++n) {
             auto const& c = d.control.controllers[n];
             if (c.io == Control::Passive) {
                 UART::Message m = {
                    .index = n,
                    .value = *c.zone
                 };
                 UART::send(u, m);
             }
        }
        break;
    }
    }
}

__attribute__((hot))
static void control(Control::data& d,
                          XSyfala& x,
                       UART::data& u,
                        SPI::data& s,
                              int* i_zone,
                            float* f_zone,
                              bool force = false)
{
    // if IP is ready to receive new control values
    if (IP::get_control_block(&x) == SYFALA_CONTROL_RELEASE) {
            // 1. block control buffers
            // 2. poll controllers (UART/SPI).
        IP::set_control_block(&x, SYFALA_CONTROL_BLOCK_HOST);
        if (poll(d, u, s) || force) {
            // 3. compute int & float control expressions from controller inputs.
            // 4. send updated values to IP.
            // 5. allow IP to read the control values once everything is written
            d.dsp.control(d.control.i, d.control.f, i_zone, f_zone);
            write(d, x);
            IP::set_control_block(&x, SYFALA_CONTROL_RELEASE);
        } else {
            IP::set_control_block(&x, SYFALA_CONTROL_RELEASE);
      }
    } else {
        sy_printf("Control lock acquired by FPGA");
    }
   #if FAUST_PASSIVES // --------------------------
    // read and send back 'passive' control values.
       read(d, x);
       send(d, g, u);
    #endif // -------------------------------------
}

#if SYFALA_HOST_BENCHMARK // --------------------------------
static XTime start, end;
static void print_elapsed_time() {
    XTime_GetTime(&end);
    double msec = (end-start)*1000/COUNTS_PER_SECOND;
    printf(RN("control loop time: %f milliseconds"), msec);
}
#endif // ---------------------------------------------------

using namespace Syfala;

int main(int argc, char* argv[])
{
    UART::data uart;
    Memory::data mem;
    Control::data ctrl;
    SPI::data spi;
    XSyfala x;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    UART::initialize(uart);
    // Wait for all peripherals to be initialized
    Status::waiting(RN("Initializing peripherals & modules"));
    // first thing to do is to initialize the syfala IP and tell it
    // not to compute anything until all ARM-side modules
    // are initialized and ready.
         IP::initialize(x);
     Memory::initialize(x, mem, FAUST_INT_ZONE, FAUST_FLOAT_ZONE);
        SPI::initialize(spi);
      Audio::initialize();
    Control::initialize(ctrl, mem.i_zone, mem.f_zone);
    // Compute/initialize first control values to be written
    // on the axilite adapter.
    control(ctrl, x, uart, spi, mem.i_zone, mem.f_zone, true);
    // From this point, we can tell the IP to start processing samples
    IP::set_arm_ok(&x, true);
    Status::ok(RN("Application ready, now running..."));
    // main event loop:
    while (true) {
    #if SYFALA_HOST_BENCHMARK // -----------------------------------------
        XTime_GetTime(&start);
    #endif // ------------------------------------------------------------
        control(ctrl, x, uart, spi, mem.i_zone, mem.f_zone);
//        usleep(UART::get_byte_transmission_period_usec());
        switch (Control::get_current_controller_type()) {
        case Control::type::Hardware: {
            break;
        }
        case Control::type::Software: {
            usleep(5000);
            break;
        }
        }
    #if SYFALA_HOST_BENCHMARK // -----------------------------------------
        print_elapsed_time();
    #endif // ------------------------------------------------------------
    #if SYFALA_AUDIO_DEBUG_UART // ---------------------------------------
        float debug[FAUST_OUTPUTS];
        memset(debug, 0, sizeof(debug));
        IP::read_audio_out_arm(&x, 0, (u32*)debug, FAUST_OUTPUTS);
        for (int n = 0; n < FAUST_OUTPUTS; ++n) {
             printf("fpga float output: (%d): %f\r\n", n, debug[n]);
        }
    #endif // ------------------------------------------------------------
    }
    return 0;
}
