
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <math.h>
#include <map>
#include <iostream>
// #include <unistd.h> //conflit avec sleep.h...
#include "sleep.h"
#include <functional>
#include "platform.h"
#include <xil_cache.h>
#include <xgpio.h>
#include "xuartps.h"	
	   
#include "xfaust_v6.h"
#include "faust_v6_app.h"
#include "spips.h"

#include "faust/gui/meta.h"
#include "faust/dsp/one-sample-dsp.h"
#include "faust/gui/DecoratorUI.h"

#include "configFAUST.h"
#include "armUartInterface.h"

#include "iic_config.h"

#define FRAME_BUFFER_BASEADDR 0x1D000000
#define FRAME_BUFFER_HIGHADDR 0x1F000000
#ifdef USE_DDR
u32* ddr_ptr = (u32*)FRAME_BUFFER_BASEADDR;
#endif

using namespace std;

// The Faust compiler will insert the C++ code here
<<includeIntrinsic>>
<<includeclass>>

/*
  Base class.
 */
 
struct ARMControlUIBase : public GenericUI {
    
    typedef function<void(FAUSTFLOAT value)> updateFunction;

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
    
    void printParams()
    {
        //printf("\n");
        printf("\033[10;0H"); // Move cursor to (0, 0)
        printf("\e[?25l"); // hide cursor (prevent the cursor from flashing anywhere)
        int nbParams = fControlIn.size();
        for (int index = 0; index < nbParams; index++) {
            printf("/----------------\\ ");
        }
        printf("\n");
        for (int index = 0; index < nbParams; index++) {
            printf("|\e[3%dm %-15d \e[0m|", index+1, index);
        }
        printf("\n");
        
        int index = 0;
        for (const auto& item : fControlIn) {
            printf("|\e[3%d;1m %-15.15s \e[0m|", index+1, item.second.fLabel.c_str());
            index++;
        }
        printf("\n");
        
        index = 0;
        for (const auto& item : fControlIn) {
            printf("|\e[3%d;1m %-15.6f \e[0m|", index+1, *item.second.fZone);
            index++;
        }
        printf("\n");
        for (int index = 0; index < nbParams; index++) {
            printf("\\________________/ ");
        }
        printf("\n Try to enlarge the terminal if the display is flickering (and relaunch) \n");
        printf("\e[?25h"); // show the cursor
    }
    
    void sendParamsServer()
    {
        int index = 0;
        for (const auto& item : fControlIn) {
            printf("%f/", *item.second.fZone);
            index++;
        }
        printf("\r\n");
        usleep(100000);
    }
    
    virtual void update() {}
    
};

/*
 Analyse all controllers and decode matadata.
 */

struct ARMControlUIMetadata : public ARMControlUIBase {
    
    // To decode metadata
    string fKey, fValue;
    
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

/*
 Analyse all controllers.
 */

struct ARMControlUIAll : public ARMControlUIBase {
     
    UartReceiverUI fUartUI;
    
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
       fUartUI.update();
    }
    
};

struct ARMController {
    
    // Control
    ARMControlUIBase* fControlUI;

    // DSP
    mydsp* fDSP;
    
    // control
    int iControl[FAUST_INT_CONTROLS];
    FAUSTFLOAT fControl[FAUST_REAL_CONTROLS];
    
    // zone
#ifdef USE_DDR
    int* iZone;
    float* fZone;
#else
    int iZone[FAUST_INT_ZONE];
    FAUSTFLOAT fZone[FAUST_FLOAT_ZONE];
#endif
    // ARM <=> FPGA
    XFaust_v6 faust_v6;
    //GPIO
    XGpio gpio;
    
    ARMController()
    {
    	init_gpio();
    	
    	XGpio_DiscreteWrite(&gpio, 2, 0b100);	//write data to the LEDs
    	/* 1 - Configure faust IP */
  		init_ip();

    #ifdef USE_DDR
        /* 2 - Init DDR first to define iZone and fZone */
   		init_ddr();
    #endif
    
        /* 3 - Allocate the DSP with fZone and iZone */
        fDSP = new mydsp(iControl, fControl, iZone, fZone);

        // Init DSP part (after reset DDR)
        fDSP->init(SAMPLE_RATE, iZone, fZone);
       
        /* 4 - Define UI type using DSP object*/
    #if CONTROLLER_TYPE == 0U
        // Use all controllers
        fControlUI = new ARMControlUIAll(fDSP);
    #else
        // Use meta-data
        fControlUI = new ARMControlUIMetadata();
    #endif
    
    	/* 5 - Build UI */
        fDSP->buildUserInterface(fControlUI);

        /* 6 - Send default controler value */
        controlFPGA();         // init controllers
        
        /* 7 - Init Periph */
        init_spi();

        /* 8 - Enable RAM access for the IP */
        XFaust_v6_Set_userVar(&faust_v6, 0);	
	
        reset_ip();  		// Reset after init is mandatory
        XFaust_v6_Set_enable_RAM_access(&faust_v6, 1);	//enable ram access from fpga after init

 		if (SSMInitialize()!= XST_SUCCESS) {
            printf("ERROR: SSMInitialize failed.\n\r");
        }
        if (SSMSetRegister(VOLUME_SSM,SSM_R07)!= XST_SUCCESS) {
            printf("ERROR: SSMSetRegister failed.\n\r");
        }

        XGpio_DiscreteWrite(&gpio, 2, LED_COLOR);	//write data to the LEDs
    }
    
    ~ARMController()
    {
        delete fControlUI;
        delete fDSP;
    }
    
