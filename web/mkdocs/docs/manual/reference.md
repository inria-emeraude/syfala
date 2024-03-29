# Command-line interface reference

## General options

| name                 | description                                                  | arguments          |
| -------------------- | ------------------------------------------------------------ | ------------------ |
| `-x` `--xilinx-root` | sets `XILINX_ROOT_DIR` for the current build                 | path               |
| `--xversion`         | sets `XILINX_VERSION` for the current build                  | `2020.2|2022.2*`   |
| `--board, -b`        | Defines the target board: Digilent Zybo Z7-10/20 or Genesys ZU-3EG | `Z10*|Z20|GENESYS` |

## Commands

| name           | description                                                  | arguments              |
| -------------- | ------------------------------------------------------------ | ---------------------- |
| `tidy`         | removes all temporary files generated by the toolchain       | none                   |
| `clean`        | deletes current build directory                              | none                   |
| `reset`        | deletes current build directory as well as the syfala_log & resets the current toolchain configuration | none                   |
| `import`       | sets previously exported .zip build as the current build     | path to the .zip build |
| `export`       | exports current build in a .zip file located in the 'export' directory | name of the build      |
| `report`       | displays HLS or global report                                | <hls\|**any***>        |
| `log`          | displays the current build's full log                        | none                   |
| `test`         | builds & runs all toolchain tests                            | none                   |
| `flash`        | flashes current build onto target device                     | none                   |
| `start-gui`    | executes the Faust-generated GUI application                 | none                   |
| `open-project` | opens the generated .xpr project with Vivado                 | <hls\|**any***>        |
| `help`         | prints list of available commands, options and run-time parameters | none                   |
| `version`      | displays the current script's version                        | none                   |

## Build options

| name      | description                                                  |
| --------- | ------------------------------------------------------------ |
| `--linux` | builds the embedded linux if doesn't already exist and exports the build in the root partition (`/home/syfala/mybuild`) |
| `--midi`  | adds MIDI control for the Faust GUI and/or the Embedded Linux Control Application |
| `--osc`   | adds OSC control for the Faust GUI and/or the Embedded Linux Control Application |
| `--http`  | adds HTTP control for the Faust GUI and/or the Embedded Linux Control Application |

## Design options

| name            | arguments                                      | description                                                  |
| --------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| `--multisample` | power of two integer (e.g. 16, 24, 32, *etc.*) | DSP block will compute a block of samples instead of a single one. This may improve overall throughput but will introduce audio i/o latency. |
| `--sigma-delta` | none                                           | Builds the project with a *sigma-delta* dac configuration (*experimental*) |
| `--tdm`         | none                                           | Builds the project with *i2s TDM* (*experimental*)           |
| `--ethernet`    | none                                           | (**linux only**) uses tcp/ip ethernet to convey input/output signals from & to faust |

## HLS options

| name                          | arguments                                             | description                                                  |
| ----------------------------- | ----------------------------------------------------- | ------------------------------------------------------------ |
| `--accurate-use`              | none                                                  | Runs HLS with the impl flow, shows more accurate resources/latency reports, but takes longer to run. |
| `--csim`                      | path to simulation .cpp file                          | Runs C simulation for the syfala DSP IP                      |
| `--csim-iter`                 | integer (1 to ...)                                    | Sets the number of `syfala` calls during the C simulation    |
| `--csim-inputs`               | path to directory containing `in0.txt / in1.txt etc.` | Set the directory containing input samples files (as `.txt` files). Each sample should be normalized floating point values going from -1.f to 1.f separated by a white space or a line return. |
| `--mcd`                       | none                                                  | (**faust only**) Max-copy-delay: threshold between copy and ring buffer implementation (default 16). |
| `--unsafe-math-optimizations` | `--umo`                                               | Adds the Vitis HLS `unsafe_math_optimizations` directive to the syfala DSP IP. |
| `--hls-flags`                 | Tcl string                                            | n/a                                                          |

## ARM options

