namespace eval Syfala {

proc get_root {} {
    set path [file dirname [file normalize [info script]]]
    return   [file dirname $path]
}

# -----------------------------------------------------------------------------
# general
# -----------------------------------------------------------------------------

set VERSION                     7
set ROOT                        [get_root]
set OS                          $tcl_platform(os)
set OS_VERSION                  $tcl_platform(osVersion)
set SOURCE_DIR                  $ROOT/source
set INCLUDE_DIR                 $ROOT/include
set SCRIPTS_DIR                 $ROOT/scripts
set BUILD_DIR                   $ROOT/build
set BUILD_LINUX_DIR             $ROOT/build-linux
set EXPORT_DIR                  $ROOT/export
set TESTS_DIR                   $ROOT/tests
set CONFIG_FILE                 $INCLUDE_DIR/syfala/config.hpp
set TOOLS_DIR                   $ROOT/tools
set DEFAULT_EXAMPLE             $ROOT/examples/virtualAnalog.dsp
set CLK_DYNAMIC_RECONFIG        0

set ARM_INCLUDE_DIR             $INCLUDE_DIR/syfala/arm
set ARM_SOURCE_DIR              $SOURCE_DIR/arm

# -----------------------------------------------------------------------------
# build
# -----------------------------------------------------------------------------

set BUILD_APPLICATION_DIR       $BUILD_DIR/syfala_application
set BUILD_APPLICATION_FILE      $BUILD_APPLICATION_DIR/syfala_application.cpp
set BUILD_APPLICATION_TARGET    $BUILD_DIR/sw_export/application.elf
set BUILD_PROJECT_DIR           $BUILD_DIR/syfala_project
set BUILD_XPR_FILE              $BUILD_PROJECT_DIR/syfala_project.xpr
set BUILD_IP_DIR                $BUILD_DIR/syfala_ip
set BUILD_IP_FILE               $BUILD_IP_DIR/syfala_ip.cpp
set BUILD_IP_TARGET             $BUILD_IP_DIR/syfala
set BUILD_XSA_TARGET            $BUILD_DIR/hw_export/main_wrapper.xsa
set BUILD_BITSTREAM_SOURCE      $BUILD_PROJECT_DIR/syfala_project.runs/impl_1/main_wrapper.bit
set BUILD_BITSTREAM_TARGET      $BUILD_DIR/hw_export/system.bit
set BUILD_HLS_REPORT_SOURCE     $BUILD_IP_DIR/syfala/syn/report/syfala_csynth.rpt
set BUILD_HLS_REPORT_COPY       $BUILD_DIR/syfala_csynth.rpt
set BUILD_INCLUDE_DIR           $BUILD_DIR/include
set BUILD_SOURCES_DIR           $BUILD_DIR/sources
set BUILD_XSOURCES_DIR          $BUILD_IP_DIR/syfala/impl/ip/drivers/syfala_v1_0/src
set BUILD_GUI_DIR               $BUILD_DIR/gui
set BUILD_GUI_TARGET            $BUILD_DIR/gui/faust-gui
set BUILD_CONFIG_FILE           $BUILD_INCLUDE_DIR/syfala/config.hpp
set BUILD_LOG                   $ROOT/syfala_log.txt

# -----------------------------------------------------------------------------
# scripts
# -----------------------------------------------------------------------------
set HLS_SCRIPT                  $SCRIPTS_DIR/hls.tcl
set APPLICATION_SCRIPT          $SCRIPTS_DIR/application.tcl
set PROJECT_SCRIPT              $SCRIPTS_DIR/project.tcl
set SYNTHESIS_SCRIPT            $SCRIPTS_DIR/synthesis.tcl
set JTAG_SCRIPT                 $SCRIPTS_DIR/jtag.tcl
set BIN_GENERATOR               $SCRIPTS_DIR/linux/bin_generator.bif
set FSBL_SCRIPT                 $SCRIPTS_DIR/linux/fsbl.tcl
set DEVICE_TREE_SCRIPT          $SCRIPTS_DIR/linux/device-tree.tcl
set LINUX_BUILD_SCRIPT          $SCRIPTS_DIR/linux/build.tcl

# -----------------------------------------------------------------------------
# sources
# -----------------------------------------------------------------------------

set HOST_BAREMETAL_SOURCES      $SOURCE_DIR/arm/baremetal
set HOST_LINUX_SOURCES          $SOURCE_DIR/arm/linux
set RTL_DIR                     $SOURCE_DIR/rtl
set CONSTRAINTS_DIR             $SOURCE_DIR/constraints
set I2S_DIR                     $RTL_DIR/i2s
set FAUST2VHDL_DIR              $RTL_DIR/faust2vhdl
set FIXED_FLOAT_TYPES_C         $FAUST2VHDL_DIR/fixed_float_types_c.vhd
set FIXED_PKG_C                 $FAUST2VHDL_DIR/fixed_pkg_c.vhd
set FLOAT_PKG_C                 $FAUST2VHDL_DIR/float_pkg_c.vhd
set SINCOS_24                   $FAUST2VHDL_DIR/SinCos24.vhd
set FAUST_VHD_EXAMPLE           $FAUST2VHDL_DIR/faust.vhd

# -----------------------------------------------------------------------------
# block designs
# -----------------------------------------------------------------------------
set BD_DIR             $SOURCE_DIR/bd
set BD_STD             $BD_DIR/standard.tcl
set BD_SIGMA_DELTA     $BD_DIR/sigma-delta.tcl
set BD_TDM             $BD_DIR/tdm.tcl
set BD_FAUST2VHDL      $BD_DIR/faust2vhdl.tcl
# -----------------------------------------------------------------------------
# architecture files
# -----------------------------------------------------------------------------

set ARCH_FPGA_HLS_TEMPLATE      $RTL_DIR/hls/faust_dsp_template.cpp
set ARCH_FPGA_SRC_FILE_VHDL     $BUILD_IP_DIR/faust.vhd
set ARCH_FPGA_SRC_FILE_HLS      $BUILD_SOURCES_DIR/fpga.cpp
set ARCH_ARM_FILE_HLS           $INCLUDE_DIR/syfala/arm/faust/control.hpp
set ARCH_ARM_FILE_VHDL          $SOURCE_DIR/arm/baremetal/arm_vhdl.cpp
set ARCH_ARM_TARGET             $ARCH_ARM_FILE_HLS
set GUI_SRC_FILE                $SOURCE_DIR/remote/faust-gui.cpp
set GUI_DST_FILE                $BUILD_GUI_DIR/faust-gui.cpp

# -----------------------------------------------------------------------------
# exported procedures
# -----------------------------------------------------------------------------

namespace export                \
color                           \
emph                            \
indent                          \
print_ok                        \
print_info                      \
print_error                     \
print_version                   \
syexec                          \
fcp                             \
foreach_n                       \
lcontains                       \
contains                        \
is_empty                        \
not_empty                       \
ffindl                          \
ffindlN                         \
freplacel                       \
freplacelfn                     \
rstbuild                        \
get_dsp_name                    \
add_runstep                     \
get_next_runstep                \
get_definition_value            \
check_xroot                     \
set_xenv                        \
parse_xroot                     \
get_num_io                      \
get_syconfig_define             \
parse_build_io                  \
display_report                  \
set_syconfig_define             \
generate_build_id               \
get_elapsed_time                \
get_elapsed_time_msec           \
get_elapsed_time_sec            \
print_elapsed_time              \
initialize_build                \
export_build

# -----------------------------------------------------------------------------
# general-purpose utilities
# -----------------------------------------------------------------------------

proc color {c t} {
    return [exec tput setaf $c]$t[exec tput sgr0]
}

proc emph {t} {
    return [exec tput bold]$t[exec tput sgr0]
}

proc indent {t {N 1}} {
    set str ""
    for {set i 0} {$i < $N} {incr i} {
         append str "\t"
    }
    return "$str$t"
}

proc basic_print {txt {f 1}} {
    puts  $txt
    if $f {
        set foutput [open $::Syfala::BUILD_LOG a+]
        puts  $foutput "[get_time] - $txt"
        close $foutput
    }
}

proc print_ok {txt} {
    basic_print "\[  [color 2 OK]  \] $txt"
}

proc print_info {txt {f 1}} {
    basic_print "\[ [color 11 INFO] \] $txt" $f
}

proc print_error {txt} {
    basic_print "\[ [color 1 ERR!] \] $txt"
}

proc print_version {} {
    upvar ::Syfala::OS os
    upvar ::Syfala::OS_VERSION osv
    print_info "Running syfala toolchain script (v$::Syfala::VERSION) on $os ($osv)"
}

proc get_time {} {
    set stime [clock seconds]
    set htime [clock format $stime -format %H:%M:%S]
    return $htime
}

proc get_elapsed_time_msec {start} {
    set end [clock milliseconds]
    return [expr $end - $start]
}

proc get_elapsed_time_sec {start} {
    set end [clock seconds]
    return [expr $end - $start]
}

proc get_elapsed_time {start} {
    set end [clock seconds]
    set len [expr $end - $start]
    set fmt [clock format $len -format {%M minutes and %S seconds}]
    return $fmt
}

proc print_elapsed_time {start} {
    print_info "Script has been running for [get_elapsed_time $start]"
}

proc foreach_n {N fn {offset 0}} {
    for {set n $offset} {$n < [expr $N+$offset]} {incr n} {
         apply $fn $n
    }
}

proc fcp {src dst {ptn *}} {
    foreach f [glob -directory $src -nocomplain $ptn] {
        print_info "Copying file [file tail $f] into $dst"
        exec sudo cp -r $f $dst
    }
}

proc syexec {cmd} {
    print_info "Executing command: $cmd"
    exec {*}$cmd
}

# returns 1 if 'str' contains 'pattern'
# returns 0 if 'pattern' couldn't be found.
proc contains {pattern str} {
     if {[string first $pattern $str] != -1} {
         return 1
     } else {
         return 0
     }
}

proc lcontains {ptn lst} {
    if {[lsearch -exact $lst $ptn] >= 0} {
        return 1
    } else {
        return 0
    }
}

# returns 1 if 'str' is empty, 0 otherwise
proc is_empty {str} {
    if {$str == ""} {
        return 1
    } else {
        return 0
    }
}

proc not_empty {str} {
    return ![is_empty $str]
}

# find a pattern within a file
# returns the whole line if found
proc ffindl {f pattern} {
    set fr   [open $f r]
    set data [read $fr]
    close    $fr
    foreach line [split $data "\n"] {
        if [contains $pattern $line] {
            return $line
        }
    }
    return ""
}

# find pattern within a file
# returns a list containing the matching line
# plus the 'N' following lines
proc ffindlN {f target N {offset 0}} {
    set fr   [open $f r]
    set data [read $fr]
    set out   ""
    set index $offset
    close     $fr
    set data_l [split $data "\n"]
    foreach line $data_l {
        if [contains $target $line] {
            append out "[lindex $data_l $index]\n"
            for {set i 0} {$i < $N} {incr i} {
                 append out "[lindex $data_l [incr index]]\n"
            }
        }
        incr index
    }
    return $out
}

# find lines containing pattern 'A' in file 'f'
# replace it by the whole line 'B'
proc freplacel {f A B} {
    set fr     [open $f r]
    set data   [read $fr]
    close      $fr
    set fw     [open $f w]
    set found  0
    foreach line [split $data "\n"] {
        if {!$found && [contains $A $line]} {
            set found 1
            if {![is_empty $B]} {
                puts $fw $B
            }
        } else {
            puts $fw $line
        }
    }
    close $fw
    if {$found == 0} {
        print_error "Couldn't find pattern '$A' in file '$f'"
        exit 1
    }
}

proc freplacelfn {f pattern args fn} {
    set fr     [open $f r]
    set data   [read $fr]
    close      $fr
    set fw     [open $f w]
    set found  0
    set index  0
    set lines  [split $data "\n"]
    set len    [llength $lines]
    foreach line $lines {
        if {!$found && [contains $pattern $line]} {
            set found 1
            set line [apply $fn $line $args]
        }
        if {$index < [expr $len-1]} {
            # we don't want to output the last empty line
            puts $fw $line
        }
        incr index
    }
    close $fw
    if {$found == 0} {
        print_error "Couldn't find pattern '$pattern' in file '$f'"
        exit 1
    }
}

# find lines containing patterns {A} in file 'f'
# replace them by lines {B}
proc freplacelN {f A B} {
    set fr     [open $f r]
    set data   [read $fr]
    set index  0
    close      $fr
    set fw     [open $f w]
    foreach line [split $data "\n"] {
        foreach a $A {
            if [contains $a $line] {
                set line [lindex $B $index]
                incr index
            }
        }
        puts $fw $line
    }
    close $fw
}

# -----------------------------------------------------------------------------
# build-related
# -----------------------------------------------------------------------------

## Resets build directory from syfala root directory
proc rstbuild {} {
    # we've got to print it first, because otherwise the log
    # file will disappear...
    print_ok "Reset build directory"
    file delete -force $::Syfala::BUILD_LOG
    file delete {*}[glob -nocomplain vivado_*]
    file delete {*}[glob -nocomplain vivado.*]
    file delete {*}[glob -nocomplain vitis_*]
    file delete {*}[glob -nocomplain *.log]
    file delete -force -- .Xil
    foreach f [glob -directory $::Syfala::BUILD_DIR -nocomplain *] {
        if {[file tail $f] != "linux"} {
            file delete -force $f
            print_info "Deleting $f"
        } else {
            print_info "'linux'build directory found, skipping!"
        }
    }
}

proc get_dsp_name {} {
    foreach f [glob -directory $::Syfala::BUILD_DIR *.dsp] {
       # pick the first one
       return [file rootname [file tail $f]]
    }
}

namespace eval runsteps {
variable data [list]
}

proc add_runstep {name targets} {
    lappend runsteps::data [list $name $targets]
}

proc get_next_runstep {} {
    set next [lindex [lindex $::Syfala::runsteps::data 0] 0]
    set index 0
    foreach runstep $::Syfala::runsteps::data {
        set name    [lindex $runstep 0]
        set targets [lindex $runstep 1]
        foreach target $targets {
            if {![file exists $target]} {
                return $next
            }
        }
        incr index
        if {$index > [llength $::Syfala::runsteps::data]} {
            return "--flash"
        }
        set next [lindex [lindex $::Syfala::runsteps::data $index] 0]
    }
    return $next
}

## Checks installation of a specific Xilinx tool
## aborts process if path is incorrect
proc check_xpath {x v t} {
    set path "$x/$t/$v/settings64.sh"
    if {[file exists $path]} {
        print_ok "Checked $path"
    } else {
        print_error "Could not find path $path, aborting"
        exit 1
    }
}

# Checks Xilinx Toolchain installation:
# Vivado/Vitis/HLS subdirectories
proc check_xroot {x v} {
     check_xpath $x $v "Vivado"
     check_xpath $x $v "Vitis"
     check_xpath $x $v "Vitis_HLS"
}

# Adds Xilinx tool $t root and bin directories to
# PATH environment variable, for the time the script is being run
proc set_xenv {x v t} {
    set ::env(PATH) "$::env(PATH):$x/$t/$v:$x/$t/$v/bin"
}

# Tries to parse Xilinx Toolchain root installation directory
proc parse_xroot {} {
    if {![info exists ::Xilinx::ROOT]} {
        # if already defined in environment as 'XILINX_ROOT_DIR'
        if {[info exists ::env(XILINX_ROOT_DIR)]} {
             set ::Xilinx::ROOT $::env(XILINX_ROOT_DIR)
             print_ok "[emph XILINX_ROOT_DIR] defined in env as: $Xilinx::ROOT"
        } else {
            print_error "[emph XILINX_ROOT_DIR] is undefined, aborting"
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
    check_xroot $::Xilinx::ROOT $::Xilinx::VERSION
    set_xenv $::Xilinx::ROOT $::Xilinx::VERSION "Vitis_HLS"
    set_xenv $::Xilinx::ROOT $::Xilinx::VERSION "Vivado"
    set_xenv $::Xilinx::ROOT $::Xilinx::VERSION "Vitis"
    print_ok "Xilinx toolchain environment added to script's PATH"
}

proc get_num_io {} {
    set line_i [ffindl $::Syfala::BUILD_IP_FILE "#define FAUST_INPUTS"]
    set line_o [ffindl $::Syfala::BUILD_IP_FILE "#define FAUST_OUTPUTS"]
    set n_inputs [lindex [split $line_i] end]
    set n_outputs [lindex [split $line_o] end]
    return [list $n_inputs $n_outputs]
}

# Parses a cpp definition value in file 'f'
# retrieved from 'pattern'
proc get_definition_value {f pattern} {
    set line [ffindl $f $pattern]
    return [lindex [split $line] end]
}

proc get_syconfig_define {pattern} {
    return [get_definition_value $::Syfala::BUILD_CONFIG_FILE $pattern]
}

# retrieve number of I/O channels from Faust macro definitions
# in the generated syfala_ip.cpp file
proc parse_build_io {} {
    print_info "Now parsing Faust-generated IP file"
    set f $::Syfala::BUILD_IP_FILE
    set ::runtime::nchannels_i [get_definition_value $f "#define FAUST_INPUTS"]
    set ::runtime::nchannels_o [get_definition_value $f "#define FAUST_OUTPUTS"]
    set ::runtime::ncontrols_i [get_definition_value $f "#define FAUST_INT_CONTROLS"]
    set ::runtime::ncontrols_f [get_definition_value $f "#define FAUST_REAL_CONTROLS"]
    set ::runtime::ncontrols_p [get_definition_value $f "#define FAUST_PASSIVES"]
    print_info "Retrieved number of audio inputs ($::runtime::nchannels_i)"
    print_info "Retrieved number of audio outputs ($::runtime::nchannels_o)"
    print_info "Retrieved number of int-based controls ($::runtime::ncontrols_i)"
    print_info "Retrieved number of real-based controls ($::runtime::ncontrols_f)"
    print_info "Retrieved number of passive controls ($::runtime::ncontrols_p)"
}

proc display_report {} {
    set dsp             [get_dsp_name]
    set board_cpp_id    [get_syconfig_define "SYFALA_BOARD"]
    set sample_rate     [get_syconfig_define "SYFALA_SAMPLE_RATE"]
    set sample_width    [get_syconfig_define "SYFALA_SAMPLE_WIDTH"]
    set volume          [get_syconfig_define "SYFALA_SSM_VOLUME"]
    set controller      [get_syconfig_define "SYFALA_CONTROLLER_TYPE"]
    set num_io          [get_num_io]
    set mem_access      [Faust::mem_access_count]
    set version         $::Syfala::VERSION
    set path            $::Syfala::ROOT

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

## Overwrites line in syconfig.hpp containing $t definition
## sets it to $v value
proc set_syconfig_define {t v {v2 ""}} {
    if [is_empty $v2] { set v2 $v }
    freplacel $::Syfala::BUILD_CONFIG_FILE $t "#define $t $v"
    print_ok "Overwritten #define [emph $t] with value [emph $v2] in config.hpp"
}

proc generate_build_id {} {
    set stime [clock seconds]
    set dtime [clock format $stime -format {%Y-%m-%d}]
    set htime [clock format $stime -format %H%M%S]
    return "build-$dtime-$htime"
}

proc initialize_build {} {
    print_info "Initializing build directory"
    file mkdir $::Syfala::BUILD_SOURCES_DIR
    if [file exists $::Syfala::BUILD_INCLUDE_DIR] {
        file delete -force -- $::Syfala::BUILD_INCLUDE_DIR
    }
    file copy $::Syfala::INCLUDE_DIR $::Syfala::BUILD_DIR
}

proc export_build {id} {
    file mkdir $::Syfala::EXPORT_DIR
    set output $::Syfala::EXPORT_DIR/$id.zip
    print_info "Now exporting $output"
    exec zip -r $output .
    print_ok "$output succesfully exported"
}
}

# -------------------------------------------------------------------------------------------------
namespace eval Faust {
# -------------------------------------------------------------------------------------------------

proc mem_access_count {} {
    set f       [open $::Syfala::BUILD_IP_FILE r]
    set data    [read $f]
    set compute_fn  0
    set count_r     0
    set count_w     0
    print_info "Analyzing HLS IP memory accesses"
    foreach line [split $data "\n"] {
        if {[contains "computemydsp" $line]} {
            set compute_fn 1
            continue
        }
        if $compute_fn {
           set rw [regexp -all {[if]Zone\[} $line]
           set w  [regexp {[i f]Zone\[.*\] =} $line]
           incr count_w $w
           incr count_r [expr {$rw-$w}]
        }
    }
    close $f
    print_info "There are a total of $count_r read and $count_w write memory accesses in the IP"
    return [list $count_r $count_w]
}

## Runs Faust compiler to generate FPGA IP from
## $ARCH_FPGA_SRC_FILE architecture file
## generated output will be located in $ARCH_FPGA_DST_FILE
proc generate_ip_hls {dsp} {
    print_info "Generating Faust DSP [emph IP] from Faust compiler & architecture file"
    # create a 'sources' directory in build directory
    # copy fpga.cpp template file to be modified accordingly
    file mkdir $::Syfala::BUILD_SOURCES_DIR
    file mkdir $::Syfala::BUILD_IP_DIR    
    set cmd "faust $dsp -lang c -light -os2 -uim
                      -mcd $::runtime::mcd
                      -t 0
                      -a $::Syfala::ARCH_FPGA_HLS_TEMPLATE
                      -o $::Syfala::BUILD_IP_FILE"
    if $::runtime::fixed_point {
        append cmd " -fx"
    }
    syexec $cmd
    print_ok "Generated $::Syfala::BUILD_IP_FILE"
}

## Runs Faust compiler to generate FPGA VHDL IP
## generated output will be located in syfala_ip/faust.vhd
proc generate_ip_vhdl {dsp t} {
    cd $::Syfala::BUILD_SOURCES_DIR
    syexec faust -vhdl -vhdl-type $t $dsp
    print_ok "Generated DSP-VHDL translation in $Syfala::BUILD_SOURCES_DIR"
    cd $Syfala::BUILD_DIR
}

## Runs Faust compiler to generate Host IP from
## $ARCH_ARM_SRC_FILE architecture file
## generated output will be located in $ARCH_ARM_DST_FILE
proc generate_host {dsp src} {
    print_info "Generating [emph Host] Control Application from Faust compiler & architecture file"
    file mkdir $::Syfala::BUILD_APPLICATION_DIR
    set cmd "faust $dsp -i -lang cpp -os2 -uim
                        -mcd $::runtime::mcd
                        -t 0
                        -a $src
                        -o $::Syfala::BUILD_INCLUDE_DIR/syfala/arm/faust/control.hpp"
    syexec $cmd
    print_ok "Generated $Syfala::BUILD_APPLICATION_FILE"
}

proc generate_gui_app {dsp} {
    file mkdir $::Syfala::BUILD_GUI_DIR
    print_info "Generating & compiling GUI control application"
    syexec "faust $dsp -a $::Syfala::GUI_SRC_FILE -o $::Syfala::GUI_DST_FILE -uim"
    # I guess that's one of the limits of tcl...
    set pkgc [exec pkg-config --libs --cflags gtk+-2.0 libmicrohttpd]
    lappend pkgc -I$::Syfala::INCLUDE_DIR
    lappend pkgc "-lHTTPDFaust"
    set cmd "c++ -v -std=c++14 $::Syfala::GUI_DST_FILE $pkgc -o $::Syfala::BUILD_GUI_DIR/faust-gui"
    print_info "Executing command: $cmd"
    exec {*}$cmd >&@stdout | tee -a $Syfala::BUILD_LOG
}
}
# -------------------------------------------------------------------------------------------------
namespace eval Xilinx {
# -------------------------------------------------------------------------------------------------

namespace export vivado vitis vitis_hls xsct

proc vivado {} {
    return $::Xilinx::ROOT/Vivado/$::Xilinx::VERSION/bin/vivado
}

proc vitis {} {
    return $::Xilinx::ROOT/Vitis/$::Xilinx::VERSION/bin/vitis
}

proc xsct {} {
    return $::Xilinx::ROOT/Vitis/$::Xilinx::VERSION/bin/xsct
}

proc vitis_hls {} {
    return $::Xilinx::ROOT/Vitis_HLS/$::Xilinx::VERSION/bin/vitis_hls
}

namespace eval Boards   {
namespace eval Zybo     {
namespace eval z710     {
    set ID          "zybo-z7-10"
    set PART        "xc7z010clg400-1"
    # Note: the board file version is now automatically retrieved in the
    # appropriate board.xml file, and appended to the following id (PART_FULL)
    # please use the 'get_board_part_full' proc in order to retrieve the correct id
    set PART_FULL   "digilentinc.com:zybo-z7-10:part0"
    set CONSTRAINT  "zybo.xdc"
}
namespace eval z720 {
    set ID          "zybo-z7-20"
    set PART        "xc7z020clg400-1"
    set PART_FULL   "digilentinc.com:zybo-z7-20:part0"
    set CONSTRAINT  "zybo.xdc"
}
}
namespace eval Genesys {
    set ID          "gzu_3eg"
    set PART        "xczu3eg-sfvc784-1-e"
    set PART_FULL   "digilentinc.com:gzu_3eg:part0"
    set CONSTRAINT  "genesys-zu-3eg.xdc"
}
}

proc get_board_version {board} {
    switch $::Xilinx::VERSION {
    2020.2 {
        set path "$::Xilinx::ROOT/Vivado/$::Xilinx::VERSION/data/boards/board_files/"
    }
    2022.2 {
        set path "$::Xilinx::ROOT/Vivado/$::Xilinx::VERSION/data/xhub/boards/XilinxBoardStore/boards/Xilinx/"
    }
    default {
        print_error "Invalid Xilinx toolchain version ($::Xilinx::VERSION), aborting"
        exit 1
    }
    }
    switch $board {
    Z10 - Z20 {
        append path [get_board_id $board]
        append path "/A.0/"
    }
    GENESYS {
        append path "genesys-zu-3eg"
        append path "/B.0/"
    }
    }
    append path "board.xml"
    print_info "Retrieving board file version in $path"
    set version [ffindl $path "\<file_version\>"]
    regexp {<file_version\>([0-9]+\.[0-9]+)\</file_version>} $version -> version
    print_ok "Board file version: $version"
    return $version
}

proc get_board_id {board} {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::ID }
        "Z20" { return $Xilinx::Boards::Zybo::z720::ID }
        "GENESYS" { return $Xilinx::Boards::Genesys::ID }
    }
}

proc get_board_part {board} {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::PART }
        "Z20" { return $Xilinx::Boards::Zybo::z720::PART }
        "GENESYS" { return $Xilinx::Boards::Genesys::PART }
    }
}

proc get_board_part_full {board} {
    switch $board {
        Z10 {return "$::Xilinx::Boards::Zybo::z710::PART_FULL:[get_board_version $board]"}
        Z20 {return "$::Xilinx::Boards::Zybo::z720::PART_FULL:[get_board_version $board]"}
        GENESYS {return "$::Xilinx::Boards::Genesys::PART_FULL:[get_board_version $board]"}
    }
}

proc get_board_constraint {board} {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::CONSTRAINT }
        "Z20" { return $Xilinx::Boards::Zybo::z720::CONSTRAINT }
        "GENESYS" { return $Xilinx::Boards::Genesys::CONSTRAINT }
    }
}

