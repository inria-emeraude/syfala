# syfala-linux getting started

## Requirements

- **Xilinx toolchain** version **2022.2**
  - for *gcc-compatibility* reasons
- `arm-none-eabi-gcc` **cross-compilation toolchain**
- An available **SD card**
- The following **Linux packages** installed on your machine: 
  - `bison flex libssl-dev bc u-boot-tools cpio libyaml-dev curl kmod squashfs-tools qemu-user-static`
  


## Building

### Available commands

#### From scratch

**First**, a regular **syfala project** has to be built with the following options: 

```shell
syfala examples/virtualAnalog.dsp --linux
```

The `--linux` option is used for **compiling the host-side** (**ARM**) **application** with the **linux-specific source files** (otherwise, it would be compiling the standard baremetal one).

After **synthesis**, the script will detect that you don't currently have a linux build, which is required for building the application, and will download and build everything for you, you'll just have to flash it to your formatted SD card afterwards

### Outputs

The build outputs are located in the`build-linux/output` directory, with two distinct `boot` and `root` subdirectories, which then will have to be be flashed on the first and second partitions of your SD card. 

## Usage

### Formatting the SD card

The **SD card** has to be formatted like so:

- **1st** partition: **FAT32**
- **2nd** partition: **ext4** (Linux filesystem)

There are many ways to achieve this, for instance:

```shell
# you can just replace </dev/...> with your SD device, e.g: /dev/sda or /dev/mmcblk0
sudo parted /dev/... --script -- mklabel msdos
sudo parted /dev/... --script -- mkpart primary fat32 1MiB 128MiB
sudo parted /dev/... --script -- mkpart primary ext4 128MiB 100%
sudo parted /dev/... --script -- set 1 boot on
sudo parted /dev/... --script -- set 1 lba on
sudo mkfs.vfat /dev/device-partition-1 # e.g. /dev/sda1
sudo mkfs.ext4 /dev/device-partition-2 # e.g. /dev/sda2
sudo parted /dev/... --script print
```

### Flashing boot & root partitions

```shell
# In case your SD device is /dev/sda
# 1. Copying boot partition files
sudo mount /dev/sda1 /mnt
sudo cp -r build-linux/output/boot/* /mnt
sync
sudo umount /mnt
# 2. Copying root partition contents
sudo mount /dev/sda2 /mnt
sudo cp -r build-linux/output/root/* /mnt
# This might take a while...
sync 
sudo umount /mnt
```

### Booting

Once flashed, just insert the SD card in your device's socket, **make also sure it is configured to boot on SD** (For the **Zybo** boards, you'll have to place a **shorting jumper on SD** instead of *JTAG*/*QSPI*).

### 	Connecting

You can still connect through the *ttyUSB* **Serial Port**, or with **SSH**.

- for **Serial Port** connection, check that devices ``/dev/ttyUSB0``and ``/dev/ttyUSB1``are present on your host and use a serial communication program with following configuration: device ``/dev/ttyUSB1``, 115200 8N1 (115200 bits/second, one start bit, eight (8) data bits, no (N) parity bit, and one (1) stop bit), no hardware flow control and no software flow control. If hardware flow control is enable, the serial connection will not behave properly. for instance when using minicom: 
```shell 
minicom -b 115200 -D/dev/ttyUSB1 -8
```
(check hardware flow control in minicom, ctrl-A Z). Linux booting console will appear. A login prompt will appear as soon as the booting process has completed:
```shell 
Welcome to Alpine Linux 3.17
Kernel 5.15.0-xilinx on an armv7l (/dev/ttyPS0)

syfala login: 
```
- for  **SSH** connection, make sure that you are connected on the same network as your device's, get its IP address by serial connection as explained above and log as root:
```shell
ssh root@192.168.0.1 . 
```
### Login/users

The rootfs has the same structure as any Linux build. The scripts adds a **default user named syfala**, which has its *home* directory in */home/syfala*.

- The password required to **login as root** is *syfala*
- The password required to **login as syfala** is *syfala*

### Faust DSP builds

All the **DSP builds** made with the **syfala toolchain** are placed in the */home/syfala* directory by default. For instance, if you make a build from the **virtualAnalog.dsp** file , the *bitstream*/*application* outputs will be located in: 

- */home/syfala/virtualAnalog/bitstream.bin*
- */home/syfala/virtualAnalog/application.elf*

You can then use the 

```shell
syfala-load <target> [--list | --help]
```

utility command (e.g. `syfala-load virtualAnalog`), which will take care of **loading the bitstream** and **executing the app** properly.

You can also do all of that manually of course: first, **load the bitstream** by entering the following command line:

```shell
fpgautil -b /home/syfala/virtualAnalog/bitstream.bin
```

