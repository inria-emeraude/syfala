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
}

# -------------------------------------------------------------------------------------------------
# runtime variable declarations
# -------------------------------------------------------------------------------------------------

proc p_runtime { v a } {
    return [dict create value $v accepted $a]
}

proc get_value { a } {
    return [dict get $a value]
}

namespace eval runtime {
    variable steps              ""
    variable dsp_target         ""
    variable board_cpp_id       10
    variable app_config         0
    variable compiler           [p_runtime "HLS" { HLS VHDL }]
    variable board              [p_runtime "Z10" { Z10 Z20 GENESYS }]
    variable memory             [p_runtime 1 { DDR STATIC }]
    variable nchannels          [p_runtime 2 { 2 4 6 8 10 }]
    variable sample_rate        [p_runtime 48000 { 48000 96000 192000 }]
    variable sample_width       [p_runtime 24 { 16 24 32 }]
    variable controller_type    [p_runtime "PCB1" { DEMO PCB1 PCB2 PCB3 PCB4 }]
    variable ssm_volume         [p_runtime "HEADPHONE" { FULL HEADPHONE DEFAULT }]
    variable ssm_speed          [p_runtime "DEFAULT" { FAST DEFAULT }]
    variable vhdl_type          [p_runtime 0 { 0 1 }]
}

# -------------------------------------------------------------------------------------------------
# utility procedures
# -------------------------------------------------------------------------------------------------

proc print_usage {} {
    print_info "See
-------------------
Usage:
-------------------
\$ syfala <command>
\$ syfala <options> myfaustprogram.dsp <steps> <parameters>

build examples:
---------------
\$ syfala examples/virtualAnalog.dsp
\$ syfala -c VHDL examples/phasor.dsp --export vanalog-vhdl-build
\$ syfala examples/virtualAnalog.dsp --board GENESYS --sample-rate 96000
\$ syfala examples/fm.dsp --hls --report
\$ syfala examples/fm.dsp --board Z20 --hls --export z20-fm-hls-build

-------------------------------------------------------------------------------
Commands
-------------------------------------------------------------------------------
      install: installs this script as a symlink in /usr/bin/
        clean: deletes current build directory
       export: \[ name of the exported build \]
       report: prints HLS report of the current build
         demo: fully builds demo based on default example (virtualAnalog)
        flash: flashes current build onto target device
          gui: executes Faust-generated gui application

command examples:
-----------------
\$ syfala demo
\$ syfala clean
\$ syfala export my-current-build
\$ syfala flash

-------------------------------------------------------------------------------
General Options
-------------------------------------------------------------------------------
           -x: <XILINX_ROOT_DIR>
-c --compiler: \[ HLS* | VHDL \] chooses between HLS & faust2vhdl
                for IP generation.
      --reset: resets current build directory before building
               (careful! all files from previous build will be lost)
-------------------------------------------------------------------------------
Run steps
-------------------------------------------------------------------------------
        --all: runs all toolchain build steps (from --arch to --gui) (DEFAULT)
       --arch: uses Faust to generate ip/host .cpp files for HLS and
               Host application compilation
   --hls --ip: runs Vitis HLS on generated ip cpp file
    --project: generates Vivado project
      --synth: synthesizes full Vivado project
 --host --app: compiles Host Control Application (ARM)
        --gui: compiles Faust GUI controller
      --flash: flashes boot files on device
     --report: prints HLS report at the end of the run
     --export: <id> exports build to export/ directory at the end of the run

-------------------------------------------------------------------------------
Run parameters
-------------------------------------------------------------------------------
   --nchannels, -n: \[ an even number (2*/4/6...) \]
      --memory, -m: \[ DDR*|STATIC \]
       --board, -b: \[ Z10*|Z20|GENESYS \]
     --sample-rate: \[ 48000*|96000|192000|384000|768000 \]
    --sample-width: \[ 16|24*|32 \]
 --controller-type: \[ DEMO|PCB1*|PCB2|PCB3|PCB4 \]
      --ssm-volume: \[ FULL|HEADPHONE|DEFAULT* \]
       --ssm-speed: \[ FAST|DEFAULT* \]

'*' means default parameter value
"
}

proc print_version {} {
    upvar OS os
    upvar OS_VERSION osv
    print_info "Running syfala toolchain script (v$::Syfala::VERSION) on $os ($osv)"
}

proc parse_xroot {} {
    # try and parse Xilinx Toolchain root installation directory:
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
    check_xroot $Xilinx::ROOT $Xilinx::VERSION
    # adding Vitis/Vivado/HLS environments to exec path
    # (we don't require the 'use_vitis' function anymore)
    set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vitis_HLS"
    set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vivado"
    set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vitis"
    print_ok "Xilinx toolchain environment added to script's PATH"
}

