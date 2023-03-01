
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
// #include <unistd.h>  conflict with sleep.h...

/* Xilinx includes */
#include "sleep.h"
#include "xuartps.h"
#include "xsyfala.h"
/* Syfala application includes */
#include "syconfig.hpp"
#include <syfala/arm/spips.h>
#include <syfala/arm/iic_config.h>
#include <syfala/arm/uart-interface.hpp>
#include <syfala/arm/utils.h>


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

/* Define the maximum number of ADAU1787 that can be connected
 * It depends of the available addresses */
#define MAX_EXTERNAL_1787 16

/* DDR zone coherent with linker script lscript.ld */

#if SYFALA_BOARD_Z10 || SYFALA_BOARD_Z20
    #define FRAME_BUFFER_BASEADDR   0x1D000000
    #define FRAME_BUFFER_DEPTH      0x02000000
    #define FRAME_BUFFER_HIGHADDR   FRAME_BUFFER_BASEADDR+FRAME_BUFFER_DEPTH
#elif SYFALA_BOARD_GENESYS
    #define FRAME_BUFFER_BASEADDR   0x0
    #define FRAME_BUFFER_DEPTH      0x40000000	// 1go
    #define FRAME_BUFFER_HIGHADDR   FRAME_BUFFER_BASEADDR+FRAME_BUFFER_DEPTH
#else
    #error("Could not identify any Board Model")
#endif

#define DDR_CLEAR_STEP  0x1000000
// 0x1000000 = 16mo (Quantity of memory clear for each printed dot during ddr clear)

#if (SYFALA_MEMORY_USE_DDR == 1)
     u32* ddr_ptr = (u32*) FRAME_BUFFER_BASEADDR;
#endif

#define WAITING_LED 0b001
#define WARNING_LED 0b110
#define OK_LED 0b010
#define ERROR_LED 0b100

using namespace std;

XUartPs Uart_Ps;        // The instance of the UART Driver
uint16_t codec_IIC_addr; //global addr to set the address of the currently configured codec just once
XIicPs Iic0;		/* Instance of the IIC_0 Device */
XIicPs Iic1;		/* Instance of the IIC_1 Device */

// The Faust compiler will insert the C++ code here
<<includeIntrinsic>>
<<includeclass>>

/* Interface Base class */
struct ARMControlUIBase : public GenericUI {

    typedef function<void(FAUSTFLOAT value)> updateFunction;
    virtual bool isHardControl() = 0;
    // Keep all information needed for a controller
    struct Controller {
        updateFunction fUpdateFunIn;
        updateFunction fUpdateFunOut;
        string fLabel;
        FAUSTFLOAT* fZone;

        Controller() {}
        Controller(const string& label, updateFunction fun_in, FAUSTFLOAT* zone)
        {
            fLabel = label;
            fUpdateFunIn = fun_in;
            fZone = zone;
        }
    };

    // Map <control index, update function> for each controller
    map<int, Controller > fControlIn;
    map<int, Controller > fControlOut; // TODO ?

    void addCheckButton(const char* label, FAUSTFLOAT* zone)
    {
        addButton(label, zone);
    }

    void addVerticalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        addNumEntry(label, zone, init, min, max, step);
    }

    void addHorizontalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        addNumEntry(label, zone, init, min, max, step);
    }

    // -- passive widgets
    void addHorizontalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) {}
    void addVerticalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) {}

    virtual void update() {}

};

/* Analyse all controllers and decode matadata. */
struct ARMControlUIMetadata : public ARMControlUIBase {

    // To decode metadata
    string fKey, fValue;
    bool isHardControl() { return true; }
    // -- active widgets
    void addButton(const char* label, FAUSTFLOAT* zone)
    {
        if (fKey == "switch") {
            int control = stoi(fValue)-1;
            if (controllerBoard[control] == SWITCH) {
                fControlIn[control] = Controller(label, ([=] (FAUSTFLOAT value) { *zone = value/1023.; }), zone);
            } else {
                cout << "ERROR : No SWITCH define on channel " << control+1 << "\n";
            }
        } else {
            cout << "WARNING : label " << label << "' does not have any metadata\n";
        }
        fValue = fKey = "";
    }

