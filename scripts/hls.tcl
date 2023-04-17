# here, pwd should be $SYFALA_BUILD_DIR
source ../scripts/sylib.tcl
namespace import Syfala::*

# note '-f' and 'fpga_hls.tcl' are the two first arguments
# so BOARD is $::argv(2)
set BOARD [lindex $::argv 2]

open_project -reset syfala_ip
add_files $::Syfala::BUILD_IP_FILE -cflags "-Iinclude/"
set_top syfala
open_solution -reset "syfala" -flow_target vivado

set_part [Xilinx::get_board_part $BOARD]

if { $BOARD == "Z10" || $BOARD == "Z20" } {
  create_clock -period 8.137634
} elseif { $BOARD == "GENESYS" } {
  create_clock -period 8.138352
}
#create_clock -period 1.355932
#csim_design
csynth_design
#cosim_design
export_design -rtl vhdl -format ip_catalog

exit
