############## File copied from vitis console
#			How to reproduce?
#				-Launch the "Program Flash" command with Vitis GUI
#				-Go to Console window and look for the command lines
#
#		!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# 		!!JP5 HAS TO BE ON POSITION 'JTAG' DuRING FLASH, NOT QSPI!!
#		!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#Add because it fail to connect without it...
connect -url tcp:127.0.0.1:3121
puts "WRONG SCRIPT, THIS ONE IS NOT FINISHED"
exec program_flash -f \
./BOOT.bin -offset 0 \
-flash_type qspi-x4-single \
-fsbl ./build/faust_v6_application/faust_v6_platform/zynq_fsbl/fsbl.elf \
-blank_check -verify -cable type xilinx_tcf url tcp:127.0.0.1:3121
#ORIGINAL: -cable type xilinx_t


### Test from scratch based on Vitis Doc (works too)
#exec program_flash -f ./build/sw_export/BOOT.bin \
#-fsbl ./build/faust_v6_application/faust_v6_platform/zynq_fsbl/fsbl.elf \
#-blank_check -verify -cable type xilinx_tcf url tcp:127.0.0.1:3121




