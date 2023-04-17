This directory contains testbenches to simulate the real Faust/I2S interaction on vivado.

First we set up ghdl testbenches to check that I2S works correctly with emul_faust which is an emulation of Faust_v4 IP (I do not know how to simulate a vivado IP in GHDL). it seems that some tried (https://stackoverflow.com/questions/41469436/how-to-use-ghdl-to-simulate-generated-xilinx-ip), didn't check.

testbench_ghdl_emul_faust  validates the behaviour of emul_faust
testbench_ghdl_new_I2S validate the behaviour of I2S (the new stands for 'with at_done taken into account)
testbench_ghdl_both_I2S_emul_faust validates the fact that both IP should work correctly together

these thee simulation are OK

next comes simulation of the real Faust IP with vivado.
I could not figure out how to include a vivado IP inside a testbench as it is done in ghdl, all I could do is build a block design and indicate that the main_wrapper is the "top" and simulate by forcing, clock, reset and other signals. 

testbench_vivado_I2S_faust_v4 is the first vivado simulation with a correct behavious between I2S and Faust.
 
