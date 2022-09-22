# here, pwd should be $SYFALA_BUILD_DIR
source ../scripts/sylib.tcl
namespace import Syfala::*

# note '-f' and 'fpga_hls.tcl' are the two first arguments
# so BOARD is $::argv(2)
set BOARD [lindex $::argv 2]

open_project -reset syfala_ip
add_files syfala_ip/syfala_ip.cpp -cflags "-Iinclude/"
set_top syfala
open_solution -reset "syfala" -flow_target vivado

set_part [Xilinx::get_board_part $BOARD]

create_clock -period 4.069204
#create_clock -period 1.355932
#csim_design
csynth_design
#cosim_design
export_design -rtl vhdl -format ip_catalog

exit