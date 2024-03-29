#!/usr/bin/tclsh

source ../../scripts/sylib.tcl
namespace import Syfala::*

set EXAMPLES_DIR [file normalize ../../examples]
set foutput [open "mem_access_counter_output.txt" w]
set index 1
set tabs "\t\t\t\t\t\t\t\t\t\t\t"

foreach file [glob -directory $EXAMPLES_DIR *.dsp] {
    set fname [file rootname [file tail $file]]
    print_info "$index: running syfala $file --arch"
    set tcl_interactive false
    exec ../../syfala.tcl $file --arch --reset
    set count [Faust::mem_access_count]
    set tcl_interactive true
    puts $foutput "$index: [file tail $file]:\n $tabs [lindex $count 0] mem read(s), [lindex $count 1] mem write(s)"
    incr index
}

close $foutput