    void addNumEntry(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        if (fKey == "knob" ) {
            int control = stoi(fValue)-1;
            if (controllerBoard[control] == KNOB) {
                fControlIn[control] = Controller(label, ([=] (FAUSTFLOAT value) { *zone = min + value * (max - min)/1023.; }), zone);
            } else {
                cout << "ERROR : No KNOB define on channel " << control+1 << "\n";
            }
        }
        else if (fKey == "slider" ) {
            int control = stoi(fValue)-1;
            if (controllerBoard[control] == SLIDER) {
                fControlIn[control] = Controller(label, ([=] (FAUSTFLOAT value) { *zone = min + value * (max - min)/1023.; }), zone);
            } else {
                cout << "ERROR : No SLIDER define on channel " << control+1 << "\n";
            }
        }
         else {
            cout << "WARNING : label " << label << "' does not have any metadata\n";
        }
        fValue = fKey = "";
    }

    // -- metadata declarations
    void declare(FAUSTFLOAT* zone, const char* key, const char* val)
    {
        // Keep key and value for later use
        if (strcmp(key, "switch") == 0 || strcmp(key, "knob") == 0 || strcmp(key, "slider") == 0) {
            fKey = key;
            fValue = val;
        }
    }
    // Hardware update function: read ADC controllers which are described with 'switch/knob' metadata
    void update()
    {
        for (const auto& item : fControlIn) {
            item.second.fUpdateFunIn(readADC(item.first));
        }
    }

};

/* Analyse all controllers. */

struct ARMControlUIAll : public ARMControlUIBase {

    UartReceiverUI fUartUI;
    bool isHardControl() { return false; }
    ARMControlUIAll(dsp* DSP){
    	DSP->buildUserInterface(&fUartUI);
    }

    // To count controllers
    int fControlNum = 0;

    // -- active widgets
    void addButton(const char* label, FAUSTFLOAT* zone)
    {
        int control = fControlNum++;
        fControlIn[control] = Controller(label, ([=] (FAUSTFLOAT value) { *zone = value;}), zone);
    }

    void addNumEntry(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        int control = fControlNum++;
        fControlIn[control] = Controller(label, ([=] (FAUSTFLOAT value) { *zone =value; }), zone);
    }

    // Software update function: read controllers value through uart
    void update()
    {
       fUartUI.update(&Uart_Ps);
    }

};

struct ARMController {
  int timer=0;
  // Control
  ARMControlUIBase* fControlUI;

  // DSP
  mydsp* fDSP;

  // controllers
  int iControl[FAUST_INT_CONTROLS];
  float fControl[FAUST_REAL_CONTROLS];

  // Passive controllers
  float passiveControl[FAUST_PASSIVES];

  // izone and fzone memory
#if (SYFALA_MEMORY_USE_DDR == 1)
  int* iZone;
  float* fZone;
#else
  int iZone[FAUST_INT_ZONE];
  float fZone[FAUST_FLOAT_ZONE];
#endif

  // ARM <=> FPGA
  XSyfala xsyfala;

  //GPIO
  XGpio gpioLED;
  XGpio gpioSW;

  ARMController()
  {
  	init_uart();
    init_gpio();

    //switch on LEDs
    XGpio_DiscreteWrite(&gpioLED, 2, WAITING_LED);

    /* 1 - Configure faust IP */
    init_ip();

#if (SYFALA_MEMORY_USE_DDR == 1)
    /* 2 - Init DDR first to define iZone and fZone */
    init_ddr();
#endif

    /* 3 - Allocate the DSP with fZone and iZone */
    fDSP = new mydsp(iControl, fControl, iZone, fZone);

    // Init DSP part (after reset DDR)
    fDSP->init(SYFALA_SAMPLE_RATE, iZone, fZone);

    /* 4 - Define UI type using DSP object based on SW3 state*/
    // SW3= UP:use hard controlers, DOWN:use SOFT
    if (XGpio_DiscreteRead(&gpioSW, 1) & (1 << 3)) {
      // Use meta-data
      fControlUI = new ARMControlUIMetadata();
    } else {
      // software control: Use all controllers
      fControlUI = new ARMControlUIAll(fDSP);
    }

    /* 5 - Build UI */
    fDSP->buildUserInterface(fControlUI);

    /* 6 - Send default controler value */
    controlFPGA();

    /* 7 - Init Peripherals */
    init_spi();
    init_audio();

    /* 8 - Enable ram access from fpga after init */
    XSyfala_Set_enable_RAM_access(&xsyfala, 1);

    //switch on LEDs 0b101
    XGpio_DiscreteWrite(&gpioLED, 2, OK_LED);	//write data to the LEDs
    PRINT_INFO("Ready! \n\r");
  }

