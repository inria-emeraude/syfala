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
- **No out-of-the-box GUI/Serial** control interface.
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

You should also be able, from this file, to access some useful *compile-time* data, such as the **current sample rate**, or **sample-width** which are defined with the following **macros**: 

```cpp
#define SYFALA_SAMPLE_RATE 48000
#define SYFALA_SAMPLE_WIDTH 24
```

### Audio inputs & outputs

First, in order to generate the *block design* that is going to be synthesized by **Vivado** and make the proper connections with *i²s*, **syfala** needs to be **explicitly informed of the number of audio input/output** channels that the DSP program is going to have. In our case, for the *stereo gain* example, we want **2 inputs** and **2 outputs**. To do so, in the current version of **syfala**, the following C macros need to be defined somewhere in the code:

```cpp
// examples/cpp/templates/gain.cpp
#define INPUTS 2
#define OUTPUTS 2
```

It will inform the toolchain to use the following **audio input and output ports**, which will  be formatted like this in our final design:

- `audio_in_#` (in our case, `audio_in_0` and `audio_in_1`)
- `audio_out_#` (in our case, `audio_out_0` and `audio_out_1`)

### Top-level interface

The *top-level function* is the DSP *kernel*'s' entrypoint, which, in the final *block design*, will be connected to other peripherals, such as the **i²s** and the **processing system**, with the help of various bus interfaces (AXI, AXI-Lite).

Its **arguments** should be considered as a **list of input & output ports**, with:

- **pointer** arguments being **output** arguments (or both *input* & *output* arguments)
- **non-pointer** arguments being **input** arguments only.
- **array** arguments can be both.

It's **signature** should always be `void syfala(...)`:

```cpp
// examples/cpp/templates/gain.cpp

/* Top-level interface function */
void syfala (
        // Audio input/output ports (variable):
        sy_ap_int audio_in[INPUTS],
        sy_ap_int audio_out[OUTPUTS],
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
        sy_ap_int audio_in[INPUTS],
        sy_ap_int audio_out[OUTPUTS],
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

Below, the HLS interface **pragmas should also remain the same,** they're here to indicate to **Vitis HLS** two things:

- to split the input/output audio arguments into **individual ports** (which will be named `audio_in_0`, `audio_in_1`, `audio_out_0`, `audio_out_1`)
- to map some of the top-level arguments to *AXI* and *AXI-Lite* bus interfaces (which will be further explained later).

```
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
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

In all standard **syfala designs**, the `bypass` and `mute` ports of a *DSP kernel* are pre-mapped to `SW0` and `SW1` in Zybo Z10/Z20 boards. You can choose to acknowledge and process them if you want:

```cpp
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                audio_out[0] = audio_in[0];
                audio_out[1] = audio_in[1];
            } else if (mute) {
                audio_out[0] = 0;
                audio_out[1] = 0;
            } else {
```

### DSP code

Finally, here is an example of a *processing function* taking advantage of the `Syfala::HLS::ioreadf()` and `Syfala::HLS::iowritef()` convenience functions in order to switch back & forth between `float` and `sy_ap_int` types.

```cpp
            } else {
                /* ... or compute samples here */
                compute(audio_in, audio_out);
            }
```

For our *stereo gain* example, we first convert the input data to *float*, multiply it by `0.5f` and **write it back to the output ports**.

