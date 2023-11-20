#!/usr/bin/tclsh

set arguments [lreplace $::argv 0 0]

print_info "Running full automated tests on the Syfala toolchain"
cd $::Syfala::ROOT

namespace eval rt {
    set mainscript [file normalize "syfala.tcl"]
    set tests [list]
    variable count 1
}

proc add_test {arguments description} {
    set testno [llength $::rt::tests]
    lappend ::rt::tests [list $arguments $description]
    print_ok "Added test [expr $testno+1] ($description)"
}

proc clean { } {
    exec $::rt::mainscript clean
}

proc run {testno} {
    set tstart [clock seconds]
    set test   [lindex $::rt::tests $testno]
    set arguments   [lindex $test 0]
    set description [lindex $test 1]
    incr testno
    print_info "Test-$testno ($description) now running with arguments: $arguments"
    exec $::rt::mainscript {*}$arguments
    print_ok "Test-$testno successfully passed!"
    print_elapsed_time $tstart
    incr ::rt::count
}

add_test --version  "checking version"
add_test --help "displaying help"
add_test clean "cleaning build directory"
add_test {examples/virtualAnalog.dsp --arch --hls --project --sigma-delta} "sigma-delta example"
add_test {examples/wfs/through32.dsp --arch --hls --project --tdm} "tdm example"
add_test {examples/fm.dsp --arch --hls --project --reset} "1-output example"
add_test {examples/dist.dsp --arch --hls --project --reset} "1-input example"
# Note: we omit the --project on purpose for this next one
# because the 'next' command will do it just after
add_test {examples/flanger.dsp --arch --hls --reset} "2/2 io example"
add_test {next} "'next' command"
add_test {examples/multichannel_test.dsp --arch --hls --project --reset} "multichannel output example"
add_test {demo --board Z10 --reset} "full demo build (Z710 board)"
add_test rebuild-app "rebuilding-app"
add_test {export demo-z710-test} "exporting demo build"
add_test {demo --board Z20 --reset} "Zybo Z20 build"

if [file exists $::Xilinx::ROOT/Vivado/2022.2/settings64.sh] {
    add_test {demo --xversion 2022.2 --reset} "Xilinx 2022.2 build"
}

add_test {demo --board GENESYS --reset} "Genesys board"
add_test {demo --memory STATIC --reset} "static memory test"

#foreach f [glob -directory $::Syfala::EXPORT_DIR *.zip] {
#    if [contains "demo-z710-test" $f] {
#        set a [list "import" [file normalize $f]]
#        add_test $a "import build test"
#        add_test {--host --gui} "rebuild host & gui after import"
#        break
#    }
#}

# run tests
if [is_empty $arguments] {
    set index 0
    print_info "Running all [llength $::rt::tests] tests"
    foreach test $::rt::tests {
        run $index
        incr index
    }
} else {
    print_info "Running tests $::argv"
    foreach testno $arguments { run [expr $testno - 1]}
}
