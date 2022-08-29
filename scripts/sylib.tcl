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

set HLS_SCRIPT                  $Syfala::SCRIPTS_DIR/hls.tcl
set FAUST2VHDL_SCRIPT           $Syfala::SCRIPTS_DIR/faust2vhdl.tcl
set APPLICATION_SCRIPT		$Syfala::SCRIPTS_DIR/application.tcl
set PROJECT_SCRIPT_TEMPLATE	$Syfala::SCRIPTS_DIR/project.tcl
set PROJECT_SCRIPT		$Syfala::BUILD_SOURCES_DIR/project.tcl
set SYNTHESIS_SCRIPT		$Syfala::SCRIPTS_DIR/synthesis.tcl
set JTAG_SCRIPT			$Syfala::SCRIPTS_DIR/jtag.tcl
set BIN_GENERATOR		$Syfala::SCRIPTS_DIR/bin_generator.bif

set VHDL_DIR                    $Syfala::SOURCE_DIR/vhdl
set XDC_DIR		                  $Syfala::VHDL_DIR/constraints
set FIXED_FLOAT_TYPES_C         $Syfala::VHDL_DIR/fixed_float_types_c.vhd
set FIXED_PKG_C                 $Syfala::VHDL_DIR/fixed_pkg_c.vhd
set FLOAT_PKG_C                 $Syfala::VHDL_DIR/float_pkg_c.vhd
set SINCOS_24                   $Syfala::VHDL_DIR/SinCos24.vhd
set FAUST_VHD_EXAMPLE           $Syfala::VHDL_DIR/faust.vhd

# used in project.tcl
set CLK_DYNAMIC_RECONFIG        0

namespace export                \
color                           \
print_ok                        \
print_info                      \
print_error                     \
strctn                          \
rstbuild                        \
check_xroot                     \
set_xenv                        \
set_syconfig_define             \
generate_build_id               \
print_elapsed_time              \
initialize_build                \
export_build

# -------------------------------------------------------------------------------------------------
# utilities
# -------------------------------------------------------------------------------------------------

proc color { c t } {
    return [exec tput setaf $c]$t[exec tput sgr0]
}

proc print_ok { txt } {
    puts "\[  [color 2 OK]  \] $txt"
}

proc print_info { txt } {
    puts "\[ [color 11 INFO] \] $txt"
}

proc print_error { txt } {
    puts "\[ [color 1 ERR!] \] $txt"
}

## Resets build directory from syfala root directory
proc rstbuild {} {
    file delete -force -- $::Syfala::BUILD_DIR
    file delete {*}[glob -nocomplain vivado_*]
    file delete {*}[glob -nocomplain vivado.*]
    file delete {*}[glob -nocomplain vitis_*]
    file delete {*}[glob -nocomplain *.log]
    file delete -force -- .Xil

    print_ok "Reset build directory"
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
    set found 0
    set fr [open $Syfala::BUILD_CONFIG_FILE "r"]
    set data [read $fr]
    close $fr
    set fw [open $Syfala::BUILD_CONFIG_FILE "w"]
    foreach l [split $data "\n"] {
	if { !$found } {
	    foreach w [regexp -all -inline {\S+} $l] {
		if { $w == $t } {
		    set l "#define $t $v"
                    print_ok "Overwritten #define $t with value $v (syconfig.hpp)"
		    set found 1
		    break
		}
	    }
	}
	puts $fw $l
    }
    close $fw
}

proc generate_build_id {} {
    set stime [clock seconds]
    set dtime [clock format $stime -format {%Y-%m-%d}]
    set htime [clock format $stime -format %H%M%S]
    return "build-$dtime-$htime"
}

proc print_elapsed_time { start } {
    set end  [clock seconds]
    set len  [expr $end - $start]
    set fmt  [clock format $len -format {%M minutes and %S seconds}]
    print_info "Script has been running for $fmt"
}

proc initialize_build {} {
    print_info "Initializing build directory"
    if {[catch {file copy -force $::Syfala::INCLUDE_DIR $::Syfala::BUILD_DIR}]} {
        print_error "Current build would be deleted, aborting"
        print_info "Please run 'syfala clean' before starting a new build"
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

set GUI_SRC_FILE         $SOURCE_DIR/control/gui-controls.cpp
set GUI_DST_FILE         $::Syfala::BUILD_GUI_DIR/faust-gui.cpp

## Runs Faust compiler to generate FPGA IP from
## $ARCH_FPGA_SRC_FILE architecture file
## generated output will be located in $ARCH_FPGA_DST_FILE
proc generate_ip_hls { dsp } {
    print_info "Generating Faust IP from Faust compiler & architecture file"
    file mkdir $Faust::ARCH_FPGA_DST_DIR
    puts $dsp
    exec faust $dsp -lang c -light -os2 -uim -mcd 0	\
	 -a $Faust::ARCH_FPGA_SRC_FILE			\
	 -o $Faust::ARCH_FPGA_DST_FILE
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
	 -o $Faust::ARCH_HOST_DST_FILE
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
    exec {*}$cmd >&@stdout
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
    exec xsct $::Syfala::APPLICATION_SCRIPT $config $board >&@stdout |& tee vitis.log
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
        exec vitis_hls -f $script $args >&@stdout
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
	exec vivado -mode batch			\
		    -notrace			\
		    -source $script		\
		    -tclargs $args >&@stdout
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
