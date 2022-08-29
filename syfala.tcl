#!/usr/bin/tclsh

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

namespace eval Syfala {
    variable RUN ""
    variable CONFIG
}

# -------------------------------------------------------------------------------------------------
# utility procedures
# -------------------------------------------------------------------------------------------------

proc print_usage {} {
    print_info "Usage:

\$ syfala myfaustprogram.dsp <options> <steps> <parameters>

General Options ------------------------------------------------------------
      -x: <XILINX_ROOT_DIR>
--report: (prints HLS report at the end of the run)
--export: <id> (exports build to export/ directory)
  --demo: runs the full toolchain on the default example (virtualAnalog.dsp)

Run steps ------------------------------------------------------------------
        --all: runs all toolchain build steps (from --arch to --gui) (DEFAULT)
      --reset: resets current build directory (careful, all files from
               previous build will be lost)
       --arch: uses Faust to generate ip/host .cpp files for HLS and
               Host application compilation
         --ip: runs Vitis HLS on generated ip cpp file
    --project: generates Vivado project
        --syn: synthesizes full Vivado project
        --app: compiles Host Control Application (ARM)
--app-rebuild: recompiles Host application (running --app won't work if
               you only want to rebuild the application after some changes)
        --gui: compiles Faust GUI controller
      --flash: flashes boot files on device

Run parameters ------------------------------------------------------------
   --nchannels, -n: \[ an even number (2/4/6...) \]
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
    print_info "Running Syfala Toolchain v$::Syfala::VERSION on $os ($osv)"
}
## Returns 1 if argument is set in the command-line arguments
## Returns 0 otherwise
proc is_argument { a } {
     foreach arg $::argv {
        if { $a == $arg } {
             return 1
        }
     }
    return 0
}
## Parses argument $ids (a list) from command-line arguments
## returning its value if any, matching against accepted values
## returning default argument $defaultv otherwise
proc parse_argument { ids accept defaultv } {
    set index 0
    foreach arg $::argv {
        incr index
        foreach id $ids {
            if { $id != "" && $arg == $id } {
		set value [lindex $::argv $index]
		if {[lsearch -exact $accept $value] >= 0 || $accept == {}} {
		     return $value
		} else {
		     print_error "Value for argument $ids not accepted"
		     print_error "Accepted values: $accept"
		     print_error "Default value: $defaultv"
		     exit 1
		}
            }
        }
    }
    return $defaultv
}

proc parse_run_step {a} {
    if {[is_argument $a]} {
        set Syfala::RUN [concat $Syfala::RUN " $a"]
    }
}

proc is_run_step {ctn} {
    if { [string first $ctn $::Syfala::RUN] != -1 } {
         return 1
    }
    return 0
}

## Parses command-line arguments, checking DSP target file
proc parse_dsp_target {} {
    set ptn ".dsp"
    foreach arg $::argv {
        if {[string match *$ptn $arg] && [file exists $arg]} {
            print_ok "Checked $arg DSP target file"
            return [file normalize $arg]
        }
    }
#    print_error "Undefined path to Faust DSP target file"
    return ""
}

# -------------------------------------------------------------------------------------------------
# SCRIPT START
# -------------------------------------------------------------------------------------------------

print_version
print_info "Running from: [pwd]"

if {[is_argument "-v"] || [is_argument "--version"]} {
     exit 0
}
if {[is_argument "-h"] || [is_argument "--help"]} {
     print_usage
     exit 0
}
# if 'clean' argument is passed, just remove the build files and quit
if {[is_argument "clean"]} {
    rstbuild
    exit 0
}