proc compile_host {config board} {
    print_info "Compiling Host control application"
    syexec "[Xilinx::xsct] $::Syfala::APPLICATION_SCRIPT $config $board
            >&@stdout | tee -a $::Syfala::BUILD_LOG"
    print_ok   "Finished building Host application"
    file mkdir sw_export
    file copy -force $::Syfala::BUILD_APPLICATION_DIR/application/src sw_export
    file copy -force $::Syfala::BUILD_APPLICATION_DIR/application/Debug/application.elf sw_export
    print_ok "Copied application sources and .elf output to sw_export directory"
}

proc flash_jtag {board} {
    print_info "Flashing image (JTAG)"
    syexec "[Xilinx::xsct] $::Syfala::JTAG_SCRIPT $board $::Xilinx::ROOT >&@stdout"
}

# -----------------------------------------------------------------------------
namespace eval Vitis_HLS {
# -----------------------------------------------------------------------------
proc run {script args} {
    print_info "Running Vitis HLS on file $script"
    syexec "[Xilinx::vitis_hls] -f $script $args >&@stdout | tee -a $::Syfala::BUILD_LOG"
    # copy HLS report to BUILD_DIR
    file copy -force $::Syfala::BUILD_HLS_REPORT_SOURCE $::Syfala::BUILD_DIR
}
proc report {} {
    exec less $::Syfala::BUILD_HLS_REPORT_COPY >&@stdout
}
}
# -----------------------------------------------------------------------------
namespace eval Vivado {
# -----------------------------------------------------------------------------
proc run {script args} {
    print_info "Running Vivado on file $script"
    syexec "[Xilinx::vivado] -mode batch
                             -notrace
                             -source $script
                             -tclargs $args
                             >&@stdout | tee -a $::Syfala::BUILD_LOG"
}
}
}
# -----------------------------------------------------------------------------
source $::Syfala::LINUX_BUILD_SCRIPT
# -----------------------------------------------------------------------------
