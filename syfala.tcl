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

namespace eval Xilinx {
    variable ROOT
    variable VERSION 2022.2
}

# -----------------------------------------------------------------------------
# add runtime steps
# -----------------------------------------------------------------------------

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
    $::Syfala::BUILD_XSA_TARGET                 \
]
add_runstep "--host" [list                      \
    $::Syfala::BUILD_APPLICATION_TARGET         \
]
add_runstep "--gui" [list                       \
    $::Syfala::BUILD_GUI_TARGET                 \
]

# -----------------------------------------------------------------------------
# runtime variable declarations
# -----------------------------------------------------------------------------

proc runtime_parameter {v a} {
    return [dict create value $v accepted $a]
}

proc get_rt_value {a} {
    return [dict get $a value]
}

proc set_rt_value {p v} {
    dict set $p value $v
}

namespace eval runtime {
    variable compiler           [runtime_parameter "HLS" { HLS VHDL }]
    variable xversion           [runtime_parameter "2020.2" { 2020.2 2022.2 }]
    variable board              [runtime_parameter "Z10" { Z10 Z20 GENESYS }]
    variable memory             [runtime_parameter 1 { DDR STATIC }]
    variable sample_rate        [runtime_parameter 48000 { 48000 96000 192000 384000 768000 }]
    variable sample_width       [runtime_parameter 24 { 16 24 32 }]
    variable controller_type    [runtime_parameter "PCB1" { DEMO PCB1 PCB2 PCB3 PCB4 }]
    variable ssm_volume         [runtime_parameter "HEADPHONE" { FULL HEADPHONE DEFAULT }]
    variable ssm_speed          [runtime_parameter "DEFAULT" { FAST DEFAULT }]
    variable bd_target          $::Syfala::BD_STD
    variable rtl_files          [list]
    variable steps              ""
    variable post_steps         ""
    variable dsp_target         ""
    variable board_cpp_id       10
    variable app_config         0
    variable export_id          ""
    variable arm_benchmark      0
    variable audio_debug_uart   0
    variable fixed_point        0
    variable verbose            0
    variable nchannels_i        0
    variable nchannels_o        0
    variable ncontrols_i        0
    variable ncontrols_f        0
    variable ncontrols_p        0
    variable mcd                16
    variable linux              0
}

proc add_rtl_file {f} {
    lappend ::runtime::rtl_files $f
}

proc check_runtime_parameters {} {
    set sr [get_rt_value $::runtime::sample_rate]
    set sw [get_rt_value $::runtime::sample_width]
    if {$sr == 768000 && $sw > 16} {
         set_rt_value ::runtime::sample_width 16
         print_info "Note: a sample-rate of 768kHz requires a 16-bit sample-width"
         print_info "SYFALA_SAMPLE_WIDTH changed to value: 16"
    }
}

# gets command line argument value at next 'argv' index
proc get_argument_value {index} {
    upvar $index idx
    return [lindex $::argv [incr idx]]
}

