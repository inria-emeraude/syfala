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

set OS $tcl_platform(os)
set OS_VERSION $tcl_platform(osVersion)

namespace eval Xilinx {
    variable ROOT
    variable VERSION 2020.2
}

# -----------------------------------------------------------------------------
# runtime steps
# -----------------------------------------------------------------------------

namespace eval runsteps {

variable data [list]

proc add_runstep { name targets } {
    lappend runsteps::data [list $name $targets]
}

proc get_next { } {
    set next [lindex [lindex $::runsteps::data 0] 0]
    set index 0
    foreach runstep $::runsteps::data {
        set name    [lindex $runstep 0]
        set targets [lindex $runstep 1]
        foreach target $targets {
            if {![file exists $target]} {
                return $next
            }
        }
        incr index
        if {$index > [llength $::runsteps::data]} {
            return "--flash"
        }
        set next [lindex [lindex $::runsteps::data $index] 0]
    }
    return $next
}

add_runstep "--arch" [list                      \
    $::Syfala::BUILD_APPLICATION_FILE           \
    $::Syfala::BUILD_IP_FILE                    \
]
add_runstep "--hls" [list                       \
    $::Syfala::BUILD_HLS_REPORT_COPY            \
]
add_runstep "--project" [list                   \
    $::Syfala::BUILD_XPR_FILE                   \
]
add_runstep "--synth" [list                     \
    $::Syfala::BUILD_BITSTREAM_FILE             \
]
add_runstep "--host" [list                      \
    $::Syfala::BUILD_APPLICATION_TARGET         \
]
add_runstep "--gui" [list                       \
    $::Syfala::BUILD_GUI_TARGET                 \
]
}

# -----------------------------------------------------------------------------
# runtime variable declarations
# -----------------------------------------------------------------------------

proc p_runtime { v a } {
    return [dict create value $v accepted $a]
}

proc get_value { a } {
    return [dict get $a value]
}

proc set_value { p v } {
    dict set $p value $v
}

namespace eval runtime {
    variable steps              ""
    variable post_steps         ""
    variable dsp_target         ""
    variable board_cpp_id       10
    variable app_config         0
    variable export_id          ""
    variable external_bd        0
    variable mcd                16
    variable compiler           [p_runtime "HLS" { HLS VHDL }]
    variable xversion           [p_runtime "2020.2" { 2020.2 2022.2 }]
    variable board              [p_runtime "Z10" { Z10 Z20 GENESYS }]
    variable memory             [p_runtime 1 { DDR STATIC }]
    variable sample_rate        [p_runtime 48000 { 24000 48000 96000 192000 384000 768000 }]
    variable sample_width       [p_runtime 24 { 16 24 32 }]
    variable controller_type    [p_runtime "PCB1" { DEMO PCB1 PCB2 PCB3 PCB4 }]
    variable ssm_volume         [p_runtime "HEADPHONE" { FULL HEADPHONE DEFAULT }]
    variable ssm_speed          [p_runtime "DEFAULT" { FAST DEFAULT }]
    variable vhdl_type          [p_runtime 0 {0 1}]
}

proc check_runtime_parameters {} {
    set sr [get_value $::runtime::sample_rate]
    set sw [get_value $::runtime::sample_width]
    if {$sr == 768000 && $sw > 16} {
         set_value ::runtime::sample_width 16
         print_info "Note: a sample-rate of 768kHz requires a 16-bit sample-width"
         print_info "SYFALA_SAMPLE_WIDTH changed to value: 16"
    }
}

# -----------------------------------------------------------------------------
# utility procedures
# -----------------------------------------------------------------------------

