#!/usr/bin/tclsh
set EXAMPLES_DIR [file normalize examples]
set index 1

foreach file [glob -directory $EXAMPLES_DIR *.dsp] {
    set fname [file rootname [file tail $file]]
    puts "$index: running syfala $file --all --export $fname"
    exec ./syfala.tcl $file --all --export $fname >&@stdout
    exec ./syfala.tcl --clean
    incr index
}
