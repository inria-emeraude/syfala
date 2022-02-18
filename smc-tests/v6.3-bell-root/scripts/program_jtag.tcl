# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: /home/maxime/vitis_workspace/ddr_V6_1_system/_ide/scripts/debugger_ddr_v6_1-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source /home/maxime/vitis_workspace/ddr_V6_1_system/_ide/scripts/debugger_ddr_v6_1-default.tcl
# 
############## File copied from vitis project (path changed)
#			How this file was found in the Vitis Workspace?
#				-Launch the wanted command with Vitis GUI
#				-Go to Vitis Log window
# Useful link:
# doc(old): https://www.xilinx.com/html_docs/xilinx2019_1/SDK_Doc/xsct/connections/reference_connections_targets.html
# doc(new): https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/usu1543754625982.html
# example: https://gist.github.com/imrickysu/b911be34cf7fffc1b9259610095973fd
# example: https://forums.xilinx.com/t5/Processor-System-Design-and-AXI/quot-Memory-write-error-at-0x100000-Cannot-access-DDR-the/td-p/993089

# Test from scratch (doesn't work, don't know why...)
#connect
#after 2000
#target -set -filter {name =~ "ARM Cortex-A9*#0"}    
#source ./build/faust_v6_application/faust_v6_platform/hw/ps7_init.tcl 
#xsct% ps7_init                                                               
#xsct% ps7_post_config                                                        
#xsct% dow ./build/sw_export/faust_v6_app.elf 
#after 2000
#con

if {$argc == 1} {
	if {$argv == "BOOT.bin"} {
		puts "File: BOOT.bin";
	} else {
		puts "File: $argv"
	}

	connect -url tcp:127.0.0.1:3121
	targets -set -nocase -filter {name =~"APU*"}
	rst -system
	after 3000

 

	if {$argv == "BOOT.bin"} {
		targets -set -nocase -filter {name =~"APU*"}
		source ./build/faust_v6_application/faust_v6_app/_ide/psinit/ps7_init.tcl
		ps7_init
		ps7_post_config
		targets -set -nocase -filter {name =~ "*A9*#0"}
		dow -data ./build/sw_export/BOOT.bin 0x00100000
		dow ./build/sw_export/faust_v6_app.elf
	} else {
		#auto generate: targets -set -filter {jtag_cable_name =~ "Digilent Zybo Z7 210351A8191DA" && level==0 && jtag_device_ctx=="jsn-Zybo Z7-210351A8191DA-13722093-0"}
		#replaced by:
		target -set -filter {name =~ "ARM Cortex-A9*#0"}   
		fpga -file ./build/faust_v6_application/faust_v6_app/_ide/bitstream/main_wrapper.bit
		targets -set -nocase -filter {name =~"APU*"}
		loadhw -hw ./build/hw_export/main_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
		configparams force-mem-access 1
		targets -set -nocase -filter {name =~"APU*"}
		source ./build/faust_v6_application/faust_v6_app/_ide/psinit/ps7_init.tcl
		ps7_init
		ps7_post_config
		targets -set -nocase -filter {name =~ "*A9*#0"}
		dow ./build/sw_export/faust_v6_app.elf
		configparams force-mem-access 0
		targets -set -nocase -filter {name =~ "*A9*#0"}
		con
	}

} else { 
	puts {[ERROR] Please put one target file in program_jtag.tcl args (BOOT.bin or xxx.elf)};
}