proc print_usage {} {
    print_info "
-------------------
Usage:
-------------------
\$ syfala <command>
\$ syfala <myfaustprogram.dsp> \[options steps parameters\]
-------------------------------------------------------------------------------
Commands
-------------------------------------------------------------------------------
      install: installs this script as a symlink in /usr/bin/
        clean: deletes current build directory
       import: <buildname> sets previously exported .zip build as the current build
       export: <buildname> exports current build as a .zip in the export/ directory
       report: <HLS|any> displays HLS or global report
         demo: fully builds demo based on default example (virtualAnalog)
        flash: flashes current build onto target device
          gui: executes Faust-generated gui application
 open-project: opens the generated .xpr project with Vivado
          log: displays log for the current build

-------------------------------------------------------------------------------
General Options
-------------------------------------------------------------------------------
   --xversion: \[ 2020.2 | 2022.2 \] chooses Xilinx toolchain version
                (2020.2 and 2022.2 only supported for now)
      --reset: resets current build directory before building
               (careful! all files from previous build will be lost)
        --mcd: <power of 2 value> (defaults to 16)
-------------------------------------------------------------------------------
Run steps
-------------------------------------------------------------------------------
        --all: runs all toolchain build steps (from --arch to --gui) (DEFAULT)
       --arch: uses Faust to generate ip/host .cpp files for HLS and
               Host application compilation
        --hls: runs Vitis HLS on generated ip cpp file
    --project: generates Vivado project
      --synth: synthesizes full Vivado project
       --host: compiles Host Control Application (ARM)
        --gui: compiles Faust GUI controller
      --flash: flashes boot files on device
     --report: prints HLS report at the end of the run
     --export: <id> exports build to export/ directory at the end of the run

-------------------------------------------------------------------------------
Run parameters
-------------------------------------------------------------------------------
      --memory, -m: \[ DDR*|STATIC \]
       --board, -b: \[ Z10*|Z20|GENESYS \]
     --sample-rate: \[ 48000*|96000|192000|384000|768000 \]
    --sample-width: \[ 16|24*|32 \]
 --controller-type: \[ DEMO|PCB1*|PCB2|PCB3|PCB4 \]
      --ssm-volume: \[ FULL|HEADPHONE|DEFAULT* \]
       --ssm-speed: \[ FAST|DEFAULT* \]

'*' means default parameter value
" 0
}

proc print_version {} {
    upvar OS os
    upvar OS_VERSION osv
    print_info "Running syfala toolchain script (v$::Syfala::VERSION) on $os ($osv)"    
}

# Tries to parse Xilinx Toolchain root installation directory
proc parse_xroot {} {
    if {![info exists ::Xilinx::ROOT]} {
        # if already defined in environment as 'XILINX_ROOT_DIR'
        if {[info exists ::env(XILINX_ROOT_DIR)]} {
             set ::Xilinx::ROOT $::env(XILINX_ROOT_DIR)
             print_ok "XILINX_ROOT_DIR defined in env as: $Xilinx::ROOT"
        } else {
            print_error "XILINX_ROOT_DIR is undefined, aborting"
            print_usage
            exit 1
        }
    } else {
        print_info "Checking XILINX_ROOT_DIR from command-line arguments...
             Please set XILINX_ROOT_DIR environment variable in your current shell configuration
             file in order to avoid this in future uses..."
    }
    # then, check if installation is valid
    # and add Vitis/Vivado/HLS environments to exec path
    # (we don't require the 'use_vitis' function anymore)
    check_xroot $Xilinx::ROOT $Xilinx::VERSION
    set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vitis_HLS"
    set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vivado"
    set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vitis"
    print_ok "Xilinx toolchain environment added to script's PATH"
}

# gets command line argument value at next 'argv' index
proc get_argument_value { index } {
    upvar $index idx
    return [lindex $::argv [incr idx]]
}

# checks argument value validity
# by comparing to the 'accepted' values set for the argument
# (see the runtime variables above)
proc parse_argument_value { argument value } {
    upvar $argument rparameter
    set accept [dict get $rparameter "accepted"]
    if {[lsearch -exact $accept $value] >= 0 || $accept == {}} {
         dict set rparameter value "$value"
    } else {
        print_error "Value ($value) for argument not accepted"
        print_error "Accepted values: $accept"
        print_error "Default value: [dict get $rparameter value]"
        exit 1
    }
}

# checks if ::runtime::steps variable includes 'step'
proc is_run_step {step} {
    return [contains $step $::runtime::steps]
}

# checks if ::runtime::post_steps variable includes 'step'
proc is_post_run_step {step} {
    return [contains $step $::runtime::post_steps]
}

