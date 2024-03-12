# Syfala toolchain dependencies

The Syfala toolchain is a compilation toolchain of Faust programs onto AMD-Xilinx FPGA targets. This document explains how to install and run the **version 0.8.0** of the toolchain  on a Linux machine. In practice, installing the Syfala toolchain means:

- Installing the required **linux-packages**, depending on your Linux distribution.
- Installing the **Faust** compiler
- Creating a **AMD-Xilinx account** and downloading/installing the **2022.2 version** (2020.2 is also still supported) of the AMD-Xilinx toolchain (providing softwares such as Vivado, Vitis, Vitis HLS).
- Installing the additional **Vivado Board Files** for Digilent Boards.
- Installing *udev* rules in order to use the JTAG connection.
- Cloning the **Syfala repository**, and running a **simple example** to make sure everything is working properly.

## Linux targets

We recommend using **Ubuntu** (>= 18.04 LTS) for installing and using the toolchain, since it is officially supported by AMD-Xilinx. While it is still possible to use other distributions, such as Archlinux, you may encounter unresolved bugs, which won't necessarily appear in our *Troubleshooting* section below. 

### Ubuntu dependencies

```shell
$ sudo apt-get update 
$ sudo apt-get install git libncurses5 libtinfo-dev build-essential default-jre pkg-config g++-multilib gtk+2.0 locales
```

### Archlinux dependencies

```bash
# faust (required)
$ sudo pacman -S faust

# for xilinx vivado/vitis etc.
$ yay -S ncurses5-compat-libs libxcrypt-compat libpng12 lib32-libpng12 xorg-xlsclients gtk2
```

## Faust

It is recommended to clone Faust from the official github repository: https://github.com/grame-cncm/faust

```shell
$ git clone https://github.com/grame-cncm/faust.git 
$ cd faust
$ make
$ sudo make install
```

## Vivado, Vitis & Vitis HLS (2022.2 version)

- Open an account on https://www.xilinx.com/registration

- The AMD-Xilinx [download page](https://www.xilinx.com/support/download.html) contains links for downloading the **Vivado Design Suite - HLx Editions - Full Product**. It is available for both Linux and Windows. 

- Download the Linux installer `Xilinx_Unified_2022.2_1014_8888_Lin64.bin`

```shell
chmod a+x Xilinx_Unified_2022.2_1014_8888_Lin64.bin
./Xilinx_Unified_2022.2_1014_8888_Lin64.bin
```

- We suggest to use the "**Download Image (Install Separately)**" option. It creates a directory with a **xsetup** file to execute that you can reuse in case of failure during the installation

- Execute `./xsetup`

  -  Choose to install **Vitis** (it will still install **Vivado**, **Vitis**, and **Vitis HLS**). 
  -  It will need **110GB of disk space**: if you uncheck *Ultrascale*, *Ultrascale+*, *Versal ACAP* and *Alveo acceleration platform*, it will use less space and still work.
  -  **Agree** with everything and choose a directory to install (e.g. ~/Xilinx)
  -  **Install and wait** (it may take quite a while)

- **Setup a shell environment variable** allowing to use the tools when necessary (add this to your `~/.bashrc`, `~/.zshrc` or whatever you're currently using, replacing `$XILINX_ROOT_DIR` by the directory you chose to install all the tools)

```shell
export XILINX_ROOT_DIR=$HOME/Xilinx
```

### Installing Cable Drivers on Linux

```shell
cd $XILINX_ROOT_DIR/Vivado/2022.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
./install_drivers
# Allow JTAG-USB connection:
sudo cp 52-xilinx-digilent-usb.rules /etc/udev/rules.d
```

### Installing Digilent Board Files

- Download the board files from [github](https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.76732885.1953828090.1655988025-1125947215.1655988024):
- Open the folder extracted from the archive and navigate to its `new/board_files` folder. You will be copying all of this folder's subfolders
  - For the **2020.2 version**, go to `$XILINX_ROOT_DIR/Vivado/2020.2/data/boards/board_files`
  - For the **2022.2 version**, go to `$XILINX_ROOT_DIR/Vivado/2022.2/data/xhub/boards/XilinxBoardStore/boards/Xilinx`

- **Copy** all of the folders found in vivado-boards `new/board_files `folder and **paste** them into this folder

### Installing the 2022 patch (AMD-Xilinx toolchain v2020.2 only)

Vivado and Vitis tools that use HLS in the background are also affected by this issue. HLS tools set the ip_version in the format YYMMDDHHMM and this value is accessed as a signed integer (32-bit) that causes an overflow and generates the errors below (or something similar).

- Follow this link: https://support.xilinx.com/s/article/76960?language=en_US
- Download the file at the bottom of th page and unzip it in `$XILINX_ROOT_DIR`

- Run the following commands: 

```shell
cd $XILINX_ROOT_DIR
export LD_LIBRARY_PATH=$PWD/Vivado/2020.2/tps/lnx64/python-3.8.3/lib/
Vivado/2022.2/tps/lnx64/python-3.8.3/bin/python3 y2k22_patch/patch.py
```

## Cloning the Syfala repository

To clone and install the latest stable version of the Syfala toolchain, you can use the following commands:

```shell
git clone https://github.com/inria-emeraude/syfala 
cd syfala
make install
syfala --help
```

In order to use the Syfala toolchain to compile your first example, please report to the main [README](https://github.com/inria-emeraude/syfala/blob/main/README.md) file located in the repository's root directory.

## Troubleshooting

On **Archlinux**, if you see an error like this one 

```shell
/lib/../lib64/crti.o: file not recognized: File format not recognized
```

you'll have to rename the `Vivado/2020.2/tps/lnx64/binutils-2.26` (Vitis will then search in the system libraries).

#### Vitis/Java issues

On recent systems (or with **Archlinux**), you might have problems compiling the host-side (**ARM**) application. The problem is caused by system libraries requiring newer versions of GCC than the one provided by Vitis. Replacing GCC target in Vitis' path **by system GCC** works:

```bash
$ cd $XILINX_ROOT_DIR/Vitis/2020.2/lib/lnx64.o/Default
$ mv libstdc++.so.6 libstdc++.so.6.old
$ rm -rf libstdc++.so (symlink)
$ sudo ln -s /usr/lib/libstdc++.so.6 libstdc++.so.6
```
