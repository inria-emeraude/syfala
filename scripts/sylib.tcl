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
set BUILD_ETH_IP_DIR            $BUILD_DIR/ethernet
set BUILD_ETH_IP_FILE           $BUILD_ETH_IP_DIR/ethernet.cpp
set BUILD_XSA_TARGET            $BUILD_DIR/hw_export/main_wrapper.xsa
set BUILD_BITSTREAM_SOURCE      $BUILD_PROJECT_DIR/syfala_project.runs/impl_1/main_wrapper.bit
set BUILD_BITSTREAM_TARGET      $BUILD_DIR/hw_export/system.bit
set BUILD_HLS_REPORT_SOURCE     $BUILD_IP_DIR/syfala/syn/report/syfala_csynth.rpt
set BUILD_HLS_REPORT_COPY       $BUILD_DIR/syfala_csynth.rpt
set BUILD_INCLUDE_DIR           $BUILD_DIR/include
set BUILD_SOURCES_DIR           $BUILD_DIR/sources
set BUILD_XSOURCES_DIR          $BUILD_IP_DIR/syfala/impl/ip/drivers/syfala_v1_0/src
set BUILD_XETHERNET_DIR         $BUILD_ETH_IP_DIR/ethernet/impl/ip/drivers/eth_audio_v1_0/src
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
set BD_MULTISAMPLE     $BD_DIR/multisample.tcl
set BD_SIGMA_DELTA     $BD_DIR/sigma-delta.tcl
set BD_TDM             $BD_DIR/tdm.tcl
set BD_FAUST2VHDL      $BD_DIR/faust2vhdl.tcl

# -----------------------------------------------------------------------------
# architecture files
# -----------------------------------------------------------------------------

set ARCH_FPGA_HLS_TEMPLATE              $RTL_DIR/hls/faust_dsp_template.cpp
set ARCH_FPGA_HLS_TEMPLATE_MULTISAMPLE  $RTL_DIR/hls/faust_dsp_template_multisample.cpp
set ARCH_FPGA_SRC_FILE_VHDL             $BUILD_IP_DIR/faust.vhd
set ARCH_FPGA_SRC_FILE_HLS              $BUILD_SOURCES_DIR/fpga.cpp
set ARCH_ARM_FILE_HLS                   $INCLUDE_DIR/syfala/arm/faust/control.hpp
set ARCH_ARM_FILE_VHDL                  $SOURCE_DIR/arm/baremetal/arm_vhdl.cpp
set ARCH_ARM_TARGET                     $ARCH_ARM_FILE_HLS
set GUI_SRC_FILE                        $SOURCE_DIR/remote/faust-gui.cpp
set GUI_DST_FILE                        $BUILD_GUI_DIR/faust-gui.cpp

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
get_elapsed_time                \
get_elapsed_time_msec           \
get_elapsed_time_sec            \
print_elapsed_time              \

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
}

