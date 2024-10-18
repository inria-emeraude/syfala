
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

using namespace Syfala::ARM;

/** From our gain-control-hls.cpp file, Vitis HLS will generate
  * the following function:
  * void XSyfala_Set_gain(XSyfala *InstancePtr, u32 Data);
  * Note: floating-point data have to be set using 'reinterpret_cast',
  * otherwise, they will be truncated.
*/

static void update_gain(XSyfala& dsp) {
    static float gain = 1.f;
    printf("Enter gain value (from 0.f to 1.f)\r\n");
    scanf("%f", &gain);
    printf("Gain: %f\r\n", gain);
    XSyfala_Set_gain(&dsp, *reinterpret_cast<u32*>(&gain));
}

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
    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");

    // main event loop:
    while (true) {
       // --------------------------------------------------------
       update_gain(dsp);
       sleep(1);
       // --------------------------------------------------------
    }
    return 0;
}