# checks dsp target file validity:
# if no dsp target file has been set in the command line
# we look for one saved in the build directory
proc check_dsp_target {} {
    if {$::runtime::dsp_target eq ""} {
         print_info "No dsp target, looking for previous target in build directory"
         foreach f [glob -directory $::Syfala::BUILD_DIR *.dsp] {
            # pick the first one
            set ::runtime::dsp_target [file normalize $f]
            print_ok "Setting [file tail $f] as dsp target"
         }
    } else {
        file copy -force $::runtime::dsp_target $::Syfala::BUILD_DIR
    }
}

proc display_report {} {
    set dsp [get_dsp_name]
    set board_cpp_id [get_syconfig_define "SYFALA_BOARD"]
    set sample_rate  [get_syconfig_define "SYFALA_SAMPLE_RATE"]
    set sample_width [get_syconfig_define "SYFALA_SAMPLE_WIDTH"]
    set volume [get_syconfig_define "SYFALA_SSM_VOLUME"]
    set controller [get_syconfig_define "SYFALA_CONTROLLER_TYPE"]
    set version $::Syfala::VERSION
    set path $::Syfala::ROOT
    set num_io [get_num_io]
    set mem_access [Faust::mem_access_count]
    switch $board_cpp_id {
        10 { set board "Z10" }
        20 { set board "Z20" }
        30 { set board "GENESYS" }
        default {
            print_error "Incorrect board model, aborting..."
            exit 1
        }
    }
    exec $::Syfala::ROOT/tools/print_reports.sh     \
            $path                                   \
            $version                                \
            $dsp                                    \
            $board                                  \
            $sample_rate                            \
            $sample_width                           \
            $controller                             \
            $volume                                 \
            [lindex $num_io 0]                      \
            [lindex $num_io 1]                      \
            [lindex $mem_access 0]                  \
            [lindex $mem_access 1]                  \
        >&@stdout
    exit 0
}

