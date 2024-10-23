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
    variable targets        [list]
    variable make_debug     0
    variable faust2vhdl     0
    variable reset_check    1
    variable force          0
    set mkenv_parameters    [list]
    set cli_parameters      [list]
    variable mode           "command"
    set root                $sroot
}

namespace eval p {
    set fpga_parameters [list   \
        "TARGET_TYPE"           \
        "FAUST_DSP_TARGET"      \
        "FAUST_FIXED_POINT"     \
        "FAUST_MCD"             \
        "FAUST_FPGA_MEM"        \
        "FAUST_VEC"             \
        "HLS_SOURCE_MAIN"       \
        "HLS_CSIM_SOURCE"       \
        "HLS_CSIM_NUM_ITER"     \
        "HLS_CSIM_INPUTS_DIR"   \
        "XILINX_ROOT"           \
        "XILINX_VERSION"        \
        "HLS_DIRECTIVES_UNSAFE_MATH_OPTIMIZATIONS"  \
        "HLS_ROUTING_AND_PLACEMENT"                 \
        "CONFIG_EXPERIMENTAL_ETHERNET"              \
        "CONFIG_EXPERIMENTAL_ETHERNET_NO_OUTPUT"    \
        "CONFIG_EXPERIMENTAL_SIGMA_DELTA"           \
        "CONFIG_EXPERIMENTAL_TDM"                   \
        "SIGMA_DELTA_ORDER"                         \
        "INPUTS"                \
        "OUTPUTS"               \
        "MULTISAMPLE"           \
        "BOARD"                 \
        "MEMORY_TARGET"         \
        "SAMPLE_RATE"           \
        "SAMPLE_WIDTH"          \
        "DEBUG_AUDIO"           \
    ]
    set arm_parameters [list    \
        "CTRL_MIDI"             \
        "CTRL_OSC"              \
        "CTRL_HTTP"             \
        "ADAU_EXTERN"           \
        "ADAU_MOTHERBOARD"      \
        "SSM_VOLUME"            \
        "SSM_SPEED"             \
        "CONTROLLER_TYPE"       \
        "VERBOSE"               \
    ]
    set cmd_parameters [list    \
        "SCP_TARGET_ADDR"       \
        "SCP_TARGET_USER"       \
        "SD_DEVICE"             \
        "IMPORT_TARGET"         \
        "EXPORT_TARGET"         \
    ]
}

if [file exists "$::runtime::root/makefile.env"] {
    # Parse parameters
    set f [open $::runtime::root/makefile.env r]
    set d [read $f]
    foreach l [split $d "\n"] {
        if [regexp {.*:=.*} $l] {
            set s [split $l ":="]
            set p [string trimright [lindex $s 0]]
            set v [string trimleft [lindex $s 2]]
            lappend ::runtime::mkenv_parameters [list $p $v]
            # print_info "Retrieved parameter $p with value $v"
        }
    }
} else {
    # Otherwise, don't ask for a reset when adding parameters
    set ::runtime::reset_check 0
}

proc add_target {target} {
    lappend ::runtime::targets $target
}

proc set_parameter {parameter value} {
    lappend ::runtime::cli_parameters [list $parameter $value]
}

proc parameter_type {p} {
    if [lcontains $p $::p::fpga_parameters] {
        return "fpga"
    } elseif [lcontains $p $::p::arm_parameters] {
        return "arm"
    } elseif [lcontains $p $::p::cmd_parameters] {
        return "cmd"
    } else {
        return "err"
    }
}

proc reset_yn {p} {
    if $::runtime::force {
        set confirm "y"
    } else {
        print_info "[emph Warning], adding/removing or re-setting parameter [emph $p] would require
re-setting the project, would you like to continue? \[y/[emph N]\]"
        set confirm [gets stdin]
    }
    switch $confirm {
        y - Y - yes - Yes - YES {
            file delete -force "build"
            exec rm -rf "syfala_log.txt"
        }
        default {
            exit 0
        }
    }
}

proc handle_value_change {p} {
    # If value is different, two possibilities:
    switch [parameter_type $p] {
        fpga {
            # For an FPGA-dependent parameter, ask for a build reset
            # print_info "Parameter $p: value changed!"
            if $::runtime::reset_check {
                reset_yn $p
                set ::runtime::reset_check 0
            }
        }
        arm {
            # For an ARM-dependent parameter, re-build host control application.
            exec touch $::Syfala::INCLUDE_DIR/syfala/config_arm.hpp
        }
        cmd {}
        err {}
    }
}

proc write_mkenv {mkenv} {
    # Write 'makefile.env'
    set f [open "$::runtime::root/makefile.env" w]
    foreach p $mkenv {
        set n [lindex $p 0]
        set v [lindex $p 1]
        set l "$n := $v"
        puts $f $l
    }
    close $f
}

