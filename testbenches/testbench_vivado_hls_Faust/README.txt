This directory show how to provide a testbench for a Faust-syfala program
1) the projet_vivado_hls directory contains the vivado_hls project that includes a testbench for a faust_v4.cpp file as well as the faust_v4.cpp file.

To run it, type
vivado_hls
then open project -> select *directory* projet_vivado_hls
click on "Run C simulation" (vivado_hls  executes the testbench_faust_v4.cpp)
click on "Run synthesis" (vivado_hls synthesize the VHDL from Faust_v4.cpp, results in directory solution1)
Click on "C/RTL Cosimulation" with selecting  "Vivado Simulator", "VHDL" and 'Dump trace -> all
(vivado_hls perform a basic synthesis and synthesize the design with the same testbench_faust_v4.cpp file and compare the two output ) 
On the C/RTL simulation finished, click on "Open Wave viewer", then vivado_hls should launch vivado and should open a waveviewer of the execution of the testbench on the IP (including ap_vld interface signal)

--> On can see here that the outleft output is *only* valud during the clock cycle of ap_done

2) The Makefile is used only to simulate Faust_v4.cpp with the testbench without using vivado_hls, just G++ compilation and printing the results 