# -----------------------------------------------------------------------------------------
# SCRIPT START
# -----------------------------------------------------------------------------------------
if ![lcontains "log" $::argv] {
    print_version
    print_info "Running from: $spath"
    Syfala::basic_print "\[ [color 3 CMD!] \] Command used: syfala $::argv"
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
            print_usage
            exit 0
        }
        -v - --version - version {
            exit 0
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # COMMANDS
        # -----------------------------------------------------------------------------------------
        }
        install {
            print_info "Installing script as symlink in /usr/bin"
            exec sudo ln -fs $spath /usr/bin/syfala
            print_ok   "You can now use \$ syfala --help to check if script has been installed properly"
            print_info "Don't forget to add 'export XILINX_ROOT_DIR=/your/path/to/Xilinx/root'
         to your shell resource file (~/.bashrc, ~/.zshrc etc.)"
            exit 0
        }
        clean {
            rstbuild
            exit 0
        }
        next {
            set ::runtime::steps [runsteps::get_next]
        }
        demo {
            set ::runtime::dsp_target [file normalize examples/virtualAnalog.dsp]
            set ::runtime::steps "$::runtime::steps
                --arch --hls --project --synth --host
                --report --export demo"
        }
        open-project {
            parse_xroot
            exec [Xilinx::vivado] $::Syfala::BUILD_XPR_FILE
            exit 0
        }
        report - rpt {
            set target [get_argument_value index]
            switch $target {
                HLS - hls {
                    cd $::Syfala::BUILD_DIR
                    Xilinx::Vitis_HLS::report
                }
                default {
                    display_report
                }
            }
            exit 0
        }
        import {
            set target [get_argument_value index]
            if [file exists $target] {
                print_info "Setting $target as current build"
                rstbuild
                exec unzip $target -d build/
                print_ok "$target successfully imported"
            }
            exit 0
        }
        export {
            set build_id [get_argument_value index]
            set build_id "[generate_build_id]-$build_id"
            print_info "build id: #$build_id"
            cd $::Syfala::BUILD_DIR
            Syfala::export_build $build_id
            exit 0
        }
        flash {
            # note: fixes the '--board' argument not being parsed
            # whenever this command is called
            set ::runtime::post_steps "$::runtime::post_steps --flash"
        }
        gui {
            print_info "Now executing Faust-generated GUI application"
            exec $::Syfala::BUILD_GUI_DIR/faust-gui
            exit 0
        }
        get-board-version {
            parse_xroot
            ::Xilinx::get_board_part_full [get_value $::runtime::board]
            exit 0
        }
        set-default-board {
            set old [get_value $::runtime::board]
            parse_argument_value ::runtime::board [get_argument_value index]
            set new [get_value $::runtime::board]
            set args [list $old $new]
            freplacelfn $spath "{ Z10 Z20 GENESYS }" $args {{line args} {
                set flat [lindex $args 0]
                set A "\"[lindex $flat 0]\""
                set B "\"[lindex $flat 1]\""
                return [string map [list $A $B] $line]
            }}
            exit 0
        }
        test {
            # remove the 'test' command from arguments
            parse_xroot
            source $::Syfala::TESTS_DIR/tests.tcl
            exit 0
        }
        log {
            exec cat syfala_log.txt >&@stdout
            display_report
            exit 0
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # OPTIONS
        # -----------------------------------------------------------------------------------------
        }
        -c - --compiler {
            parse_argument_value ::runtime::compiler [get_argument_value index]
        }
        -x - --xilinx-root {
            # note: it has to be before any other options or flags
            set ::Xilinx::ROOT [get_argument_value index]
            print_info "Setting XILINX_ROOT to $::Xilinx::ROOT"
        }

        --xversion {
            parse_argument_value ::runtime::xversion [get_argument_value index]
            set ::Xilinx::VERSION [get_value $::runtime::xversion]
            print_info "Setting XILINX_VERSION to $::Xilinx::VERSION"
        }
        --reset {
            # resets current build directory (careful, all files from previous build will be lost)
            rstbuild
            file mkdir $::Syfala::BUILD_DIR
        }
        -sd - --sigma-delta {
            set ::runtime::external_bd 1
            set_value ::runtime::sample_rate 5000000
            set_value ::runtime::sample_width 16
            file mkdir $::Syfala::BUILD_DIR
            file mkdir $::Syfala::BUILD_SOURCES_DIR
            file copy -force $::Syfala::EXTERNAL_BD_SIGMA_DELTA     \
                             $::Syfala::BUILD_EXTERNAL_BD
            file copy -force $::Syfala::VHDL_DIR/sd_dac_first.vhd   \
                             $::Syfala::BUILD_SOURCES_DIR/sd_dac_first.vhd
             file copy -force $::Syfala::PROJECT_SCRIPT_TEMPLATE \
                              $::Syfala::PROJECT_SCRIPT
        }
        --tdm {
            set ::runtime::external_bd 1
            set_value ::runtime::sample_rate 48825
            set_value ::runtime::sample_width 16
            file mkdir $::Syfala::BUILD_DIR
            file mkdir $::Syfala::BUILD_SOURCES_DIR
            file copy -force $::Syfala::EXTERNAL_BD_TDM                     \
                             $::Syfala::BUILD_EXTERNAL_BD
            file copy -force $::Syfala::VHDL_DIR/i2s_transceiver_tdm.vhd    \
                             $::Syfala::BUILD_SOURCES_DIR/i2s_transceiver_tdm.vhd
            file copy -force $::Syfala::PROJECT_SCRIPT_TEMPLATE \
                             $::Syfala::PROJECT_SCRIPT
        }
        --mcd {
            set ::runtime::mcd [get_argument_value index]
            print_info "Set Faust -mcd option to $::runtime::mcd"
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # RUNTIME STEPS
        # -----------------------------------------------------------------------------------------
        }
        -a - --all {
            # runs all toolchain build steps (from --arch to --gui) (DEFAULT)
            set ::runtime::steps "$::runtime::steps --arch --hls --project --synth --host --gui"
        }
        --arch           { append ::runtime::steps "--arch"    }
        --hls - --ip     { append ::runtime::steps "--hls"     }
        --project        { append ::runtime::steps "--project" }
        --syn - --synth  { append ::runtime::steps "--synth"   }
        --app - --host - --app-rebuild - --rebuild-app - rebuild-app - app-rebuild  {
            if {[file exists build/syfala_application/application] ||
                [file exists build/syfala_application/platform]} {
                print_info "Resetting Host Application build"
                file delete -force -- build/include
                file delete -force -- build/syfala_application
                file delete -force -- build/sw_export
                append ::runtime::steps "--arch --host"
            } else {
                append ::runtime::steps "--host"
            }
        }
        --gui             { append ::runtime::steps "--gui" }
        --report - --rpt  { append ::runtime::post_steps "--report" }
        --flash           { append ::runtime::post_steps "--flash"  }
        --export          {
            append ::runtime::post_steps "--export"
            set build_id [get_argument_value index]
            set build_id "[generate_build_id]-$build_id"
            set ::runtime::export_id $::build_id
        }

        COMMENT {
        # -----------------------------------------------------------------------------------------
        # RUNTIME PARAMETERS
        # -----------------------------------------------------------------------------------------
        }
        -b - --board {
            parse_argument_value ::runtime::board [get_argument_value index]
            switch [get_value $::runtime::board] {
                Z10      { set ::runtime::board_cpp_id 10 }
                Z20      { set ::runtime::board_cpp_id 20 }
                GENESYS  { set ::runtime::board_cpp_id 30 }
            }
        }
        -m - --memory {
            parse_argument_value ::runtime::memory [get_argument_value index]
            switch [get_value $::runtime::memory] {
                "DDR"     { dict set ::runtime::memory value 1 }
                "STATIC"  { dict set ::runtime::memory value 0 }
            }
        }
        --sample-rate {
            parse_argument_value ::runtime::sample_rate [get_argument_value index]
        }
        --sample-width {
            parse_argument_value ::runtime::sample_width [get_argument_value index]
        }
        --controller-type {
            parse_argument_value ::runtime::controller_type [get_argument_value index]
        }
        --ssm-volume {
            parse_argument_value ::runtime::ssm_volume [get_argument_value index]
        }
        --ssm-speed {
            parse_argument_value ::runtime::ssm_speed [get_argument_value index]
        }
        --vhdl-type {
            parse_argument_value ::runtime::vhdl_type [get_argument_value index]
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # DSP FILE / INVALID ARGUMENT
        # -----------------------------------------------------------------------------------------
        }
        default {
            # check DSP target file
            set pattern ".dsp"
            if {[string match *$pattern $argument] && [file exists $argument]} {
                 print_ok "Setting $argument as DSP target file"
                 set ::runtime::dsp_target [file normalize $argument]
                 # copy file into build directory root
            } else {
                print_error "Invalid argument ($argument), aborting"
                exit 1
            }
        }
    }
}

