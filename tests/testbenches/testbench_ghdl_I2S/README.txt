This directory explains how to use ghdl to simulate a VHDL file such as i2stransceiver.vhd.

WARNING: it is a test for the old I2S (without hand shake)

First install ghdl and gtkwave on your computer (ghdl in no more maintained in linux packages, http://ghdl.free.fr/site/pmwiki.php?n=Main.Download) 
sudo apt-get install  gtkwave

Then type "make" to compile and simulate the two vhdl files (test_bench_i2s.vhd
 shows how to read samples from a file and give them to i2s) and generate the sim/test_bench_i2s.vcd  trace file  (VCD format)

then type "make view" to visualize the trace.
Once gtkwave launched you have to explicitely indicate which signals you want to see, for instance:  right click on i2s_transceiver_inst -> recurs import -> append -> yes, next, click on the square next to '+' and '-' to see the whole trace and zoom and unzoom to understand what is going on

In this i2stransceiver version, the 'latched' signals allows to enter two signal in parallel on left and right, there is also that in the testbench:
sd_rx <= sd_tx;
which means that every thing ouput to the audio chip is immediatly re-entered as if it was the output of the audio chip.

In this version, the two output (left and right) cannot be read at the same instant. 
