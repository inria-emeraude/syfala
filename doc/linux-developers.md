# syfala-linux (developers)

## Status

#### Boards

- [x] Support for **Zybo-Z710** & **Z720** boards
- [ ] Support for **Genesys** board

#### Peripherals & drivers

- [x] **Ethernet**/**network**
  - [ ] Ethernet-based streaming i/o (AVB?)

- [x] **IIC-0** (SSM2603)
- [ ] **IIC-1** (external codecs)
- [ ] Serial Peripheral Interface (**SPI**)
  - [x] **spidev** device identification (mcp3008)
  - [ ] /!\ **jitter/noise issues**

- [x] Shared/reserved **DDR** **memory**
  - [ ] DMA (cache bypass)

- [x] GPIO **LEDs** interface
- [x] GPIO **SWs** interface
- [ ] **Internal codecs ALSA** support
- [ ] **External codecs ALSA** support

#### Control

- [x] **MIDI** support
- [x] Open Sound Control (**OSC**) support
  
- [ ] OSCQuery support
  - [ ] **TUI** OSC support?

- [x] **HTTP** support

#### Misc.

- [ ] Soundfiles

- [ ] **Device-tree overlays** (DTO)

- [x] **On-device** application **compilation**
  
- [x] Wi-Pi (Ralink 5370 Wi-Fi USB Dongle)

- [x] Avahi support

# details on the build procedure

The `syfala.tcl` main script, after receiving the `build-linux` or `build-linux boot` command, will call the `build_boot` procedure in the file `scripts/linux/build.tcl`. 

It will first create all the necessary **build** **subdirectories**: 

```
# build-linux 
# |---| boot (all boot-related build files)
# |	  |---| u-boot
# |	  |---| kernel
# |	  |---| device-tree
# |---| output (copies of all required files for boot partition)
# |	  |---| boot
# |---| root
```

The script then takes care of all the following build procedures.

```shell
$ syfala linux build
```

- it will build both **boot** and **root** partition contents to be transferred to an external **SD** card

#### Building or re-building boot & root partitions separately

You can also build/update the boot & root partitions **separately** with the following commands: 

```shell
$ syfala linux build boot
```

this will only build **boot** partition's contents. These subcommands are also available:

- `syfala linux build uboot` - recompiles and exports uboot
- `syfala linux build kernel` - recompiles and exports kernel image & modules
- `syfala linux build device-tree` - recompiles and exports device-tree

```shell
$ syfala linux build root
```

this will only build **root** partition's contents. These subcommands are also available:

- `syfala linux build dsp` - **re-builds the app** and update the **bitstream** in the **root partition**
- `syfala linux build app` - only **re-builds the app**

## boot

### Build steps

#### 1. Cloning and compiling Xilinx' u-boot repository 

https://github.com/Xilinx/u-boot-xlnx

*branch/tag xilinx-v2022.2*

It will generate the **First Stage Boot Loader** (FSBL), and the **Secondary Program Loader** (SPL) included in the main '*boot.bin*' binary and the *u-boot.img* image.

##### Outputs:

- *boot.bin*
- *spl/u-boot.img*

#### 2. Cloning and Compiling Xilinx' custom Linux Kernel repository (tag xilinx-v2022.2)

https://github.com/Xilinx/linux-xlnx

*branch/tag xilinx-v2022.2*

This modified Kernel comes shipped with custom **Xilinx drivers**, and some **pre-configured options**. We add to that a **custom configuration file**, located in *source/linux/configs/zybo_z7_defconfig*, with the following options:

##### UIO-related

| Option                   | Value            | Description                                                  | Comments |
| ------------------------ | ---------------- | ------------------------------------------------------------ | -------- |
| `CONFIG_UIO`             | **Y** (activate) | allows userspace i/o communication with the **syfala ip** (including generic interrupt handling code) |          |
| `CONFIG_UIO_PDRV_GENIRQ` | **Y**            |                                                              |          |

##### SPI-related

| Option               | Value            | Description                                                  | Comments |
| -------------------- | ---------------- | ------------------------------------------------------------ | -------- |
| `CONFIG_SPI_MASTER`  | **Y** (activate) |                                                              |          |
| `CONFIG_SPI_CADENCE` | **Y**            | xilinx's own **spi_master** drivers                          |          |
| `CONFIG_SPI_SPIDEV`  | **Y**            | generic **spidev** drivers for communication with the **SPI0 bus** **slave** (MCP3008 ADC) |          |

##### Sound-related (ALSA)

| Option                                      | Value              | Description | Comments                        |
| ------------------------------------------- | ------------------ | ----------- | ------------------------------- |
| `CONFIG_SOUND`                              | **M** (module)     |             | required                        |
| `CONFIG_SOUND_OSS_CORE`                     | **N** (deactivate) |             |                                 |
| `CONFIG_SND`                                | **M**              |             | required                        |
| `CONFIG_SND_DRIVERS`                        | **Y** (activate)   |             | required                        |
| `CONFIG_SND_MAX_CARDS`                      | 32                 |             |                                 |
| `CONFIG_SND_DYNAMIC_MINORS`                 | **Y**              | ?           |                                 |
| `CONFIG_SND_DEBUG`                          | **Y**              |             |                                 |
| `CONFIG_SND_PCM`                            | **M**              |             |                                 |
| `CONFIG_SND_USB`                            | **Y**              |             | required                        |
| `CONFIG_SND_USB_AUDIO`                      | **M**              |             | required                        |
| `CONFIG_SND_USB_AUDIO_USE_MEDIA_CONTROLLER` | **Y**              |             | ?                               |
| `CONFIG_SND_MIXER_OSS`                      | **N**              |             |                                 |
| `CONFIG_SND_PCM_OSS`                        | **N**              |             |                                 |
| `CONFIG_SND_SUPPORT_OLD_API`                | **N**              |             |                                 |
| `CONFIG_SND_DUMMY`                          | **M**              |             | optional                        |
| `CONFIG_SND_TIMER`                          | **M**              |             |                                 |
| `CONFIG_SND_HRTIMER`                        | **M**              |             |                                 |
| `CONFIG_SND_SIMPLE_CARD`                    | **M**              |             |                                 |
| `CONFIG_SND_SIMPLE_CARD_UTILS`              | **M**              |             |                                 |
| `CONFIG_SND_HWDEP`                          | **M**              |             |                                 |
| `CONFIG_SND_RAWMIDI`                        | **M**              |             | required for faust midi control |
| `CONFIG_SND_VIRMIDI`                        | **M**              |             | optional                        |
| `CONFIG_SND_SEQUENCER`                      | **M**              |             | required for faust midi control |
| `CONFIG_SND_SEQUENCER_OSS`                  | **N**              |             |                                 |
| `CONFIG_SND_SEQ_DUMMY`                      | **M**              |             |                                 |
| `CONFIG_SND_SEQ_DEVICE`                     | **M**              |             | required for faust midi control |
| `CONFIG_SND_SEQ_MIDI_EVENT`                 | **M**              |             | required (?)                    |
| `CONFIG_SND_SEQ_MIDI`                       | **M**              |             | required for faust midi control |
| `CONFIG_SND_SEQ_MIDI_EMUL`                  | **M**              |             | ?                               |
| `CONFIG_SND_SEQ_VIRMIDI`                    | **M**              |             |                                 |
| `CONFIG_SND_SEQ_HRTIMER_DEFAULT`            | **Y**              |             | ?                               |
| `CONFIG_SND_DMAENGINE_PCM`                  | **M**              |             | ?                               |

##### WLAN-related (Wi-Pi example)

| Option                            | Value            | Description            | Comments         |
| --------------------------------- | ---------------- | ---------------------- | ---------------- |
| `CONFIG_WLAN`                     | **Y** (activate) |                        |                  |
| `CONFIG_WLAN_VENDOR_RALINK`       | **Y**            |                        |                  |
| `CONFIG_NL80211`                  | **Y**            |                        |                  |
| `CONFIG_NL80211_TESTMODE`         | **Y**            |                        |                  |
| `CONFIG_RT2X00`                   | **Y**            | for Ralink USB drivers |                  |
| `CONFIG_HAS_DMA`                  | **Y**            |                        |                  |
| `CONFIG_RT2800USB`                | **M** (module)   | for Ralink USB drivers |                  |
| `CONFIG_RT2800USB_RT33XX`         | **Y**            |                        |                  |
| `CONFIG_RT2800USB_RT35XX`         | **Y**            |                        |                  |
| `CONFIG_RT2800USB_RT3573`         | **Y**            |                        |                  |
| `CONFIG_RT2800USB_RT53XX`         | **Y**            | for Wi-Pi              |                  |
| `CONFIG_RT2800USB_RT55XX`         | **Y**            |                        |                  |
| `CONFIG_RT2800USB_UNKNOWN`        | **Y**            |                        |                  |
| `CONFIG_RT2800_LIB`               | **M**            |                        |                  |
| `CONFIG_RT2800_LIB_MMIO`          | **M**            |                        |                  |
| `CONFIG_RT2X00_LIB_MMIO`          | **M**            |                        |                  |
| `CONFIG_RT2X00_LIB_PCI`           | **M**            |                        |                  |
| `CONFIG_RT2X00_LIB_USB`           | **M**            |                        |                  |
| `CONFIG_RT2X00_LIB`               | **M**            |                        |                  |
| `CONFIG_RT2X00_LIB_FIRMWARE`      | **Y**            |                        |                  |
| `CONFIG_RT2X00_LIB_CRYPTO`        | **Y**            |                        |                  |
| `CONFIG_RT2X00_LIB_LEDS`          | **Y**            |                        |                  |
| `CONFIG_CFG80211`                 | **Y**            |                        |                  |
| `CONFIG_CFG80211_WEXT`            | **Y**            |                        |                  |
| `CONFIG_MAC80211`                 | **Y**            |                        |                  |
| `CONFIG_KEY_DH_OPERATIONS`        | **Y**            |                        |                  |
| `CONFIG_RFKILL`                   | **Y**            |                        |                  |
| `CONFIG_CRYPTO_USER_API_HASH`     | **Y**            |                        |                  |
| `CONFIG_CRYPTO_USER_API_SKCIPHER` | **Y**            |                        |                  |
| `CONFIG_CRYPTO_ECB`               | **Y**            |                        |                  |
| `CONFIG_CRYPTO_MD4`               | **Y**            |                        | required for iwd |
| `CONFIG_CRYPTO_MD5`               | **Y**            |                        |                  |
| `CONFIG_CRYPTO_CBC`               | **Y**            |                        |                  |
| `CONFIG_CRYPTO_SHA256`            | **Y**            |                        |                  |
| `CONFIG_CRYPTO_AES`               | **Y**            |                        |                  |
| `CONFIG_CRYPTO_DES`               | **Y**            |                        |                  |
| `CONFIG_CRYPTO_CMAC`              | **Y**            |                        |                  |
| `CONFIG_CRYPTO_HMAC`              | **Y**            |                        |                  |
| `CONFIG_CRYPTO_SHA512`            | **Y**            |                        |                  |
| `CONFIG_CRYPTO_SHA1`              | **Y**            |                        |                  |
| `CONFIG_CRYPTO_SHA1_SSSE3`        | **Y**            |                        |                  |
| `CONFIG_CRYPTO_AES_NI_INTEL`      | **Y**            |                        |                  |
| `CONFIG_CRYPTO_SHA512_SSSE3`      | **Y**            |                        |                  |
| `CONFIG_CRYPTO_AES_X86_64`        | **Y**            |                        |                  |
| `CONFIG_CRYPTO_DES3_EDE_X86_64`   | **Y**            |                        |                  |
| `CONFIG_CRYPTO_SHA256_SSSE3`      | **Y**            |                        |                  |

**Outputs**

- *uImage*
- **Kernel modules** (*see rootfs section*)

#### 3. Building the device-tree from static sources

Sources in: [source/linux/device-tree/system.dts](../source/linux/device-tree/system.dts)

Due to the difficulties encountered with generating a proper and correct device-tree with the **Xilinx tools**, we use (for now) a **static device-tree source file** that has been modified by hand in order to facilitate the procedure.

##### Modifications:

- **boot arguments** (*bootargs*)

Here, we have to specify - among other things - the location of the **rootfs** partition (*/dev/mmcblk0p2*) and its type (*ext4*). 

