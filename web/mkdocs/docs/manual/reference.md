# Syfala Reference

### General Option Flags

| option       | accepted values   | description                                                  |
| ------------ | ----------------- | ------------------------------------------------------------ |
| `--xversion` | `2020.2 - 2022.2` | chooses Xilinx toolchain version (2020.2 & 2022.2 only supported for now) |
| `--reset`    | /                 | resets current build directory before building (**careful**! all files from previous build will be lost) |
| `--mcd`      | power of 2        | (defaults to 16)                                             |

### 'One-shot' Commands

| name           | description                                                  | arguments              |
| -------------- | ------------------------------------------------------------ | ---------------------- |
| `install`      | installs this script as a symlink in /usr/bin/               | none                   |
| `clean`        | deletes current build directory                              | none                   |
| `import`       | sets previously exported .zip build as the current build     | path to the .zip build |
| `export`       | exports current build in a .zip file located in the 'export' directory | name of the build      |
| `report`       | displays HLS or global report                                | HLS \| any             |
| `demo`         | fully builds demo based on default example (virtualAnalog.dsp) | none                   |
| `flash`        | flashes current build onto target device                     | none                   |
| `gui`          | executes the Faust-generated GUI application                 | none                   |
| `open-project` | opens the generated .xpr project with Vivado                 | none                   |
| `help`         | prints list of available commands, options and run-time parameters | none                   |
| `version`      | displays the current script's version                        |                        |

### Run Steps

**Note**: the `--all` is not necessary if you wish to run all steps, just run `syfala myfaustdsp.dsp `

| `--all`     | runs all toolchain compilation steps (from `--arch` to `--gui`) |
| ----------- | ------------------------------------------------------------ |
| `--arch`    | uses Faust to generate ip/host cpp files for HLS  and Host application compilation |
| `--hls`     | runs Vitis HLS on generated ip cpp file                      |
| `--project` | generates Vivado project                                     |
| `--synth`   | synthesizes full Vivado project                              |
| `--host`    | compiles Host application, exports sources and .elf output to `build/sw_export` |
| `--gui`     | compiles Faust GUI control application                       |
| `--flash`   | flashes boot files on device at the end of the run           |
| `--report`  | prints HLS report at the end of the run                      |
| `--export`  | `<id>` exports build to export/ directory at the end of the run |

### Run Parameters

| parameter           | accepted values                            | default value |
| :------------------ | ------------------------------------------ | ------------- |
| `--memory, -m`      | `DDR - STATIC`                             | `DDR`         |
| `--board, -b`       | `Z10 - Z20 - GENESYS`                      | `Z10`         |
| `--sample-rate`     | `48000 - 96000 - 192000 - 384000 - 768000` | `48000`       |
| `--sample-width`    | `16 - 24 - 32`                             | `24`          |
| `--controller-type` | `DEMO - PCB1 - PCB2 - PCB3 - PCB4`         | `PCB1`        |
| `--ssm-volume`      | `FULL - HEADPHONE - DEFAULT`               | `DEFAULT`     |
| `--ssm-speed`       | `FAST - DEFAULT`                           | `DEFAULT`     |

### Parameter Description

| parameter           | description                                                  |
| ------------------- | ------------------------------------------------------------ |
| `--memory, -m`      | selects if **external** **DDR3** is used. Enable if you use some delay, disable if you do not want any memory access (should not be disabled) |
| `--board`           | Defines target board. **Z10** ,**Z20** and **GENESYS** only. If you have a VGA port (rather than 2 HDMI ports), you have an old Zybo version, which is not supported. |
| `--sample-rate`     | Changes **sample rate** value (Hz). Only 48kHz and 96kHz is available for **SSM** embeded codec. 192000 (**ADAU1777** and **ADAU1787** only)  384000 (**ADAU1787** only)  768000 (**ADAU1787** only and with `--sample--width 16` only) |
| `--sample-width`    | Defines **sample bit depth** (16\|24\|32)                    |
| `--controller-type` | Defines the controller used to drive the controls when **SW3** is **UP**. (**SW3** **DOWN** for **software** control), <u>**SEE BELOW**</u> for details on each value |
| `--ssm-volume`      | Chooses audio codec to use. For now, it only changes the scale factor. **FULL**: Maximum (**WARNING**: for speaker only, do not use with headphones). **HEADPHONE**: Lower volume for headphone use. **DEFAULT**: Default value +1dB because the true 0dB (`0b001111001`) decreases the signal a little bit. |
| `--ssm-speed`       | Changes **SSM ADC/DAC** sample rate. **DEFAULT**: 48kHz sample rate. **FAST**: 96Khz sample rate |

## Hardware Configuration (Zybo Z7-10/20)

#### Syfala Hardware Controller Board (SW3 UP)  

If you use a Hardware Controller Board, please set the `--controller-type` command-line parameter to the proper value (see below)

##### Controller-Type Values Description

- **DEMO**:  Popophone demo box
- **PCB1**: Emeraude PCB config 1: 4 knobs, 2 switches, 2 sliders (default)
- **PCB2**: Emeraude PCB config 2: 8 knobs
- **PCB3**: Emeraude PCB config 3: 4 knobs, 4 switches 
- **PCB4**: Emeraude PCB config 4: 4 knobs above, 4 switches below 

You can **swap from hardware to software controller** during DSP execution by changing **SW3**.

### Switch Description

Default configuration in **bold**  

<pre>
  SW3   SW2    SW1    SW0
+-----+-----+-------+------+
| Hard| ADAU| BYPASS| MUTE |
|     |     |       |      |
|     |     |       |      |
| <b>GUI</b> | <b>SSM</b> |<b>USE DSP</b>|<b>UNMUTE</b>|
+-----+-----+-------+------+
</pre>
- **SW3**: Controller type select: hardware (Controller board) or software (GUI).  
- **SW2**: Audio codec input select (ADAU=external or SSM=onboard). Does not affect output.  
- **SW1**: Bypass audio dsp.  
- **SW0**: Mute.  

### Status LEDs

The RGB led indicate the program state:

* **BLUE**: waiting
* **GREEN**: all good!
* **ORANGE**: warning (bypass or mute enabled)
* **RED**: ERROR! (configuration failed or incompatible), could happen if you select the SSM codec with incompatible sample rate.

The 4 LEDs above the switches indicate the switches state. If one of them blink, it indicates the source of the warning/error.

### SD Card Files

You can put the program on an SD card (if you want something reproducible and easily launchable, for the demos...).  
After a `make` command, you should see a `BOOT.bin` file in SW_export (or you can build it with `make boot_file`).  
Put the file on the root of SD card. And don't forget to put JP5 on 'SD' position !  
