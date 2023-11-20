# Using syfala with C++

## Introduction

While Faust is undoubtedly a nice and easy way to create complex and fully-controllable DSP programs on FPGAs, in some cases - where for instance balancing resource usage and latency becomes a critical issue - bypassing Faust and programming directly in C++ can become a more suitable solution.

#### How does it work?

Ordinarily, the easiest way to get started with *syfala* is to use *Faust* to generate the C++ code that is going to be fed to the **High Level Synthesis** (**HLS**) tool and turned into **Hardware Description Language** (HDL) code. The resulting DSP *kernel* (or *IP*: Intellectual Property) is then going to be added to a more global *design*, which will include the **processing system** (PS), our custom-made **Integrated Interchip Sound** (*i²s*) and various other modules as well.

Consequently - and since we're already using *HLS* - programming the DSP *kernel* directly in C++ is entirely possible, but remains a more complex solution, and won't offer the same user-friendly features that Faust is able to provide out-of-the-box.

#### Pros:

- Better **balance control** between **FPGA resource usage** & **latency**.
  - HLS-friendly/optimized code.
  - HLS libraries, pragmas & tools.


#### Cons:

- Limited support of C++ features (up to **C++14**).
- Complex HLS interfaces & documentation.
- **No out-of-the-box UART/GUI** control interface.
- Data exchange with **ARM** through *AXI-Lite* or *DDR* memory has to be done manually.

## Code structure

The following describes how to program a syfala DSP *kernel* using C++. It is intended for advanced users.

### Using pre-made examples

To get an idea on how to program the DSP *kernel* in C++, you can refer to the `examples/cpp` directory in the **syfala** repository.

For this tutorial, we will build a simple *stereo gain* DSP kernel. The interface that we propose is pretty straightforward, but there a couple of things that still need to be explained in details:

### Signal types

In the global syfala FPGA design, audio signals are conveyed as streams of **24-bits integers, by default**. The bit width can be changed using the `--sample-width` flag in the **syfala** command line interface, but cannot be changed to single or double precision floating point types.  Since audio DSP programs are usually processing `float` or `double`-based signals, a few convenience functions and types have been added in the `syfala/utilities.hpp` header, which can be easily included in your C++ file:

```c++
#include <syfala/utilities.hpp>
```

This header defines for instance the type `sy_ap_int`, as the following:

```cpp
// include/syfala/utilities.hpp

using sy_ap_int = ap_int<SYFALA_SAMPLE_WIDTH>;
// note: the 'ap_int' (arbitrary precision integer) type is defined by Vitis_HLS in $XILINX_ROOT_DIR/Vitis_HLS/2022.2/include/ap_int.h
```

It also defines the following **read/write convenience functions** between `sy_ap_int` and `float` types. These will come in handy when reading and writing from/to the audio input/output ports.

```cpp
// include/syfala/utilities.hpp

namespace Syfala::HLS {
/**
 * @brief ioreadf Read sy_ap_int as float
 * @param input sy_ap_int data input
 * @return floating-point conversion of input
 */
float ioreadf(sy_ap_int const& input);
/**
 * @brief iowritef write floating point data to ap_int
 * top-level function output.
 * @param f float data input
 * @param output ap_int interface output.
 */
void iowritef(float f, sy_ap_int& output);
}
```

### Audio inputs & outputs

First, in order to generate the *block design* that is going to be synthesized by **Vivado** and make the proper connections with *i²s*, **syfala** needs to be **explicitly informed of the number of audio input/output** channels that the DSP program is going to have. In our case, for the *stereo gain* example, we want **2 inputs** and **2 outputs**. To do so, in the current version of **syfala**, the following C macros need to be defined somewhere in the code:

```cpp
// examples/cpp/templates/gain.cpp
#define INPUTS 2
#define OUTPUTS 2
```

It will inform the toolchain to use the following **audio input and output ports**, which will have to be formatted in the exact same way in the **top-level interface** function:

- `audio_in_#` (in our case, `audio_in_0` and `audio_in_1`)
- `audio_out_#` (in our case, `audio_out_0` and `audio_out_1`)

### Top-level interface

The *top-level function* is the DSP *kernel*'s' entrypoint, which, in the final *block design*, will be connected to other peripherals, such as the **i²s** and the **processing system**, with the help of various bus interfaces (AXI, AXI-Lite).

Its **arguments** should be considered as a **list of input & output ports**, with:

- **pointer** arguments being **output** arguments (or both *input* & *output* arguments)
- **non-pointer** arguments being **input** arguments only.

