
# Syfala repo
 
Syfala gitlab repository, automatic compilation of  Faust programs onto the Zybo-Z7 FPGA 


## Vivado and Faust version 

*Vivado Version: 2020.2*  
*FAUST Version: 2.39.3*

## Getting started
see documentation in file syfala-getting-started.pdf

### Check Zybo switches and Jumpers
*Jumper JP5 should be on "JTAG"*__
**Jumper J2 should be on**
**Power select Jumper should be on "USB"**
**Swicth SW0 should be up (LD0)**
**Switches SW1, SW2, SW3 should be down (SW1, SW2, SW3)**

### Configure

First check the compilation flow parameters: 
** Name of the Faust program compil (``virtualAnalog.dsp`` by default)
** Parameters in configFAUST.h

### Build

To build the project, just do :  

```
make
```
  
### boot

Then, you can upload and execute it on the board with:  

```
make boot
```
  

### Control


```
make controlUI

```

To control your DSP, you can either use a Hardware Controller Board or a GUI on your computer.  
Please edit the configFAUST file to choose one of the two by modifying the `CONTROLLER_TYPE` field.  
  
- If you use a Hardware Controller Board, just connect it to the Zybo before booting.  
- If you use GUI, open the GUI controller after booting with the following command:

*Note: You can change `CONTROLLER_TYPE` without a full rebuid. Just delete the app with `make remove_app` and then rebuild only the app with `make`*



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