```cpp
static void compute(sy_ap_int const inputs[], sy_ap_int outputs[])
{
    // if you need to convert to float, use the following:
    // (audio inputs and outputs are 24-bit integers by default)
    float f0 = Syfala::HLS::ioreadf(inputs[0]) * 0.5f;
    float f1 = Syfala::HLS::ioreadf(inputs[1]) * 0.5f;
    Syfala::HLS::iowritef(f0, outputs[0]);
    Syfala::HLS::iowritef(f1, outputs[1]);
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

C simulation is an important Vitis HLS feature, which allows you to test your C-written kernel without having to get through the full synthesis process. In short: Vitis HLS *guarantees* (with a few exceptions) that the outputs of your kernel is going to be the same as they would be in a real context of execution.

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
     sy_ap_int audio_in[2],
     sy_ap_int audio_out[2],
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
sy_ap_int audio_in[2] = {0, 0};
sy_ap_int audio_out[2] = {0, 0};
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
            Syfala::HLS::iowritef(f_inputs[0], audio_in[0]);
            Syfala::HLS::iowritef(f_inputs[1], audio_in[1]);
        // call top-level function
            syfala(audio_in, audio_out,
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
		f_outputs[0] = Syfala::HLS::ioreadf(audio_out[0]);
		f_outputs[1] = Syfala::HLS::ioreadf(audio_out[1]);
		printf("[ch0] input: %f, result: %f\n", f_inputs[0], f_outputs[0]);
		printf("[ch1] input: %f, result: %f\n", f_inputs[1], f_outputs[1]);
	}
```

## Optimizing code 

For simple examples, such as our previous *stereo-gain kernel*, there's obviously not going to be an immediate and imperative need for optimization. Consequently, we will this time get our hands on something a little **more resource and computation hungry**.

In audio digital signal processing, **FIR filters** are encountered on a very regular basis, and, depending on the number of coefficients that they have, they can be tricky to implement on FPGAs, especially if no optimizations are made. Let's have a look at our `examples/cpp/fir/fir.cpp` example:  

```cpp
#include "coeffs.hpp"

static float coeffs[] = {
    0.000000000000000000,
    -0.000000914435621961,
    0.000000000000000000,
    0.000008609100789076,
    [...]
};

#define INPUTS 0
#define OUTPUTS 2
#define NCOEFFS 115

static float samples[NCOEFFS];
static float sawtooth;

float compute_fir() {
    float out = 0;
    samples[0] = sawtooth;
    for (int n = 0; n < NCOEFFS; ++n) {
         out += mem[n] * coeffs115[n];
    }
    for (int j0 = NCOEFFS-1; j0 > 0; --j0) {
         mem[j0] = samples[j0-1];
    }
    sawtooth += 0.01f;
    sawtooth = fmodf(sawtooth, 1.f);
    return out;
}
```

In this example, we first statically define a bunch of **FIR coefficients** in the `examples/cpp/fir/coeffs.hpp` header, as well as a **zero-initialized array** (`samples[NCOEFFS]`), which will be used to store the previous samples. The `compute_fir` function generates a really **basic phasor/sawtooth signal**, and feed it into the FIR filter. Once all the samples are computed for `NCOEFFS`, we **shift** the `samples[]` array by one in the right direction. Then, as in our previous examples, we call the '**compute**' function from the `syfala` top-level function. In this case, we are going to write the same signal on both left and right output channels.

```cpp
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                float f = compute_fir();
                Syfala::HLS::iowritef(f, audio_out[0]);
                Syfala::HLS::iowritef(f, audio_out[1]);
```

### Monitoring latency & resource utilization

Now, in order to evaluate the program's performance and efficiency, the first thing that we can do is run the **High Level Synthesis step** and carefully read the **output results**. This can be done using the following command:

```shell
syfala examples/cpp/fir/fir.cpp --board Z10 --hls
```

which is going to give us this **estimate**:

```
fir.cpp Z10 48000 24 (Vitis HLS estimate)
115 coefficients

- DSP:	 8% (7)
- Reg:	 5% (1829)
- LUT: 	20% (3617)
- BRAM:  2% (3)

Tot. 1057 Cycles, 8.602us
Max. 2559 Cycles, 20,8333us
Lat. 41%
```

Needless to say, even for a **Zybo Z7-10**, this is not really satisfying: if we project ourselves **linearly**, it means that we could probably only **fit at best a 300 coefficients FIR filter** or so without reaching the **maximum sample latency**. Let's try it out with 300 coefficients now:

```
fir.cpp Z10 48000 24 (Vitis HLS estimate)
300 coefficients

- DSP:	 8% (7)
- Reg:	 5% (1837)
- LUT: 	20% (3619)
- BRAM:  2% (4)

Tot. 2722 Cycles, 22.152us
Max. 2559 Cycles, 20,8333us
Lat. 106%
```

