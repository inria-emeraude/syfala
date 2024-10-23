# Syfala example for a stereo parametric EQ

Written by Benjamin Quiédeville (April 2024)

Create, setup and process an arbitrary number of stereo biquad filters in series. It is composed of a *HLS* file with the processing, an *ARM* file to setup the internal memory and the OSC integration, a *CSIM* file to run tests and a Pure Data patch to control via OSC. 


The Makefile present the commands to run to compile and mount the project on the Z20 board with OSC integration.

To build and mount on a board run `make` and `make mount`