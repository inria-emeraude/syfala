############## File copied from vitis project (path changed)
# Create an app and run it (right click / "run as..."/ "Launch on Hardware")
# This script should be generated in <vitis_workspace>/app_system/_ide/scripts/debugger_app_standalone.tcl
# Useful link:
# doc(old): https://www.xilinx.com/html_docs/xilinx2019_1/SDK_Doc/xsct/connections/reference_connections_targets.html
# doc(new): https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/usu1543754625982.html
# example: https://gist.github.com/imrickysu/b911be34cf7fffc1b9259610095973fd
# example: https://forums.xilinx.com/t5/Processor-System-Design-and-AXI/quot-Memory-write-error-at-0x100000-Cannot-access-DDR-the/td-p/993089
source ../scripts/sylib.tcl
namespace import Syfala::*


set BOARD [lindex $argv 0]
set XILINX_ROOT [lindex $argv 1]  ;#Don't know how to fetch the path directrly


if { $BOARD == "Z10" || $BOARD == "Z20" } {
	set targetName "*A9*#0"
	set address "0x40000000 0xbfffffff"
	source ./syfala_application/application/_ide/psinit/ps7_init.tcl
} elseif { $BOARD == "GENESYS" } {
	set targetName "*A53*#0"
	set address "{0x80000000 0xbfffffff} {0x400000000 0x5ffffffff} {0x1000000000 0x7fffffffff}"
        source $XILINX_ROOT/Vitis/2020.2/scripts/vitis/util/zynqmp_utils.tcl
} else {
	print_error "Invalid Zybo version, aborting..."
	exit 2;
}

connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000


#targets -set -filter {jtag_cable_name =~ "Digilent Zybo Z7 210351A8191DA" && level==0 && jtag_device_ctx=="jsn-Zybo Z7-210351A8191DA-13722093-0"}
#targets -set -filter {jtag_cable_name =~ "Digilent Genesys ZU - 3EG 210383AD9C62A" && level==0 && jtag_device_ctx=="jsn-Genesys ZU - 3EG-210383AD9C62A-14710093-0"}
targets -set -filter [format {name =~ "%s"} $targetName]
fpga -file ./syfala_application/application/_ide/bitstream/main_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw ./hw_export/main_wrapper.xsa -mem-ranges [format [list "%s"] $address] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}

if { $BOARD == "Z10" || $BOARD == "Z20" } {
	ps7_init
	ps7_post_config
} elseif { $BOARD == "GENESYS" } {
	set mode [expr [mrd -value 0xFF5E0200] & 0xf]
	targets -set -nocase -filter [format {name =~ "%s"} $targetName]
	rst -processor
	dow ./syfala_application/platform/export/platform/sw/platform/boot/fsbl.elf
	set bp_5_55_fsbl_bp [bpadd -addr &XFsbl_Exit]
  con -block -timeout 60
  bpremove $bp_5_55_fsbl_bp
} else {
	print_error "Invalid Zybo version, aborting..."
	exit 2;
}

targets -set -nocase -filter [format {name =~ "%s"} $targetName]
rst -processor
dow ./sw_export/application.elf
configparams force-mem-access 0
targets -set -nocase -filter [format {name =~ "%s"} $targetName]
con
