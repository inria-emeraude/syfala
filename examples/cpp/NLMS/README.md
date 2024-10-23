# NLMS README

The folder contains an implmentation of the Normalised Least Mean Square adaptative filtering algorithm.
A `Makefile` allows to compile and launch the different implementations.

## Setup
In the `Makefile`, change the `SYFALA_DIR` and `VITIS_HLS_INCUDE_DIR` to the location of the root of syfala and the includes of Vitis HLS. Also change the `VITIS_VERSION` to the version you are using.

## Files
The HLS implementation in `NLMS_hls.cpp` is based on the original code in `NLMS_orignial.cpp`.

The `generate_and_plot_result.jl` file is used to generate the input signals and to plot the result of the CSIM. Use it by including it in a julia REPL and calling either `generate_inputs`, `read_inputs`, `read_output_std` or `read_outputs_HLS`.