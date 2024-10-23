PROJECT_NAME = FDPlate
BOARD = Z20
BUFFER_SIZE = 32
VITIS_VERSION = 2023.2

# change to the directory where syfala is
SYFALA_DIR = /home/syfala/syfala
WORKING_DIR = $(SYFALA_DIR)/examples/cpp/phys-model/static-plate-fdtd
VITIS_HLS_INCLUDE_DIR = /home/syfala/.xilinx/Vitis_HLS/2023.2/include

main: 
	syfala $(PROJECT_NAME)_partitioned_hls.cpp --arm-target $(PROJECT_NAME)_arm.cpp --board $(BOARD) --umo --xversion $(VITIS_VERSION)

main-multi: 
	syfala $(PROJECT_NAME)_partitioned_hls_multi.cpp --arm-target $(PROJECT_NAME)_arm.cpp --multisample $(BUFFER_SIZE) --board $(BOARD) --umo --xversion $(VITIS_VERSION)

standalone: $(PROJECT_NAME)_cpp.cpp
	# g++ -o plate_cpp $(PROJECT_NAME)_cpp.cpp -IFDPlate_Cpp_Craig_Webb/ -O3
	g++ -o plate_cpp $(PROJECT_NAME)_partitioned_cpp.cpp -IFDPlate_Cpp_Craig_Webb/ -ggdb
	# ./plate_cpp


# only compiles the HLS
hls-unpartitioned: 
	syfala $(PROJECT_NAME)_unpartitioned_hls.cpp --hls --umo --board $(BOARD) --xversion $(VITIS_VERSION)

hls-unpartitioned-multi: 
	syfala $(PROJECT_NAME)_unpartitioned_hls_multi.cpp --hls --umo --board $(BOARD) --multisample $(BUFFER_SIZE) --xversion $(VITIS_VERSION)
	
hls-unpartitioned-accurate: 
	syfala $(PROJECT_NAME)_unpartitioned_hls.cpp --hls --umo --accurate-use --board $(BOARD) --xversion $(VITIS_VERSION)

hls-unpartitioned-accurate-multi: 
	syfala $(PROJECT_NAME)_unpartitioned_hls_multi.cpp --hls --umo --accurate-use --board $(BOARD) --multisample $(BUFFER_SIZE) 

hls-partitioned: 
	syfala $(PROJECT_NAME)_partitioned_hls.cpp --hls --umo --board $(BOARD) --xversion $(VITIS_VERSION)

hls-partitioned-accurate: 
	syfala $(PROJECT_NAME)_partitioned_hls.cpp --hls --umo --accurate-use --board $(BOARD) --xversion $(VITIS_VERSION)

hls-partitioned-multi: 
	syfala $(PROJECT_NAME)_partitioned_hls_multi.cpp --hls --umo --board $(BOARD) --multisample $(BUFFER_SIZE) --xversion $(VITIS_VERSION)

hls-partitioned-accurate-multi: 
	syfala $(PROJECT_NAME)_partitioned_hls_multi.cpp --hls --umo --accurate-use --board $(BOARD) --multisample $(BUFFER_SIZE) --xversion $(VITIS_VERSION)


# compiles the HLS and runs csim to test the algorithm
csim-unpartitioned:
	cd $(SYFALA_DIR)
	syfala $(WORKING_DIR)/$(PROJECT_NAME)_unpartitioned_hls.cpp --multisample $(BUFFER_SIZE) --csim $(WORKING_DIR)/$(PROJECT_NAME)_csim.cpp --csim-inputs $(WORKING_DIR)/csim_signals --csim-iter 48000 --xversion $(VITIS_VERSION)
	cp -r $(SYFALA_DIR)/reports/$(PROJECT_NAME)_hls/ $(WORKING_DIR)/outputs
	cd $(WORKING_DIR)
	
csim-partitioned:
	cd $(SYFALA_DIR)
	syfala $(WORKING_DIR)/$(PROJECT_NAME)_partitioned_hls_multi.cpp --multisample $(BUFFER_SIZE) --csim $(WORKING_DIR)/$(PROJECT_NAME)_partitioned_csim.cpp --csim-inputs $(WORKING_DIR)/csim_signals --csim-iter 48000 --xversion $(VITIS_VERSION)
	cp -r $(SYFALA_DIR)/reports/$(PROJECT_NAME)_partitioned_hls/ $(WORKING_DIR)/outputs
	cd $(WORKING_DIR)

# compiles the csim and hls files with gcc for standalone debugging in gdb 
csim-gcc-unpartitioned:
	g++ -o csim $(PROJECT_NAME)_csim.cpp -ggdb -std=c++14 -I $(VITIS_HLS_INCLUDE_DIR) -I $(SYFALA_DIR)/include -D __CSIM__ -D GCC_STANDALONE


csim-gcc-partitioned:
	g++ -o csim $(PROJECT_NAME)_partitioned_csim.cpp -ggdb -std=c++14 -I $(VITIS_HLS_INCLUDE_DIR) -I $(SYFALA_DIR)/include -D __CSIM__ -D GCC_STANDALONE


clean:
	rm csim 
	rm plate_cpp
	rm plate_cpp_debug
	