#!/usr/bin/tclsh

source ../../scripts/sylib.tcl
namespace import Syfala::*

# usage: ./vbapN.tcl 8

### WARNING
# for vbapN.dsp to be compiled correctly by Faust,
# you need to edit /usr/local/share/hoa.lib and add
# ba = library("basics.lib");
# after the other library imports

set fpath [file normalize "dsp/vbapN.dsp"]
puts $fpath

set N [lindex $::argv 0]
set N_array ""
set C_array ""
set mul [expr {360/$N}]

print_info "N = $N - multiplier: $mul"

for {set i 0} {$i < $N} {incr i} {
     set r [expr {$i * $mul}]
     lappend N_array $r
     lappend C_array "_"
}

set N_array "($N_array)"
set N_array [string map -nocase { " " ", " } $N_array]
set C_array [string map -nocase { " " ", " } $C_array]

set fvbapn_r [open $fpath r]
set data     [read $fvbapn_r]

close $fvbapn_r
set fvbapn_w  [open $fpath w]

foreach line [split $data "\n"] {
    if [contains "speakers =" $line] {
        print_info "Found speakers position line"
        set line "speakers = $N_array;"
        print_info $line
    } elseif [contains "process =" $line] {
        print_info "Found process line"
        set line "process = fm(1,440,440,440,3,2) : circularScaledVBAP(speakers, source) : $C_array;"
        puts $line
    }
    puts $fvbapn_w $line
}

close $fvbapn_w

print_ok    "Succesfully replaced speaker positions and process line"
print_info  "Now testing HLS compilation"

cd $::Syfala::ROOT
exec ./syfala.tcl $fpath --arch --hls --report --reset >&@stdout
