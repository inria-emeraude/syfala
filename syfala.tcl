#!/usr/bin/tclsh

# -------------------------------------------------------------------------------------------------
# configuration
# -------------------------------------------------------------------------------------------------

set tstart  [clock seconds]
set spath   [file normalize [info script]]
set sroot   [file dirname $spath]

# If user executes a symlink, set spath to symlink's target
set sym [exec ls -l $spath]
if {[string match "l*" $sym]} {
     set spath [file normalize [exec readlink -f $spath]]
     set sroot [file dirname $spath]
}

source $sroot/scripts/sylib.tcl
namespace import Syfala::*

# gets command line argument value at next '::argv' index
proc get_argument_value {index} {
    upvar $index idx
    return [lindex $::argv [incr idx]]
}

namespace eval runtime {
# runtime makefile variable & targets
    variable parameters     [list]
    variable targets        [list]
    variable make_debug     0
    variable reset          0
}

proc set_parameter {parameter value} {
    lappend ::runtime::parameters "$parameter := $value"
}

proc overwrite_parameter {parameter value} {
    set A $parameter
    set B "$parameter := $value"
    set f "makefile.env"
    if [not_empty [ffindl $f $A]] {
        print_info "Setting $B in '$f'"
        freplacel $f $A $B
    } else {
        print_info "Appending $B to '$f'"
        exec echo $B >> $f
    }
}

proc add_target {target} {
    lappend ::runtime::targets $target
}

proc write_env {} {
    set f "makefile.env"
    set fw [open $f "w"]
    foreach p $::runtime::parameters {
        puts $fw $p
    }
    close $fw
}

proc make {} {
    if [file exists "makefile.env"] {
       if $::runtime::reset {
          print_info "Overwriting makefile.env"
          write_env
       }
       print_info "Configuration stored in 'makefile.env' already exists"
       print_info "Please use the '--reset' flag or the 'syfala reset' command
         if you wish to restart a new build"
    } else {
        write_env
    }
    if [is_empty $::runtime::targets] {
        lappend ::runtime::targets "all"
    }
    if $::runtime::make_debug {
        exec make -dn {*}$::runtime::targets reports >&@stdout
    } else {
        exec make {*}$::runtime::targets reports >&@stdout | tee -a syfala_log.txt
    }
}

# -----------------------------------------------------------------------------------------
# PARSING COMMAND-LINE ARGUMENTS
# -----------------------------------------------------------------------------------------