With a **300-coefficients filter**, we even actually go a little bit **above max latency**. On the other hand, we can see that the resources stay pretty much the same as before, so there's probably room for improvement here in terms of **balance** between latency & resource utilization, and the first thing we can do to remedy this problem would maybe be to use some of the **Vitis HLS C/C++ pragmas**.

### Using optimization directives & pragmas

Now, what we really want Vitis HLS to do here, for the latency to drop down, would be to **parallelize the computations** a bit more. If we go through **Vitis HLS documentation**, there are a couple of things that can be tried in order to do that, without modifying the code too much. Our first choice here would be to use the **unroll #pragma**, which could introduce more parallelization in our **accumulation loop**:

```cpp
float compute_fir() {
    float out = 0;
    mem[0] = sawtooth;
    for (int n = 0; n < NCOEFFS; ++n) {
        #pragma HLS UNROLL
         out += mem[n] * coeffs[n];
    }
    [...]
```

If we try to run HLS with this code, we see that pretty much nothing happens (the results may even be  worse than before). That's because this particular accumulation loop cannot really be parallelized without using what we call a **balanced tree** (in our case, an 'adder tree'). By default, Vitis HLS does not automatically make this optimization for floating-point operations, but it can be enabled using the `--unsafe-math-optimizations` (or `--umo`) flag in the syfala command line:

```shell
syfala examples/cpp/fir/fir300.cpp --hls --umo
```

Let's now try to see what it's giving us for our **300 coefficients** example:

```
fir.cpp Z10 48000 (Vitis HLS estimate)
300 coefficients

- DSP:	31% (25)
- Reg:	18% (6532)
- LUT: 	66% (3619)
- BRAM:  1% (2)

Tot. 529 Cycles, 4.536us
Max. 2559 Cycles, 20,8333us
Lat. 20%
```

The results are definitely more reasonable in terms of latency. On the other hand, we can see that the resources (**LUTs** in particular) have increased a lot. If we push it a little bit more, let's say with **600 coefficients** this time, this is what we get:

```
fir.cpp Z10 48000 (Vitis HLS estimate)
600 coefficients

- DSP:	31% (25)
- Reg:	23% (8101)
- LUT: 	85% (15019)
- BRAM:  1% (2)

Tot. 987 Cycles, 8.537us
Max. 2559 Cycles, 20,8333us
Lat. 38%
```

With **600 coefficients**, we're still okay on latency, but the **Lookup Table** (**LUT**) **number** is now getting dangerously **high**. 

Remember: the numbers shown on these reports are only **an estimate**, which means that this number could be in reality a bit higher, introducing the risk that our kernel might not actually fit on the Zybo Z7-10 board. 

#### Accurate reports

In a situation like this one, it is usually a good idea to tell Vitis HLS that we need **a more accurate report** on the allocated resources. Adding the `--accurate-use` flag to the syfala command line will do exactly that for us:

```shell
syfala examples/cpp/fir300.cpp --hls --umo --accurate-use
```

This will tell Vitis HLS to run both the **synthesis** and **implementation** **steps** on the *DSP kernel* only (not on the final design). It usually takes more time (approximately 5 to 10 minutes, depending on the kernel), but it will give precise and valuable information on the resources that will be used on the board:

```
                                GUIDELINE
- DSP:	31% (25)		OK (80%)
- Reg:	22% (7912)		OK (50%)
- LUT: 	70% (12332)		WARNING (70%)
- BRAM:  1% (2)			OK (80%)
```

If we now look at the **GUIDELINE** column, we can see that we have indeed a **WARNING** on the LUT section, which basically means that the design may not fit on the board. But instead of trying to run the full synthesis and hope for the best, maybe we can tweak the **pragmas** a little more, to give ourselves a safer margin.

**Vitis HLS documentation** tells us that we can add to the **UNROLL pragma ** a parameter called`factor` , which basically represents the level of parallelization that we want to introduce in the loop. When this parameter is **not explicitly set**, Vitis HLS will **fully unroll the loop**, which might explain why the number of LUTs has sky-rocketted in our previous examples. If we tune this factor with a lower number, it might help bring down the utilization of this specific FPGA resource. Let's try it now with a **factor** `10`, and see what it does:

```cpp
float compute_fir() {
    [...]
    for (int n = 0; n < NCOEFFS; ++n) {
        #pragma HLS UNROLL factor=10
         out += samples[n] * coeffs[n];
    }
    [...]
```

Which is going to give us:

```
fir.cpp Z10 48000 (Vitis HLS estimate)
600 coefficients

- DSP:	15% (12)
- Reg:	 9% (3452)
- LUT: 	28% (4966)
- BRAM:  3% (4)

Tot. 1139 Cycles, 9.269us
Max. 2559 Cycles, 20,8333us
Lat. 44%
```

This is starting to get a lot better, and if we go up to **1000 coefficients** now:

```
fir.cpp Z10 48000 (Vitis HLS estimate)
1000 coefficients

- DSP:	15% (12)
- Reg:	 9% (3452)
- LUT: 	28% (4966)
- BRAM:  3% (4)

Tot. 1859 Cycles, 15.129us
Max. 2559 Cycles, 20,8333us
Lat. 72%
```

The results here are getting really interesting, since we can clearly see that **the resources used are exactly the same** as our 600 coefficients example. Latency is the only thing that has increased, from 44% to 72%, which remains a somewhat comfortable margin.

### Using a 'sample block' configuration (--multisample)

Another method that can be used in order to balance latency and resource utilization would be for the DSP kernel **to process a block of samples** instead of a single one, i.e. to '**bufferize**' the signal to maximize efficiency and parallelization. Not unlike CPUs,  this may also result in better FPGA resource dispatch and/or throughput, but has on the other hand the drawback of introducing **I/O latency**.

**Syfala** supports **sample block processing** for both Faust and C++ targets,  by adding the `--multisample <N>` flag:

```shell
syfala examples/cpp/templates/gain-multisample.cpp --multisample 16 --hls
```

For C++ targets, the code needs to be adapted a bit, since we now have **FIFO arrays** as inputs and outputs, we have to declare them as **C multidimensional arrays**, like the following: 

```cpp
void syfala (
        sy_ap_int audio_in[INPUTS][SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES],
    	[...]
```

```cpp
#pragma HLS INTERFACE ap_fifo port=audio_in
#pragma HLS INTERFACE ap_fifo port=audio_out
#pragma HLS array_partition variable=audio_in type=complete
#pragma HLS array_partition variable=audio_out type=complete
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
```

Within the top-level function, this also changes the way we have to process the **bypass/mute switches**:

```cpp
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
            	for (int n = 0; n < OUTPUTS; ++n) {
                	for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
                             audio_out[n][m] = audio_in[n][m];
                	}
                }
            } else if (mute) {
                for (int n = 0; n < OUTPUTS; ++n) {
                	for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
                             audio_out[n][m] = 0;
                	}
                }
```

And finally our **compute function**:

```cpp
            } else {
                /* ... or compute samples here */
                compute(audio_in, audio_out);
            }
```

```cpp
// examples/cpp/templates/gain-multisample.cpp

static void compute(sy_ap_int const inputs[INPUTS][SYFALA_BLOCK_NSAMPLES],
                    sy_ap_int outputs[OUTPUTS][SYFALA_BLOCK_NSAMPLES])
{
    for (int n = 0; n < OUTPUTS; ++n)
    	for (int m = 0; m < SYFALA_BLOCK_NSAMPLES; ++m) {
         	// if you need to convert to float, use the following:
         	// (audio inputs and outputs are 24-bit integers by default)
         	float f = Syfala::HLS::ioreadf(inputs[n][m]) * 0.5f;
         	Syfala::HLS::iowritef(f, outputs[n][m]);
    	}
	}
}
```

#### FIR example

Let's get back to our FIR example, in order to see what can be done to optimize things a bit more. An unoptimized `multisample` example can be found in `examples/cpp/fir/fir-multisample.cpp`. 