# check if script is running in 'install' mode
if {[is_argument "--install"]} {
    print_info "Installing script as symlink in /usr/bin"
    exec sudo ln -fs $spath /usr/bin/syfala
    print_ok "You can now use \$ syfala --help to check if script has been installed properly"
    print_info "Don't forget to add 'export XILINX_ROOT_DIR=/your/path/to/Xilinx/root'
         to your shell resource file (~/.bashrc, ~/.zshrc etc.)"
    exit 0
}
# try and parse Xilinx Toolchain root installation directory:
# 1. if already defined in environment as 'XILINX_ROOT_DIR'
if {[info exists ::env(XILINX_ROOT_DIR)]} {
    set ::Xilinx::ROOT $::env(XILINX_ROOT_DIR)
    print_ok "XILINX_ROOT_DIR defined in env as: $Xilinx::ROOT"
    check_xroot $Xilinx::ROOT $Xilinx::VERSION
} else {
    # 2. Otherwise, parse the '-x' command-line argument
    print_info "Checking XILINX_ROOT_DIR from command-line arguments...
	 Please set XILINX_ROOT_DIR environment variable in your current shell configuration
	 file in order to avoid this in future uses..."
    set $Xilinx::ROOT [parse_argument "-x" {}]
    if {[info exists $Xilinx::ROOT]} {
	 check_xroot $Xilinx::ROOT $Xilinx::VERSION
    } else {
         # If couldn't parse '-x' argument, abort
         print_error "XILINX_ROOT_DIR is undefined, aborting"
         print_usage
         exit 1
    }
}
# if script is running in post-install mode,
# install cable drivers, vivado boards (v1.0), y2k22 patch
# and exit script
#if {[is_argument "--post-install"]} {
#    post_install $Xilinx::ROOT $Xilinx::VERSION
#    exit 0
#}


# Returns normalized filepath of the file
# required for faust ip generation
set dsp_target [parse_dsp_target]

# RUN STEPS ---------------------------------------------------------------------------------------

if {[is_argument "--app-rebuild"]} {
     print_info "Resetting Host Application build"
     file delete -force -- build/include
     file delete -force -- build/syfala_application
     file delete -force -- build/sw_export
     set ::argv "$::argv --arch --app --flash"
}

if {[is_argument "--reset"]} {
     rstbuild
}

if {[is_argument "--demo"]} {
    set dsp_target $Syfala::DEFAULT_EXAMPLE
    set Syfala::RUN "--all --export demo --report --flash"
} else {
    parse_run_step "--arch"
    parse_run_step "--ip"
    # parse_run_step "--linux"
    # parse_run_step "--sim"
    parse_run_step "--project"
    parse_run_step "--syn"
    parse_run_step "--app"
#    parse_run_step "--boot"
    parse_run_step "--flash"
    parse_run_step "--gui"

    # if no run step is provided, run them all
    if {$::Syfala::RUN == "" && $dsp_target != ""} {
        set Syfala::RUN "--all"
    }
    ## Exports build into a .zip file
    parse_run_step "--export"
    parse_run_step "--report"

    # If no argument is provided, run the whole script until --gui
    parse_run_step "--all"
}

if {[is_run_step "--all"]} {
     set Syfala::RUN "$::Syfala::RUN --arch --ip --project --syn --app --gui"
}

# RUN PARAMETERS ----------------------------------------------------------------------------------

# Parse all additional run parameters, setting default values otherwise
set syconfig         [parse_argument { -c --compiler } { HLS VHDL } "HLS"]
set board            [parse_argument { -b --board } { Z10 Z20 GENESYS } "Z10"]
set memory           [parse_argument { -m --memory } { DDR STATIC } "DDR"]
set sample_rate      [parse_argument { --sample-rate } { 48000 96000 192000 384000 768000 } 48000]
set sample_width     [parse_argument { --sample-width }  { 16 24 32 } 24]
set controller_type  [parse_argument { --controller-type } { DEMO PCB1 PCB2 PCB3 PCB4 } "PCB1"]
set ssm_volume       [parse_argument { --ssm-volume } { FULL HEADPHONE DEFAULT } "HEADPHONE"]
set ssm_speed        [parse_argument { --ssm-speed } { FAST DEFAULT } "DEFAULT"]
set nchannels	     [parse_argument { --nchannels } {} 2]
set vhdl_type        [parse_argument { --vhdl-type } { 0 1 } 0]

variable board_cpp_id

# TODO: something else other than this...
if { $memory == "DDR" } {
     set memory 1
} else {
     set memory 0
}

# Note: macro has to be defined as a number,
# so we can test it correctly in the cpp code.
switch $board {
    Z10      { set board_cpp_id 10 }
    Z20      { set board_cpp_id 20 }
    GENESYS  { set board_cpp_id 30 }
    default  {
        print_error "Unknown board model, aborting."
        exit 1
    }
}