```bash
bootargs = "earlycon uio_pdrv_genirq.of_id=generic-uio root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait";
```

- **reserved memory** 

**128Mo** of memory are here reserved for the **syfala IP**, starting at address *0x35000000*.

**Note**: *0x38000000* address was originally chosen, but it seems in the **2022.2 version** of Xilinx' custom kernel (*5.15.0-xilinx*) that it's somehow already used/reserved for another purpose (CMA?), warning us at boot-time that the memory range cannot be reserved.

```shell
reserved-memory {
    #address-cells = <1>;
    #size-cells = <1>;
    ranges;
    reserved: buffer@35000000 {
        no-map;
        reg = <0x35000000 0x08000000>;
    };
};
reserved-driver@0 {
    compatible = "xlnx,reserved-memory";
	memory-region = <&reserved>;
};
```

- **SPI-0**

The **SPI Master** device uses Xilinx's own **cadence** drivers (*spi-cadence.c*)

We had to **add slave peripherals** as children of the master device. For instance, here it communicates with the **MCP3008**'s SPI controller with a maximum throughput frequency of 1 MHz.

The *compatible* property has to be registered as a peripheral explicitly supported by the **spidev linux driver** (here, *lwn-bk4*, it can be anything as long as it's listed in *spidev.c*), otherwise, it won't be instantiated as an accessible device (**/dev/spidev0.0** in our case) 

```shell
        spi0: spi@e0006000 {
			compatible = "cdns,spi-r1p6"";
            reg = <0xe0006000 0x1000>;
            status = "okay";
            interrupt-parent = <&intc>;
            interrupts = <0 26 4>;
            clocks = <&clkc 25>, <&clkc 34>;
            clock-names = "ref_clk", "pclk";
            #address-cells = <1>;
            #size-cells = <0>;
            is-decoded-cs = <0>;
            num-cs = <3>;
			slave@0 {
				compatible = "lwn,bk4";
				reg = <0>;
				spi-max-frequency = <1000000>;
			}; 
```

**Note**: the way the driver sets the **prescaler** is the following: 

* It fetches master's '*speed_hz*' property, compares it with the slave's. If it is different, it will add automatically add an appropriate **prescaler** to get master's frequency **below the slave's max-frequency**. We don't have to set it ourselves. But there still seems like we have some sort of **jitter/clocking issues** at play here

- **clock-wizard**

**Note:** for reasons not yet fully understood, the **clock-wizard** (*misc_clk_0*) has to be moved out of *amba_pl*, otherwise the connections to its peripherals are not properly established.

```shell
   misc_clk_0: misc_clk_0 {
        #clock-cells = <0>;
        clock-frequency = <122885835>;
        compatible = "fixed-clock";
    };
    amba_pl: amba_pl {
        #address-cells = <1>;
        #size-cells = <1>;
        compatible = "simple-bus";
        ranges ;
[...]
```

- **syfala IP**

For the initialization and the axilite communication to work properly, the IP has to be registered as a "*generic-uio*" device. It will then be accessible as */dev/uio0* in our case.

https://www.kernel.org/doc/html/v4.11/driver-api/uio-howto.html

```shell
        syfala: syfala@40010000 {
            clock-names = "ap_clk";
            clocks = <&misc_clk_0>;
            compatible = "generic-uio";       
            status = "okay";
            reg = <0x40010000 0x10000>;
            xlnx,s-axi-control-addr-width = <0x7>;
            xlnx,s-axi-control-data-width = <0x20>;
        };
```

##### Outputs

- *system.dtb*

#### 4. Generate (sign) the Boot script file 

It will indicate to **u-boot** the proper commands to execute and the binaries to load when booting.

```shell
fatload ${devtype} ${devnum}:${distro_bootpart} 0x00200000 uImage;
fatload ${devtype} ${devnum}:${distro_bootpart} 0x00e00000 system.dtb;
fatload ${devtype} ${devnum}:${distro_bootpart} 0x4000000 system.bit
fpga loadb 0 0x4000000 ${filesize}
bootm 0x00200000 - 0x00e00000
exit;
```

##### Outputs

- *boot.scr*

### Boot partition contents

Once all targets have been build, all the files of interest can be found in :

*build-linux/output/boot*. It should contain **the following files**:

- *bitstream.bit* (copied from *build/hw_export*)
- *boot.bin* (embedding the **FSBL**)
- *u-boot.img* (embedding the **SPL**)
- *boot.scr* (**boot script**)
- *system.dtb* (**device-tree** blob/binary)
- *uImage* (**kernel** image)

All of these files can now be copied to the **SD card's** first (**FAT32**) **partition**.

## root-filesystem (rootfs)

For the *rootfs*, we chose (for now) a custom Alpine linux distribution, known to be lightweight, not relying on *gcc* and *systemd*, but instead on *musl*, *busybox* and *OpenRC* (https://en.wikipedia.org/wiki/Alpine_Linux).

**Current version**: **3.17.0-armv7**

### Build steps

The script in charge of building the *rootfs* is located in [scripts/linux/root/alpine.tcl](../scripts/linux/root/alpine.tcl). It is called by the main [scripts/linux/build.tcl](../scripts/linux/build.tcl) script. 

#### 1. Downloading and unpacking sources

First, the script downloads the Alpine sources from the official repository. It consists in 3 different compressed files: 

- the **u-boot archive** (uncompressed in build-linux/root/alpine-alpine-3.17.0/alpine-uboot)
  - **NOTE**: (**unused** at the moment)
  - https://dl-cdn.alpinelinux.org/alpine/releases/armv7/alpine-uboot-3.17.0-armv7.tar.gz
- the **apk-tools archive**
  - needed for the base package installation 
  - https://dl-cdn.alpinelinux.org/alpine/main/armv7/apk-tools-static-2.12.9-r3.apk
- the **linux-firmware archive**
  - https://dl-cdn.alpinelinnux.org/alpine/main/armv7/linux-firmware-other-20220509-r1.apk

#### 2. Collect kernel modules

Some Linux Kernel modules are built as *loadable modules*, meaning they can be loaded/unloaded at **runtime**, depending on the user's needs. We gather them and copy them in *build-linux/root/alpine-3.17.0/alpine-modloop* (more on modloop **TODO**), they will be loaded from the rootfs in the directory  */lib/modules/kernel/5.15.0-xilinx*.

#### 3. Creating rootfs structure and contents

- Create required **subdirectories**:
  - */usr/bin*
  - */etc*
  - */etc/apk*
- Copy **alpine-apk-tools** binaries into */sbin*
- Copy **qemu arm CPU emulator** to install *alpine* as **chroot**
- Copy **host resolving configuration** for the *chroot* environment to find the alpine-linux servers
  - on *systemd* systems, apparently the *stub-resolv.conf* file is the one that works.
- **Copy the linux kernel loadable .ko modules** in */lib/modules*
- **Copy the linux firmwares** in */lib/firmware*
- **Install** the *alpine-base* package by running */sbin/apk.static* within a *chroot* (**apk** is the alpine-linux **package manager**).
- **Write alpine repositories' URL** in the file */etc/apk/repositories*
- **Install** all packages listed below (*Installed packages (apk) section*).
- **Register OpenRC processes** (similar to *systemd*)
- **Overwrite** *inittab* starting configuration file with a custom one
- **Add ** *snd-seq* (alsa sequencer) to the list of modules to be loaded on startup (otherwise it won't get loaded automatically).
- **Setup hostname, users and passwords**
  - we usually have to **login as root** (pwd: **syfala**) 
  - we have to allow *ttyPS0* to login as root as well, by adding it to the */etc/securetty* file
- **Add root & syfala** to the 'audio' group

#### 4. Install syfala-related files and applications

-  Copy **bitstream** and **host-side application**
-  Copy **fpgautil.c**, **syfala-load.c** and the **fpga-bit-to-bin** python script
-  **Compile** *fpgautil.c* and install it in */usr/bin*
-  **Compile** *syfala-load.c* and install it in */usr/bin*
-  **Convert** bitstream .bit to .bin with the help of the python script.
-  **Install alpine faust package**.
-  **Copy and compile ** host application files, using the Makefile

The **rootfs** is now ready and moved to the *build-linux/output/root* directory, ready to be flashed on the **second partition** of the **SD card**.

### Installed packages (apk)

All the following packages are currently installed in the *rootfs* when building is complete. The table below has been made to keep track of the packages, their status, relevance...

| name/category      | description                                                  | flag  | comments                                                     |
| ------------------ | ------------------------------------------------------------ | ----- | ------------------------------------------------------------ |
| *alpine-base*      | meta-package for minimal alpine base                         | **Y** | **required**                                                 |
| **admin**          |                                                              |       |                                                              |
| *sudo*             |                                                              | ?     | Might not need it if we do everything as root?               |
| *busybox-suid*     |                                                              | ?     | ^                                                            |
| **network**        |                                                              |       |                                                              |
| openssh            |                                                              | **Y** | **required**                                                 |
| ucspi-tcp6         | IPv6 enabled ucspi-tcp superserver                           | ?     |                                                              |
| iw                 | nl80211 based CLI configuration utility for wireless devices | ?     |                                                              |
| iwd                |                                                              | **Y** | required for wlan                                            |
| ~~wpa_supplicant~~ | utility providing key negotiation for WPA wireless networks  | ?     | replaced by iwd                                              |
| dhcpcd             | RFC2131 compliant DHCP client                                | **Y** |                                                              |
| dnsmasq            | A lightweight DNS, DHCP, RA, TFTP and PXE server             | **Y** |                                                              |
| hostapd            | daemon for wireless software access points                   | ?     |                                                              |
| iptables           | Linux kernel firewall, NAT and packet mangling tools         | ?     |                                                              |
| avahi              |                                                              | **Y** | Might be good to have an auto-connect/query system with OSC or something else... |
| wget               |                                                              | ?     | Is there really a need to ship it?                           |
| **system**         |                                                              |       |                                                              |
| dbus               | Freedesktop.org message bus system                           | ?     |                                                              |
| dcron              | dillon's lightweight cron daemon                             | ?     |                                                              |
| chrony             | NTP client and server programs                               | ?     |                                                              |
| gpsd               | GPS daemon                                                   | ?     |                                                              |
| musl-dev           | the musl c library (libc) implementation (development files) | ?     |                                                              |
| libconfig-dev      | A simple library for manipulating structured configuration files | ?     |                                                              |
| **audio/control**  |                                                              |       |                                                              |
| alsa-lib-dev       |                                                              | ?     | Useless at the moment                                        |
| alsa-utils         |                                                              | ?     | ^                                                            |
| alsaconf           |                                                              | ?     |                                                              |
|                    |                                                              |       |                                                              |
| liblo-dev          | Open Sound Control protocol implementation for POSIX systems | **Y** | Keep it for Faust control application                        |
| libmicrohttpd-dev  |                                                              | **Y** | Remote Faust HTTP control                                    |
| **development**    |                                                              |       |                                                              |
| bc                 | An arbitrary precision numeric processing language (calculator) | ?     |                                                              |
| patch              | Utility to apply diffs to files                              | ?     |                                                              |
| make               |                                                              | **Y** | **required** (on-device host application compilation)        |
| gcc                |                                                              | **Y** | **required** ^                                               |
| g++                |                                                              | **Y** | **required** ^                                               |
| libc6-compat       | compatibility libraries for glibc                            | ?     | ?                                                            |
| linux-headers      |                                                              | **Y** | **required** for host application                            |
| python3            |                                                              | **Y** | **required** for fpga-bit-to-bin.py script                   |
| **utilities**      |                                                              |       |                                                              |
| vim                |                                                              | ?     |                                                              |
| emacs              |                                                              | **Y** | for Tanguy ;)                                                |
| i2c-tools          |                                                              | **Y** | really useful for i2c-device probing                         |
| spi-tools          |                                                              | **Y** | same, but for spi-device probing                             |
| faust-dev          |                                                              | **Y** | used for linking with OSC and HTTP control libraries         |
| autologin          |                                                              | **O** | self-explanatory                                             |
| hwdata-usb         |                                                              | **Y** | useful for `lsusb` and peripheral debug                      |
| usbutils           |                                                              | **Y** | ^                                                            |

## Userspace application 

### Communication with the faust dsp fpga block (IP)

- source file: *arm/linux/ip.cpp*

The initialization is pretty straightforward, all the drivers are generated by the Xilinx toolchain and located in the files *xsyfala.h/c* and *xsyfala_linux.h*.  We just have to call the following function, which embeds all the proper *uio* system calls.

```cpp
void initialize(XSyfala& x) {
	XSyfala_Initialize(&x, "syfala");
    [...]
```

In *include/syfala/arm/ip.hpp*, some aliases have been written in the **IP namespace** in order to make the IP function calls more readable:

```cpp
namespace Syfala::IP {
	constexpr auto set_mem_zone_f  = XSYFALA_SET(mem_zone_f);
	constexpr auto set_mem_zone_i  = XSYFALA_SET(mem_zone_i);	
}
```

For example, these two functions, used to pass the DDR pointers to the IP, can be called like this: 

```cpp
IP::set_mem_zone_i(...);
IP::set_mem_zone_f(...);
```

### Inter-Integrated Circuit (i²c) 

- source file: *arm/linux/audio.cpp*

The i²c initialization calls are pretty straightforward:

```cpp
#include <linux/i2c-dev.h>
// open /dev/i2c-0 and get its file-descriptor index
int fd = open("/dev/i2c-0", O_RDWR);
// then, acquire slave bus access
// I2C_SLAVE is defined in linux/i2c-dev.h
#define IIC_SSM_SLAVE_ADDR 0b0011010
ioctl(fd, I2C_SLAVE, IIC_SSM_SLAVE_ADDR);
```

To write to the proper registers, the function that we use is pretty much the same as the one we use in the *baremetal* version:

```cpp
static void write_reg(int fd, unsigned char offset, unsigned short data) {
    unsigned char buffer[2];
    buffer[0] = offset << 1;
    buffer[0] = buffer[0] | ((data >> 8) & 0b1);
    buffer[1] = data & 0xff;
    write(fd, buffer, sizeof(buffer));
}
```

### GPIO (LED/SW)

- source file: *arm/linux/gpio.cpp*

**Note**: the API used here is apparently an old one, and is deprecated. It still works, but it **should be rewritten with the more recent one**.

Here, we use two different 'devices':

- `/dev/gpiochip0` - handling the **RGB LED**
- `/dev/gpiochip1` - handling the **switches** (including their LEDs)

Like all other peripherals, calls are made with the `open-device()` and `ioctl()` functions.

```cpp
// example for writing to the RGB LED
// it works pretty much the same way for 'read' calls
#define SYFALA_GPIO_AXI_LED_RGB_R_LINENO    6
#define SYFALA_GPIO_AXI_LED_RGB_G_LINENO    5
#define SYFALA_GPIO_AXI_LED_RGB_B_LINENO    4

static void write(const char* dev, int R, int G, int B) {
    gpiohandle_request req;
    giohandle_data data;
    // requests are structured with 'lines', we set the line indexes first
    req.lineoffsets[0] = SYFALA_GPIO_AXI_LED_RGB_R_LINENO;
    req.lineoffsets[1] = SYFALA_GPIO_AXI_LED_RGB_G_LINENO;
    req.lineoffsets[2] = SYFALA_GPIO_AXI_LED_RGB_B_LINENO;
    req.lines = 3;
    // set request's direction (output for write calls)
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    // and now the matching data
    data.values[0] = R;
    data.values[1] = G;
    data.values[2] = B;
    // now, open device
	int fd = open_device(dev, O_WRONLY);
    // get a 'line handle file descriptor' from the request
    ioctl(fd, GPIO_GET_LINEHANDLE_IOCTL, &req);
    close(fd);
    // write the data
    ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    close(req.fd);
}
```

### Memory

- source file: *arm/linux/memory.cpp*

Accessing the reserved memory space specified in the device-tree requires a call to the `mmap()` function, like so:

```cpp
#define MEM_ADDR 0x35000000
#define MEM_LEN  0x08000000
int fd = open("/dev/mem", O_RDRW | O_SYNC);
void* mem = mmap(NULL, MEM_LEN, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_FILE, fd, off);
if (mem == MAP_FAILED) {
    perror("Can't map reserved memory space");
    exit(1);
}
```

### Serial Peripheral Interface (SPI)

- source file: *arm/linux/spi.cpp*

**Note:** the *spi-cadence.c* driver only supports at the moment transfers using **PL-PS interruptions**, which are not enabled in our current projects (**polling mode** is used). Polling-mode transfers might be supported in a near future (see: https://lore.kernel.org/lkml/20221219144254.20883-4-wsadowski@marvell.com/).

SPI uses, like other IO peripherals the `open-device()` and `ioctl()` functions, as well as a set of *userspace-targeted* macros:

```cpp
#define SPI_MASTER_CLOCK_BASE_HZ  166666672
#define SPI_SLAVE0_SPEED_MAX_HZ   1000000
#define SPI_SLAVE0_DEV_ID 	      "/dev/spidev0.0"

static void initialize() {
    int mode  = SPI_MODE_0;
    int speed = SPI_SLAVE0_SPEED_MAX_HZ;
    int bpw   = 8;
    int fd = open(SPI_SLAVE0_DEV_ID, O_RDWR);
    // set SPI mode, speed and bits-per-word parameters
    // we use ioctl() and the SPI_IOC_WR_ macros to do so:
    ioctl(fd, SPI_IOC_WR_MODE, &mode);
    ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &mode);
    ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &mode);    
}
```

For **read/write transfers**, a specific data structure `spio_ioc_transfer` is used:

```cpp
static u32 poll(int fd, int channel) {
    struct spi_ioc_transfer xfer;
    int r, value;
    u8 data[3];
    // Full-duplex mode: 
    // we set both tx & rx buffers on the same 'transfer'
    memset(&xfer, 0, sizeof(xfer));
    xfer.tx_buf = (__u64) data;
    xfer.rx_buf = (__u64) data;
    xfer.len = 3;
    /* for the MCP30008 target: 
     * byte n°1 is used to send a 'start bit'
     * byte n°2 is used to send the channel number we want to poll
     * byte n°3 is a 'don't care' byte. */
    data[0] = 0b00000001;
    data[1] = 0b10000000 | ((channel & 7) << 4);
    data[2] = 0;
    // request transfer with ioctl()
    r = ioctl(fd, SPI_IOC_MESSAGE(1), &xfer);
    // merge data[1] & data[2] to get proper result
    value  = (data[1] << 8) & 0b1100000000;
    value |= (data[2] & 0xff);
    return value;        
}
```
