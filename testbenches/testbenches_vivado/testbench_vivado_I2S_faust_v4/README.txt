This directory is (yes!) a working example of I2S and faust sending each other data which are correctly received from both side.

The project uses faust "withtout axi", hence a small amount of memory (only tested with sawtooth).

It consists of just a simulation of these two IP and it work up to bitstreamtoo. Hence, there is no synthesis and program targets in the Makefile.

The fpga.cpp has been ugraded to faust_v4 (which does not use any AXI bus) to simplify the design. Warning, this can be used only for very small amount of data store on the FPGA: less than 100 sample I guess.

The DSP is a sawtooth with 8 values which are easy to recognize in hexadecimal.

to program the FPGA, do as usual:
make
make program

to perform a simulation:
1)generate the project type
make project

2) then open the project with vivado:
 vivado build/faust_v4_project/faust_v4_project.xpr

Check the warnings and the bloc design, everything should be OK

Click on Run Simulation -> Run behavioral simulation (simulation window open).
There are two things to do: put the interesting signals in the wave window
and set the clock and the reset for the simulation to run.

for setting the signal in the wave windows
- remove all the existing signals from the wave window
- in the scope window,
    unrol simu_both_wrapper/simu_both_i/
    right click on faust_v4_0 -> add to wave window
    right click on i2s_transceiver_0 -> add to wave window
    
for setting the clock and reset:
- in the scope window, go back to the top (simu_both_wrapper)
- in the object window are the input to the design, in particular the clock (clk_in_0 --> sys_clk?) and reset (reset_0)
   - right click on clk_in_0 (--> sys_clk?= -> force clock
       --> leading edge value  -> 1
       --> trailing edge value  -> 0
       --> period   --> 8ns
    - right click on reset_0 -> force constant
       --> force value 0

You are ready to simulate:
In the top menu click restart (like rewind button) and then start (play)
Stop it when you wante (pause)
In the simu_both_wrapper_behav.wcfg window, click on unzoom (four arrows)
put the cursor somewhere and zoom until you see the values on ports (radix hexadecimal is better: right click on the signal name -> radix -> hexadecimal)

The in_left_V in_right_V are words formed by i2s from input from TB, TB act as an echo so they correspond to output of faust (i.e. out_left_V, out_right_V)
The XXX seen in out_left_V can be undesrstand by zooming between two XXX: the value is only hold for 1 cylce, i.e. when the ap_done is high. 
       
