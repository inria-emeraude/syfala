#include <syfala/utilities.hpp>
#include <cmath>

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
#include <syfala/arm/memory.hpp>
#include <syfala/arm/ip.hpp>
#include "plateModalData.h"

#define OS_FAC 1
#define BASE_SR 48000
#define modesNumber 30000

static const double base_sample_rate = OS_FAC * BASE_SR;
static double k = 1.0/base_sample_rate;

static void initialize_coeffs(XSyfala& x, float* coeffs) {
    int c = 0;
    for (int m = 0 ; m < modesNumber; ++m) {
         coeffs[c] = 2.f * std::exp(-dampCoeffs[m] * k)
                   * std::cos(k * std::sqrt(
                        eigenFreqs[m] * eigenFreqs[m]
                      - dampCoeffs[m] * dampCoeffs[m]
                    ));
        coeffs[c+1] = -std::exp(-2.0 * dampCoeffs[m] * k);
        coeffs[c+2] = k * k * modesIn[m];
        coeffs[c+3] = modesOut[m];
        c += 4;
    }
    XSyfala_Set_coeffs(&x, (u64)(coeffs));
    fprintf(stderr, "Modal coefficients initialized\r\n");
}

using namespace Syfala::ARM;

int main(int argc, char* argv[])
{
    XSyfala dsp;
    UART::data uart;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    UART::initialize(uart);
    // Wait for all peripherals to be initialized
    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    DSP::initialize(dsp);
    // Initialize coefficient arrays ------------
    initialize_coeffs(dsp, (float*)(Memory::ddr_ptr));

    // ------------------------------------------
    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");
    // main event loop:
    while (true) {
        // ...
    }
    return 0;
}