# -------------------------------------------------------------------------
# From this point, script is running in build mode:
# -------------------------------------------------------------------------
# if there are no runtime steps, set them all
if {[is_empty $::runtime::steps] && ![is_empty $::runtime::dsp_target]} {
    set ::runtime::steps "--arch --hls --project --synth --host --gui"
}
# Check that XILINX_ROOT_DIR and correct .dsp target are set
parse_xroot

# Make sure we're into BUILD_DIR, even if we didn't run the --arch step
if ![file exist $::Syfala::BUILD_DIR] {
     file mkdir $::Syfala::BUILD_DIR
}
cd $::Syfala::BUILD_DIR

if [file exists $::Syfala::BUILD_INCLUDE_DIR] {
    # If build already exists, retrieve board value
    set ::runtime::board_cpp_id [get_syconfig_define "SYFALA_BOARD"]
    switch $::runtime::board_cpp_id {
        10 { set_value ::runtime::board "Z10" }
        20 { set_value ::runtime::board "Z20" }
        30 { set_value ::runtime::board "GENESYS" }
        default {
            print_error "Incorrect board model, aborting..."
            exit 1
        }
    }
    print_info "Retrieved previously used board model: [get_value $::runtime::board]"
}

print_info "Running build steps: $::runtime::steps"
print_info "Running post-build steps: $::runtime::post_steps"

check_dsp_target