  ~ARMController()
  {
    delete fControlUI;
    delete fDSP;
  }

  void sendControlToFPGA()
  {
    XSyfala_Write_ARM_fControl_Words(&xsyfala, 0,(u32*)fControl, FAUST_REAL_CONTROLS);
    XSyfala_Write_ARM_iControl_Words(&xsyfala, 0,(u32*)iControl, FAUST_INT_CONTROLS);
  }
  void readControlFromFPGA()
  {
    int field = 0;

    XSyfala_Read_ARM_passive_controller_Words(&xsyfala, 0, (u32*)passiveControl, FAUST_PASSIVES);

    // Macro ACTIVE_ELEMENT_OUT copy ARM_active_controller values in DSP struct
    #define ACTIVE_ELEMENT_IN(type, ident, name, var, def, min, max, step) fDSP->var = *(float*)&passiveControl[field++];
    // apply ACTIVE_ELEMENT_OUT on all existing controllers
    FAUST_LIST_PASSIVES(ACTIVE_ELEMENT_IN);
  }

  void controlFPGA()
  {
    // Compute iControl and fControl from controllers value
    fDSP->control(iControl, fControl, iZone, fZone);
    // Send iControl and fControl to FPGA
    sendControlToFPGA();
    // Read passive controlers
    readControlFromFPGA();
  }

  void init_uart()
  {
   // WARNING!! It works well without this initialisation, I don't know if I have to do it...
   /*
   * Initialize the UART driver so that it's ready to use
   * Look up the configuration in the config table and then initialize it.
   */

	XUartPs_Config *Config;
	Config = XUartPs_LookupConfig(XPAR_XUARTPS_0_DEVICE_ID);
	if (NULL == Config) {
		PRINT_INFO("Error while XUartPs_LookupConfig\n\r");
	}
	int Status = XUartPs_CfgInitialize(&Uart_Ps, Config, XPAR_XUARTPS_0_BASEADDR);
	if (Status != XST_SUCCESS) {
		PRINT_INFO("Error while XUartPs_CfgInitialize\n\r");
	}
	XUartPs_SetBaudRate(&Uart_Ps, 115200);
  PRINT_INFO("\n\n\r[UART] Init Done\n\r");

  }
  void init_ip()
  {
    PRINT_INFO("[SYFALA IP] Init... ");

#ifndef __linux__
    XSyfala_Config* xsyfala_Ptr = XSyfala_LookupConfig(XPAR_XSYFALA_0_DEVICE_ID);
    if (!xsyfala_Ptr) {
      PRINT_INFO("ERROR: Lookup of Faust v6 failed.\n\r");
    }

    // Initialize the device
    if (XSyfala_CfgInitialize(&xsyfala, xsyfala_Ptr) != XST_SUCCESS) {
      PRINT_INFO("ERROR: Could not initialize Faust v6.\n\r");
    }

    // Initialize with other function (not sure if it's useful)
    if (XSyfala_Initialize(&xsyfala, XPAR_XSYFALA_0_DEVICE_ID) != XST_SUCCESS) {
      PRINT_INFO("ERROR: Could not initialize Faust v6.\n\r");
    }
#else
    if (XSyfala_Initialize(&xsyfala, "xsyfala") != XST_SUCCESS) {
        PRINT_INFO("Error while initializing xsyfala\n\r");
    }
#endif
    PRINT_INFO("Done\n\r");
  }

#if (SYFALA_MEMORY_USE_DDR == 1)
  void init_ddr()
  {
    // Get iZone/fZone from the global DDR zone
    iZone = (int*)(ddr_ptr);
    fZone = (float*)(ddr_ptr + FAUST_INT_ZONE);

    PRINT_INFO("[DDR] Erase memory");

    reset_ddr();		//Write zeros everywhere

    /* Send base address and depth to IP  */
    XSyfala_Set_ramBaseAddr(&xsyfala, FRAME_BUFFER_BASEADDR); // send base address
    XSyfala_Set_ramDepth(&xsyfala, (FRAME_BUFFER_HIGHADDR-FRAME_BUFFER_BASEADDR));
  }
#endif