It's **signature** should always be `void syfala(...)`:

```cpp
// examples/cpp/templates/gain.cpp

/* Top-level interface function */
void syfala (
        // Audio input/output ports (variable):
        sy_ap_int audio_in_0,
        sy_ap_int audio_in_1,
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
        // The following arguments are required and should not be changed:
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
    [...]
```

Again, each **audio input & output arguments** have to be formatted exactly like the following:

```cpp
void syfala (
        // Audio input/output ports (variable):
        sy_ap_int audio_in_0,
        sy_ap_int audio_in_1,
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
```

And have to be followed by **these exact same arguments** (which we will present in the next sections):

```cpp
        // The following arguments are required and their respective names should not be changed:
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
    [...]
```

Below, the HLS interface **pragmas should also remain the same,** they're here to indicate to **Vitis HLS** to map some of the top-level arguments to *AXI* and *AXI-Lite* bus interfaces (which will be further explained later).

```
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
```

### Initialization

#### Waiting for ARM initialization

Since the *DSP kernel* and the *ARM* are **not synchronized at a sample-rate level**, and the *ARM* has to first initialize a few peripherals (audio codecs, GPIOs, UART...) before being able to do anything else, it is necessary for the *DSP kernel* to wait for the `arm_ok` **signal** to be received before doing any initialization or processing.

Once the *ARM* is ready, the initialization routine can be done manually with, for example, a static `initialization` variable. In our *stereo gain* example, we do:

```cpp
static bool initialization = true;
[...]
	/* Initialization and computations can start after the ARM
     * has been initialized */
    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
            // Initialize all runtime data here.
            // don't forget to toggle the variable off
            initialization = false;
        } else {
```

### Bypass/mute switches

In all standard **syfala designs**, the `bypass` and `mute` ports of a *DSP kernel* are pre-mapped to `SW0` and `SW1` in Zybo Z10/Z20 boards. You can choose to acknowledge them if you want:

```cpp
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                audio_out_0 = audio_in_0;
                audio_out_1 = audio_in_1;
            } else if (mute) {
                audio_out_0 = 0;
                audio_out_1 = 0;
            } else {
```

### DSP code

Finally, here is an example of a *processing function* taking advantage of the `Syfala::HLS::ioreadf()` and `Syfala::HLS::iowritef()` convenience functions in order to switch back & forth between `float` and `sy_ap_int` types.

```cpp
            } else {
                /* ... or compute samples here */
                compute(audio_in_0, audio_in_1, audio_out_0, audio_out_1);
            }
```

For our *stereo gain* example, we first convert the input data to *float*, multiply it by `0.5f` and **write it back to the output ports**.

```cpp
static void compute(sy_ap_int const input_0,
                    sy_ap_int const input_1,
                    sy_ap_int* output_0,
                    sy_ap_int* output_1)
{
    // if you need to convert to float, use the following:
    // (audio inputs and outputs are 24-bit integers by default)
    float f0 = Syfala::HLS::ioreadf(input_0) * 0.5f;
    float f1 = Syfala::HLS::ioreadf(input_1) * 0.5f;
    Syfala::HLS::iowritef(f0, output_0);
    Syfala::HLS::iowritef(f1, output_1);
}
```

## Building and flashing with the syfala CLI

**syfala** works the same way with C++ targets, you'll only need to replace the Faust `.dsp` target with your `.cpp` file in the command line. We can now try to synthesize our *stereo gain DSP kernel*, in order to see if our code compiles:

```shell
syfala examples/cpp/templates/gain.cpp --board Z20 --hls
```

Once the high-level synthesis is done, **syfala** should display the **Vitis HLS estimate** of the **kernel's latency and resource utilization**:

```
DSP     2% (6)
FF     ~0% (997)
LUT     3% (2070)
BRAM	0% (0)

Latency:
Tot. 47 Cycles 0.382us
```

## Verifying code with C simulation (CSIM)

We know now that our code compiles, but we won't be able to test it until the full **Vivado synthesis** & **implementation** are done, which, depending on your machine, can take up some time. We'll then have to flash the device, connect an audio-input and a headset to the board, and see if the *stereo gain* in our example is properly applied.

Needless to say, the process is a bit long and tedious. You don't really want to go through all of that too many times when you're debugging code, and that's precisely where **C simulation** (**CSIM**) comes into play.

C simulation is an important Vitis HLS feature, which allows you to test your C-written kernel without having to get through the full synthesis process. In short: Vitis HLS guarantees (with a few exceptions) that the outputs of your kernel is going to be the same as they would be in a real context of execution.

