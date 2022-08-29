
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

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <math.h>
#include <map>
#include <iostream>
#include <functional>
#include <xil_cache.h>
#include <xgpio.h>
#include <sleep.h>
#include <xuartps.h>

#include "syconfig.hpp"
#include <syfala/arm/spips.h>
#include <syfala/arm/iic_config.h>
#include <syfala/arm/uart-interface.hpp>

#include <faust/gui/meta.h>
#include <faust/dsp/one-sample-dsp.h>
#include <faust/gui/DecoratorUI.h>

/* Faust IP configuration */
#define FAUST_UIMACROS 1

/* Generic definition used to accept a variable
 number of controllers */
#define FAUST_ADDBUTTON(l,f)
#define FAUST_ADDCHECKBOX(l,f)
#define FAUST_ADDVERTICALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDHORIZONTALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDNUMENTRY(l,f,i,a,b,s)
#define FAUST_ADDVERTICALBARGRAPH(l,f,a,b)
#define FAUST_ADDHORIZONTALBARGRAPH(l,f,a,b)

using namespace std;

#ifdef SYFALA_TESTING_PRECOMPILED
    #include FAUST_PRECOMPILED_EXAMPLE_ARM_TARGET
#else
    // The Faust compiler will insert the C code here
    <<includeIntrinsic>>
    <<includeclass>>
#endif

namespace GPIO // -------------------------------------------------------------
{
struct data {
    XGpio led;
    XGpio sw;
};

#define WAITING_LED     0b001
#define WARNING_LED     0b110
#define OK_LED          0b010
#define ERROR_LED       0b100

void initialize(data& d) {
    //initialize input XGpio variable
    XGpio_Initialize(&d.led, XPAR_AXI_GPIO_LED_DEVICE_ID);
    XGpio_Initialize(&d.sw, XPAR_AXI_GPIO_SW_DEVICE_ID);
    //set first channel tristate buffer to output (RGB led)
    XGpio_SetDataDirection(&d.led, 1, 0x0);
    //set second channel tristate buffer to output (LED)
    XGpio_SetDataDirection(&d.led, 2, 0x0);
    //set first channel tristate buffer to input (switch)
    XGpio_SetDataDirection(&d.sw, 1, 0xF);
}
}

namespace Info // ----------------------------------------------------
{
__always_inline void
waiting(GPIO::data& gpio, const char* message) {
    XGpio_DiscreteWrite(&gpio.led, 2, WAITING_LED);
    xil_printf(message);
}

__always_inline void
warning(GPIO::data& gpio, const char* message) {
    XGpio_DiscreteWrite(&gpio.led, 2, WARNING_LED);
    xil_printf(message);
}

__always_inline void
error(GPIO::data& gpio,const char* message) {
    XGpio_DiscreteWrite(&gpio.led, 2, ERROR_LED);
    xil_printf(message);
}

__always_inline void
ok(GPIO::data& gpio, const char* message) {
    XGpio_DiscreteWrite(&gpio.led, 2, OK_LED);
    xil_printf(message);
}
}

namespace UART // -------------------------------------------------------------
{

struct data {
  XUartPs ps;
};

/** Initialize the UART driver so that it's ready to use
* Look up the configuration in the config table and then initialize it.
*/
void initialize(data& d, GPIO::data& g) {
  // WARNING!! It works well without this initialisation
  // I don't know if I have to do it... (Maxime)
   XUartPs_Config* c;
   c = XUartPs_LookupConfig(XPAR_XUARTPS_0_DEVICE_ID);
   if (c == nullptr) {
       Info::error(g, "ERROR: XUartPs configuration not found.\n");
   }
   int status = XUartPs_CfgInitialize(&d.ps, c, XPAR_XUARTPS_0_BASEADDR);
   if (status != XST_SUCCESS) {
       Info::error(g, "ERROR: could not initialize XUartPs configuration\n");
   }
   XUartPs_SetBaudRate(&d.ps, 115200);
}
}

namespace Audio // ------------------------------------------------------------
{
void initialize(GPIO::data& g) {
    // Initialize IIC controller
    if (fnInitIic() != XST_SUCCESS) {
        Info::error(g, "Error: initializing I2C controller.\n");
        exit(1);
    }
#if SYFALA_BOARD_GENESYS // -----------------------------------------
    if (GenCodecSetConfig() != XST_SUCCESS) {
        Info::error(g, "Error: Genesys codec configuration.\n");
    }
#elif SYFALA_BOARD_Z10 || SYFALA_BOARD_Z20 // -----------------------
    if (SSMSetConfig(SYFALA_SSM_VOLUME, SSM_R07, SSM_R08) != XST_SUCCESS) {
        Info::error(g, "Error: SSMSetConfig failed.\n");
        exit(1);
    }
#endif
}
}

namespace SPI // --------------------------------------------------------------
{
void initialize(GPIO::data& g) {
    int status  = SpiPs_Init(XPAR_XSPIPS_0_DEVICE_ID);
    if (status != XST_SUCCESS) {
        Info::error(g, "ERROR: failed to initialize SPI\n");
        exit(1);
    }
}
}
// ----------------------------------------------------------------------------
// MAIN
// ----------------------------------------------------------------------------

int main(int argc, char* argv[])
{
    UART::data uart;
    GPIO::data gpio;
    // UART & GPIO should be initialized first,
    // i.e. before outputing information.
    GPIO::initialize(gpio);
    UART::initialize(uart, gpio);

    // Wait for all peripherals to be initialized
    Info::waiting(gpio, "Initializing...\n");
    SPI::initialize(gpio);
    Audio::initialize(gpio);
    Info::ok(gpio, "Application ready, now running\n");
    while (true);
    return 0;
}
