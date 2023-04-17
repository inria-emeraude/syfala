# -------------------------------------------------------------------------------------------------
# post-install script (not fully functional yet...)
# -------------------------------------------------------------------------------------------------

proc get_cable_drivers_installer_path {x} {
    return "$x/Vivado/$TOOLCHAIN_VERSION/data/xicom/cable_drivers/lin64/install_script/install_drivers"
}

proc install_cable_drivers { x v } {
    if {[file exists "/etc/udev/rules.d/52-xilinx-digilent-usb.rules"]} {
        print_info "Cable drivers already installed, skipping"
        return
    } else {
        cd [get_cable_drivers_installer_path $x]
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
