
NSAMPLES ?= 64
CSIM_PATH := ../../../examples/cpp/phys-model/static-plate-full/maxi
CSIM_ITER ?= 750
BD ?= $(MK)/../ila.tcl
BOARD ?= Z20

MK := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

csim:
	syfala hls.cpp -b $(BOARD) $(FLAGS) \
		        --multisample $(NSAMPLES) \
			--csim $(MK)/csim.cpp \
			--csim-iter $(CSIM_ITER)

hls:
	syfala hls.cpp -b $(BOARD) $(FLAGS) \
	--multisample $(NSAMPLES) \
	--hls
	

full: 
	syfala hls.cpp -b $(BOARD)		    \
		       --flatpak		    \
		       --multisample $(NSAMPLES)    \
		       --arm-target arm.cpp	    \
		       --bd $(BD)

