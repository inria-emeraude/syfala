## Syfala dependencies

#### Ubuntu

```shell
sudo apt install libncurses5 libtinfo-dev g++-multilib gtk2.0
```

#### Archlinux

```bash
# faust (required)
sudo pacman -S faust

# for xilinx vivado/vitis etc.
yay -S ncurses5-compat-libs libxcrypt-compat libpng12 lib32-libpng12 xorg-xlsclients gtk2
```

### Vivado, Vitis & Vitis HLS (2020.2 version)

Unfortunately at the moment, these tools are quite tedious to install, but are required for using the Syfala toolchain. 

- Open an account on https://www.xilinx.com/registration
- The Xilinx download page (https://www.xilinx.com/support/download.html) and browse to the 2020.2 version. The page contains links for downloading the "Xilinx_Unified_2020.2_1118_1232_Lin64.bin" (It is available for both Linux and Windows but Syfala compiles only on Linux). 
  - Download the Linux installer `Xilinx_Unified_2020.2_1118_1232_Lin64.bin`

- execute `chmod a+x Xilinx_Unified_2020.2_1118_1232_Lin64.bin`

- execute `./Xilinx_Unified_2020.2_1118_1232_Lin64.bin`

  - We suggest to use the "Download Image (Install Separately)" option. It creates a directory with a xsetup file to execute that you can reuse in case of failure during the installation

- execute `./xsetup`

  -  Choose to install **Vitis** (it will still install **Vivado**, **Vitis**, and **Vitis HLS**). 
  - It will need 110GB of disk space: if you uncheck *Ultrascale*, *Ultrascale+*, *Versal ACAP* and *Alveo acceleration platform*, it will use less space and still work.
  - Agree with everything and choose a directory to install (e.g. ~/Xilinx)
  - Install and wait for hours...

- Setup a shell function allowing to use the tools when necessary (add this to your `~/.bashrc`, `~/.zshrc` or whatever you're currently using, replacing `$XILINX_ROOT_DIR` by the directory you chose to install all the tools)

  - ```shell
    export XILINX_ROOT_DIR=$HOME/Xilinx
    ```


### Installing Cable Drivers on Linux

-  go to: `$XILINX_ROOT_DIR/Vivado/2020.2/data/xicom/cable_drivers/lin64/install_script/install_drivers` directory
- run `./install_drivers`
- run `sudo cp 52-digilent-usb.rules /etc/udev/rules.d`, this allows **JTAG** connection through **USB**.

### Installing Digilent Board Files

- download https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.76732885.1953828090.1655988025-1125947215.1655988024
- Open the folder extracted from the archive and navigate to its `new/board_files` folder. You will be copying all of this folder's subfolders
- go to `$XILINX_ROOT_DIR/Vivado/2020.2/data/boards/board_files`
- **Copy** all of the folders found in vivado-boards `new/board_files `folder and **paste** them into this folder

### Installing the 2022 patch

- Follow this link: https://support.xilinx.com/s/article/76960?language=en_US
- Download the file at the bottom of th page and unzip it in `$XILINX_ROOT_DIR`
- run `cd $XILINX_ROOT_DIR`
- run ` export LD_LIBRARY_PATH=$PWD/Vivado/2020.2/tps/lnx64/python-3.8.3/lib/			 Vivado/2020.2/tps/lnx64/python-3.8.3/bin/python3 y2k22_patch/patch.py			 `

### Troubleshooting

On **Archlinux**, if you see an error like this one 

```
/lib/../lib64/crti.o: file not recognized: File format not recognized
```

you'll have to rename the `Vivado/2020.2/tps/lnx64/binutils-2.26` (Vitis will then search in the system libraries).