# checks argument value validity
# by comparing to the 'accepted' values set for the argument
# (see the runtime variables above)
proc parse_argument_value {argument value} {
    upvar $argument rparameter
    set accept [dict get $rparameter "accepted"]
    if {[lcontains $value $accept] || $accept == {}} {
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
            break
         }
    } else {
        # Look for previous .dsp files and remove them
        catch {
            foreach f [glob -directory $::Syfala::BUILD_DIR *.dsp] {
                file delete -force $f
            }
        }
        # Copy current .dsp file into build directory
        file copy -force $::runtime::dsp_target $::Syfala::BUILD_DIR
    }
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
            source $::Syfala::SCRIPTS_DIR/misc/help.tcl
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
            set ::runtime::steps [get_next_runstep]
        }
        demo {
            set ::runtime::dsp_target [file normalize examples/virtualAnalog.dsp]
            set ::runtime::steps "$::runtime::steps
                --arch --hls --project --synth --host
                --report --export demo"
        }
        open-project {
            parse_xroot
            exec [Xilinx::vivado] $::Syfala::BUILD_PROJECT_DIR/syfala_project.xpr
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
            exec $::Syfala::BUILD_GUI_DIR/faust-gui >&@stdout
            exit 0
        }
        test {
            # remove the 'test' command from arguments
            parse_xroot
            source $::Syfala::TESTS_DIR/tests.tcl
            exit 0
        }
        build-linux {
            set target [get_argument_value index]
            parse_xroot
            switch $target {
                boot {
                    Linux::build_boot
                }
                uboot {
                    Linux::set_env
                    Linux::build_uboot
                }
                kernel {
                    Linux::set_env
                    Linux::build_kernel
                }
                device-tree {
                    Linux::build_device_tree_static
                }
                root {
                    Linux::build_root
                }
                dsp {
                    Linux::update_dsp
                }
                app {
                    Linux::build_app
                }
                default {
                    Linux::build_boot
                    Linux::build_root
                }
            }
            exit 0
        }

        format-linux {
        print_info                                                          \
        "Please use the following commands in order to properly format your sd-card:"
        puts                                                                \
        "
        - sudo parted </dev/...> --script -- mklabel msdos
        - sudo parted </dev/...> --script -- mkpart primary fat32 1MiB 128MiB
        - sudo parted </dev/...> --script -- mkpart primary ext4 128MiB 100%
        - sudo parted </dev/...> --script -- set 1 boot on
        - sudo parted </dev/...> --script -- set 1 lba on
        - sudo mkfs.vfat <device-partition-1>
        - sudo mkfs.ext4 <device-partition-2>
        - sudo parted </dev/...> --script print
        "
            exit 0
        }
        format-linux-unsafe {
            set device [get_argument_value index]
            Linux::format_sd_card $device
            exit 0
        }
        flash-linux {
            # i.e. /dev/sda or /dev/mmcblk0
            set target [get_argument_value index]
            set device [get_argument_value index]
            switch $target {
                boot { Linux::flash_boot $device }
                root { Linux::flash_root $device }
                dsp  { Linux::flash_dsp $device }
                all  {
                    Linux::flash_boot $device
                    Linux::flash_root $device
                }
            }
            exit 0
        }
        chroot {
            exec sudo chroot $::Linux::BUILD_OUTPUT_ROOT_DIR "/bin/sh" >&@stdout
            exit 0
        }
        log {
            exec cat syfala_log.txt >&@stdout
            display_report
            exit 0
        }
        build-container-image {
            set path $::Syfala::ROOT/tools/containers/
            set name [get_argument_value index]
            append path $name
            cd $path
            if [file exists $path] {
                print_info "Building container $name"
                exec buildah build -f Containerfile -t $name >&@stdout
                exec buildah from --name "$name-container" $name >&@stdout
                print_ok "Container $name successfully built"
                print_info "Running container, you can now install the Xilinx toolchain"
            } else {
                print_error "Invalid target, aborting"
            }
            exit 0
        }
        import-container {
            set path [get_argument_value index]
            set name [file tail $path]
            if [file exists $path] {
                print_info "Loading image $path"
                exec podman pull oci:$path
                exec podman from --name "$name" $name >&@stdout
                print_ok "Container $name successfully imported!"
            } else {
                print_error "Invalid target, aborting"
            }
        }
        run-container {
            set name [get_argument_value index]
            exec xhost +local:
            exec podman run --user=syfala                       \
                            --network=host                      \
                            --env DISPLAY=\$DISPLAY             \
                            -v /tmp/.X11-unix:/tmp/.X11-unix:z  \
                            -v /dev/dri:/dev/dri:z              \
                            -v /dev/bus/usb:/dev/bus/usb        \
                            -v /dev/ttyUSB1:/dev/ttyUSB1        \
                            $name                               \
                            bash
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
            set ::Xilinx::VERSION [get_rt_value $::runtime::xversion]
            print_info "Setting XILINX_VERSION to $::Xilinx::VERSION"
        }

        -f - --hls-flags {
            set flag [get_argument_value index]
            #note: TODO
        }
        --reset {
            # resets current build directory (careful, all files from previous build will be lost)
            rstbuild
            file mkdir $::Syfala::BUILD_DIR
        }
        --benchmark {
            set ::runtime::arm_benchmark 1
        }
        --audio-debug-uart {
            set ::runtime::audio_debug_uart 1
        }
        --verbose {
            set ::runtime::verbose [get_argument_value index]
        }
        -sd - --sigma-delta {
            set_rt_value ::runtime::sample_rate 5000000
            set_rt_value ::runtime::sample_width 16
            set ::runtime::bd_target $::Syfala::BD_SIGMA_DELTA
            add_rtl_file $::Syfala::RTL_DIR/sd_dac_first.vhd
        }
        --tdm {
            set_rt_value ::runtime::sample_rate 48825
            set_rt_value ::runtime::sample_width 16
            set ::runtime::bd_target $::Syfala::BD_TDM
            add_rtl_file $::Syfala::I2S_DIR/i2s_transceiver_tdm.vhd
        }
        --linux {
            set ::runtime::linux 1
        }
        --fixed-point {
            set ::runtime::fixed_point 1
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
            append ::runtime::steps "--arch --hls --project --synth --host --gui"
        }
        --arch           { append ::runtime::steps "--arch"    }
        --hls - --ip     { append ::runtime::steps "--hls"     }
        --project        { append ::runtime::steps "--project" }
        --syn - --synth  { append ::runtime::steps "--synth"   }
        --app - --host   {
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
            switch [get_rt_value $::runtime::board] {
                Z10      { set ::runtime::board_cpp_id 10 }
                Z20      { set ::runtime::board_cpp_id 20 }
                GENESYS  { set ::runtime::board_cpp_id 30 }
            }
        }
        -m - --memory {
            parse_argument_value ::runtime::memory [get_argument_value index]
            switch [get_rt_value $::runtime::memory] {
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
    # TODO: something cleaner than this
    if {[get_rt_value $::runtime::compiler] == "HLS"} {
        set ::runtime::app_config 1
    }
    switch $::runtime::board_cpp_id {
        10 {set_rt_value ::runtime::board "Z10"}
        20 {set_rt_value ::runtime::board "Z20"}
        30 {set_rt_value ::runtime::board "GENESYS"}
        default {
            print_error "Incorrect board model, aborting..."
            exit 1
        }
    }
    print_info "Retrieved previously used board model: [get_rt_value $::runtime::board]"
}

print_info "Running build steps: $::runtime::steps"
print_info "Running post-build steps: $::runtime::post_steps"

check_dsp_target

if [is_run_step "--arch"] {
     # Overwrite #define values in syconfig.hpp from command-line arguments
     # Note: this is common to both configurations (HLS/FAUST2VHDL)
    initialize_build    
    check_runtime_parameters
    set_syconfig_define "SYFALA_BOARD"            $::runtime::board_cpp_id      \
                                                  [get_rt_value $::runtime::board]
    set_syconfig_define "SYFALA_SAMPLE_RATE"      [get_rt_value $::runtime::sample_rate]
    set_syconfig_define "SYFALA_SAMPLE_WIDTH"     [get_rt_value $::runtime::sample_width]
    set_syconfig_define "SYFALA_CONTROLLER_TYPE"  [get_rt_value $::runtime::controller_type]
    set_syconfig_define "SYFALA_SSM_VOLUME"       [get_rt_value $::runtime::ssm_volume]
    set_syconfig_define "SYFALA_SSM_SPEED"        [get_rt_value $::runtime::ssm_speed]
    set_syconfig_define "SYFALA_MEMORY_USE_DDR"   [get_rt_value $::runtime::memory]
    set_syconfig_define "SYFALA_AUDIO_DEBUG_UART" $::runtime::audio_debug_uart
    set_syconfig_define "SYFALA_HOST_BENCHMARK"   $::runtime::arm_benchmark
    set_syconfig_define "SYFALA_VERBOSE"          $::runtime::verbose
    set_syconfig_define "SYFALA_REAL_FIXED_POINT" $::runtime::fixed_point
}
# This is where the toolchain's steps diverge,
# depending on the chosen IP 'compiler' (HLS | faust2vhdl)
# this includes the following steps:
# --arch     (IP file generation)
# --hls      (not needed for faust2vhdl)
# --project  (project script files are different)
switch [get_rt_value $::runtime::compiler] {
    HLS {
    # -------------------------------------------------------------------------
        print_ok "Selected [emph HLS] configuration (with Vitis)"
    # -------------------------------------------------------------------------
        set ::runtime::app_config 0
        # 1. Generate Faust IP and Host Application cpp files
        if [is_run_step "--arch"] {
            Faust::generate_ip_hls $::runtime::dsp_target
            # Generate sources with set number of channels
            parse_build_io
            source $::Syfala::SCRIPTS_DIR/preprocessor.tcl
            preprocessor::run_hls_preprocessor
            # count izone/fzone accesses immediately after
            # ip cpp file is generated.
            Faust::mem_access_count
            Faust::generate_host $::runtime::dsp_target     \
                                 $::Syfala::ARCH_ARM_TARGET
        }
        # 2. Synthesize IP with Vitis HLS
        if [is_run_step "--hls"] {
            Xilinx::Vitis_HLS::run $::Syfala::HLS_SCRIPT    \
                                   [get_rt_value $::runtime::board]
        }
    }
    VHDL {
    # -------------------------------------------------------------------------
        print_ok "Selected [emph faust2vhdl] configuration"
    # -------------------------------------------------------------------------
        set ::runtime::app_config 1
        set ::runtime::bd_target $::Syfala::BD_FAUST2VHDL
        add_rtl_file $::Syfala::FIXED_FLOAT_TYPES_C
        add_rtl_file $::Syfala::FIXED_PKG_C
        add_rtl_file $::Syfala::FLOAT_PKG_C
        add_rtl_file $::Syfala::SINCOS_24
        if [is_run_step "--arch"] {
            # Note: we generate the HLS IP just to parse number of i/o there
            # TODO: fix that..., there's gotta be a better way to do this
            Faust::generate_ip_hls $::runtime::dsp_target
            parse_build_io
            source $::Syfala::SCRIPTS_DIR/preprocessor.tcl
            preprocessor::run_hls_preprocessor
            Faust::generate_ip_vhdl $::runtime::dsp_target             \
                                    $::runtime::fixed_point
            Faust::generate_host    $::runtime::dsp_target             \
                                    $::Syfala::ARCH_ARM_FILE_VHDL
        }
    }
}

# -------------------------------------------------------------------------
# common steps
# -------------------------------------------------------------------------

# 3. Run Vivado to generate the full project
if [is_run_step "--project"] {
    # add multiplexer common rtl file
    add_rtl_file $::Syfala::RTL_DIR/mux_2to1.vhd
    # run preprocessor on the i2s template
    if {$::runtime::bd_target == $::Syfala::BD_FAUST2VHDL
    ||  $::runtime::bd_target == $::Syfala::BD_STD} {
            parse_build_io
            source $::Syfala::SCRIPTS_DIR/preprocessor.tcl
            preprocessor::run_i2s_preprocessor
    } else {
            print_info "Skipping i2s preprocessor"
            print_info $::runtime::bd_target
            print_info $::Syfala::BD_FAUST2VHDL
    }
    # Copy all required RTL files in build/sources
    foreach f $::runtime::rtl_files {
        print_info "Adding [file tail $f] RTL source file to project"
        file copy -force $f $::Syfala::BUILD_SOURCES_DIR/[file tail $f]
    }
    set arguments [list                             \
        [get_rt_value $::runtime::board]            \
        [get_rt_value $::runtime::sample_rate]      \
        [get_rt_value $::runtime::sample_width]     \
        $::runtime::nchannels_i                     \
        $::runtime::nchannels_o                     \
        $::runtime::bd_target                       \
        $::Xilinx::ROOT                             \
        $::Xilinx::VERSION                          \
    ]
    Xilinx::Vivado::run $::Syfala::PROJECT_SCRIPT $arguments
}

# 4. Synthesize the whole design
if [is_run_step "--synth"] {
     Xilinx::Vivado::run $::Syfala::SYNTHESIS_SCRIPT
}
# 5. Compile Host Control Application
if [is_run_step "--host"] {
    if $::runtime::linux {
        if [file exists $::Linux::BUILD_OUTPUT_DIR] {
#            Linux::update_dsp
            Linux::build_app
        } else {
            print_info "No Linux build could be found, would you like to create one? [y/N]"
            gets stdin lbuild
            switch $lbuild {
                y - Y - yes - YES {
                    Linux::build_boot
                    Linux::build_root
                }
            }
        }
        exit 0
    } else {
        set board [get_rt_value $::runtime::board]
        Xilinx::compile_host $::runtime::app_config $board
    }
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
    Xilinx::flash_jtag [get_rt_value $::runtime::board]
}

print_elapsed_time $tstart
print_ok "Successful run!"
print_ok "To see the build's full log: open 'syfala_log.txt' in the repository's root directory"
display_report