  void init_gpio()
  {
    //initialize input XGpio variable
    XGpio_Initialize(&gpioLED, XPAR_AXI_GPIO_LED_DEVICE_ID);
    XGpio_Initialize(&gpioSW, XPAR_AXI_GPIO_SW_DEVICE_ID);
    //set first channel tristate buffer to output (RGB led)
    XGpio_SetDataDirection(&gpioLED, 1, 0x0);
    //set second channel tristate buffer to output (LED)
    XGpio_SetDataDirection(&gpioLED, 2, 0x0);
    //set first channel tristate buffer to input (switch)
    XGpio_SetDataDirection(&gpioSW, 1, 0xF);
    }

  void init_spi()
  {
    // initializing SPI driver
    PRINT_INFO("[SPI] Init... ");
    int Status = SpiPs_Init(XPAR_XSPIPS_0_DEVICE_ID);
    if (Status == XST_SUCCESS) PRINT_INFO("Done\r\n");
    else PRINT_INFO("Initialization error\r\n");
  }

  void init_audio()
  {
    PRINT_INFO("[I2C AUDIO] Init... \r\n");

    // Initialize IIC_0 controller
    if (initIic(&Iic0, XPAR_XIICPS_0_DEVICE_ID) != XST_SUCCESS) {
       XGpio_DiscreteWrite(&gpioLED, 2, ERROR_LED);
       PRINT_INFO("[I2C AUDIO] Error initializing I2C_0 controller\n\r");
    }
    // Initialize IIC_1 controller
    if (initIic(&Iic1, XPAR_XIICPS_1_DEVICE_ID) != XST_SUCCESS) {
       XGpio_DiscreteWrite(&gpioLED, 2, ERROR_LED);
       PRINT_INFO("[I2C AUDIO] Error initializing I2C_1 controller\n\r");
    }
    // Interrupt mode for IIC_1 (Polled mode for IIC_0)
  /*  if (initIicInterrupt(&Iic1) != XST_SUCCESS) {
       XGpio_DiscreteWrite(&gpioLED, 2, ERROR_LED);
       PRINT_INFO("[I2C AUDIO] Error initializing I2C_1 Interrupt\n\r");
    }*/

    PRINT_DEBUG("[I2C AUDIO] I2Cs initialized\n\r");

#if SYFALA_BOARD_GENESYS
    // Initialize ADAU1761
    codec_IIC_addr = IIC_GENESYS_SLAVE_ADDR;
    if (ADAU1761SetConfig() != XST_SUCCESS) {
        PRINT_INFO(" >[ADAU1761] Audio Codec initializing ERROR\n\r");
    }
    else PRINT_INFO(" >[ADAU1761] Init done\n\r");
#elif SYFALA_BOARD_Z10 || SYFALA_BOARD_Z20
    // Initialize SSM2603
    if (SSMSetConfig(SYFALA_SSM_VOLUME, SSM_R07, SSM_R08)!= XST_SUCCESS) {
        XGpio_DiscreteWrite(&gpioLED, 2, ERROR_LED);
        PRINT_DEBUG(" >[SSM2603] ERROR: SSMSetConfig failed.\n\r");
    }
    else PRINT_INFO(" >[SSM2603] Init done\n\r");
#endif

// Initialize ADAU1777
PRINT_DEBUG("\n >[ADAU1777] Searching for connected devices...\n\r");
int nb_codec77_found=0;

for (int i=0;i<4; i++) {
  codec_IIC_addr = (IIC_ADAU1777_SLAVE_ADDR_0+i);
  PRINT_DEBUG("\n");

  if (ADAU1777SetConfig() != XST_SUCCESS) {
      PRINT_DEBUG(" >[ADAU1777]-0x%02x Audio Codec initializing ERROR\n\r",codec_IIC_addr);
  }
  else {
    PRINT_DEBUG(" >[ADAU1777]-0x%02x Init done\n\r",codec_IIC_addr);
    nb_codec77_found++;
  }
}
PRINT_DEBUG("\n");
PRINT_INFO(" >[ADAU1777] %d codecs found \n\r",nb_codec77_found);

 // Initialize ADAU1787
  PRINT_DEBUG("\n >[ADAU1787] Searching for connected devices...\n\r");
  int nb_codec87_found=0;

  for (int i=0;i<MAX_EXTERNAL_1787; i++) {
    codec_IIC_addr = (((i/4)<<8) | (IIC_ADAU1787_SLAVE_ADDR_0+(i%4)));
    PRINT_DEBUG("\n");

    if (ADAU1787BootSequence() != XST_SUCCESS) {
        PRINT_DEBUG(" >[ADAU1787]-0x%04x Audio Codec boot ERROR\n\r",codec_IIC_addr);
    }
    else if (ADAU1787SetConfig() != XST_SUCCESS) {
        PRINT_DEBUG(" >[ADAU1787]-0x%04x Audio Codec initializing ERROR\n\r",codec_IIC_addr);    }
    else {
      PRINT_DEBUG(" >[ADAU1787]-0x%04x Init done\n\r",codec_IIC_addr);
      nb_codec87_found++;
    }
  }
  PRINT_DEBUG("\n");
  PRINT_INFO(" >[ADAU1787] %d codecs found \n\r",nb_codec87_found);
  int tot_codec_found=(nb_codec77_found+nb_codec87_found);
  if (get_max(FAUST_INPUTS,FAUST_OUTPUTS)/2>tot_codec_found) PRINT_INFO("[I2C AUDIO] WARNING: Not enough external codecs (%d codecs=%d channels) to satisfy the DSP channels need (%d) \n\r",tot_codec_found,tot_codec_found*2,get_max(FAUST_INPUTS,FAUST_OUTPUTS));

  PRINT_INFO("[I2C AUDIO] Init Done\n\r");

  }

