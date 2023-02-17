#include <syfala/faust/pc-uart-interface.hpp>

#include <faust/gui/GTKUI.h>
#include <faust/gui/meta.h>
#include <faust/dsp/dsp.h>
#include <faust/gui/MidiUI.h>
#include <faust/midi/rt-midi.h>
#include <faust/midi/RtMidi.cpp>

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

    // MIDI interface
    rt_midi rt("MIDI");
    MidiUI midi_ui(&rt);
    DSP.buildUserInterface(&midi_ui);

    // start sending & run
    uart_ui.start();
    midi_ui.run();
    gtk_ui.run();
}
