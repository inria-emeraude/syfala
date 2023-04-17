# -----------------------------------------------------------------------------
# ALPINE_LINUX BUILD
# -----------------------------------------------------------------------------

namespace eval Alpine {

set VERSION_MAJOR           3
set VERSION_MINOR           17
set VERSION_PATCH           0
set VERSION_DATE            20221214
set VERSION                 "$VERSION_MAJOR.$VERSION_MINOR"
set VERSION_FULL            "$VERSION.$VERSION_PATCH"
set BUILD_DIR               $::Linux::BUILD_ROOT_DIR/alpine-$VERSION_FULL
set BUILD_UBOOT_DIR         $BUILD_DIR/alpine-uboot
set BUILD_TOOLS_DIR         $BUILD_DIR/alpine-tools
set BUILD_ROOT_DIR          $BUILD_DIR/alpine-root
set BUILD_INITRAMFS_DIR     $BUILD_DIR/alpine-initramfs
set BUILD_INITRAMFS_SRC     $BUILD_UBOOT_DIR/boot/initramfs-lts
set BUILD_INITRAMFS_DST     $BUILD_INITRAMFS_DIR/initramfs-lts.gz
set TARGET_URL              "http://dl-cdn.alpinelinux.org/alpine/v$VERSION"
set TARGET_UBOOT            "alpine-uboot-$VERSION_FULL-armv7.tar.gz"
set TARGET_APK_TOOLS        "apk-tools-static-2.12.10-r1.apk"
set TARGET_FIRMWARE         "linux-firmware-other-$VERSION_DATE-r1.apk"

set INSTALL_APKS [list  \
    busybox-suid        \
    sudo                \
    openssh             \
    ucspi-tcp6          \
    iw                  \
    iwd                 \
    dhcpcd              \
    dnsmasq             \
    hostapd             \
    iptables            \
    avahi-dev           \
    dbus                \
    dcron               \
    chrony              \
    gpsd                \
    musl-dev            \
    libconfig-dev       \
    alsa-lib-dev        \
    alsa-utils          \
    alsaconf            \
    alsa-ucm-conf       \
    wget                \
    vim                 \
    emacs               \
    bc                  \
    patch               \
    make                \
    gcc                 \
    g++                 \
    liblo-dev           \
    libmicrohttpd-dev   \
    faust-dev           \
    libc6-compat        \
    linux-headers       \
    python3             \
    i2c-tools           \
    spi-tools           \
    autologin           \
    hwdata-usb          \
    usbutils            \
    util-linux          \
    eudev               \
    udev-init-scripts   \
    gzip                \
    procps-dev          \
    mingetty            \
]

set ADDITIONAL_FIRMWARE [list                       \
    linux-firmware-ath9k_htc-$VERSION_DATE-r1.apk   \
    linux-firmware-brcm-$VERSION_DATE-r1.apk        \
    linux-firmware-rtlwifi-$VERSION_DATE-r1.apk     \
]

set TARGET_UBOOT_URL $TARGET_URL/releases/armv7/$TARGET_UBOOT
set TARGET_APK_TOOLS_URL $TARGET_URL/main/armv7/$TARGET_APK_TOOLS
set TARGET_FIRMWARE_URL $TARGET_URL/main/armv7/$TARGET_FIRMWARE

proc download_unpack_sources {} {
    file mkdir $::Linux::Alpine::BUILD_DIR
    cd $::Linux::Alpine::BUILD_DIR
    # Download sources
    if ![file exists $::Linux::Alpine::TARGET_UBOOT] {
        print_info "Downloading alpine-linux u-boot archive"
        exec curl -o $::Linux::Alpine::TARGET_UBOOT             \
                  -L $::Linux::Alpine::TARGET_UBOOT_URL         \
                  >&@stdout
    }
    if ![file exists $::Linux::Alpine::TARGET_APK_TOOLS] {
        print_info "Downloading alpine-linux apk-tools archive"
        exec curl -o $::Linux::Alpine::TARGET_APK_TOOLS         \
                  -L $::Linux::Alpine::TARGET_APK_TOOLS_URL     \
                  >&@stdout
    }
    if ![file exists $::Linux::Alpine::TARGET_FIRMWARE] {
        print_info "Downloading alpine-linux firmware archive"
        exec curl -o $::Linux::Alpine::TARGET_FIRMWARE          \
                  -L $::Linux::Alpine::TARGET_FIRMWARE_URL      \
                  >&@stdout
    }
    # Unpack sources
    print_info "Unpacking alpine-linux archives"
    file mkdir $::Linux::Alpine::BUILD_UBOOT_DIR
    file mkdir $::Linux::Alpine::BUILD_TOOLS_DIR
    exec tar -zxf $::Linux::Alpine::TARGET_UBOOT               \
            --directory=$::Linux::Alpine::BUILD_UBOOT_DIR
    exec tar -zxf $::Linux::Alpine::TARGET_APK_TOOLS           \
            --directory=$::Linux::Alpine::BUILD_TOOLS_DIR      \
            --warning=no-unknown-keyword
    print_ok "Alpine archives succesfully unpacked"
}

proc generate_initramfs {} {
    print_info "Creating initramfs"
    file mkdir $::Linux::Alpine::BUILD_INITRAMFS_DIR
    cd $::Linux::Alpine::BUILD_INITRAMFS_DIR
    file copy -force $::Linux::Alpine::BUILD_INITRAMFS_SRC    \
                     $::Linux::Alpine::BUILD_INITRAMFS_DST
    catch {
        exec gzip -dc $::Linux::Alpine::BUILD_INITRAMFS_DST | cpio -id
    }
    file delete -force $::Linux::Alpine::BUILD_INITRAMFS_DST
    # remove kernel module configurations
    file delete -force "etc/modprobe.d"
    # remove kernel firmware (binary drivers)
    file delete -force "lib/firmware"
    # remove kernel modules
    file delete -force "lib/modules"
    # remove cache
    file delete -force "var"
    # Repack initramfs
    exec find . | sort | cpio --quiet -o -H newc | gzip -9 > ../initrd.gz
    # exit
    cd ..
    print_ok "initramfs successfully created"
}

set MODULES_DIR $BUILD_DIR/alpine-modloop/lib/modules/$::Linux::VERSION
set MODULES_KERNEL_DIR $MODULES_DIR/kernel

proc generate_modloop {} {
    # look for all .ko files in the kernel and copy them to the new location
    # This command looks for all .ko files, sets user and group to 0
    # and copies them to target location
    print_info "Generating u-boot image"
    exec mkdir -p $::Linux::Alpine::MODULES_KERNEL_DIR
    cd $::Linux::BUILD_KERNEL_DIR
    print_info "Collecting Loadable Kernel Modules"
    exec find . -name "*.ko" |                          \
         tar -zcf modules -T - --owner=0 --group=0      \
         >&@stdout
    cd $::Linux::Alpine::MODULES_KERNEL_DIR
    exec tar -zxf $::Linux::BUILD_KERNEL_DIR/modules
    # Copy the modules order and builtin files to the destination
    print_info "Copying module files from Kernel"
    file copy -force $::Linux::BUILD_KERNEL_DIR/modules.builtin \
                     $::Linux::Alpine::MODULES_DIR
    file copy -force $::Linux::BUILD_KERNEL_DIR/modules.builtin.modinfo \
                     $::Linux::Alpine::MODULES_DIR
    file copy -force $::Linux::BUILD_KERNEL_DIR/modules.order \
                     $::Linux::Alpine::MODULES_DIR
    # From the copied kernel modules we generate modules.dep and map files
    cd $::Linux::Alpine::BUILD_DIR
    print_info "Executing depmod"
    exec depmod -a -b alpine-modloop $::Linux::VERSION
    # ---------------------
    # Alpine kernel modules
    # ---------------------
    # copy all ar* files
    # copy all rt* files
    print_info "Collecting Kernel Modules for modloop"
    exec tar -zxf $::Linux::Alpine::TARGET_FIRMWARE         \
             --directory=alpine-modloop/lib/modules         \
             --warning=no-unknown-keyword                   \
             --strip-components=1                           \
             --wildcards lib/firmware/ar* lib/firmware/rt*

    # Download and unpack additional firmware
    foreach fw $::Linux::Alpine::ADDITIONAL_FIRMWARE {
        set url $::Linux::Alpine::TARGET_URL/main/armv7/$fw
        if ![file exists $fw] {
            print_info "Downloading additional firmware: $url"
            exec curl -L $url -o $fw >&@stdout
        }
        exec tar -zxf $fw --directory=alpine-modloop/lib/modules \
                 --warning=no-unknown-keyword \
                 --strip-components=1
    }
    # Pack kernel modules and firmware into a squashfs using xz compression
    print_info "Packing kernel modules and firmware into squashfs using xz compression"
    if [file exists modloop] {
        file delete -force modloop
    }
    exec mksquashfs alpine-modloop/lib modloop -b 1048576 -comp xz -Xdict-size 100%
    print_ok "Packing complete"
}

proc chroot_sh {args} {
    exec sudo chroot $::Linux::Alpine::BUILD_ROOT_DIR "/bin/sh" -c $args >&@stdout
}

proc generate_rootfs {} {
    print_info "Now creating root-filesystem (rootfs)"
    # Create required subdirectories
    set root $::Linux::Alpine::BUILD_ROOT_DIR
    file mkdir $root/usr/bin
    file mkdir $root/etc
    file mkdir $root/etc/apk
    # Copy alpine binary and qemu arm CPU emulator to install alpine.
    # For the chroot environment to find the alpine servers our hosts resolv
    # config is copied
    exec cp -r alpine-tools/sbin $root
    exec cp -r /usr/bin/qemu-arm-static $root/usr/bin
    # On systemd systems, apparently the stub-resolv.conf file
    # is the one that works for some reason...
    print_info "Setting up network configuration"
    if [file exists /run/systemd/resolve/stub-resolv.conf] {
        exec cp -r /run/systemd/resolve/stub-resolv.conf $root/etc/resolv.conf
    } else {
        exec cp -r /etc/resolv.conf $root/etc/resolv.conf
    }
    # We now install alpine by running apk.static in a chroot
    # - apk is the alpine packet manager
    # --repository $alpine_url/main tells apk which repository to use
    # --update-cache does what it says it does
    # --allow-untrusted, even unsigned packages
    # --initdb undocumented
    # and alpine-base tells apk to install the alpine base system
    # Note: required on archlinux: yay -S qemu-user-static qemu-user-static-binfmt
    print_info "Installing alpine-base package"
    exec sudo chroot $root "/sbin/apk.static"                   \
                --repository $::Linux::Alpine::TARGET_URL/main  \
                --update-cache                                  \
                --allow-untrusted                               \
                --initdb                                        \
                add alpine-base                                 \
          >&@stdout
    print_ok "alpine-base package succesfully installed!"    
    print_info "Copying modules directory"
    exec sudo cp -r alpine-modloop/lib $root
    exec sudo cp -r alpine-modloop/lib/modules/firmware $root/lib
}

proc setup_repositories {} {
    chroot_sh echo $::Linux::Alpine::TARGET_URL/main                        \
                >> etc/apk/repositories
    chroot_sh echo $::Linux::Alpine::TARGET_URL/community                   \
                >> etc/apk/repositories
    chroot_sh echo "http://dl-cdn.alpinelinux.org/alpine/edge/main"         \
                >> etc/apk/repositories
    chroot_sh echo "http://dl-cdn.alpinelinux.org/alpine/edge/community"    \
                >> etc/apk/repositories
    chroot_sh echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing"      \
                >> etc/apk/repositories
    print_ok "Registered Alpine 'main', 'community' & 'testing' repositories"
}

proc install_packages {} {
    set pkgs [join $::Linux::Alpine::INSTALL_APKS]
    print_info "Installing the following packages: $pkgs"
    chroot_sh /sbin/apk update
    chroot_sh /sbin/apk add {*}$pkgs
}

proc register_processes {} {
    print_info "Registering OpenRC processes"
    # Register OpenRC processes for boot
    chroot_sh /sbin/rc-update add bootmisc boot
    chroot_sh /sbin/rc-update add hostname boot
    chroot_sh /sbin/rc-update add hwdrivers boot
    #    chroot_sh /sbin/rc-update add modloop boot
    chroot_sh /sbin/rc-update add modules boot
    chroot_sh /sbin/rc-update add swclock boot
    chroot_sh /sbin/rc-update add hwclock boot
    chroot_sh /sbin/rc-update add sysctl boot
    chroot_sh /sbin/rc-update add syslog boot
    chroot_sh /sbin/rc-update add seedrng boot
    # Register OpenRC processes for shutdown
    chroot_sh /sbin/rc-update add killprocs shutdown
    chroot_sh /sbin/rc-update add mount-ro shutdown
    chroot_sh /sbin/rc-update add savecache shutdown
    # Register OpenRC processes for system initialization
    chroot_sh /sbin/rc-update add devfs sysinit
    chroot_sh /sbin/rc-update add dmesg sysinit
    chroot_sh /sbin/rc-update add mdev sysinit
    # Register default OpenRC processes
    chroot_sh /sbin/rc-update add avahi-daemon default
    chroot_sh /sbin/rc-update add chronyd default
    chroot_sh /sbin/rc-update add dhcpcd default
    chroot_sh /sbin/rc-update add local default
    chroot_sh /sbin/rc-update add dcron default
    chroot_sh /sbin/rc-update add sshd default
    chroot_sh /sbin/rc-update add alsa default
    chroot_sh /sbin/rc-update add iwd default
    # Overwriting inittab to activate PS0 console
    print_info "Overwriting /etc/inittab starting configuration"
    exec sudo cp -r $::Linux::LINUX_SOURCES/alpine-root/inittab alpine-root/etc/inittab
    print_info "Adding snd-seq kernel module autoload"
    chroot_sh echo "snd-seq" >> /etc/modules
}

proc setup_users_permissions {} {
    # Setup hostname and passwords
    print_info "Setting up users and permissions"
    chroot_sh sed -i {'s/^SAVE_ON_STOP=.*/SAVE_ON_STOP="no"/;s/^IPFORWARD=.*/IPFORWARD="yes"/'} "etc/conf.d/iptables"
    chroot_sh sed -i {'s/^#PermitRootLogin.*/PermitRootLogin yes/'} "etc/ssh/sshd_config"
    chroot_sh echo "root:syfala" | /usr/sbin/chpasswd
    chroot_sh /sbin/setup-hostname syfala
    chroot_sh echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
    catch { chroot_sh /usr/sbin/adduser -h /home/syfala -s /bin/ash syfala } {}
    catch { chroot_sh /usr/sbin/adduser syfala wheel } {}
    chroot_sh chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo
    # Allow ttyPS0 to login as root
    chroot_sh echo ttyPS0 >> /etc/securetty
    print_info "Adding users to 'audio' group"
    chroot_sh /usr/sbin/addgroup syfala audio
    chroot_sh /usr/sbin/addgroup root audio
}

proc install_utilities {} {
    # Copy bitstream and application, fpgautil and
    # bit-to-bin python script
    set root $::Linux::Alpine::BUILD_ROOT_DIR
    print_info "Copying FPGA bitstream, application and utilities"
    set fpga_files $::Linux::LINUX_SOURCES/files
    exec sudo cp -r $fpga_files/fpgautil.c $root/home/syfala
    exec sudo cp -r $fpga_files/fpga-bit-to-bin.py $root/home/syfala
    exec sudo cp -r $fpga_files/syfala-load.c $root/home/syfala
    # Compile fpgautil.c with gcc and install it in /usr/bin
    print_info "Compiling fpgautil.c with gcc"
    chroot_sh gcc /home/syfala/fpgautil.c -o /usr/bin/fpgautil
    chroot_sh rm -rf /home/syfala/fpgautil.c
    print_info "Compiling syfala-load.c with gcc"
    chroot_sh gcc -O3 /home/syfala/syfala-load.c -o /usr/bin/syfala-load -lprocps
    chroot_sh rm -rf /home/syfala/syfala-load.c
}

proc check_root_build {} {
    if ![file exists $::Linux::Alpine::BUILD_ROOT_DIR] {
        if [file exists $::Linux::BUILD_OUTPUT_ROOT_DIR/bin] {
            set ::Linux::Alpine::BUILD_ROOT_DIR $::Linux::BUILD_OUTPUT_ROOT_DIR
            print_info "Found root build in $::Linux::Alpine::BUILD_ROOT_DIR"
        } else {
            print_error "No current root build directory could be found, aborting..."
            exit 1
        }
    }
}

proc update_bitstream {} {    
    check_root_build
    set root $::Linux::Alpine::BUILD_ROOT_DIR
    set dsp [Syfala::get_dsp_name]
    file mkdir $root/home/syfala/$dsp
    exec sudo cp -r $::Syfala::BUILD_BITSTREAM_TARGET $root/home/syfala/$dsp
    print_info "Converting bitstream to .bin with python script"
    chroot_sh python3 "/home/syfala/fpga-bit-to-bin.py"     \
                    -f /home/syfala/$dsp/system.bit         \
                       /home/syfala/$dsp/bitstream.bin
    chroot_sh rm -rf /home/syfala/$dsp/system.bit
}

proc build_app {} {        
    check_root_build
    set root $::Linux::Alpine::BUILD_ROOT_DIR
    set dsp [Syfala::get_dsp_name]
    # Copy application files and run gcc
    print_info "Copying Host application files"
    file mkdir $root/home/syfala/$dsp/src/include
    fcp $::Syfala::BUILD_INCLUDE_DIR            \
        $root/home/syfala/$dsp/src/include
    fcp $::Syfala::BUILD_XSOURCES_DIR           \
        $root/home/syfala/$dsp/src
    fcp $::Syfala::HOST_LINUX_SOURCES           \
        $root/home/syfala/$dsp/src
    fcp $::Syfala::SOURCE_DIR/arm/faust         \
        $root/home/syfala/$dsp/src
    print_info "Compiling Host Application"
    chroot_sh make -C /home/syfala/$dsp/src -j8 EXECUTABLE=../application.elf
}

proc flash_dsp {dst} {
    check_root_build
    set dsp [Syfala::get_dsp_name]
    set root $::Linux::Alpine::BUILD_ROOT_DIR
    print_info "Deleting previous build ($dst/home/syfala/$dsp)"
    exec sudo rm -rf $dst/home/syfala/$dsp
    print_info "Copying new build..."
    exec sudo cp -r $root/home/syfala/$dsp \
                     $dst/home/syfala/$dsp
}

proc build {} {
    download_unpack_sources
    generate_initramfs
    generate_modloop
    generate_rootfs
    setup_repositories
    install_packages
    register_processes
    setup_users_permissions
    install_utilities
    update_bitstream
    build_app
    print_ok "Alpine Linux build ($::Linux::Alpine::VERSION_FULL) succesfully generated!"
    if [file exists $::Linux::BUILD_OUTPUT_ROOT_DIR] {
        exec sudo rm -rf $::Linux::BUILD_OUTPUT_ROOT_DIR
    }
    exec sudo mv $::Linux::Alpine::BUILD_ROOT_DIR $::Linux::BUILD_OUTPUT_ROOT_DIR
}
}
