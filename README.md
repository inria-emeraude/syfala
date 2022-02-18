
# Syfala repo
 
Syfala gitlab repository, see documentation in file syfala-getting-started.pdf


## Disclaimer

**PLEASE CHECK FAUST AND VIVADO VERSION REQUIRED IN "VERSION" SECTION**

**From v5** we use vivado 2020.2 version, together with vitis_hls and vitis (2020.2).  
**v5 only** we use petalinux to have a real hardware/software design. Petalinux should be the same version as Vivado, so use petalinux v2020.2.  
**v6 only** We use standalone (baremetal) mode instead of petalinux. The compilation is much faster and you don't need to install petalinux.   

## Getting started v6.2 (Standalone latest)

*Vivado Version: 2020.2*  
*FAUST Version: 2.34.2*

### Switch description
Default config in **bold**  
<pre>
  SW3   SW2   SW1   SW0
+-----+-----+-----+------+
|  NC | ADAU|  NC |<b>UNMUTE</b>|
|     |     |     |      |
|     |     |     |      |
|  NC | <b>SSM</b> |  <b>NC</b> | MUTE |
+-----+-----+-----+------+
</pre>
  
SW3: NC  
SW2: Audio codec input select (ADAU=external or SSM=onboard). Does not affect output.  
SW1: DEBUG, doesn't matter  
SW0: Mute onboard audio codec (SSM)  

### Build

To build the project, just do :  

```
make
```
  
Then, you can upload and execute it on the board with:  

```
make standalone_boot
```
  
Then open a terminal to interact with your dsp.  
`Putty` and `minicom` work well. If you use `minicom`, please open it with:
```
minicom --color=on

```
in order to add the colors.  

### Control

To control your DSP, you can either use a Hardware Controller Board or a GUI on your computer.  
Please edit the configFAUST file to choose one of the two by modifying the `CONTROLLER_TYPE` field.  
  
- If you use a Hardware Controller Board, just connect it to the Zybo before booting.  
- If you use GUI, open the GUI controller after booting with the following command:

```
make controlUI

```
*Note: You can change `CONTROLLER_TYPE` without a full rebuid. Just delete the app with `make remove_app` and then rebuild only the app with `make`*

### SD card files

You can put the program on an SD card (if you want something reproductible and easily launchable, for the demos...).  
After a `make` command, you should see a `BOOT.bin` file in SW_export (or you can build it with `make boot_file`).  
Put the file on the root of SD card. And don't forget to put JP5 on 'SD' position !  

### Backup

Since the V6.1, a backup folder is generate when the hardware compilation is complete.  
You can find a history of all .xsa you generate for this version.  
**Please, don't git this folder!**  
  
To use it:  
1- Replace the `main_wrapper.xsa` in `hw_export` with the wanted .xsa in the backup file (and rename it `main_wrapper.xsa`).  
2- Change the name of the DSP in the makefile with the one you use to generate the .xsa you choose in the backup folder.  
3-Just do
```
make remove_app
make app
make standalone_boot
```
No clean!!
  

## Getting started v5.5 (Petalinux latest)

Clone the repository and go inside the choosen version.  
From the v5.5, everything is handle with one makefile.  
  
You can choose to use your own Petalinux directory or create one from a provided BSP.  

#### Create a Petalinux project (default)

If you don't already have a petalinux project on your computer or don't want to modify it, you can create a new one from a provided BSP.  
Set the `PETALINUX_DIR` variable in the makefile to the 'petalinux' folder of your syfala directory.  
It should be OK as default:  

```
PETALINUX_DIR=${ORIGIN_DIR}/../petalinux
```
This folder contains the BSP which will be used to create the project.  
Create a project from a BSP is faster but it's still few hours, don't be in a rush...

#### Use your own petalinux directory

Use your own directory allows you to avoid rebuilding a petalinux (which can take several hours).  
You can use the same Petalinux directory for each version of syfala.  
For that, just set the `PETALINUX_DIR` variable in the makefile to your Petalinux directory (absolute path)  

### Build the project

#### Auto
To build the project and create (if you chose it), build and boot Petalinux:  

```
make full
```
Make sure that JP5 is on JTAG position and that the zybo is connected, reset and trun on.  
Then, go to the ****Upload and connect**** section.  

#### Manually

To make the hardware files:  
```
make 
```
  
To build and eventually create the Petalinux project:  
```
make petalinux_build
```
  
To boot petalinux on Zybo:  
```
make boot
```
Ensure that JP5 is on JTAG position and that the zybo is connected and reset.  
  

### Upload and connect

#### With SSH

If you want to use SSH to communicate with the board, please find the board IP and set the `ZYBO_IP_ADDRESS` variable in the makefile.  
Then, use:  
```
make download 
make connect
```
To download and connect to the board with SSH.  
Once the login prompt appears:
```
login:root
pass: root
```

#### With UART (not sure que ca marche)

Make sure that `lrzsz` is installed on your computer  

```
sudo apt-get install lrzsz
```

Use `minicom` in sudo mode to connect to the board (only minicom works).  
Once the login prompt appears:

```
login:root
pass: root
```

