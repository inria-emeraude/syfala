#!/usr/bin/tclsh

source ../scripts/sylib.tcl
namespace import Syfala::*

print_info "Running full automated tests on the Syfala toolchain"
cd $::Syfala::ROOT
set mainscript [file normalize "syfala.tcl"]
variable count 1

proc test { arguments description } {
    upvar mainscript mainscript
    upvar count count
    set tstart [clock seconds]
    print_info "Test-$count ($description) now running with arguments: $arguments"
    exec $mainscript {*}$arguments
    print_ok "Test-$count successfully passed!"
    print_elapsed_time $tstart
    incr count
}

proc clean { } {
    upvar mainscript mainscript
    exec $mainscript clean
}

# 1. print version and help
test --version  "checking version"
test --help "displaying help"
test clean "cleaning build directory"

test {examples/fm.dsp --arch --hls --project} "1-output example"
test {examples/dist.dsp --arch --hls --project --reset} "1-input example"
test {examples/flanger.dsp --arch --hls --reset} "2/2 io example"
test {next} "'next' command"
clean

test demo "full demo build (Z710 board)"
test rebuild-app "rebuilding-app"
test {export demo-z710-test} "exporting demo build"
clean

test {import export/demo-z710-test} "import build test"
test {--host --gui} "rebuild host & gui after import"

test {examples/virtualAnalog.dsp --board Z20 --reset} "Zybo Z20 build"
test {demo --board GENESYS --reset} "Genesys board"

# 5. faust2vhdl compiler (TODO)
