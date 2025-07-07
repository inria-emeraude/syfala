#include <cfloat>
#include <fstream>
#include <sstream>
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
#include <unistd.h>
// #include "plateModalData.h"
// #include "plateModalData_small.h"
#include "plateModalData_mid.h"
#include "syfala/config_common.hpp"
#include "xsyfala.h"

#define OS_FAC 1
#define BASE_SR 48000
#define modesNumber 12952

static const double base_sample_rate = OS_FAC * BASE_SR;
static double k = 1.0/base_sample_rate;

static void initialize_coeffs(XSyfala& x, float* coeffs) {
    int c = 0;
    for (int m = 0 ; m < modesNumber; ++m) {
         coeffs[c] =
             (2.f * std::exp(-dampCoeffs[m] * k)
                  * std::cos(k * std::sqrt(
                     (eigenFreqs[m] * eigenFreqs[m])
                   - (dampCoeffs[m] * dampCoeffs[m])
                  ))
             );
         coeffs[c+1] = (-std::exp(-2.f * dampCoeffs[m] * k));
         coeffs[c+2] = (k * k * modesIn[m]);
         coeffs[c+3] = modesOut[m];
         c += 4;
    }
    fprintf(stderr, "Modal coefficients initialized\r\n");
}

using namespace Syfala::ARM;

int main(int argc, char* argv[])
{
    XSyfala dsp;
    UART::data uart;
    Memory::data mem;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    UART::initialize(uart);
    // Wait for all peripherals to be initialized
    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    DSP::initialize(dsp);
    Memory::initialize(dsp, mem, 0, modesNumber*4 + SYFALA_SAMPLE_RATE);
    float* out = &mem.f_zone[modesNumber*4];
    println("Setting out_samples memory zone");
    XSyfala_Set_out_samples(&dsp, (u64)(out));
    // Initialize coefficient arrays ------------
    println("Initializing modal coefficients");
    initialize_coeffs(dsp, mem.f_zone);
    // ------------------------------------------
    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");

    sleep(1);
    for (int n = 0; n < SYFALA_SAMPLE_RATE; ++n) {
         std::stringstream of;
         of << out[n];
        //  printf("%f\n", out[n]);
        printf("%s\n", of.str().c_str());
    }
    return 0;
}