Let's see what kind of results we get with a **block of size 16 and 300 coefficients**:

```shell
syfala examples/cpp/fir/fir-multisample.cpp --board Z10 --multisample 16 --hls
```

```
fir-multisample.cpp Z10 48000 (Vitis HLS estimate)
block size: 16 samples
300 coefficients

- DSP:	 8% (7)
- Reg:	 5% (1935)
- LUT: 	21% (3829)
- BRAM:  3% (4)

Tot. 43585 Cycles, 0.355ms
Per sample: 2724 Cycles.
Max. 2559 Cycles, 20,8333us
Lat. 106%
```

Compared to our unoptimized 'one-sample' FIR example with the **same number of coefficients**, and considering we also introduce **an I/O latency of 16 samples** (about 0.3 milliseconds), we can say with confidence that this is not really good, and that's essentially because - if we carefully look at the more advanced reports that Vitis HLS is giving us - **the samples are still processed sequentially**, which is not going to introduce a lot of changes compared to the single-sample version. Consequently, even if we unroll our accumulation loop as we did before, the results are also going to be more or less the same. 

[...]

#### CSIM with --multisample configuration:

```shell
syfala examples/cpp/templates/gain-multisample.cpp
       --multisample 32
       --csim tests/csim/csim_cpp_template_multisample.cpp
       --csim-inputs tests/stimuli
       --csim-iter 5
# output results will be stored in reports/csim/gain-multisample/out0.txt & reports/csim/gain-multisample/out1.txt
```

## Sharing processing/control with the ARM executable

Since the resources on a FPGA are far from being infinite, it is usually preferable to use a custom **ARM** executable for some specific use-cases, such as:

- Initialization of **constants**, **wavetables**...
- Long **delay-lines** (stored/initialized in DDR memory).
- **Control-rate** computations.
- etc.

This is exactly what **syfala** does under the hood with **Faust programs**: control-rate expressions, resulting from the sliders/button being interacted with, are for instance made on the ARM, and shared through a memory bus called **AXI-Lite**. 

The following example shows how we can implement a similar (though simpler) control-rate *gain* parameter, which we will be able update on the console and share with the DSP kernel.

### Basic AXI-Lite control example

This example, which you can find in `examples/cpp/templates/gain-control-hls.cpp`, is almost exactly the same as our previous `gain.cpp` example. The only difference is that we want to make **variable** the `gain` parameter that we *hardcoded* to `0.5f` before. All we basically need to do here is to introduce a new floating-point argument `gain` **in the top-level function**, which will also be declared as an **AXI-Lite** interface port using the appropriate `pragma`: 

```cpp
void syfala (
        sy_ap_int audio_in[INPUTS],
        sy_ap_int audio_out[OUTPUTS],
    	   [...]
           float gain
) {
[...]
#pragma HLS INTERFACE s_axilite port=gain
```

For the rest of the code, we simply add `gain` to the `compute()` function's arguments, and then apply it to the inputs.

```cpp
            } else {
                /* ... or compute samples here */
                compute(audio_in, audio_out, gain);
            }
```

```cpp
static void compute(sy_ap_int const inputs[],
                    sy_ap_int outputs[]
                    float gain) {
    float f0 = Syfala::HLS::ioreadf(inputs[0]) * gain;
    float f1 = Syfala::HLS::ioreadf(inputs[1]) * gain;
    Syfala::HLS::iowritef(f0, outputs[0]);
    Syfala::HLS::iowritef(f1, outputs[1]);
}
```

That's it! On the **HLS side** of things, it remains pretty simple. On the **ARM side**, it gets unfortunately a bit more complicated, as we are going to see now :-)

#### DSP kernel drivers

We already know that Vitis HLS is going to take our `gain-control-hls.cpp` file and generate the VHDL-equivalent, which is then going to be integrated in our final design. But it's not the only thing that it does: among other things, **it also generates 'drivers' for interacting with the kernel from the ARM**.

Let's first **synthesize** our DSP kernel with Vitis HLS, and take a look at some of the files that are generated in the `build` directory:

```shell
syfala examples/cpp/templates/gain-control-hls.cpp --hls
```

If we now go in the `build/syfala_ip/syfala/impl/ip/drivers/syfala_v1_0/src` directory, we see that a Makefile and **some C files have been generated**, specifically:

```
- xsyfala.c
- xsyfala.h
- xsyfala_hw.h
- xsyfala_linux.c
- xsyfala_sinit.c
```

We're not going to go into details about each file: the one that is truly interesting to us in the context of our example is the `xsyfala.h` **C header** . If we **open this file**, we see that the following **function prototypes** are declared: 

```cpp
void XSyfala_Set_arm_ok(XSyfala *InstancePtr, u32 Data);
u32 XSyfala_Get_arm_ok(XSyfala *InstancePtr);
void XSyfala_Set_mem_zone_f(XSyfala *InstancePtr, u64 Data);
u64 XSyfala_Get_mem_zone_f(XSyfala *InstancePtr);
void XSyfala_Set_mem_zone_i(XSyfala *InstancePtr, u64 Data);
u64 XSyfala_Get_mem_zone_i(XSyfala *InstancePtr);
void XSyfala_Set_gain(XSyfala *InstancePtr, u32 Data);
u32 XSyfala_Get_gain(XSyfala *InstancePtr);
```

You can see that these functions' names match some of the arguments that we put in the top-level function. That's because these arguments are already registered as **AXI** or **AXI-Lite** interface arguments in our **DSP kernel code**:

```cpp
void syfala (
    	   [...]
           int arm_ok,
        float* mem_zone_f,
          int* mem_zone_i,
         float gain
) {
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE s_axilite port=gain
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram
```

 In our case, since the other arguments `arm_ok`, `mem_zone_f` and `mem_one_i` are already taken of by **syfala**, the one that is going to be useful to us is the `gain` parameter, and, specifically, its **'setter' function**:

```cpp
void XSyfala_Set_gain(XSyfala *InstancePtr, u32 Data)
```

#### Writing the ARM executable

In order to code the executable that is going to run on the ARM, we will take the code from`source/arm/baremetal/arm_minimal.cpp`, which contains all that is necessary for the application to run properly, and we are going to add our `gain` **control function**. The result can be seen in `examples/cpp/templates/gain-control-arm.cpp`.

In our `update_gain()` function, we are simply going to fetch a new `gain` value using `scanf`, and update it on the FPGA using the `XSyfala_Set_gain` **driver function**:

```cpp
static void update_gain(XSyfala& syfala) {
    static float gain = 1.f;
    printf("Enter gain value (from 0.f to 1.f)\r\n");
    scanf("%f", &gain);
    printf("Gain: %f\r\n", gain);
    XSyfala_Set_gain(&syfala, *reinterpret_cast<u32*>(&gain));
}
```

> **Note**: floating-point data have to be set using `reinterpret_cast<u32*>`, otherwise, it will be interpreted as an integer and truncated. 

In the `main()` function, all we have to do now is call our `update_gain()` function in the **main event loop**, passing it the `XSyfala` handle `struct`.

```cpp
int main(int argc, char* argv[]) {
    XSyfala syfala;
    UART::data uart;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    UART::initialize(uart);
    // Wait for all peripherals to be initialized
    Status::waiting(RN("[status] Initializing peripherals & modules"));
    Audio::initialize();
    IP::initialize(syfala);
    IP::set_arm_ok(&syfala, true);
    Status::ok(RN("[status] Application ready, now running..."));

    // main event loop:
    while (true) {
       // --------------------------------------------------------
       update_gain(syfala);
       sleep(1);
       // --------------------------------------------------------
    }
    return 0;
}
```

#### Running syfala

Finally, **to fully run syfala on our example**, including the ARM executable, we need to add the `--arm-target` **flag** to the command line, with the path to our `.cpp` file as an argument:

```shell
syfala examples/cpp/templates/gain-control-hls.cpp --arm-target examples/cpp/templates/gain-control-arm.cpp --board Z10
```

### Delay-line AXI example (DDR memory)

[...]