if [is_run_step "--arch"] {
     # Overwrite #define values in syconfig.hpp from command-line arguments
     # Note: this is common to both configurations (HLS/FAUST2VHDL)
    initialize_build
    check_runtime_parameters
    set_syconfig_define  "SYFALA_BOARD" $::runtime::board_cpp_id [get_value $::runtime::board]
    set_syconfig_define  "SYFALA_SAMPLE_RATE"      [get_value $::runtime::sample_rate]
    set_syconfig_define  "SYFALA_SAMPLE_WIDTH"     [get_value $::runtime::sample_width]
    set_syconfig_define  "SYFALA_CONTROLLER_TYPE"  [get_value $::runtime::controller_type]
    set_syconfig_define  "SYFALA_SSM_VOLUME"       [get_value $::runtime::ssm_volume]
    set_syconfig_define  "SYFALA_SSM_SPEED"        [get_value $::runtime::ssm_speed]
    set_syconfig_define  "SYFALA_MEMORY_USE_DDR"   [get_value $::runtime::memory]
}

# This is where the toolchain's steps diverge,
# depending on the chosen IP 'compiler' (HLS | faust2vhdl)
# this includes the following steps:
# --arch     (IP file generation)
# --hls      (not needed for faust2vhdl)
# --project  (project script files are different)

switch [get_value $::runtime::compiler] {
    HLS {
    # -------------------------------------------------------------------------
        print_ok "Selected HLS configuration (with Vitis)"
    # -------------------------------------------------------------------------
        set ::runtime::app_config 1
        # 1. Generate Faust IP and Host Application cpp files
        if [is_run_step "--arch"] {
            Faust::generate_ip_hls $::runtime::dsp_target
            # Generate sources with set number of channels
            source $::Syfala::SCRIPTS_DIR/prebuild.tcl
            # new: count izone/fzone accesses immediately after
            # ip cpp file is generated.
            Faust::mem_access_count
            Faust::generate_host $::runtime::dsp_target                 \
                                 $::Syfala::ARCH_ARM_FILE_HLS
        }
        # 2. Synthesize IP with Vitis HLS
        if [is_run_step "--hls"] {
            Xilinx::Vitis_HLS::run $::Syfala::HLS_SCRIPT                \
                                   [get_value $::runtime::board]
        }

        # 3. Run Vivado to generate the full project
        if [is_run_step "--project"] {
            Xilinx::Vivado::run $::Syfala::PROJECT_SCRIPT               \
                                [get_value $::runtime::board]           \
                                $::runtime::external_bd                 \
                                $::Xilinx::ROOT                         \
                                $::Xilinx::VERSION
        }
    }
    VHDL {
    # -------------------------------------------------------------------------
        print_ok "Selected faust2vhdl configuration"
    # -------------------------------------------------------------------------
        set ::runtime::app_config 0
        if [is_run_step "--arch"] {
            Faust::generate_ip_vhdl $::runtime::dsp_target             \
                                    [get_value $::runtime::vhdl_type]
            Faust::generate_host    $::runtime::dsp_target             \
                                    $::Syfala::ARCH_ARM_FILE_VHDL
        }
        if [is_run_step "--project"] {
            Xilinx::Vivado::run $Syfala::FAUST2VHDL_SCRIPT             \
                                [get_value $::runtime::board]
        }
    }
}

# -------------------------------------------------------------------------
# common steps
# -------------------------------------------------------------------------

# 4. Synthesize the whole design
if [is_run_step "--synth"] {
     Xilinx::Vivado::run $::Syfala::SYNTHESIS_SCRIPT
}
# 5. Compile Host Control Application
if [is_run_step "--host"] {
     Xilinx::compile_host $::runtime::app_config [get_value $::runtime::board]
}
if [is_run_step "--gui"] {
    Faust::generate_gui_app $::runtime::dsp_target
}
if [is_post_run_step "--export"] {
    Syfala::export_build $::runtime::export_id
}
if [is_post_run_step "--report"] {
    Xilinx::Vitis_HLS::report
}
if [is_post_run_step "--flash"] {
    Xilinx::flash_jtag [get_value $::runtime::board]
}

print_elapsed_time $tstart
print_ok "Successful run!"
print_ok "To see the build's full log: open 'syfala_log.txt' in the repository's root directory"
display_report