    void sendControlToFPGA()
    {
        XFaust_v6_Write_ARM_fControl_Words(&faust_v6, 0,(u32*)fControl, FAUST_REAL_CONTROLS);
        XFaust_v6_Write_ARM_iControl_Words(&faust_v6, 0,(u32*)iControl, FAUST_INT_CONTROLS);
    }
    
    void controlFPGA()
    {
        fDSP->control(iControl, fControl, iZone, fZone);  // Compute iControl and fControl from controllers value
        sendControlToFPGA();                              // send iControl and fControl to FPGA
    }

    void init_ip()
    {
      #ifndef __linux__
        XFaust_v6_Config* faust_v6_Ptr = XFaust_v6_LookupConfig(XPAR_XFAUST_V6_0_DEVICE_ID);
        if (!faust_v6_Ptr) {
            printf("ERROR: Lookup of Faust v6 failed.\n\r");
        }
        
        // Initialize the device
        if (XFaust_v6_CfgInitialize(&faust_v6, faust_v6_Ptr) != XST_SUCCESS) {
            printf("ERROR: Could not initialize Faust v6.\n\r");
        }
        
        // Initialize with other function (not sure if it's useful)
        if (XFaust_v6_Initialize(&faust_v6, XPAR_XFAUST_V6_0_DEVICE_ID) != XST_SUCCESS) {
            printf("ERROR: Could not initialize Faust v6.\n\r");
        }
    #else
        if (XFaust_v6_Initialize(&faust_v6, "faust_v6") != XST_SUCCESS) {
            printf("Error while initializing faust_v6\n");
        }
    #endif
    }
    
    #ifdef USE_DDR
    void init_ddr()
    {          
        // Get iZone/fZone from the global DDR zone
        iZone = (int*)(ddr_ptr);
        fZone = (float*)(ddr_ptr + FAUST_INT_ZONE);

        printf("Erase memory... (see note in comment)\n\r");
        //Xil_DCacheDisable();
        // Disable the Data cache for DDR read and write
        // NOTE: If we disable the cache after reset_ddr,
        // it's much faster and the ddr seems still fully reset.
        // But i suppose it's safer to disable it before...?
        reset_ddr();		//Write zeros everywhere
        
        /* Send base address and depth to IP  */  
        XFaust_v6_Set_ramBaseAddr(&faust_v6, FRAME_BUFFER_BASEADDR); // send base address
        XFaust_v6_Set_ramDepth(&faust_v6, (FRAME_BUFFER_HIGHADDR-FRAME_BUFFER_BASEADDR));
    }
    #endif
    void init_gpio()
    {
	   XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_DEVICE_ID);	//initialize input XGpio variable
	   XGpio_SetDataDirection(&gpio, 1, 0xF);			//set first channel tristate buffer to input (switch)
	   XGpio_SetDataDirection(&gpio, 2, 0x0);			//set second channel tristate buffer to output (LED)
    }
    
    void init_spi()
    {
    	// initializing SPI driver
        int Status = SpiPs_Init(XPAR_PS7_SPI_0_DEVICE_ID);
        if (Status == XST_SUCCESS) printf("SPI OK\r\n");
        else printf("Initialization error\r\n");
    }
    
    void reset_ip()
    {
        printf("Reset IP...");
        XFaust_v6_Set_soft_reset(&faust_v6, 1);
        usleep(100);
        XFaust_v6_Set_soft_reset(&faust_v6, 0);
        printf(" OK\r\n");
    }
    
    void reset_ddr(void)
    {        Xil_DCacheEnable();
        for (int i = FRAME_BUFFER_BASEADDR; i < FRAME_BUFFER_HIGHADDR; i+=4) {
            Xil_Out32(i, (int)0);
        }
        Xil_DCacheDisable();
    }
    
    // Update loop
    void run()
    {
        while (true) {
			if( XGpio_DiscreteRead(&gpio, 1))//check if reset btn is pressed (verify if it's not too long)
			{
				for (int i=0; i<0x0000FFFF; i++);	//tempo reset
			    XGpio_DiscreteWrite(&gpio, 2, 0b100);	//write data to the LEDs
			    XFaust_v6_Set_enable_RAM_access(&faust_v6, 0);	//disable ram access
			    #ifdef USE_DDR
			    reset_ddr();
			    #endif
			    SSMSetRegister(VOLUME_SSM,SSM_R07);
			    fDSP->init(SAMPLE_RATE, iZone, fZone);
				reset_ip();
       			XFaust_v6_Set_enable_RAM_access(&faust_v6, 1);	//enable ram access from fpga after init
       			XGpio_DiscreteWrite(&gpio, 2, LED_COLOR);	//write data to the LEDs
			}
			else
			{
		        controlFPGA();
		        //fControlUI->printParams();
		        //fControlUI->update_SW();

		        fControlUI->update();
		        /*u32 retourSoc[32];
        		XFaust_v6_Read_ARM_passive_controller_Words(&faust_v6, 0, retourSoc, 32);
				for(int i=0; i<32; i++)
				{
					printf("[%d]: %d  \n",i, retourSoc[i]);
				}
				printf("\n\n\n");*/
		        //fControlUI->sendParamsServer();
		        // usleep(100);
		    }
        }
    }
    
};

int main(int argc, char* argv[])
{
    printf("\033[H"); // Move cursor to (0, 0)
    printf("\033[J"); // Clean screen
    printf("\e[0m"); /* Reset all color attribute */

    // Create and run controller update loop
    ARMController controller;
    controller.run();
}