for {set index 0} {$index < [llength $::argv]} {incr index} {
    set argument [lindex $::argv $index]
    switch $argument {
        COMMENT {
        # tcl doesn't allow comments outside of switch blocks...
        # we actually have to do this...
        # -----------------------------------------------------------------------------------------
        # BASICS
        # -----------------------------------------------------------------------------------------
        }
        -h - --help - help {
            add_target "help"
        }
        -v - --version - version {
            add_target "version"
        }
        --reset {
            set ::runtime::reset 1
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # COMMANDS
        # -----------------------------------------------------------------------------------------
        }
        install {
            add_target "install"
        }
        tidy {
            add_target "tidy"
            break
        }
        clean {
            add_target "clean"
            break
        }
        reset {
            set target [get_argument_value index]
            switch $target {
                linux {
                    set part [get_argument_value index]
                    switch $part {
                        boot    {add_target "reset-linux-boot"}
                        root    {add_target "reset-linux-root"}
                        default {add_target "reset-linux"}
                    }
                }
                default {
                    add_target "reset"
                }
            }
        }
        demo {
            set_parameter "FAUST_DSP_TARGET" [file normalize "examples/virtualAnalog.dsp"]
            add_target "all"
        }
        open-project {
            set target [get_argument_value index]
            switch $target {
                hls - HLS {
                    add_target "open-project-hls"
                }
                default {
                    add_target "open-project"
                }
            }
        }
        report - rpt {
            set target [get_argument_value index]
            switch $target {
                HLS - hls {
                    add_target "report-hls"
                }
                default {
                    add_target "report"
                }
            }
        }
        import {
            set target [get_argument_value index]
            set_parameter "SYFALA_IMPORT_TARGET" [file normalize $target]
            add_target "import"
        }
        export {
            set build_id [get_argument_value index]
            set build_id "[generate_build_id]-$build_id"
            set_parameter "SYFALA_EXPORT_TARGET" [file normalize $build_id]
            add_target "export"
        }
        flash {
            set platform [get_argument_value index]
            switch $platform {
                linux {
                    set target  [get_argument_value index]
                    switch $target {
                        boot    {add_target "flash-linux-boot"}
                        root    {add_target "flash-linux-root"}
                        dsp     {add_target "flash-linux-dsp"}
                        default {
                            incr index -1
                            add_target "flash-linux"
                        }
                    }
                }
                default {
                    add_target "flash"
                }
            }
        }

        scp {
            set addr [get_argument_value index]
            set host [get_argument_value index]
            overwrite_parameter "SCP_TARGET_ADDR" $addr
            if [not_empty $host] {
                overwrite_parameter "SCP_TARGET_USER" $host
            }
            add_target "scp"
        }

        test {
            add_target "tests"
        }
        log {
            add_target "log"
        }

        COMMENT {
        # -----------------------------------------------------------------------------------------
        # OPTIONS
        # -----------------------------------------------------------------------------------------
        }
        --vhdl {
            set_parameter "CONFIG_EXPERIMENTAL_VHDL" [get_argument_value index]
        }

        -x - --xilinx-root {
            set_parameter "XILINX_ROOT" [get_argument_value index]
        }

        --xversion {
            set_parameter "XILINX_VERSION" [get_argument_value index]
        }

        --unsafe-math-optimizations - --umo {
            set_parameter "HLS_DIRECTIVES_UNSAFE_MATH_OPTIMIZATIONS" TRUE
        }
        --arm-target {
            set_parameter "HOST_MAIN_SOURCE" [file normalize [get_argument_value index]]
        }
        --benchmark {
            set_parameter "ARM_BENCHMARK" TRUE
        }
        --verbose {
            set_parameter "VERBOSE" TRUE
        }
        -sd - --sigma-delta {
            set_parameter "CONFIG_EXPERIMENTAL_SIGMA_DELTA" TRUE
        }
        --tdm {
            set_parameter "CONFIG_EXPERIMENTAL_TDM" TRUE
        }
        --linux {
            set_parameter "LINUX" TRUE
        }
        --fixed-point {
            set_parameter "FAUST_FIXED_POINT" TRUE
        }
        --mcd {
            set_parameter "FAUST_MCD" [get_argument_value index]
        }
        --multisample {
            set_parameter "MULTISAMPLE" [get_argument_value index]
        }
        --no-ctrl-block - --ncb {
            set_parameter "CONTROL_BLOCK" 0
        }
        --adau-extern {
            set_parameter "SYFALA_ADAU_EXTERN" 1
        }
        --ethernet - --eth {
            set_parameter "CONFIG_EXPERIMENTAL_ETHERNET" TRUE
        }
        --midi {
            set_parameter "CTRL_MIDI" 1
        }
        --osc {
            set_parameter "CTRL_OSC" 1
        }
        --http {
            set_parameter "CTRL_HTTP" 1
        }
        --sd {
            set target [get_argument_value index]
            overwrite_parameter "SD_DEVICE" $target
        }
        --debug {
            set target [get_argument_value index]
            switch $target {
                audio {
                    set_parameter "AUDIO_DEBUG_UART" TRUE
                }
                make {
                    set ::runtime::make_debug 1
                }
                default {
                    # TODO
                }
            }
        }

        COMMENT {
        # -----------------------------------------------------------------------------------------
        # BUILD STEPS
        # -----------------------------------------------------------------------------------------
        }
        arch - --arch - sources - --sources {
            add_target "sources"
        }
        hls - --hls - ip - --ip {
            add_target "hls"
        }
        project - --project {
            add_target "project"
        }
        syn - synth - --syn - --synth {
            add_target "hw"
        }
        app - --app - host - --host {
            add_target "sw"
        }
        gui - --gui {
            add_target "gui"
        }

        COMMENT {
        # -----------------------------------------------------------------------------------------
        # RUNTIME PARAMETERS
        # -----------------------------------------------------------------------------------------
        }
        -b - --board {
            set_parameter "BOARD" [get_argument_value index]
        }
        -m - --memory {
            set_parameter "MEMORY_TARGET" [get_argument_value index]
        }
        --sample-rate {
            set_parameter "SAMPLE_RATE" [get_argument_value index]
        }
        --sample-width {
            set_parameter "SAMPLE_WIDTH" [get_argument_value index]
        }
        --controller-type {
            set_parameter "CONTROLLER_TYPE" [get_argument_value index]
        }
        --ssm-volume {
            set_parameter "SSM_VOLUME" [get_argument_value index]
        }
        --ssm-speed {
            set_parameter "SSM_SPEED" [get_argument_value index]
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # DSP FILE / INVALID ARGUMENT
        # -----------------------------------------------------------------------------------------
        }
        default {
            # check DSP target file
            set pattern ".dsp"
            if [string match "*.dsp" $argument] {
                 set_parameter "FAUST_DSP_TARGET" [file normalize $argument]
                 set_parameter "TARGET" faust
            } elseif [string match "*.cpp" $argument] {
                 set_parameter "HLS_SOURCE_MAIN" [file normalize $argument]
                 set_parameter "TARGET" cpp
            } else {
                print_error "Invalid argument ($argument), aborting"
                exit 1
            }
        }
    }
}

make
print_elapsed_time $tstart
print_ok "Successful run!"
print_ok "To see the build's full log: open 'syfala_log.txt' in the repository's root directory"