# EXECUTION ---------------------------------------------------------------------------------------

# adding Vitis/Vivado/HLS environments to exec path
# (we don't require the 'use_vitis' function anymore)
set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vitis_HLS"
set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vivado"
set_xenv $Xilinx::ROOT $Xilinx::VERSION "Vitis"
print_ok "Xilinx toolchain environment added to script's PATH..."

# Script running in build mode: generate a new build id
set build_id [parse_argument { --export } {} ""]
set build_id "[generate_build_id]-$build_id"
print_info "build id: #$build_id"
print_info "Now running following steps: $::Syfala::RUN"

# Matches '-c / --compiler' argument for hls/faust2vhdl configuration
# note: in the future, we'd probably have to add linux and
# baremetal configurations for the Host
file mkdir $Syfala::BUILD_DIR
cd $Syfala::BUILD_DIR

if {[is_run_step "--arch"]} {
     # Overwrite #define values in syconfig.hpp from command-line arguments
     Syfala::initialize_build
     set_syconfig_define    "SYFALA_SAMPLE_RATE"       $sample_rate
     set_syconfig_define    "SYFALA_SAMPLE_WIDTH"      $sample_width
     set_syconfig_define    "SYFALA_BOARD"             $board_cpp_id
     set_syconfig_define    "SYFALA_CONTROLLER_TYPE"   $controller_type
     set_syconfig_define    "SYFALA_SSM_VOLUME"        $ssm_volume
     set_syconfig_define    "SYFALA_SSM_SPEED"         $ssm_speed
     set_syconfig_define    "SYFALA_MEMORY_USE_DDR"    $memory
}

switch $syconfig {
    "hls" - "HLS" {
        set Syfala::CONFIG 1
        print_ok "Selected HLS configuration (with Vitis)"
        # Make and go into build directory
        # 1. Generate Faust IP and Host Application cpp files
	if {[is_run_step "--arch"]} {
            # Generate sources with set number of channels
            exec $::Syfala::SCRIPTS_DIR/syfala_maker.tcl $nchannels $board >&@stdout
            Faust::generate_ip_hls $dsp_target
            Faust::generate_host $dsp_target $Faust::ARCH_HOST_SRC_FILE
	}
	# 2. Synthesize faust ip with Vitis HLS
	if {[is_run_step "--ip"]} {
             Xilinx::Vitis_HLS::run $Syfala::HLS_SCRIPT $board
	}

	# 3. Run Vivado to generate the full project
	if {[is_run_step "--project"]} {
	     Xilinx::Vivado::run $Syfala::PROJECT_SCRIPT	\
                                $board                          \
                                $sample_rate                    \
                                $sample_width
	}
    }
    "vhdl" - "VHDL" - "faust2vhdl" {
        set Syfala::CONFIG 0
        print_ok "Selected faust2vhdl configuration"
        if {[is_run_step "--arch"]} {
             Faust::generate_ip_vhdl $dsp_target $vhdl_type
             Faust::generate_host $dsp_target $Faust::ARCH_HOST_SRC_FILE_VHDL
        }
        if {[is_run_step "--project"]} {
             Xilinx::Vivado::run $Syfala::FAUST2VHDL_SCRIPT $board
        }

    }
    default {
	print_error "No matching configuration for '$SYCONFIG', aborting..."
        exit 1
    }
}

# 4. Synthesize the whole design
if {[is_run_step "--syn"]} {
     Xilinx::Vivado::run $Syfala::SYNTHESIS_SCRIPT
}
# 5. Compile Host Control Application
if {[is_run_step "--app"]} {
     Xilinx::compile_host $Syfala::CONFIG $board
}
#if {[is_run_step "--boot"]} {
#     Xilinx::generate_boot
#}
if {[is_run_step "--gui"]} {
     Faust::generate_gui_app $dsp_target
}
if {[is_run_step "--export"]} {
     Syfala::export_build $build_id
}
if {[is_run_step "--report"]} {
     Xilinx::Vitis_HLS::report
}
if {[is_run_step "--flash"]} {
     Xilinx::flash_jtag $board
}

print_elapsed_time $tstart
print_ok "Successful run, goodbye!"