### Using pre-defined generic templates:

Now, if we get back to our *stereo gain* example, and since it is a really simple one, we will take advantage of the generic **CSIM C++ template** that is available in the syfala source tree (located in `tests/csim/csim_cpp_template.cpp`). Here's an example of command that can be used:

```shell
syfala examples/cpp/templates/gain.cpp --csim tests/csim/csim_cpp_template.cpp --csim-inputs tests/stimuli --csim-iter 64
# output results will be stored in reports/csim/gain/out0.txt & reports/csim/gain/out1.txt
```

Where:

- `--csim tests/csim/csim_cpp_template.cpp` - the simulation test file.
- `--csim-inputs tests/stimuli` - we specify using the `tests/stimuli` directory to fetch input samples.
  - `tests/stimuli` contains two `.txt` files, named `in0.txt` and `in1.txt` and are filled with normalized (`-1.f` to `1.f`) floating point values.
- `--csim-iter 64` - the DSP kernel will be called 64 times (64 samples).

We can finally verify the outputs of our *stereo gain* kernel, by comparing the input *stimuli* files with the output files (output samples should be `input/2`).

### Writing your own CSIM

While the generic template will work for simple *DSP kernels* that have the same top-level function signature, you will have to write your own CSIM file to validate kernels that have more complex interfaces. In order to do this, and since the generic template is scripted and a bit complicated to read, let's take inspiration from the `csim_cpp_template_gain.cpp` example file, and see what it is actually doing:

- We first **declare the syfala top-level function prototype**, which is going to have the **exact same signature** as in our `gain.cpp` file.

```cpp
// tests/csim/csim_cpp_template_gain.cpp

void syfala (
     sy_ap_int audio_in_0,
    sy_ap_int* audio_out_1,
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
);
```

- We then instantiate and pre-initialize **the values** that are going to be passed to the `syfala` **function arguments**:

```cpp
sy_ap_int audio_in_0 = sy_ap_int(0);
sy_ap_int audio_in_1 = sy_ap_int(0);
sy_ap_int audio_out_0 = sy_ap_int(0);
sy_ap_int audio_out_1 = sy_ap_int(0);
// Here, we simulate having the ARM initialized and ready, by setting the 'arm_ok' variable to 'true':
int arm_ok   = true;
// The i2s is not part of the simulation, so this really doesn't matter:
bool i2s_rst = false;
// We don't use DDR memory, nor the bypass/mute switches: set everything to zero:
float* mem_zone_f = nullptr;
int* mem_zone_i   = nullptr;
bool bypass = false;
bool mute   = false;
bool debug  = false;
```

- We also instantiate `float` type copies of inputs and outputs, for setting random input values, and printing outputs.

```cpp
    float f_inputs[2]  = {0, 0};
    float f_outputs[2] = {0, 0};
```

- Then, call the `syfala` function with all the proper arguments.

```cpp
	// For each simulation iteration (set with the '--csim-iter' flag)   
	for (int i = 0; i < SYFALA_CSIM_NUM_ITER; i++) {
         if (i > 0) {
         // first iteration = initialization, inputs will be ignored
         // wait for second iteration.
            f_inputs[0] = (float)rand()/RAND_MAX;
            f_inputs[1] = (float)rand()/RAND_MAX;
         }
         Syfala::HLS::iowritef(f_inputs[0], audio_in_0);
         Syfala::HLS::iowritef(f_inputs[1], audio_in_1);
        // call top-level function
		 syfala(audio_in_0, audio_in_1,
		 	   &audio_out_0, &audio_out_1,
			    arm_ok, &i2s_rst,
			    mem_zone_f, mem_zone_i,
			    bypass, mute, debug
      	);
        [...]
    }
```

- Once it is done, fetch and print the input/output samples (as float) :

```cpp
		[...]
		f_outputs[0] = Syfala::HLS::ioreadf(audio_out_0);
		f_outputs[1] = Syfala::HLS::ioreadf(audio_out_1);
		printf("[ch0] input: %f, result: %f\n", f_inputs[0], f_outputs[0]);
		printf("[ch1] input: %f, result: %f\n", f_inputs[1], f_outputs[1]);
	}
```

## Optimizing code 

For simple examples, such as our previous *stereo-gain kernel*, there's obviously not going to be an immediate and imperative need for optimization. Consequently, we will this time get our hands on something a little more resource and computation hungry.

