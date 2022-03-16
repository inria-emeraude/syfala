
# Syfala repo

Syfala gitlab repository, automatic compilation of Faust programs onto the Zybo-Z7 FPGA. The compiler is in the ``syfala`` directory:

```
cd syfala
make
make boot
```

## Vivado and Faust version

*Vivado Version: 2020.2*  
*FAUST Version: 2.39.3*

## Getting started
See documentation in file `syfala-getting-started.pdf`

### Prerequisite
*Jumper JP5 should be on "JTAG"*  
*Power select Jumper should be on "USB"*  
*Switches SW0, SW1, SW2, SW3 should be down*  
*The audio input is "LINE IN", not "MIC IN"*
*The audio output is the black "HPH OUT" jack*
*SyFaLa is only compatible with Zybo-Z10 and Zybo-Z20 for now*

### Configure

First check the compilation flow parameters:

- Name of the Faust program compil (`virtualAnalog.dsp` by default) in the Makefile
- Parameters in `configFAUST.h`

### Build

To build the project:  

```
make
```

### Boot

Then, you can upload and execute it on the board with:  

```
make boot
```

### Control

To control your DSP, you can either use a Hardware Controller Board or a GUI on your computer.  

#### GUI (SW3 DOWN)
SW3 should be down (0).
If you use GUI, open the GUI controller after booting with the following command:

```
make controlUI
```

#### Syfala Hardware Controller Board (SW3 UP)
SW3 should be up (1).
If you use a Hardware Controller Board, please edit the `configFAUST.h` file to choose the right one by modifying the `CONTROLLER_TYPE` field.  
And just connect it to the Zybo on port JE.  

You can swap from hardware to software controller during dsp execution by changing SW3.

*Note: You can change `CONTROLLER_TYPE` without a full rebuid. Just delete the app with `make remove_app` and then rebuild only the app with `make`*.


### Switch description
Default config in **bold**  
<pre>
  SW3   SW2   SW1   SW0
+-----+-----+-----+------+
|  Hard | ADAU|  BYPASS | MUTE |
|     |     |     |      |
|     |     |     |      |
|  GUI | <b>SSM</b> |  <b>USE DSP</b> | <b>UNMUTE</b> |
+-----+-----+-----+------+
</pre>

SW3: Controller type select: hardware (Controller board) or software (GUI)
SW2: Audio codec input select (ADAU=external or SSM=onboard). Does not affect output.  
SW1: Bypass audio dsp
SW0: Mute  

### Status LEDs

The RGB led indicate the program state:
* BLUE = WAITING
* GREEN = ALL GOOD
* ORANGE = WARNING (Bypass or mute enable)
* RED = ERROR (Config failed or incompatible). Could happen if you select SSM codec with incompatible sample rate.

The 4 LEDs above the switches indicate the switches state. If one of them blink, it indicates the source of the warning/error.

### Compatibility

The SyFaLa project is only compatible with Zybo-Z10 and Zybo-Z20 for now.
If you have a VGA port (rather than 2 HDMI port), you have an old zybo version which is not supported.
Please select between Z10 and Z20 in the configFAUST.h file.

### SD card files

You can put the program on an SD card (if you want something reproductible and easily launchable, for the demos...).  
After a `make` command, you should see a `BOOT.bin` file in SW_export (or you can build it with `make boot_file`).  
Put the file on the root of SD card. And don't forget to put JP5 on 'SD' position !  

### Backup

Since the V6.1, a backup folder is generate when the hardware compilation is complete.  
You can find a history of all .xsa you generate for this version.  
**Please, don't git this folder!**  

To use it:  
- Replace the `main_wrapper.xsa` in `hw_export` with the wanted .xsa in the backup file (and rename it `main_wrapper.xsa`).  
- Change the name of the DSP in the makefile with the one you use to generate the .xsa you choose in the backup folder.  
* WARNING: The DSP must be the same as the one used to compile the .xsa you are using (no code change)

Just do:

```
make remove_app
make app
make standalone_boot
```
