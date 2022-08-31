#!/usr/bin/tclsh

set syroot ../..
source $syroot/scripts/sylib.tcl
source common.tcl
namespace import Syfala::*

set N [lindex $::argv 0]
set dsp [file normalize "dsp/bellN.dsp"]
set i [list "N = "]
set o [list "N = $N;"]

# load file bellN.dsp & replace N = accordingly
print_info "Attempting to replace N parameter ($N) in bellN.dsp"
freplacel $dsp $i $o

print_ok    "Succesfully replaced N parameter"
print_info  "Now testing HLS compilation"

exec $syroot/syfala.tcl $dsp --arch --hls --report --reset >&@stdout
