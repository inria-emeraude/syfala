namespace eval Syfala {

proc get_root {} {
    set path [file dirname [file normalize [info script]]]
    return   [file dirname $path]
}

set VERSION                     7
set ROOT                        [get_root]
set SOURCE_DIR                  $ROOT/source
set INCLUDE_DIR                 $ROOT/include
set SCRIPTS_DIR                 $ROOT/scripts
set BUILD_DIR                   $ROOT/build
set EXPORT_DIR                  $ROOT/export
set CONFIG_FILE                 $INCLUDE_DIR/syconfig.hpp

set DEFAULT_EXAMPLE             $ROOT/examples/virtualAnalog.dsp

set BUILD_APPLICATION_DIR       $BUILD_DIR/syfala_application
set BUILD_PROJECT_DIR           $BUILD_DIR/syfala_project
set BUILD_IP_DIR                $BUILD_DIR/syfala_ip
set BUILD_INCLUDE_DIR           $BUILD_DIR/include
set BUILD_SOURCES_DIR           $BUILD_DIR/sources
set BUILD_GUI_DIR               $BUILD_DIR/gui
set BUILD_CONFIG_FILE           $BUILD_INCLUDE_DIR/syconfig.hpp
set BUILD_LOG                   $ROOT/syfala_log.txt

set HLS_SCRIPT                  $Syfala::SCRIPTS_DIR/hls.tcl
set FAUST2VHDL_SCRIPT           $Syfala::SCRIPTS_DIR/faust2vhdl.tcl
set APPLICATION_SCRIPT          $Syfala::SCRIPTS_DIR/application.tcl
set PROJECT_SCRIPT_TEMPLATE     $Syfala::SCRIPTS_DIR/project.tcl
set PROJECT_SCRIPT              $Syfala::BUILD_SOURCES_DIR/project.tcl
set SYNTHESIS_SCRIPT            $Syfala::SCRIPTS_DIR/synthesis.tcl
set JTAG_SCRIPT                 $Syfala::SCRIPTS_DIR/jtag.tcl
set BIN_GENERATOR               $Syfala::SCRIPTS_DIR/bin_generator.bif

set VHDL_DIR                    $Syfala::SOURCE_DIR/vhdl
set XDC_DIR                     $Syfala::VHDL_DIR/constraints
set FIXED_FLOAT_TYPES_C         $Syfala::VHDL_DIR/fixed_float_types_c.vhd
set FIXED_PKG_C                 $Syfala::VHDL_DIR/fixed_pkg_c.vhd
set FLOAT_PKG_C                 $Syfala::VHDL_DIR/float_pkg_c.vhd
set SINCOS_24                   $Syfala::VHDL_DIR/SinCos24.vhd
set FAUST_VHD_EXAMPLE           $Syfala::VHDL_DIR/faust.vhd

# used in project.tcl
set CLK_DYNAMIC_RECONFIG        0

namespace export                \
color                           \
emph                            \
print_ok                        \
print_info                      \
print_error                     \
contains                        \
is_empty                        \
ffindl                          \
ffindlN                         \
freplacel                       \
rstbuild                        \
check_xroot                     \
set_xenv                        \
set_syconfig_define             \
generate_build_id               \
get_elapsed_time                \
get_elapsed_time_msec           \
get_elapsed_time_sec            \
print_elapsed_time              \
initialize_build                \
export_build

# -------------------------------------------------------------------------------------------------
# utilities
# -------------------------------------------------------------------------------------------------

proc color { c t } {
    return [exec tput setaf $c]$t[exec tput sgr0]
}

proc emph { t } {
    return [exec tput bold]$t[exec tput sgr0]
}

proc basic_print { txt } {
    set foutput [open $::Syfala::BUILD_LOG a+   ]
    puts  $txt
    puts  $foutput "[get_time] - $txt"
    close $foutput
}

proc print_ok { txt } {
    basic_print "\[  [color 2 OK]  \] $txt"
}

proc print_info { txt } {
    basic_print "\[ [color 11 INFO] \] $txt"
}

proc print_error { txt } {
    basic_print "\[ [color 1 ERR!] \] $txt"
}

# returns 1 if 'str' contains 'pattern'
# returns 0 if 'pattern' couldn't be found.
proc contains { pattern str } {
     if {[string first $pattern $str] != -1} {
         return 1
     } else {
         return 0
     }
}

# returns 1 if 'str' is empty, 0 otherwise
proc is_empty { str } {
    if {$str == ""} {
        return 1
    } else {
        return 0
    }
}

# find a pattern within a file
# returns the whole line if found
proc ffindl { f pattern } {
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
proc ffindlN { f target N {offset 0}} {
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
proc freplacel { f A B } {
    set fr     [open $f r]
    set data   [read $fr]
    close      $fr
    set fw     [open $f w]
    set found  0
    foreach line [split $data "\n"] {
        if {!$found && [contains $A $line]} {
            set line $B
            set found 1
            puts $fw $line
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

# find lines containing patterns {A} in file 'f'
# replace them by lines {B}
proc freplacelN { f A B } {
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

## Resets build directory from syfala root directory
proc rstbuild {} {
    # we've got to print it first, because otherwise the log
    # file will disappear...
    print_ok "Reset build directory"
    file delete -force -- $::Syfala::BUILD_DIR
    file delete -force $::Syfala::BUILD_LOG
    file delete {*}[glob -nocomplain vivado_*]
    file delete {*}[glob -nocomplain vivado.*]
    file delete {*}[glob -nocomplain vitis_*]
    file delete {*}[glob -nocomplain *.log]
    file delete -force -- .Xil
}

## Checks installation of a specific Xilinx tool
## aborts process if path is incorrect
proc check_xpath { x v t } {
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
proc check_xroot { x v } {
     check_xpath $x $v "Vivado"
     check_xpath $x $v "Vitis"
     check_xpath $x $v "Vitis_HLS"
}

# Adds Xilinx tool $t root and bin directories to
# PATH environment variable, for the time the script is being run
proc set_xenv { x v t } {
    set ::env(PATH) "$::env(PATH):$x/$t/$v:$x/$t/$v/bin"
}

## Overwrites line in syconfig.hpp containing $t definition
## sets it to $v value
proc set_syconfig_define { t v } {
    freplacel $::Syfala::BUILD_CONFIG_FILE $t "#define $t $v"
    print_ok "Overwritten #define $t with value $v in syconfig.hpp"
}

proc get_time {} {
    set stime [clock seconds]
    set htime [clock format $stime -format %H:%M:%S]
    return $htime
}

proc generate_build_id {} {
    set stime [clock seconds]
    set dtime [clock format $stime -format {%Y-%m-%d}]
    set htime [clock format $stime -format %H%M%S]
    return "build-$dtime-$htime"
}

proc get_elapsed_time_msec { start } {
    set end [clock milliseconds]
    return [expr $end - $start]
}

proc get_elapsed_time_sec { start } {
    set end [clock seconds]
    return [expr $end - $start]
}

proc get_elapsed_time { start } {
    set end [clock seconds]
    set len [expr $end - $start]
    set fmt [clock format $len -format {%M minutes and %S seconds}]
    return $fmt
}

proc print_elapsed_time { start } {
    print_info "Script has been running for [get_elapsed_time $start]"
}

proc initialize_build {} {
    print_info "Initializing build directory"
    if {[catch {file copy -force $::Syfala::INCLUDE_DIR $::Syfala::BUILD_DIR}]} {
        print_error "Current build would be deleted, aborting"
        print_info "Please run 'syfala clean' before starting a new build"
        print_info "You can also add the '--reset' run step to your command"
        print_info "If you wish to save previous build first, run 'syfala --export mybuild'"
        exit 1
    }
}

proc export_build { id } {
    file mkdir $::Syfala::BUILD_DIR/scripts
    file copy -force $::Syfala::JTAG_SCRIPT $::Syfala::BUILD_DIR/scripts
    file copy -force $::Syfala::SCRIPTS_DIR/Makefile $::Syfala::BUILD_DIR
    file mkdir $::Syfala::EXPORT_DIR
    set output $::Syfala::EXPORT_DIR/$id.zip
    print_info "Now exporting $output"
    exec zip -r $output .
    print_ok "$output succesfully exported"
}

# this has to be renamed, and maybe put elsewhere
proc normalize_ip_controls { nchannels } {
    print_info "Normalizing IP control arrays & I/O buffers"
    set f $::Syfala::BUILD_IP_DIR/syfala_ip.cpp
    set A "FAUSTFLOAT inputs"
    set B "\tstatic FAUSTFLOAT inputs\[$nchannels\], outputs\[$nchannels\];"
    freplacel $f $A $B
    # now we have to get number of int controls & float controls
    # get line with pattern #define FAUST_INT_CONTROLS
    # get line with pattern #define FAUST_REAL_CONTROLS
    set icontrols_l [ffindl $f "#define FAUST_INT_CONTROLS"]
    set fcontrols_l [ffindl $f "#define FAUST_REAL_CONTROLS"]
    set pcontrols_l [ffindl $f "#define FAUST_PASSIVES"]
    # now, get the last number of these lines
    set icontrols [lindex [split $icontrols_l] end]
    set fcontrols [lindex [split $fcontrols_l] end]
    set pcontrols [lindex [split $pcontrols_l] end]
    # if no controls, set to 2 (minimum), otherwise [0] arrays won't compile
    # and [1] array change the function's name in xsyfala.c from 'write_%%_words' to 'set'
    # we should script this as well in a near future...
    set icontrols [expr max($icontrols, 2)]
    set fcontrols [expr max($fcontrols, 2)]
    set pcontrols [expr max($pcontrols, 2)]

    # finally, replace control arrays with the correct length values
    freplacel $f "int ARM_fControl" "\t\tint ARM_fControl\[$fcontrols\],"
    freplacel $f "int ARM_iControl" "\t\tint ARM_iControl\[$icontrols\],"
    freplacel $f "int ARM_passive_controller" "\t\tint ARM_passive_controller\[$pcontrols\],"
    freplacel $f "static int icontrol\[FAUST_INT_CONTROLS\]" "static int icontrol\[$icontrols\];"
    freplacel $f "static float fcontrol\[FAUST_REAL_CONTROLS\]" "static float fcontrol\[$fcontrols\];"
}

}

# -------------------------------------------------------------------------------------------------
# Faust compiler calls
# -------------------------------------------------------------------------------------------------

namespace eval Faust {

set SOURCE_DIR $::Syfala::SOURCE_DIR/faust

set ARCH_FPGA_TEMPLATE_FILE   $SOURCE_DIR/architecture/fpga.cpp
set ARCH_FPGA_SRC_FILE        $::Syfala::BUILD_SOURCES_DIR/fpga.cpp
set ARCH_FPGA_DST_DIR         $::Syfala::BUILD_IP_DIR
set ARCH_FPGA_DST_FILE        $ARCH_FPGA_DST_DIR/syfala_ip.cpp
set ARCH_FPGA_DST_FILE_VHDL   $::Syfala::VHDL_DIR/faust.vhd

set ARCH_HOST_DST_DIR        $::Syfala::BUILD_APPLICATION_DIR
set ARCH_HOST_SRC_FILE       $SOURCE_DIR/architecture/arm.cpp
set ARCH_HOST_SRC_FILE_VHDL  $SOURCE_DIR/architecture/arm_vhdl.cpp
set ARCH_HOST_DST_FILE       $ARCH_HOST_DST_DIR/syfala_application.cpp

set GUI_SRC_FILE            $SOURCE_DIR/control/gui-controls.cpp
set GUI_DST_FILE            $::Syfala::BUILD_GUI_DIR/faust-gui.cpp

proc mem_access_count {} {
    set f [open $Faust::ARCH_FPGA_DST_FILE r]
    set data [read $f]
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
           set rw  [regexp -all {[if]Zone\[} $line]
           set w   [regexp {[i f]Zone\[.*\] =} $line]
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
proc generate_ip_hls { dsp } {
    print_info "Generating Faust IP from Faust compiler & architecture file"
    file mkdir $Faust::ARCH_FPGA_DST_DIR
    exec faust $dsp -lang c -light -os2 -uim -mcd 0  \
     -a $Faust::ARCH_FPGA_SRC_FILE                   \
     -o $Faust::ARCH_FPGA_DST_FILE                   \
     -t 0
    print_ok "Generated $Faust::ARCH_FPGA_DST_FILE"
}

proc generate_ip_vhdl { dsp t } {
    file mkdir $Faust::ARCH_FPGA_DST_DIR
    cd $Faust::ARCH_FPGA_DST_DIR
    exec faust -vhdl -vhdl-type $t $dsp
    print_ok "Generated DSP-VHDL translation in $Faust::ARCH_FPGA_DST_DIR"
    cd $Syfala::BUILD_DIR
}

## Runs Faust compiler to generate Host IP from
## $ARCH_ARM_SRC_FILE architecture file
## generated output will be located in $ARCH_ARM_DST_FILE
proc generate_host { dsp src } {
    print_info "Generating HOST Control Application from Faust compiler & architecture file"
    file mkdir $Faust::ARCH_HOST_DST_DIR
    exec faust $dsp -i -lang cpp -os2 -uim -mcd 0   \
         -a $src                                    \
         -o $Faust::ARCH_HOST_DST_FILE              \
         -t 0
    print_ok "Generated $Faust::ARCH_HOST_DST_FILE"
}

proc generate_gui_app { dsp } {
    file mkdir $::Syfala::BUILD_GUI_DIR
    print_info "Generating GUI control application"
    exec faust $dsp -a $Faust::GUI_SRC_FILE -o $Faust::GUI_DST_FILE
    print_info "Compiling GUI control application"
    # I guess that's one of the limits of tcl...
    set pkgc [exec pkg-config --libs --cflags gtk+-2.0]
    lappend pkgc -I$::Syfala::INCLUDE_DIR
    set cmd "c++ -v -std=c++11 $Faust::GUI_DST_FILE $pkgc -o $::Syfala::BUILD_GUI_DIR/faust-gui"
    exec {*}$cmd >&@stdout | tee -a $Syfala::BUILD_LOG
}
}

# -------------------------------------------------------------------------------------------------
# Xilinx toolchain calls
# -------------------------------------------------------------------------------------------------

namespace eval Xilinx {

set VERSION 2020.2

namespace eval Boards {
    namespace eval Zybo {
        namespace eval z710 {
            set ID          "zybo-z7-10"
            set PART        "xc7z010clg400-1"
            set PART_FULL   "digilentinc.com:zybo-z7-10:part0:1.0"
            set CONSTRAINT  "master_zybo.xdc"
        }
        namespace eval z720 {
            set ID          "zybo-z7-20"
            set PART        "xc7z020clg400-1"
            set PART_FULL   "digilentinc.com:zybo-z7-20:part0:1.0"
            set CONSTRAINT  "master_zybo.xdc"
        }
    }
    namespace eval Genesys {
        set ID          "gzu_3eg"
        set PART        "xczu3eg-sfvc784-1-e"
        set PART_FULL   "digilentinc.com:gzu_3eg:part0:1.0"
        set CONSTRAINT	"master_Genesys-ZU-3EG.xdc"
    }
}

proc get_board_id { board } {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::ID }
        "Z20" { return $Xilinx::Boards::Zybo::z720::ID }
        "GENESYS" { return $Xilinx::Boards::Genesys::ID }
    }
}

proc get_board_part { board } {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::PART }
        "Z20" { return $Xilinx::Boards::Zybo::z720::PART }
        "GENESYS" { return $Xilinx::Boards::Genesys::PART }
    }
}

proc get_board_part_full { board } {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::PART_FULL }
        "Z20" { return $Xilinx::Boards::Zybo::z720::PART_FULL }
        "GENESYS" { return $Xilinx::Boards::Genesys::PART_FULL }
    }
}

proc get_board_constraint { board } {
    switch $board {
        "Z10" { return $Xilinx::Boards::Zybo::z710::CONSTRAINT }
        "Z20" { return $Xilinx::Boards::Zybo::z720::CONSTRAINT }
        "GENESYS" { return $Xilinx::Boards::Genesys::CONSTRAINT }
    }
}

proc compile_host { config board } {
    print_info "Compiling Host control application"
    exec xsct $::Syfala::APPLICATION_SCRIPT $config $board >&@stdout | tee -a $::Syfala::BUILD_LOG
    print_ok "Finished building host application"
    file mkdir sw_export
    file copy -force syfala_application/application/src sw_export
    file copy -force syfala_application/application/Debug/application.elf sw_export
    print_ok "Copied application sources and .elf output to sw_export directory"
}

proc generate_boot {} {
    print_info "Generating Boot Image"
    exec bootgen -image $::Syfala::BIN_GENERATOR    \
                 -arch zynq                         \
                 -o sw_export/BOOT.bin              \
                 -w on >&@stdout
    print_ok "Boot Image successfully generated"
}

proc flash_jtag {board} {
    print_info "Flashing image (JTAG)"
    exec xsct $::Syfala::JTAG_SCRIPT $board >&@stdout
}

namespace eval Vitis_HLS {
    proc run { script args } {
        print_info "Running Vitis HLS on file $script"
        exec vitis_hls -f $script $args >&@stdout | tee -a $::Syfala::BUILD_LOG
        # copy report to BUILD_DIR
        file copy -force syfala_ip/syfala/syn/report/syfala_csynth.rpt $::Syfala::BUILD_DIR
    }
    proc report { } {
        exec less syfala_csynth.rpt >&@stdout
    }
}
namespace eval Vivado {
    proc run { script args } {
	print_info "Running Vivado on file $script"
    exec vivado -mode batch     \
		    -notrace			\
		    -source $script		\
            -tclargs $args      \
            >&@stdout | tee -a $::Syfala::BUILD_LOG
    }

    proc get_cable_drivers_installer_path {x} {
        return "$x/Vivado/$TOOLCHAIN_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers"
    }
}
}
# -------------------------------------------------------------------------------------------------
# post-install script (not fully functional yet...)
# -------------------------------------------------------------------------------------------------

proc install_cable_drivers { x v } {
    if {[file exists "/etc/udev/rules.d/52-xilinx-digilent-usb.rules"]} {
        print_info "Cable drivers already installed, skipping"
        return
    } else {
        cd [Xilinx::Vivado::get_cable_drivers_installer_path]
        print_info "Installing cable drivers (requires sudo)"
        exec sudo ./install_drivers
        print_info "Copying 52-xilinx-digilent-usb.rules to /etc/udev/rules.d (JTAG)"
        exec sudo cp -r 52-xilinx-digilent-usb.rules /etc/udev/rules.d
    }
}

proc install_digilent_board_files { x v } {
    cd $::Syfala::ROOT
    set boards_src "misc/vivado-boards/new/board_files/."
    set boards_dst "$x/Vivado/$v/data/boards/board_files"
    if {[file exists "$boards_dst/zybo-z7-10"]} {
        print_info "Board files already installed, skipping"
        return
    } else {
        print_info "Downloading Digilent Board Files from github"
        exec git clone https://github.com/Digilent/vivado-boards vivado-boards
        print_info "Installing Digilent Board Files in $boards_dst"
        file copy -force $boards_src $boards_dst
        file delete -force -- boards_src
    }
}

proc install_y2k22_patch { x v } {
     cd $::Syfala::ROOT
     if {[file exists "$x/y2k22_patch"]} {
         print_info "Y2K22 patch already installed, skipping"
         return
     } else {
         print_info "Installing Xilinx y2k22_patch-1.2"
         exec cp -f "misc/y2k22_patch" $x
         cd $x
         set ::env(LD_LIBRARY_PATH) "$x/Vivado/2020.2/tps/lnx64/python-3.8.3/lib"
         exec Vivado/$v/tps/lnx64/python-3.8.3/bin/python3 y2k22_patch/patch.py
     }
}

proc post_install { x v } {
     install_digilent_board_files $x $v
     install_cable_drivers $x $v
     install_y2k22_patch $x $v
     print_ok "Post-installation succesfull"
}