| name                | arguments                          | description                                                  |
| ------------------- | ---------------------------------- | ------------------------------------------------------------ |
| `--shield`          | `adau|motherboard`                 | Adds support for *ADAU1777*/*ADAU1787* external codecs, or for the *ADAU Motherboard* |
| `--benchmark`       | none                               | (**faust only**) Enables benchmark for the ARM control-loop. |
| `--verbose`         | none                               | n/a                                                          |
| `--arm-target`      | path to .cpp file                  | Selects the main (.cpp) source file for the ARM control application. |
| `--controller-type` | `DEMO|PCB1*|PCB2|PCB3|PCB4|TEENSY` | Defines the controller used to drive the controls when SW3 is UP. |
| `--ssm-volume`      | `FULL|HEADPHONE*|DEFAULT`          | (**Zybo boards only**)  `HEADPHONE`: lower volume for headphone use. `DEFAULT`: default value +1dB, the true 0dB (`0b001111001`) decreases the signal a little bit. |
| `--ssm-speed`       | `FAST|DEFAULT*`                    | (**Zybo boards only**) changes **SSM ADC/DAC** sample rate. `DEFAULT`: 48kHz sample rate. **FAST**: 96Khz sample rate |

## Run steps

**Note**: the `--all` is not necessary if you wish to run all steps, just run `syfala myfaustdsp.dsp `

| `--all`     | runs all toolchain compilation steps (from `--sources` to `--gui`) |
| ----------- | ------------------------------------------------------------ |
| `--sources` | uses Faust to generate ip/host cpp files for HLS  and Host application compilation |
| `--hls`     | runs Vitis HLS on generated ip cpp file                      |
| `--project` | generates Vivado project                                     |
| `--synth`   | synthesizes full Vivado project                              |
| `--host`    | compiles Host application, exports sources and .elf output to `build/sw_export` |
| `--gui`     | compiles Faust GUI control application                       |
| `--flash`   | flashes boot files on device at the end of the run           |
| `--report`  | prints HLS report at the end of the run                      |
| `--export`  | `<id>` exports build to export/ directory at the end of the run |

## Run parameters

| parameter        | accepted values                            | description                                                  | default value |
| :--------------- | ------------------------------------------ | ------------------------------------------------------------ | ------------- |
| `--memory, -m`   | `DDR - STATIC`                             | (**faust only**) Choose between DDR & static memory layout for faust delay-lines, rd/rwtables. | `DDR`         |
| `--sample-rate`  | `48000 - 96000 - 192000 - 384000 - 768000` | Changes **sample rate** value (Hz). Only 48kHz and 96kHz is available for **SSM** embeded codec. 192000 (**ADAU1777** and **ADAU1787** only)  384000 (**ADAU1787** only)  768000 (**ADAU1787** only and with `--sample--width 16` only) | `48000`       |
| `--sample-width` | `16 - 24 - 32`                             | Defines **sample bit depth** (16\|24\|32)                    | `16`          |

## Hardware configuration (Zybo Z7-10/20)

### Syfala Hardware Controller Board (SW3 UP)

If you use a Hardware Controller Board, please set the `--controller-type` command-line parameter to the proper value (see below)

#### Controller-type values description

- `DEMO`:  Popophone demo box
- `PCB1`: Emeraude PCB config 1: 4 knobs, 2 switches, 2 sliders (default)
- `PCB2`: Emeraude PCB config 2: 8 knobs
- `PCB3`: Emeraude PCB config 3: 4 knobs, 4 switches
- `PCB4`: Emeraude PCB config 4: 4 knobs above, 4 switches below
- `TEENSY`: Teensy-based controller.

You can **swap from hardware to software controller** during DSP execution by changing **SW3**.

### Switch description

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

### SD card files (baremetal configuration)

You can put the program on an SD card (if you want something reproducible and easily launchable, for the demos...).
After a `make` command, you should see a `BOOT.bin` file in SW_export (or you can build it with `make boot_file`).
Put the file on the root of SD card. And don't forget to put JP5 on 'SD' position !