 void reset_ddr(void)
  {
    // Disable the Data cache for DDR read and write
    // NOTE: If we disable the cache after reset_ddr,
    // it's much faster and the ddr seems still fully reset.
    // But i suppose it's safer to disable it before...?
   // Xil_DCacheDisable();
		Xil_DCacheEnable();
		for (uint32_t i = 0; i < FRAME_BUFFER_DEPTH; i+=DDR_CLEAR_STEP){
			for (uint32_t j = i; j < i+DDR_CLEAR_STEP; j+=4) {
				Xil_Out32(FRAME_BUFFER_BASEADDR+j, (int)0);
			}
            PRINT_INFO(".");
        /* Note: use xil_printf instead of printf:
           https://support.xilinx.com/s/question/0D52E00006hpTbUSAU/xil_printf-vs-xilxil_printf?language=en_US */
		}
		Xil_DCacheFlush();
		Xil_DCacheDisable();
		PRINT_INFO(" Done\r\n");

  }


  void UIhandler(void)
  {
    timer++;
    if (timer>10000) timer=0; //loop sur modulo?

    int ledState=0b0000;
    int rgbState=OK_LED;
    /* if mute enable, LED 0 flash and WARNING, else LED 0 off*/
    if (!(XGpio_DiscreteRead(&gpioSW, 1) & 1 << 0)) ledState |= 0 << 0;
    else{
      rgbState=WARNING_LED;
      ledState |= (timer<5000?0:1) << 0;
    }
    /*  if bypass enable and there is no inputs:ERROR_LED, else if bypass: LED 1 flash and WARNING, else LED 1 off */
    if (!(XGpio_DiscreteRead(&gpioSW, 1) & 1 << 1)) ledState |= 0 << 1;
    else{
      if (FAUST_INPUTS == 0 ) rgbState=ERROR_LED;
      else  rgbState=WARNING_LED;
      ledState |= (timer<5000?0:1) << 1;
    }
    /* if SSM selected on incompatible config, LED 2 flash, else LED 2 on when ADAU selected*/
    if (XGpio_DiscreteRead(&gpioSW, 1) & (1 << 2)) ledState |= 1 << 2;
    else{
      if(SYFALA_SAMPLE_RATE>96000)
      {
        ledState |= (timer<5000?0:1) << 2;
        rgbState=ERROR_LED;
      }
      else ledState |= 0 << 2;
    }

    /* SW3 used to select the controler type. LED 3 is on when hard controler selected, off when soft */
    int SW3State=(XGpio_DiscreteRead(&gpioSW, 1) & (1 << 3))>>3;
    if (SW3State!=fControlUI->isHardControl())
    {
      delete fControlUI;
      if (SW3State)
      {
        fControlUI = new ARMControlUIMetadata();
      }
      else{
        fControlUI = new ARMControlUIAll(fDSP);
        init_uart();
      }
      fDSP->buildUserInterface(fControlUI);
    }
    ledState |= SW3State << 3;
    XGpio_DiscreteWrite(&gpioLED, 1, ledState);
    XGpio_DiscreteWrite(&gpioLED, 2, rgbState);
  }
  // infinit loop
  void run()
  {
    while (true) {
	  controlFPGA();
    UIhandler();
	  fControlUI->update();
    }
  }

};

int main(int argc, char* argv[])
{
    // Create and run controller update loop
    ARMController controller;
    controller.run();
}
