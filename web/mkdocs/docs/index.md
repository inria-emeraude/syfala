# syfala v0.8.0

Automatic compilation of Faust and C++ audio DSP programs for AMD/Xilinx FPGA platforms.

## Supported platforms

- Digilent **Zybo Z7-10** - Zynq-7000 ARM/FPGA SoC Development Board

- Digilent **Zybo Z7-20** - Zynq-7000 ARM/FPGA SoC Development Board

- Digilent **Genesys ZU-3EG** - Zynq UltraScale+ MPSoC Development Board

and more to come...

## Dependencies

Please follow the instructions in the file [dependencies.md](manual/dependencies.md) in order to install the **AMD-Xilinx** **toolchain** and various other dependencies.

## Installing

the command `make install` will install a **symlink** in **/usr/bin**. After this you'll be able to just run on your terminal: 

`syfala myfaustprogram.dsp` 

You'll also have to **edit** your shell **resource** **file** (~/.**bashrc** / ~/.**zshrc**) and set the following environment variable: 

```shell
export XILINX_ROOT_DIR=/my/path/to/Xilinx/root/directory
```

`XILINX_ROOT_DIR` is the root directory where all of the AMD-Xilinx tools (Vivado, Vitis, Vitis_HLS) are installed.

## Tutorials

### Getting started with syfala and Faust

[tutorials/getting-started-faust.md](tutorials/faust-getting-started.md)

In this tutorial, we will cover the essential topics to get you started with the **Faust programming language**, **syfala**, and audio programming on **FPGAs**. 

### Embedded Linux

Please report to the [tutorials/embedded-linux-getting-started.md](tutorials/embedded-linux-getting-started.md) document in order to get you started with the Embedded Linux for Syfala

### Using syfala with C++ (advanced)

[tutorials/cpp-tutorial-advanced.md](tutorials/cpp-tutorial-advanced.md)

This tutorial will show you how to program a syfala DSP *kernel* using C++. It is intended for advanced users.

## Quick getting-started

### Software

#### Faust targets

Building a simple example for the **default board** (Digilent Zybo **Z7-10)**:

```shell
syfala examples/faust/virtualAnalog.dsp
```

This will run the **full syfala toolchain** on the virtualAnalog.dsp **Faust** file, which will then be ready to be flashed on the board. Y**ou can specify the targeted board** using the `-b (--board)` option:

```shell
syfala examples/faust/virtualAnalog.dsp --board Z20
syfala examples/faust/virtualAnalog.dsp --board GENESYS
```

Once the build is finished (depending on your computer, it usually takes between 15 and 30 minutes to complete), you can **connect the board** to your computer with the proper **USB/Serial port cable** and run the `flash` command:

```shell
syfala flash
```

The board's **RGB LED** should then flash **green** after a few seconds, indicating that your program is running. You can now **start the Faust GUI application**, which will display a set of sliders/knobs/buttons and **update the DSP parameters in real-time through USB-UART**:

```shell
syfala start-gui
```

#### C++ targets

For C++ targets, the process is exactly the same (excepted for the GUI part, which is not available):

```shell
syfala examples/cpp/templates/bypass.cpp --board Z20
syfala flash
```

### Exporting and re-importing your builds

When you're done playing with your program, you can **save and export it** as a `.zip` file with the following command:

```shell
syfala export my-faust-virtual-analog-build
# output in 'export/my-faust-virtual-analog-build.zip'
```

The resulting `.zip` file is now available in the repository's `export` directory, you can **re-import** it by typing:

```shell
syfala import export/my-faust-virtual-analog-build.zip
```

### Building another DSP target

Before building another DSP program, please **make sure you have saved and exported your previous build** beforehand, otherwise **it will be overwritten** whenever you start a new build. 

```shell
syfala examples/my-new-dsp-build.dsp
```

### Hardware (Digilent **Zybo-Z7-10/20** boards)

- Jumper **JP5** should be on *JTAG* 

- **Power select** jumper should be on *USB*  

- **Switches** SW0, SW1, SW2, SW3 should be **down**  

- The **audio input** is **LINE IN** (blue), not MIC IN  

- The **audio output** is the black **HPH OUT** jack  

## Going further

Please report to the [reference](manual/reference.md) for more information on available **commands**, **options** and documentation.

## The syfala team

Here is a list of person that have contributed to the Syfala project :

- Tanguy Risset
- Yann Orlarey 
- Romain Michon
- Stephane Letz
- Florent de Dinechin
- Anastasia Volkova
- Alain Darte
- Yohan Uguen
- Gero Müller
- Adeyemi Gbadamosi
- Ousmane Touat
- Luc Forget
- Antonin Dudermel
- Maxime Popoff
- Thomas Delmas
- Oussama Bouksim
- Pierre Cochard
- Joseph Bizien
- Agathe Herrou
- Jurek Weber
- Aloïs Rautureau
- Jessica Zaki-Sewa
