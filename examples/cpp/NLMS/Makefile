PROJECT_NAME = NLMS
BOARD = Z20
BUFFER_SIZE = 64
VITIS_VERSION = 2023.2

# change to the directory where syfala is
SYFALA_DIR = /home/syfala/syfala
WORKING_DIR = $(SYFALA_DIR)/examples/cpp/NLMS
VITIS_HLS_INCLUDE_DIR = /home/syfala/.xilinx/Vitis_HLS/2023.2/include

main:
	syfala $(PROJECT_NAME)_hls.cpp --board $(BOARD) --umo --xversion $(VITIS_VERSION)

# only compiles the HLS
hls:
	syfala $(PROJECT_NAME)_hls.cpp --hls --umo --board $(BOARD) --xversion $(VITIS_VERSION)
	
hls-accurate:
	syfala $(PROJECT_NAME)_hls.cpp --hls --umo --accurate-use --board $(BOARD) --xversion $(VITIS_VERSION)

# compiles the HLS and runs csim to test the algorithm
csim:
	#julia generate_signals.jl
	cd $(SYFALA_DIR)
	syfala $(WORKING_DIR)/$(PROJECT_NAME)_hls.cpp --csim $(WORKING_DIR)/$(PROJECT_NAME)_csim.cpp --multisample $(BUFFER_SIZE) --csim-inputs $(WORKING_DIR)/csim_signals --csim-iter 24000 --xversion $(VITIS_VERSION)
	cp -r $(SYFALA_DIR)/reports/$(PROJECT_NAME)_hls/ $(WORKING_DIR)/outputs
	cd $(WORKING_DIR)

csim-gcc:
	g++ -o csim-std NLMS_csim.cpp -O3 -std=c++14 -I $(VITIS_HLS_INCLUDE_DIR) -I $(SYFALA_DIR)/include -D __CSIM__ -D GCC_STANDALONE