proc parse_argument_value { argument value } {
    upvar $argument rparameter
    set accept [dict get $rparameter "accepted"]
    if {[lsearch -exact $accept $value] >= 0 || $accept == {}} {
         dict set rparameter value "$value"
    } else {
        print_error "Value for argument not accepted"
        print_error "Accepted values: $accept"
        print_error "Default value: [dict get $rparameter value]"
        exit 1
    }
}

proc is_run_step {ctn} {
    if { [string first $ctn $::runtime::steps] != -1 } {
         return 1
    } else {
        return 0
    }
}

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

# -----------------------------------------------------------------------------------------
# SCRIPT START
# -----------------------------------------------------------------------------------------
print_version
print_info "Running from: [pwd]"

# reset log and build directory
file mkdir $::Syfala::BUILD_DIR
file delete -force $::Syfala::BUILD_LOG

# -----------------------------------------------------------------------------------------
# PARSING COMMAND-LINE ARGUMENTS
# -----------------------------------------------------------------------------------------

for { set index 0 }                         \
    { $index < [llength $::argv] }          \
    { incr index } {
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
        demo {
            set ::runtime::dsp_target [file normalize examples/virtualAnalog.dsp]
            set ::runtime::steps "$::runtime::steps
                --arch --hls --project --synth --host
                --report --export demo"
        }
        report {
            Xilinx::Vitis_HLS::report
            exit 0
        }
        export {
            set build_id [lindex $::argv [incr index]]
            set build_id "[generate_build_id]-$build_id"
            print_info "build id: #$build_id"
            Syfala::export_build $build_id
            exit 0
        }
        flash {
            parse_xroot
            cd $Syfala::BUILD_DIR
            Xilinx::flash_jtag [get_value $::runtime::board]
            exit 0
        }
        gui {
            print_info "Now executing Faust-generated GUI application"
            exec $::Syfala::BUILD_GUI_DIR/faust-gui
            exit 0
        }
        COMMENT {
        # -----------------------------------------------------------------------------------------
        # OPTIONS
        # -----------------------------------------------------------------------------------------
        }
        -c - --compiler {
            parse_argument_value ::runtime::compiler [lindex $::argv [incr index]]
        }
        -x - --xilinx-root {
            # note: it has to be before any other options or flags
            set ::Xilinx::ROOT [lindex $::argv [incr index]]
            print_info "Setting XILINX_ROOT to $::Xilinx::ROOT"
        }
        --reset {
            # resets current build directory (careful, all files from previous build will be lost)
            rstbuild
            file mkdir $::Syfala::BUILD_DIR
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
        --arch           { set ::runtime::steps "$::runtime::steps --arch"      }
        --hls - --ip     { set ::runtime::steps "$::runtime::steps --hls"       }
        --project        { set ::runtime::steps "$::runtime::steps --project"   }
        --syn - --synth  { set ::runtime::steps "$::runtime::steps --synth"     }
        --app - --host - --app-rebuild - --rebuild-app - rebuild-app - app-rebuild  {
            if {[file exists build/syfala_application/application] ||
                [file exists build/syfala_application/platform]} {
                print_info "Resetting Host Application build"
                file delete -force -- build/include
                file delete -force -- build/syfala_application
                file delete -force -- build/sw_export
                set ::runtime::steps "$::runtime::steps --arch --host"
            } else {
                set ::runtime::steps "$::runtime::steps --host"
            }
        }
        --gui       { set ::runtime::steps "$::runtime::steps --gui"        }
        --report    { set ::runtime::steps "$::runtime::steps --report"     }
        --flash     { set ::runtime::steps "$::runtime::steps --flash"      }
        --export    { set ::runtime::steps "$::runtime::steps --export"     }

        COMMENT {
        # -----------------------------------------------------------------------------------------
        # RUNTIME PARAMETERS
        # -----------------------------------------------------------------------------------------
        }
        -b - --board {
            parse_argument_value ::runtime::board [lindex $::argv [incr index]]
            switch [get_value $::runtime::board] {
                Z10      { set ::runtime::board_cpp_id 10 }
                Z20      { set ::runtime::board_cpp_id 20 }
                GENESYS  { set ::runtime::board_cpp_id 30 }
            }
        }
        -m - --memory {
            parse_argument_value ::runtime::memory [lindex $::argv [incr index]]
            switch [get_value $::runtime::memory] {
                "DDR"     { dict set ::runtime::memory value 1 }
                "STATIC"  { dict set ::runtime::memory value 0 }
            }
        }
        -n - --nchannels {
            parse_argument_value ::runtime::nchannels [lindex $::argv [incr index]]
        }
        --sample-rate {
            parse_argument_value ::runtime::sample_rate [lindex $::argv [incr index]]
        }
        --sample-width {
            parse_argument_value ::runtime::sample_width [lindex $::argv [incr index]]
        }
        --controller-type {
            parse_argument_value ::runtime::controller_type [lindex $::argv [incr index]]
        }
        --ssm-volume {
            parse_argument_value ::runtime::ssm_volume [lindex $::argv [incr index]]
        }
        --ssm-speed {
            parse_argument_value ::runtime::ssm_speed [lindex $::argv [incr index]]
        }
        --vhdl-type {
            parse_argument_value ::runtime::vhdl_type [lindex $::argv [incr index]]
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
# Script running in build mode:
# -------------------------------------------------------------------------

if {$::runtime::steps eq ""} {
    set ::runtime::steps "--arch --hls --project --synth --host --gui"
}
parse_xroot
# make sure we're into BUILD_DIR, even if we didn't run the --arch step
cd $::Syfala::BUILD_DIR
print_info "Running build steps: $::runtime::steps"

check_dsp_target

if {[is_run_step "--arch"]} {
     # Overwrite #define values in syconfig.hpp from command-line arguments
     # Note: this is common to both configurations (HLS/FAUST2VHDL)
     initialize_build
     set_syconfig_define  "SYFALA_BOARD"            $::runtime::board_cpp_id
     set_syconfig_define  "SYFALA_SAMPLE_RATE"      [get_value $::runtime::sample_rate]
     set_syconfig_define  "SYFALA_SAMPLE_WIDTH"     [get_value $::runtime::sample_width]
     set_syconfig_define  "SYFALA_CONTROLLER_TYPE"  [get_value $::runtime::controller_type]
     set_syconfig_define  "SYFALA_SSM_VOLUME"       [get_value $::runtime::ssm_volume]
     set_syconfig_define  "SYFALA_SSM_SPEED"        [get_value $::runtime::ssm_speed]
     set_syconfig_define  "SYFALA_MEMORY_USE_DDR"   [get_value $::runtime::memory]
}

switch [get_value $::runtime::compiler] {
    HLS {
    # -------------------------------------------------------------------------
        print_ok "Selected HLS configuration (with Vitis)"
    # -------------------------------------------------------------------------
        set ::runtime::app_config 1
        # 1. Generate Faust IP and Host Application cpp files
        if {[is_run_step "--arch"]} {
            # Generate sources with set number of channels
            exec $::Syfala::SCRIPTS_DIR/syfala_maker.tcl                \
                 [get_value $::runtime::nchannels]                      \
                 [get_value $::runtime::board]                          \
                 >&@stdout

            Faust::generate_ip_hls $::runtime::dsp_target
            # new: count izone/fzone accesses immediately after
            # ip cpp file is generated.
            Faust::mem_access_count
            Faust::generate_host   $::runtime::dsp_target               \
                                   $Faust::ARCH_HOST_SRC_FILE
        }
        # 2. Synthesize IP with Vitis HLS
        if {[is_run_step "--hls"]} {
             Xilinx::Vitis_HLS::run $Syfala::HLS_SCRIPT                 \
                                    [get_value $::runtime::board]
        }

        # 3. Run Vivado to generate the full project
        if {[is_run_step "--project"]} {
             Xilinx::Vivado::run $Syfala::PROJECT_SCRIPT                \
                                [get_value $::runtime::board]           \
                                [get_value $::runtime::sample_rate]     \
                                [get_value $::runtime::sample_width]
        }
    }
    VHDL {
    # -------------------------------------------------------------------------
        print_ok "Selected faust2vhdl configuration"
    # -------------------------------------------------------------------------
        set ::runtime::app_config 0
        if {[is_run_step "--arch"]} {
             Faust::generate_ip_vhdl $::runtime::dsp_target             \
                                     [get_value $::runtime::vhdl_type]
             Faust::generate_host    $::runtime::dsp_target             \
                                     $::Faust::ARCH_HOST_SRC_FILE_VHDL
        }
        if {[is_run_step "--project"]} {
             Xilinx::Vivado::run $Syfala::FAUST2VHDL_SCRIPT             \
                                 [get_value $::runtime::board]
        }
    }
}

# -------------------------------------------------------------------------
# common steps
# -------------------------------------------------------------------------

# 4. Synthesize the whole design
if {[is_run_step "--synth"]} {
     Xilinx::Vivado::run $Syfala::SYNTHESIS_SCRIPT
}
# 5. Compile Host Control Application
if {[is_run_step "--host"]} {
     Xilinx::compile_host $::runtime::app_config [get_value $::runtime::board]
}
if {[is_run_step "--gui"]} {
     Faust::generate_gui_app $::runtime::dsp_target
}
if {[is_run_step "--export"]} {
    Syfala::export_build "demo"
}
if {[is_run_step "--report"]} {
     Xilinx::Vitis_HLS::report
}
if {[is_run_step "--flash"]} {
     Xilinx::flash_jtag [get_value $::runtime::board]
}

print_elapsed_time $tstart
print_ok "Successful run!"
print_ok "To see the build's full log: open 'syfala_log.txt' in the repository's root directory"

