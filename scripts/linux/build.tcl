# -------------------------------------------------------------------------------------------------
# Linux
# -------------------------------------------------------------------------------------------------
namespace eval Linux {

set VERSION                 "5.15.0-xilinx"
set BUILD_DIR               $::Syfala::BUILD_LINUX_DIR
set BUILD_BOOT_DIR          $BUILD_DIR/boot
set BUILD_ROOT_DIR          $BUILD_DIR/root
set BUILD_OUTPUT_DIR        $BUILD_DIR/output
set BUILD_OUTPUT_BOOT_DIR   $BUILD_OUTPUT_DIR/boot
set BUILD_OUTPUT_ROOT_DIR   $BUILD_OUTPUT_DIR/root
set LINUX_SOURCES           $::Syfala::SOURCE_DIR/linux
set CONFIG_DIR              $LINUX_SOURCES/configs
set DEVICE_TREE_SOURCES     $LINUX_SOURCES/device-tree

# -----------------------------------------------------------------------------
# U-Boot
# -----------------------------------------------------------------------------

set BUILD_UBOOT_DIR     $BUILD_BOOT_DIR/u-boot-xlnx-xilinx-v2022.2
set BUILD_UBOOT_SRC     "https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2022.2.zip"
set BUILD_UBOOT_ZIP     $BUILD_BOOT_DIR/xilinx-uboot-v2022.2.zip
set BUILD_BOOT_BIN_SRC  $BUILD_UBOOT_DIR/spl/boot.bin
set BUILD_BOOT_BIN_DST  $BUILD_OUTPUT_BOOT_DIR/boot.bin
set BUILD_BOOT_DTB_SRC  $BUILD_UBOOT_DIR/u-boot.img
set BUILD_BOOT_DTB_DST  $BUILD_OUTPUT_BOOT_DIR/u-boot.img


proc build_uboot {} {
    if ![file exists $::Linux::BUILD_UBOOT_DIR] {
        print_info "Fetching Xilinx u-boot v2022.2"
        exec curl -L $::Linux::BUILD_UBOOT_SRC \
                  -o $::Linux::BUILD_UBOOT_ZIP >&@stdout
        exec unzip $::Linux::BUILD_UBOOT_ZIP -d $::Linux::BUILD_BOOT_DIR >&@stdout
        file delete $::Linux::BUILD_UBOOT_ZIP
    }
    cd $::Linux::BUILD_UBOOT_DIR
    print_info "Compiling Boot Loader (v2022.2)"
    exec make distclean
    exec make "xilinx_zynq_virt_defconfig" >&@stdout
    exec make -j8 >&@stdout
    file copy -force $::Linux::BUILD_BOOT_BIN_SRC $::Linux::BUILD_BOOT_BIN_DST
    file copy -force $::Linux::BUILD_BOOT_DTB_SRC $::Linux::BUILD_BOOT_DTB_DST
    print_ok "Successfully compiled Boot Loader"
    cd $::Syfala::BUILD_DIR
}

# -----------------------------------------------------------------------------
# Kernel
# -----------------------------------------------------------------------------

set BUILD_KERNEL_SRC "https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2022.2.zip"
set BUILD_KERNEL_ZIP $BUILD_BOOT_DIR/xilinx-kernel-v2022.2.zip
set BUILD_KERNEL_DIR $BUILD_BOOT_DIR/linux-xlnx-xilinx-v2022.2
set BUILD_UIMAGE_SRC $BUILD_KERNEL_DIR/arch/arm/boot/uImage
set BUILD_UIMAGE_DST $BUILD_OUTPUT_BOOT_DIR/uImage

proc build_kernel {} {
    if ![file exists $::Linux::BUILD_KERNEL_DIR] {
        print_info "Fetching Xilinx Linux Kernel v2022.2 (this might take a while...)"
        exec curl -L $::Linux::BUILD_KERNEL_SRC \
                  -o $::Linux::BUILD_KERNEL_ZIP >&@stdout
        exec unzip $::Linux::BUILD_KERNEL_ZIP -d $::Linux::BUILD_BOOT_DIR
        file delete $::Linux::BUILD_KERNEL_ZIP
    }
    cd $::Linux::BUILD_KERNEL_DIR
    print_info "Compiling Xilinx Linux Kernel (v2022.2)"
    file copy -force $::Linux::CONFIG_DIR/zybo_z7_defconfig \
                     $::Linux::BUILD_KERNEL_DIR/arch/arm/configs
    exec make ARCH=arm "zybo_z7_defconfig" >&@stdout
    exec make ARCH=arm                      \
          "CFLAGS=-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard" \
          "UIMAGE_LOADADDR=0x8000"          \
          "CONFIG_USB_OTG=y"                \
          uImage                            \
          modules                           \
          -j8                               \
    >&@stdout
    file copy -force $::Linux::BUILD_UIMAGE_SRC $::Linux::BUILD_UIMAGE_DST
    print_ok "Succesfully compiled Xilinx Linux Kernel"
    cd $::Syfala::BUILD_DIR
}

# -----------------------------------------------------------------------------
# device-tree
# -----------------------------------------------------------------------------

set BUILD_DTREE_DIR     $BUILD_BOOT_DIR/device-tree
set BUILD_DTC_DIR       $BUILD_DTREE_DIR/compiler
set BUILD_DTG_DIR       $BUILD_DTREE_DIR/generator
set BUILD_DTS_DIR       $BUILD_DTG_DIR/sources
set BUILD_DTX_DIR       $BUILD_DTG_DIR/xilinx

# Device-tree TCL script ------------------------------------------------------
set BUILD_DTG_DTS_TCL_SRC   $::Syfala::SCRIPTS_DIR/linux/dts.tcl
set BUILD_DTG_DTS_TCL_DST   $BUILD_DTG_DIR/dts.tcl

# Device-tree XSA -------------------------------------------------------------
set BUILD_DTG_XSA_SRC   $::Syfala::BUILD_XSA_TARGET
set BUILD_DTG_XSA_DST   $BUILD_DTG_DIR/system.xsa

# Device-tree dtsi ------------------------------------------------------------
set BUILD_DTG_DTSI_SRC  $DEVICE_TREE_SOURCES/zynq-zybo-syfala.dtsi
set BUILD_DTG_DTSI_DST  $BUILD_DTG_DIR/zynq-zybo-syfala.dtsi

# Device tree blob ------------------------------------------------------------
set BUILD_DTB_SRC   $BUILD_DTS_DIR/system.dtb
set BUILD_DTB_DST   $BUILD_OUTPUT_BOOT_DIR/system.dtb

# -----------------------------------------------------------------------------

proc build_device_tree_static {} {
    set STATIC_DTS_TARGET $::Linux::DEVICE_TREE_SOURCES/system.dts
    file mkdir $::Linux::BUILD_DTREE_DIR
    file mkdir $::Linux::BUILD_DTG_DIR
    file mkdir $::Linux::BUILD_DTS_DIR
    exec gcc -I $::Linux::BUILD_DTS_DIR -E -nostdinc    \
             -undef -D__DTS__                           \
             -x assembler-with-cpp                      \
             -o $::Linux::BUILD_DTS_DIR/system.dts      \
             $STATIC_DTS_TARGET                         \
             >&@stdout
    exec dtc -I dts -O dtb                              \
             -o $::Linux::BUILD_DTB_SRC                 \
             $::Linux::BUILD_DTS_DIR/system.dts         \
             >&@stdout
    print_ok "Succesfully compiled Device Tree Blob"
    file copy -force $::Linux::BUILD_DTB_SRC $::Linux::BUILD_DTB_DST
    cd $::Syfala::BUILD_DIR
}

# -----------------------------------------------------------------------------
# boot script
# -----------------------------------------------------------------------------

set BOOT_CMD_SRC $::Syfala::SCRIPTS_DIR/linux/boot.cmd
set BOOT_SCRIPT $BUILD_OUTPUT_BOOT_DIR/boot.scr
set BUILD_UBOOT_MKIMAGE_BIN $BUILD_UBOOT_DIR/tools/mkimage

proc generate_boot_script {} {
    print_info "Generating Boot Script with 'mkimage'"
    exec $::Linux::BUILD_UBOOT_MKIMAGE_BIN  \
         -c none                            \
         -A arm                             \
         -T script                          \
         -d $::Linux::BOOT_CMD_SRC          \
         $::Linux::BOOT_SCRIPT              \
         >&@stdout
}

proc set_env {} {
    set ::env(DEVICE_TREE) "zynq-zybo-z7"
    set ::env(CROSS_COMPILE) "arm-none-eabi-"
    set ::env(ARCH) "arm"
}

proc create_build_directories {} {
    # - linux
    # | -----> boot
    # |       | ----> u-boot
    # |       | ----> kernel
    # |       | ----> device-tree
    # | -----> output
    # |       | ----> boot
    # |       | ----> root
    file mkdir $::Syfala::BUILD_DIR
    file mkdir $::Linux::BUILD_DIR
    file mkdir $::Linux::BUILD_BOOT_DIR
    file mkdir $::Linux::BUILD_OUTPUT_DIR
    file mkdir $::Linux::BUILD_OUTPUT_BOOT_DIR
}

# -----------------------------------------------------------------------------
# main build function
# -----------------------------------------------------------------------------
proc build_boot {} {
    print_info "Building Boot Partition's contents"
    # Create all the necessary build subdirectories
    create_build_directories
    cd $::Linux::BUILD_DIR
    # Set some environment variables (required for cross-compilation)
    # note: Genesys board is not yet supported...
    set_env
    # 1. Clone and compile Xilinx' u-boot repository
    # https://github.com/Xilinx/u-boot-xlnx
    # It will generate the First Stage Boot Loader (FSBL)
    # and the Secondary Program Loader (SPL)
    # both included in the main 'boot.bin' binary
    build_uboot
    # 2. Clone and Compile Xilinx' custom Linux Kernel repository
    # https://github.com/Xilinx/linux-xlnx
    # it comes shipped with custom Xilinx drivers
    # and some pre-configured options
    build_kernel
    # 3. Build the device-tree from static sources
    # (source/linux/device-tree/system.dts)
    # Note: due to the difficulties encountered with generating
    # a proper and correct device-tree with the Xilinx tools
    # we use (for now) a static device-tree source file
    # that has been modified by hand in order to facilitate
    # its readability, and make things work properly...
    build_device_tree_static
    # 4. Generate (sign) the Boot script file that will indicate
    # to u-boot the proper commands to execute and the binaries to load
    # when booting
    generate_boot_script
    # 5. Copy bitstream to boot output directory
    # Note: for some reason, Xilinx's u-boot (version 2022.2)
    # seems to require a bitstream to be loaded during boot,
    # otherwise, it won't load the Kernel.
    file copy -force $::Syfala::BUILD_BITSTREAM_TARGET \
                     $::Linux::BUILD_OUTPUT_BOOT_DIR/system.bit
    print_ok "Linux boot image succesfully built, results available in $::Linux::BUILD_OUTPUT_BOOT_DIR"
}

# -----------------------------------------------------------------------------
# root filesystem build
# -----------------------------------------------------------------------------
# Main root file system building function
# Ideally, we could target other distributions
# (like ubuntu or archlinux-arm...)
# For now, the default one is Alpine Linux (scripts/linux/alpine-root.tcl)
set ROOT_TARGET "Alpine"
set ROOT_TARGET_BUILD_SCRIPT_ALPINE $::Syfala::SCRIPTS_DIR/linux/root/alpine.tcl

proc build_root {} {
    switch $::Linux::ROOT_TARGET {
        Alpine {
            source $::Linux::ROOT_TARGET_BUILD_SCRIPT_ALPINE
            Alpine::build
        }
    }
}

proc update_dsp {} {
    file copy -force $::Syfala::BUILD_BITSTREAM_TARGET          \
                     $::Linux::BUILD_OUTPUT_BOOT_DIR/system.bit
    switch $::Linux::ROOT_TARGET {
        Alpine {
            source $::Linux::ROOT_TARGET_BUILD_SCRIPT_ALPINE
            Alpine::update_bitstream
            Alpine::build_app
        }
    }
}

proc build_app {} {
    switch $::Linux::ROOT_TARGET {
        Alpine {
            source $::Linux::ROOT_TARGET_BUILD_SCRIPT_ALPINE
            Alpine::build_app
        }
    }
}

proc root_flash_dsp {root} {
    switch $::Linux::ROOT_TARGET {
        Alpine {
            source $::Linux::ROOT_TARGET_BUILD_SCRIPT_ALPINE
            Alpine::flash_dsp $root
        }
    }
}

# -----------------------------------------------------------------------------
# utility functions for formatting/flashing sd cards
# -----------------------------------------------------------------------------

proc format_sd_card {device} {
    switch $device {
    /dev/mmcblk0 {
        set part1 "/dev/mmcblk0p1"
        set part2 "/dev/mmcblk0p2"
    }
    /dev/sda {
        set part1 "/dev/sda1"
        set part2 "/dev/sda2"
    }
    default {
        print_error "Unrecognized device format, aborting..."
        exit 1
    }
    }
    print_info "Checking device $device"
    if ![file exists $device] {
        print_error "Device: $device does not exist, aborting..."
        exit 1
    }
#    print_info "Formatting device $device..."
#    exec sudo dd if=/dev/zero of=$device bs=4096 status=progress
    print_info "Creating boot & root partitions ($part1 & $part2)"
    syexec sudo parted $device --script -- mklabel msdos
    syexec sudo parted $device --script -- mkpart primary fat32 1MiB 128MiB
    syexec sudo parted $device --script -- mkpart primary ext4 128MiB 100%
    syexec sudo parted $device --script -- set 1 boot on
    syexec sudo parted $device --script -- set 1 lba on
    syexec sudo mkfs.vfat $part1
    syexec sudo mkfs.ext4 $part2
    syexec sudo parted $device --script print
    print_ok "Partitions successfully created!"
}

proc flash_check {device partition} {
    print_info "Checking device $device"
    if ![file exists $device] {
        print_error "Device: $device does not exist, aborting..."
        exit 1
    }
    print_info "Mounting partition"
    exec sudo mount $device /mnt
    print_info "Checking partition type"
    if [contains $partition [exec df -Th | grep $device]] {
        print_ok "Correct partition type ($partition)"
    } else {
        print_error "Incorrect partition type (should be $partition), aborting..."
        exec sudo umount /mnt
        exit 1
    }
}

proc flash_generic {device type} {
    variable target_dir ""
    print_info "Flashing $type partition on device $device"
    switch $device {
        /dev/mmcblk0 {
            set part1 "/dev/mmcblk0p1"
            set part2 "/dev/mmcblk0p2"
        }
        /dev/sda {
            set part1 "/dev/sda1"
            set part2 "/dev/sda2"
        }
        default {
            print_error "Unrecognized device format, aborting..."
            exit 1
        }
    }
    switch $type {
        boot {
            set device $part1
            set partition "vfat"
            set target_dir $::Linux::BUILD_OUTPUT_BOOT_DIR
        }
        root {
            set device $part2
            set partition "ext4"
            set target_dir $::Linux::BUILD_OUTPUT_ROOT_DIR
        }
        default {
            print_error "Something very wrong happened here"
            exit 1
        }
    }
    flash_check $device $partition
    print_info "Removing partition's contents"
    catch {file delete -force {*}[glob -directory /mnt *]} {}
    print_info "Copying new files..."
    foreach f [glob -directory $target_dir -nocomplain *] {
        print_info "Copying file/directory: [file tail $f]"
        file copy -force $f /mnt
    }
    print_info "Syncing..."
    exec sync
    print_info "Unmounting partition"
    exec sudo umount /mnt
    print_ok "$type partition succesfully flashed!"
}

proc flash_dsp {device} {
    switch $device {
    /dev/mmcblk0 {
        set root "/dev/mmcblk0p2"
    }
    /dev/sda {
        set root "/dev/sda2"
    }
    default {
        print_error "Unrecognized device format, aborting..."
        exit 1
    }
    }
    flash_check $root "ext4"
    print_info "Mounting partition"
    root_flash_dsp "/mnt"
    exec sudo umount /mnt
    print_ok "DSP build successfully flashed!"
}

proc flash_boot {device} {
    flash_generic $device "boot"
}

proc flash_root {device} {
    flash_generic $device "root"
}

}; # namespace Linux
