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
#include "plateModalData_mid.h"
#include <sleep.h>

int isTUI = false;

#define OS_FAC 1
#define BASE_SR 48000
#define modesNumber 12952

static const double base_sample_rate = OS_FAC * BASE_SR;

static double k = 1.0/base_sample_rate;
// static float* c1;
// static float* c2;
// static float* c3;
// static float* exc_arr;
// static float* modes_out;
static float c1[modesNumber];
static float c2[modesNumber];
static float c3[modesNumber];
static float exc_arr[modesNumber];
static float modes_out[modesNumber];

static void initialize_coeffs(float* mem) {
    for (int m = 0 ; m < modesNumber; ++m) {
        c1[m] = (float)
            (2.0 * std::exp(-dampCoeffs[m] * k)
             * std::cos(std::sqrt((eigenFreqs[m] * eigenFreqs[m])
                                  - (dampCoeffs[m] * dampCoeffs[m])) * k)
             );
        c2[m] = (float)(-std::exp(-2.0 * dampCoeffs[m] * k));
        c3[m] = (float)(k*k * modesIn[m]);
        exc_arr[m] = 170.0;
        modes_out[m] = modesOut[m];
    }
    fprintf(stderr, "Modal coefficients initialized\r\n");
}

using namespace Syfala;

int main(int argc, char* argv[])
{
    XSyfala x;
    UART::data uart;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    UART::initialize(uart);
    // Wait for all peripherals to be initialized
    Status::waiting(RN("[status] Initializing peripherals & modules"));
    // c1 = new float[modesNumber];
    // c2 = new float[modesNumber];
    // c3 = new float[modesNumber];
    // exc_arr = new float[modesNumber];
    // modes_out = new float[modesNumber];
    Audio::initialize();
    IP::initialize(x);
    // Initialize coefficient arrays ------------
    initialize_coeffs((float*)(Memory::ddr_ptr));
    int n = XSyfala_Write_c1_Words(&x, 0, reinterpret_cast<u32*>(c1), modesNumber);
    fprintf(stderr, "Intialized c1 %d\r\n", n);
    XSyfala_Write_c2_Words(&x, 0, (u32*)(c2), 1);
    fprintf(stderr, "Intialized c2\r\n");
    XSyfala_Write_c3_Words(&x, 0, (u32*)(c3), modesNumber);
    fprintf(stderr, "Intialized c3\r\n");
    XSyfala_Write_xc_Words(&x, 0, (u32*)(exc_arr), modesNumber);
    fprintf(stderr, "Intialized exc\r\n");
    XSyfala_Write_mo_Words(&x, 0, (u32*)(modes_out), modesNumber);
    fprintf(stderr, "Intialized mo\r\n");
    // ------------------------------------------
    IP::set_arm_ok(&x, true);
    Status::ok(RN("[status] Application ready, now running..."));
    // main event loop:
    while (true) {
        // ...
    }
    return 0;
}