In audio digital signal processing, FIR filters are encountered on a very regular basis, and, depending on the number of coefficients that they have, they can be troublesome to implement on FPGAs, let's have a look at the `examples/fir/fir.cpp` example:  

### Monitoring latency & resource usage



[...]

`--accurate-use`

### Using optimization directives & pragmas

[...]

### Using a 'sample-block' configuration (--multisample)

- One function call for one **block of N samples**.
- May result in better FPGA **resource usage** and/or **throughput**.
- Introduces **I/O latency**.

```shell
syfala examples/cpp/templates/gain_multisample.cpp --multisample 32 --board Z10
```

```cpp
void syfala (
        sy_ap_int audio_in_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_in_1[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES],
    	[...]
```

```cpp
#pragma HLS INTERFACE ap_fifo port=audio_in_0
#pragma HLS INTERFACE ap_fifo port=audio_in_1
#pragma HLS INTERFACE ap_fifo port=audio_out_0
#pragma HLS INTERFACE ap_fifo port=audio_out_1
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
```

```cpp
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = audio_in_0[n];
                     audio_out_1[n] = audio_in_1[n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = 0;
                     audio_out_1[n] = 0;
                }
```

```cpp
            } else {
                /* ... or compute samples here */
                compute(audio_in_0, audio_in_1, audio_out_0, audio_out_1);
            }
```

```cpp
static void compute(sy_ap_int const input_0[],
                    sy_ap_int const input_1[],
                    sy_ap_int output_0[],
                    sy_ap_int output_1[])
{
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
         // if you need to convert to float, use the following:
         // (audio inputs and outputs are 24-bit integers by default)
         float f0 = Syfala::HLS::ioreadf(input_0[n]) * 0.5f;
         float f1 = Syfala::HLS::ioreadf(input_1[n]) * 0.5f;
         Syfala::HLS::iowritef(f0, output_0[n]);
         Syfala::HLS::iowritef(f1, output_1[n]);
    }
}
```

#### Multisample configuration:

```shell
syfala examples/cpp/templates/gain_multisample.cpp
       --multisample 32
       --csim tests/csim/csim_cpp_template_multisample.cpp
       --csim-inputs tests/stimuli
       --csim-iter 5
# output results will be stored in reports/csim/gain_multisample/out0.txt & reports/csim/gain_multisample/out1.txt
```

### Sharing processing with the ARM

- Initialization of wavetables and other data on the ARM.
- delay-lines in DDR.
- Control-rate expressions.

## Controlling the DSP kernel from an ARM executable

[...]

```cpp
void syfala (
        sy_ap_int audio_in_0,
        sy_ap_int audio_in_1,
        sy_ap_int* audio_out_0,
        sy_ap_int* audio_out_1,
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug,
         float gain
) {
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=gain
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
```

```cpp
            } else {
                /* ... or compute samples here */
                compute(audio_in_0, audio_in_1,
                        audio_out_0, audio_out_1,
                        gain
                );
            }
```

```cpp
static void compute(sy_ap_int const input_0,
                    sy_ap_int const input_1,
                    sy_ap_int* output_0,
                    sy_ap_int* output_1,
                    float gain)
{
    // if you need to convert to float, use the following:
    // (audio inputs and outputs are 24-bit integers by default)
    float f0 = Syfala::HLS::ioreadf(input_0) * gain;
    float f1 = Syfala::HLS::ioreadf(input_1) * gain;
    Syfala::HLS::iowritef(f0, output_0);
    Syfala::HLS::iowritef(f1, output_1);
}
```

```cpp
#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>

using namespace Syfala;

constexpr auto set_gain = XSYFALA_SET(gain);

int main(int argc, char* argv[])
{
    XSyfala x;
    UART::data uart;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    UART::initialize(uart);
    // Wait for all peripherals to be initialized
    Status::waiting(RN("[status] Initializing peripherals & modules"));
    Audio::initialize();
    IP::initialize(x);
    IP::set_arm_ok(&x, true);
    float gain = 1.f;
    set_gain(&x, *reinterpret_cast<u32*>(&gain));

    Status::ok(RN("[status] Application ready, now running..."));
    // main event loop:
    while (true) {
       printf("Enter gain value (from 0.f to 1.f)\r\n");
       scanf("%f", &gain);
       printf("Gain: %f\r\n", gain);
       set_gain(&x, *reinterpret_cast<u32*>(&gain));
       sleep(1);
    }
    return 0;
}
```

```shell
syfala examples/cpp/templates/gain-control-hls.cpp --arm-target examples/cpp/templates/gain-control-arm.cpp --board Z10
```
