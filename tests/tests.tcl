#!/usr/bin/tclsh

source ../scripts/sylib.tcl
namespace import Syfala::*

print_info "Running full automated tests on the Syfala toolchain"
cd $::Syfala::ROOT
set mainscript [file normalize "syfala.tcl"]
variable count 0

proc test { arguments description } {
    upvar mainscript mainscript
    upvar count count
    set tstart [clock seconds]
    print_info "test-$count ($description) now running with arguments: $arguments"
    exec $mainscript {*}$arguments
    print_ok "test-$count successfully passed!"
    print_elapsed_time $tstart
    incr count
}

# 1. print version and help
test --version                  "checking version"
test --help                     "displaying help"

# 2. run demo (Z710 default)
test demo                       "building demo (for z7-10 board)"
test rebuild-app                "rebuilding-app"
test {export demo-z710-test}    "exporting demo build"

# 3. run demo for other supported boards
test {demo --board GENESYS}     "genesys board"
exec $mainscript clean

test {demo --board Z20}         "zybo z7-20"
exec $mainscript clean

# 4. test with nchannels = 4
test {demo --nchannels 4}       "4-channels"
exec $mainscript clean

# 5. faust2vhdl compiler (TODO)