and then **execute the Host application** like you would normally do with a Linux binary:

```shell
cd /home/syfala/virtualAnalog
./application.elf	  
```

If you wish to **add another build** to the SD card, you just have to re-run the syfala toolchain normally on your computer, with the `--linux` option. **Your previous builds won't be erased or modified.**

```shell
syfala examples/fm.dsp --linux
```

Once the build is complete,  you will have two distinct project directories in your`build-linux/output/root/home/syfala` directory:

- `/home/syfala/virtualAnalog`
- `/home/syfala/fm`

You will then have to **re-flash your SD card** to **update the root partition**, or directly copy the directory through **ssh** (e.g. with the `scp` command).

### Getting the device's IP & port from avahi (for network-based control)

Once a DSP target is loaded with the `syfala-load` command, an **avahi service** is automatically started in a separate thread. If your desktop machine is on the same network as the FPGA board, and you have **avahi** installed & running, you should be able to **retrieve the FPGA board's IP address and port** required for the HTTP/OSC controls. You can use the `avahi-browse` command in order to do so:

```shell
avahi-browse _syfala._tcp --resolve
```

### HTTP control

In order to build a target with **HTTP support**, you can add the `--http` flag to the command line:

```shell
syfala examples/fm.dsp --linux --http
```

After loading a DSP target with the `syfala-load` command (or manually), the host application **will create a HTTP server** allowing users to **control the Faust DSP parameters remotely** (given that you are on the same network as your FPGA board).

At runtime, when executed, the **application will print the device's current network IP** (IPv4), and the **port** used by the HTTP server. You can then **use any web browser**, and control the application by entering the server's URL, for example *http://192.168.0.1:5510*

### OSC control

In order to build a target with **OSC support**, you can add the `--osc` flag to the command line:

```shell
syfala examples/fm.dsp --linux --osc
```

**Note:** your Faust **.dsp file must also contain this line** in order to enable OSC support:

```faust
declare options "[osc:on]";
```

In parallel, the Host application will also create an **Open Sound Control-compliant UDP server**, and **print its send/receive ports** when executed. You can then control remotely the Faust DSP parameters by sending OSC messages like so:

- */virtualAnalog/lfoRange 2000*
- */virtualAnalog/oscFreq 500*
- ...

More on: https://faustdoc.grame.fr/manual/osc/

### MIDI control

In order to build a target with **MIDI support**, you can add the `--midi` flag to the command line:

```shell
syfala examples/fm.dsp --linux --midi
```

**Note:** your Faust **.dsp file must also contain this line** in order to enable MIDI support:

```faust
declare options "[midi:on]";
```

The **Zybo boards** have a **Host USB port**, located next to the switches. It can be used to **connect a MIDI  device** and map its controls accordingly. No additional driver configuration is needed, **but the board needs to be powered from an external power supply source**:

> The supply must use a center-positive 2.1mm internal-diameter plug and deliver between 4.5V to 5.5V DC. It should also be able to output at least 2.5 A (12.5 Watts) in order to support power-hungry Zynq projects and external peripherals. To use an external supply with a barrel jack, plug it into the power jack (J17), set jumper JP6 to “WALL”, and then set SW4 to “ON”. 

You'll also have to put a **shorting jumper** on **JP2** (*HOST*), next to the USB port.

The **Faust midi-mapping process** is explained here: https://faustdoc.grame.fr/manual/midi/

### Wi-Fi

Wi-Fi is handled by *iwd* (provided you have an USB dongle, or the appropriate additional hardware, which Zybo boards do not possess natively), the available commands are: 

```shell
# List your available wifi device(s), look for wlan0
iwctl device list
# If you don't know the SSID of your network, you can run a scan and retrieve a list of all the detected networks:
iwctl station wlan0 scan && iwctl station wlan0 get-networks
# To connect to a network (use connect-hidden if it is a private network):
iwctl station wlan0 connect <SSID>
```

more on: https://wiki.alpinelinux.org/wiki/Wi-Fi

### Autologin / Autostart DSP target

In order to **autologin** as root on the board, you have to edit the file */etc/inittab* like the following:

```shell
#ttyPS0::respawn:/sbin/getty -L ttyPS0 115200 vt100
# For autologin (as root): comment out the previous line and uncomment the next one:
ttyPS0::respawn:/sbin/mingetty --autologin root --noclear ttyPS0 115200 vt100
```

To **autostart a DSP target on boot**, create a *.start* file in */etc/local.d* , for example */etc/local.d/virtualAnalog.start*:

```shell
#!/bin/sh
syfala-load virtualAnalog
```

Execute `chmod 755 /etc/local.d/virtualAnalog` . That's it!
