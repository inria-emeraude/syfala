#include "pcUartInterface.h"

#include "faust/gui/GTKUI.h"
#include "faust/gui/meta.h"
#include "faust/dsp/dsp.h"

/******************************************************************************
 *******************************************************************************
 
 VECTOR INTRINSICS
 
 *******************************************************************************
 *******************************************************************************/

<<includeIntrinsic>>

/********************END ARCHITECTURE SECTION (part 1/2)****************/

/**************************BEGIN USER SECTION **************************/

<<includeclass>>

/***************************END USER SECTION ***************************/

/*******************BEGIN ARCHITECTURE SECTION (part 2/2)***************/

std::list<GUI*> GUI::fGuiList;
ztimedmap GUI::gTimedZoneMap;

int main(int argc, char* argv[])
{
    mydsp DSP;
    
    // GTK interface
    GTKUI gtk_ui((char*)"Controller", &argc, &argv);
    DSP.buildUserInterface(&gtk_ui);
    
    // UART interface
    UARTSenderUI uart_ui;
    DSP.buildUserInterface(&uart_ui);
    // Start sending
    uart_ui.start();
    
    // Run
    gtk_ui.run();
}