Once you are logged in, type:  

```
rz -bZ
```
If the command is not recognized, use the SSH method.  
Else, use `ctrl+a, s`, select zmodem, and find the .elf file in build/sw_export and upload it.  

### Execute

On the board's shell:  
```
./faust_v5_app.elf
```

### Clean

```
make clean #delete the project but leave the petalinux project
make remove_petalinux #delete the petalinux project (be careful!!)
```


## Version

Please make sure to use the corresponding version of faust and vivado.

### v6.2-new-i2s

Same as 6.1 and:  
SSM is configured with arm (no more hard IP)  
SSM bug is resolved!!  
Patched i2s transceiver to work with 16 and 32b  
New ADAU1787 codec (up to 768kHz)  

*Vivado Version: 2020.2*  
*FAUST Version: 2.33.1 (to check)*

### v6.1-ddr-tests

Same as 6.0 and:  
Use DDR3 to store sample (if USE_DDR is define in fpga.cpp).  
ARM architecture is handeled in cpp.  
Use ADAU audio Codec.  

*Vivado Version: 2020.2*  
*FAUST Version: 2.33.1 (new -os1 version)*


### v6.0-spi-ps-control

Use external controller and MCP3008 to send value through SPI.  
SPI is handled with the Zynq Proc (soft).  
Standalone mode.  

*Vivado Version: 2020.2*  
*FAUST Version: 2.31.1 (-uim and new -os version)*

### v5.5-stable (Latest petalinux version)

Same as v5.4.  
I2C and I2S transceivers are stablizied.
The scale factor is controlled on ARM and set to 0x400000 by default to patch de SSM bug...

*Vivado Version: 2020.2*  
*FAUST Version: 2.31.1 (-uim and new -os version)*

#### v5.4-sinewave-generic

Use of petalinux with generic app on ARM based on arm.c architecture file to control IP.  
Compute the controlmydsp function on the ARM and send icontrol and fcontrol value.  
Generic compilation, no need to modify computemydsp

*Vivado Version: 2020.2*  
*FAUST Version: 2.31.1 (-uim and new -os version)*
#### v5.3.2-sinewave-arm-newfaust

*Same as v5.3 but this one works with Faust v2.31 (which change the -os option and make other version not compatible)*  
Use of petalinux with generic app on ARM based on arm.c architecture file to control IP.  
Compute the controlmydsp function on the ARM and send icontrol and fcontrol value.  
The controlmydsp function on arm.c has to be modified by hand because of the non generic faust compilation  

*Vivado Version: 2020.2*  
*FAUST Version: 2.31.1 (-uim and new -os version)*

#### v5.3-sinewave-arm
Use of petalinux with generic app on ARM based on arm.c architecture file to control IP.  
Compute the controlmydsp function on the ARM and send icontrol and fcontrol value.  
The controlmydsp function on arm.c has to be modified by hand because of the non generic faust compilation  

*Vivado Version: 2020.2*  
*FAUST Version:  2.30.8 (-uim version)*

#### v5.2-petalinux-2
Use of petalinux with generic app on ARM based on arm.c architecture file to control IP.  
The app directly send value of controler to the FPGA, contromydsp is on the FPGA	

*Vivado Version: 2020.2*  
*FAUST Version: 2.30.8 (-uim version)*

#### v5.1-petalinux-1
Use of petalinux with non generic app on ARM to control IP.  
The app directly send value of controler to the FPGA, contromydsp is on the FPGA  

*Vivado Version: 2020.2*  
*FAUST Version: 2.30.2 (no -uim)*

#### v4.3-button-trigger
Use a switch to trigger the first button define on the faust DSP (and no axi)  

*Vivado Version: 2019.1*  
*FAUST Version: 2.30.2 (no -uim)*

#### v4.2-hand-shake-one-axi:
Uses one axi bus for storing samples  
Does not work correctly, it has to be debugged yet.

*Vivado Version: 2019.1*  
*FAUST Version: 2.30.2 (no -uim)*

#### v4.1-hand-shake-no-axi:
Does not use  the external memory, it only uses block Ram for all memory  
Is correct on example that do not use to many samples (ex: KarpusStrong)  

*Vivado Version: 2019.1*  
*FAUST Version: 2.30.2 (no -uim)*
   

## Petalinux
For HW/SW design you need, in addition to vivado tools,  to install petalinux distribution on your machine.  
Directory petalinux can help you install petalinux on your machine (warning: 5OGB needed) and build a petalinux_syfala distribution.  
Please look at petalinux/README.txt for that.  
Once petalinux_syfala installed, you need to set up petalinux_syfala directory in current directory Makefile in order to be able to run the "make boot" directory.  
  
## Vivado 2019 backward compatibility
From v5 we use vivado 2020.2 version, together with vitis_hls and vitis (2020.2)

It's possible to use vivado 2020.2 with v4 or older, just do this:

1. Call *vitis_hls* instead of *vivado_hls* in the makefile
2. In *fpga.cpp*, rename all vector argument with a "**_V**" at the end: 
   
```ap_int<24> in_left   =>    ap_int<24> in_left_V```


See README_maj_2020.txt for more info



