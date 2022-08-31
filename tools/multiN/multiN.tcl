#!/usr/bin/tclsh

set syroot ../..

source $syroot/scripts/sylib.tcl
source common.tcl

namespace import Syfala::*

set name  [lindex $::argv 0]
set N     [lreplace $::argv 0 0]

print_info "Running multiN script with file '$name.tcl' and N = '$N'"

set flatency      [open "output/$name-latency.txt" w]
set futilization  [open "output/$name-utilization.txt" w]

proc run { N } {
    upvar flatency fl
    upvar futilization fu
    upvar name name
    upvar syroot syroot
    set header "+ With N = $N:\n"
    print_info "Synthesizing $name with N = $N, please wait..."
    exec ./$name.tcl $N
    puts $fl $header
    puts $fu $header
    puts $fl [ffindlN $syroot/build/syfala_csynth.rpt "+ Latency:" 5 2]
    puts $fu [ffindlN $syroot/build/syfala_csynth.rpt "Utilization Estimates" 16 3]
    print_ok "Done with N = $N, cleaning up..."
    exec $syroot/syfala.tcl clean
}

foreach n $N { run $n }

close $flatency
close $futilization

print_ok "All done!"
print_ok "Latency output successfully written in file 'output/$name-latency.txt'"
print_ok "Utilization output successfully written in file 'output/$name-utilization.txt'"