proc process_mkenv {} {
    switch $::runtime::mode {
        command {
        # If we're in 'command mode':
        # - we should keep 'makefile.env' as is, not to mess with the current build.
        set mkenv [list]
        foreach mkenv_p $::runtime::mkenv_parameters {
            set mkenv_pn [lindex $mkenv_p 0]
            set mkenv_pv [lindex $mkenv_p 1]
        # - the only thing we can remove/replace are the command-related
        # options & variables.
            switch [parameter_type $mkenv_pn] {
                fpga - arm {
                    lappend mkenv $mkenv_p
                }
                cmd {
                    foreach p $::runtime::cli_parameters {
                        set pn [lindex $p 0]
                        set pv [lindex $p 1]
                        if {$pn == $mkenv_pn} {
                        # 1. if also in cli, re-set it with newest value
                            lappend mkenv $p
                            break
                        }
                    }

                }
            }
        }
        # Now, check if new cmd_parameters have been added
        foreach p $::runtime::cli_parameters {
            set pn [lindex $p 0]
            switch [parameter_type $pn] {
                cmd {
                    set found 0
                    foreach mkenv_p $::runtime::mkenv_parameters {
                        set mkenv_pn [lindex $mkenv_p 0]
                        if {$pn == $mkenv_pn} {
                            set found 1
                        }
                    }
                    # Parameter not already found in 'makefile.env'
                    # Add it to the list.
                    if !$found {
                        lappend mkenv $p
                    }
                }
            }
        }
        write_mkenv $mkenv
        }
        build {
            # Otherwise, check all command-line-entered parameters.
            foreach p $::runtime::cli_parameters {
                # Retrieve parameter name 'pn' & value 'pv'
                set pn [lindex $p 0]
                set pv [lindex $p 1]
                set found 0
                # Check if parameters is not already registered in 'makefile.env'
                foreach mkenv_p $::runtime::mkenv_parameters {
                    set mkenv_pn [lindex $mkenv_p 0]
                    set mkenv_pv [lindex $mkenv_p 1]
                    if {$pn == $mkenv_pn} {
                        # If already registered, compare their values
                        set found 1
                        if {$pv != $mkenv_pv} {
                            handle_value_change $pn
                        }
                    }
                }
                # Now if the parameter has not been registered in previous 'makefile.env':
                if !$found {
                    handle_value_change $pn
                }
            }
            # Finally, check for 'removed' parameters
            foreach mkenv_p $::runtime::mkenv_parameters {
                set mkenv_pn [lindex $mkenv_p 0]
                set found 0
                foreach p $::runtime::cli_parameters {
                    set pn [lindex $p 0]
                    if {$mkenv_pn == $pn} {
                        set found 1
                    }
                }
                if !$found {
                    handle_value_change $mkenv_pn
                }
            }
            write_mkenv $::runtime::cli_parameters
        }
    }
}

proc make {} {
    # Write 'makefile.env' with cli parameters
    cd $::runtime::root
    process_mkenv
    if [is_empty $::runtime::targets] {
        lappend ::runtime::targets "all"
    }
    if $::runtime::make_debug {
        exec make -dn {*}$::runtime::targets reports >&@stdout
    } else {
        if [contains "log" $::runtime::targets] {
            exec make {*}$::runtime::targets >&@stdout
        } elseif [contains "help" $::runtime::targets] {
            exec make {*}$::runtime::targets >&@stdout
        } else {
            if {[set err [catch "exec make {*}$::runtime::targets reports >&@stdout | tee -a syfala_log.txt"]]} {
                print_error "Command failed with error code: $err"
                if [contains "hls" $::runtime::targets] {
                    exec make reports >&@stdout
                }
                exit
            }
        }
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
        }
        clean {
            add_target "clean"
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
        report - rpt - --report - --rpt {
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
            set_parameter "IMPORT_TARGET" $target
            add_target "import"
        }
        export {
            set target [get_argument_value index]
            set_parameter "EXPORT_TARGET" $target
            add_target "export"
        }
        --export-hls {
            add_target "hls-export"
        }
        flash - --flash {
            set platform [get_argument_value index]
            switch $platform {
                linux {
                    set target [get_argument_value index]
                    add_target "linux"
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
                boot {
                    add_target "flash-boot"
                }
                default {
                    add_target "flash"
                }
            }
        }
        scp {
            set addr [get_argument_value index]
            set host [get_argument_value index]
            set_parameter "SCP_TARGET_ADDR" $addr
            if [not_empty $host] {
                set_parameter "SCP_TARGET_USER" $host
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
        -x - --xilinx-root {
            set_parameter "XILINX_ROOT" [get_argument_value index]
        }
        --xversion {
            set_parameter "XILINX_VERSION" [get_argument_value index]
        }
        --flatpak {
            set_parameter "FLATPAK" TRUE
        }
        --unsafe-math-optimizations - --umo {
            set_parameter "HLS_DIRECTIVES_UNSAFE_MATH_OPTIMIZATIONS" TRUE
        }
        --accurate-use {
            set_parameter "HLS_ROUTING_AND_PLACEMENT" TRUE
        }
        --csim {
            add_target "hls-csim"
            set_parameter "HLS_CSIM_SOURCE" [get_argument_value index]
        }
        --csim-iter {
            set_parameter "HLS_CSIM_NUM_ITER" [get_argument_value index]
        }
        --csim-inputs {
            set_parameter "HLS_CSIM_INPUTS_DIR" [file normalize [get_argument_value index]]
        }
        --arm-target {
            set_parameter "HOST_MAIN_SOURCE" [file normalize [get_argument_value index]]
        }
        --benchmark {
            set_parameter "ARM_BENCHMARK" 1
        }
        --verbose {
            set level [get_argument_value index]
            if [is_empty $level] {
                set level 1
            }
            set_parameter "VERBOSE" $level
        }
        --sigma-delta {
            set order [get_argument_value index]
            set_parameter "CONFIG_EXPERIMENTAL_SIGMA_DELTA" TRUE
            set_parameter "SIGMA_DELTA_ORDER" $order
        }
        --tdm {
            set_parameter "CONFIG_EXPERIMENTAL_TDM" TRUE
        }
        --linux {
            add_target "linux"
        }
        --linux-dsp {
            set_parameter "LINUX" TRUE
            add_target "linux-dsp"
        }
        --vhdl - --faust2vhdl {
            set_parameter "TARGET_TYPE" faust2vhdl
            set ::runtime::faust2vhdl 1
        }
        --fixed-point {
            set_parameter "FAUST_FIXED_POINT" TRUE
        }
        --inputs {
            set_parameter "INPUTS" [get_argument_value index]
        }
        --outputs {
            set_parameter "OUTPUTS" [get_argument_value index]
        }
        --mcd {
            set_parameter "FAUST_MCD" [get_argument_value index]
        }
        --fvec {
            set_parameter "FAUST_VEC" 1
        }
        --multisample {
            set_parameter "MULTISAMPLE" [get_argument_value index]
        }
        --no-ctrl-block - --ncb {
            set_parameter "CONTROL_BLOCK" 0
        }
        --block-design - --bd {
            set_parameter "BD_TARGET" [get_argument_value index]
        }
        --transceiver - --i2s {
            set_parameter "I2S_SOURCE" [get_argument_value index]
        }
        --shield {
            set target [get_argument_value index]
            switch $target {
                adau {
                    set_parameter "ADAU_EXTERN" 1
                }
                motherboard {
                    set_parameter "ADAU_EXTERN" 1
                    set_parameter "ADAU_MOTHERBOARD" 1
                }
            }
        }
        --ethernet - --eth {
            set_parameter "CONFIG_EXPERIMENTAL_ETHERNET" TRUE
        }
        --no-ethernet-output {
            set_parameter "CONFIG_EXPERIMENTAL_ETHERNET_NO_OUTPUT" 1
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
            set_parameter "SD_DEVICE" $target
        }
        --debug {
            set target [get_argument_value index]
            switch $target {
                audio {
                    set_parameter "DEBUG_AUDIO" 1
                }
                make {
                    set ::runtime::make_debug 1
                }
                default {
                    # TODO
                }
            }
        }
        -y {
            set ::runtime::force 1
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # BUILD STEPS
        # -----------------------------------------------------------------------------------------
        }
	--faust {
	    # This is used by multiN, in order to make a copy of the dsp file and
	    # replace the patterns there instead of doing so in the original file.
	    add_target "build-faust-target"
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
        start-gui {
            add_target "start-gui"
        }
        boot - --boot {
            add_target "boot"
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
        --faust-mem {
            set_parameter "FAUST_FPGA_MEM" [get_argument_value index]
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
            if [string match "*.dsp" $argument] {
                 set_parameter "FAUST_DSP_TARGET" [file normalize $argument]
                 set ::runtime::mode "build"
                 if !$::runtime::faust2vhdl {
                     set_parameter "TARGET_TYPE" faust
                 }
            } elseif [string match "*.cpp" $argument] {
                 set_parameter "HLS_SOURCE_MAIN" [file normalize $argument]
                 set_parameter "TARGET_TYPE" cpp
                 set ::runtime::mode "build"
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
