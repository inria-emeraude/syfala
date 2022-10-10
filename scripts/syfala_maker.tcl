#!/usr/bin/tclsh
source ../scripts/syfala_maker_utils.tcl
source ../scripts/sylib.tcl
namespace import Syfala::*

set FAUST_INPUTS    [lindex $argv 0]
set FAUST_OUTPUTS   [lindex $argv 1]
set NCHANNELS_MAX   [lindex $argv 2]
set BOARD           [lindex $argv 3]

print_info "syfala_maker.tcl running with arguments:
        - inputs  = $FAUST_INPUTS,
        - outputs = $FAUST_OUTPUTS,
        - nchannels_max = $NCHANNELS_MAX,
        - board   = $BOARD"

set clk_dynamic_reconfig false

if { $BOARD == "Z10" } {
  set maxPhysicalCodec 3 ;
} elseif { $BOARD == "Z20" } {
  set maxPhysicalCodec 4 ;
} elseif { $BOARD == "GENESYS" } {
  set maxPhysicalCodec 4 ;
}
#guidelines (a marquer quelquepart):
# Inliner les conditions des if: pas de mise à la ligne dans le "if(ICI)"
# Ca risque d'être compliqué si la condition d'un "if" contient à la fois un right_ et un left_...
# Mettre à la ligne à chaque appel de left_ ou right_. Exemple:
#	in_left=foo; in_right=bar;
#Devient
#	in_left=foo;
#	in_right=bar;
# NE PAS INLINER LES IF. Trop compliqué de gerer ça...
# le nombre d'entrées/sorties est toujours paire, si on demande 7 cannaux, il y en aura 8 (de 0 à 7)
# Impossible de faire des if avec une condition qui contient right ou left imbriqués
######

set I2S_SRC_PATH   $Syfala::SOURCE_DIR/vhdl/i2s_transceiver.vhd
set I2S_DST_PATH   $Syfala::BUILD_SOURCES_DIR/i2s_transceiver.vhd
set MUX_2TO1_PATH  $Syfala::SOURCE_DIR/vhdl/mux_2to1.vhd

file mkdir $Syfala::BUILD_SOURCES_DIR

#-----------------------------------------------transceiver I2S ---------------------

set i2s_src_file [open "$I2S_SRC_PATH" r]
set i2s_dst_file [open "$I2S_DST_PATH" w]

print_info "Generating i2s_transceiver source file in $Syfala::BUILD_SOURCES_DIR"
replace_right_left $i2s_src_file $i2s_dst_file $NCHANNELS_MAX

close $i2s_src_file
close $i2s_dst_file

print_ok "i2s_transceiver source file succesfully generated"

#----------------------------------------------------------------


#----------------------------------------------------------------

print_info "Generating project.tcl file in $Syfala::BUILD_SOURCES_DIR"

set project_file [open "$Syfala::PROJECT_SCRIPT_TEMPLATE" r]
set generated_project_file [open "$Syfala::PROJECT_SCRIPT" w]

set ports ""
set declarations_path ""
set connections ""
set module_names ""
set user_instances ""
set system_instances ""
set address ""
set ip_check ""
set clock_instances ""

if { $BOARD == "Z10" || $BOARD == "Z20" } {
append ip_check "  xilinx.com:ip:processing_system7:5.5\\"
} elseif { $BOARD == "GENESYS" } {
append ip_check "  xilinx.com:ip:smartconnect:1.0\\\n"
append ip_check "  xilinx.com:ip:zynq_ultra_ps_e:3.3\\"
}

#---------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------- PORTS ---------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------#

#------------------------ Create Interface Ports --------------------
if { $BOARD == "Z10" || $BOARD == "Z20" } {
    append ports "  set DDR \[ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR \]\n"
    append ports "  set FIXED_IO \[ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO \]\n"
    append ports "  set board_clk \[ create_bd_port -dir I -type clk -freq_hz 125000000 board_clk \]\n"
} elseif { $BOARD == "GENESYS" } {
    append ports "  set board_clk \[ create_bd_port -dir I -type clk -freq_hz 25000000 board_clk \]\n"
}
append ports "  set IIC_0 \[ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_0 \]\n"
append ports "  set leds_4bits \[ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits \]\n"
append ports "  set rgb_led \[ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 rgb_led \]\n"
append ports "  set switches \[ create_bd_port -dir I -from 3 -to 0 switches \]\n"

# we have to round to the superior before the following 'for' loops
# otherwise we don't have the matching number of codec ports
proc round_sup_div2 { x } {
    return [expr $x % 2 ? ($x+1)/2 : $x/2]
}
set n_inputs  [round_sup_div2 $FAUST_INPUTS]
set n_outputs [round_sup_div2 $FAUST_OUTPUTS]
set nchn_max  [round_sup_div2 $NCHANNELS_MAX]

#------------------------ Create CODECs Ports --------------------
for {set i 1} {($i <= $n_inputs) && ($i <= $maxPhysicalCodec)} {incr i} {
  create_port CODEC$i\_sd_rx 		"I"
}
for {set i 1} {($i <= $n_outputs) && ($i <= $maxPhysicalCodec)} {incr i} {
  create_port CODEC$i\_sd_tx 		"O"
}
for {set i 1} {($i <= $nchn_max) && ($i <= $maxPhysicalCodec)} {incr i} {
    create_port CODEC$i\_bclk 		"O"
    create_port CODEC$i\_mclk 		"O"
    create_port CODEC$i\_ws         "O"
    create_port CODEC$i\_bclk_GND 	"O"
    create_port CODEC$i\_mclk_GND 	"O"
    create_port CODEC$i\_ws_GND     "O"
}

#------------------------ Create onboard codec Ports (SSM for Zybo, ADAU for Genesys)--------------------
  create_port internal_codec_bclk		 	"O"
  create_port internal_codec_mclk 			"O"
  create_port internal_codec_sd_rx 		"I"
  create_port internal_codec_sd_tx 		"O"
  create_port internal_codec_ws_tx 		"O"
  if { $BOARD == "Z10" || $BOARD == "Z20" } {
    create_port internal_codec_ws_rx 		"O"
    create_port internal_codec_out_mute 	"O"
  }

#------------------------ Create SPI ports --------------------
 # create_port faustIP_debug "O"
create_port spi_MISO 		"I"
create_port spi_MOSI 		"O"
create_port spi_SS 		  "O"
create_port spi_clk 		"O"

#------------------------ Create other ports --------------------
create_port debug_btn "I"
create_port syfala_out_debug0 "O"
create_port syfala_out_debug1 "O"
create_port syfala_out_debug2 "O"
create_port syfala_out_debug3 "O"

#------------------------ Create MCU ports --------------------
#https://digilent.com/reference/programmable-logic/genesys-zu/reference-manual#application_section
if { $BOARD == "GENESYS" } {
  create_port vadj_level0 "O"
  create_port vadj_level1 "O"
  create_port vadj_auton "O"
}

#---------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------- INSTANCES -----------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------#

#------------------------  Create system instance -------------------------

if {$clk_dynamic_reconfig} {
    create_axi_interconnect "axi_periph_interconn" 4
    append system_instances "# Create instance: rst_sys_clk_125M, and set properties \n set rst_sys_clk_125M \[ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_sys_clk_125M \] \n"
} else {
    create_axi_interconnect "axi_periph_interconn" 3
}

if { $BOARD == "Z10" || $BOARD == "Z20" } {
    create_axi_interconnect "axi_mem_interconn" 1
    create_axi_gpio "axi_gpio_LED" zybo
} elseif { $BOARD == "GENESYS" } {
    create_axi_interconnect "axi_mem_interconn" 1 "smartconnect"
    create_axi_gpio "axi_gpio_LED" genesys
}

#------------------------  Create constants instance -------------------------
append system_instances "  # Create constants instance, and set properties \n"
append system_instances "  set vdd33 \[ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vdd33 \] \n"
append system_instances "  set GND \[ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 GND \] \n set_property -dict \[ list CONFIG.CONST_VAL {0} \] \$GND \n"

#------------------------  Create clock instance -------------------------

if { $BOARD == "Z10" || $BOARD == "Z20" } {
  set IN_CLK_FREQ 125
  # Change sys_clk frequency here.
  # Don"t forget to change the corresponding period in hls.tcl (not in master_zybo.xdc, this one is the board clk!)
  # Tested frequency:
  # |---SYS_CLK_FREQ--|------period-----|-SYSCLK_I2S_RATIO (for 48k)-|----Functional---|
  # |    122.885835   |     8.137634    |              10            |       YES       |
  # |    245.748299   |     4.069204    |              20            |       YES       |
  # |    491.596638   |     2.034188    |              40            |       NO        |
  # |-----------------|-----------------|----------------------------|-----------------|
  set SYS_CLK_FREQ 122.885835
  set SYSCLK_I2S_RATIO 10
} elseif { $BOARD == "GENESYS" } {
  set IN_CLK_FREQ 25
  # Change sys_clk frequency here.
  # Don"t forget to change the corresponding period in hls.tcl (not in master_zybo.xdc, this one is the board clk!)
  # Tested frequency:
  # |---SYS_CLK_FREQ--|------period-----|-SYSCLK_I2S_RATIO (for 48k)-|----Functional---|
  # |    122.875      |     8.138352    |              10            |       YES       |
  # |      737.5      |     1.355932    |              60            |        NO       |
  # |-----------------|-----------------|----------------------------|-----------------|
  set SYS_CLK_FREQ 122.875
  set SYSCLK_I2S_RATIO 10
}
  set sys_clk_instance_name "clk_wiz_sys_clk"
  append clock_instances "\n\n  # Create instance: $sys_clk_instance_name, and set properties \n\
  set $sys_clk_instance_name \[ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 $sys_clk_instance_name \] \n\
  set_property -dict \[ list \\\n\
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$SYS_CLK_FREQ} \\\n\
   CONFIG.CLK_OUT1_PORT {sys_clk} \\\n\
   CONFIG.PRIM_IN_FREQ {$IN_CLK_FREQ} \\\n\
   CONFIG.PRIM_SOURCE {Global_buffer} \\\n\
   CONFIG.USE_LOCKED {false} \\\n\
   CONFIG.USE_RESET {false} \\\n\
 \] \$$sys_clk_instance_name "
 #buffer values: No_buffer, Global_buffer. If nothing, single ended is default.

 set i2s_clk_instance_name "clk_wiz_I2S"
 append clock_instances "\n\n  # Create instance: $i2s_clk_instance_name, and set properties \n\
 set $i2s_clk_instance_name \[ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 $i2s_clk_instance_name \] \n\
 set_property -dict \[ list \\\n\
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {[expr {$SYS_CLK_FREQ/$SYSCLK_I2S_RATIO}]} \\\n\
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {[expr {$SYS_CLK_FREQ/($SYSCLK_I2S_RATIO/2)}]} \\\n\
  CONFIG.CLKOUT2_USED {true} \\\n\
  CONFIG.NUM_OUT_CLKS {2} \\\n\
  CONFIG.CLK_OUT1_PORT {clk_I2S} \\\n\
  CONFIG.CLK_OUT2_PORT {clk_24Mhz} \\\n\
  CONFIG.PRIM_IN_FREQ {$SYS_CLK_FREQ} \\\n\
  CONFIG.USE_LOCKED {true} \\\n\
  CONFIG.USE_RESET {false} \\\n\
\] \$$i2s_clk_instance_name "


#------------------------  Create user instance -------------------------
declare_user_module "i2s_transceiver" 	$I2S_DST_PATH
declare_user_module "mux_2to1" 			$MUX_2TO1_PATH


#---------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------- CONNECTIONS ---------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------#


#------------------------ Connections clock --------------------

set SYSTEM_CLOCK "$sys_clk_instance_name/sys_clk"

connect "ports" board_clk					"pins" $sys_clk_instance_name/clk_in1
connect "pins" $SYSTEM_CLOCK    "pins" $i2s_clk_instance_name/clk_in1

if {$clk_dynamic_reconfig } {
    connect "intf_pins" clk_wiz_I2S/s_axi_lite 						"intf_pins" axi_periph_interconn/M03_AXI   "bd_intf_net"
  connect "pins" clk_wiz_I2S/s_axi_aclk  								"pins" $SYSTEM_CLOCK
    connect "pins" rst_sys_clk_125M/slowest_sync_clk  		"pins" $SYSTEM_CLOCK
    connect "pins" rst_sys_clk_125M/ext_reset_in 					"pins"  processing_system7_0/FCLK_RESET0_N
    connect "pins" rst_sys_clk_125M/peripheral_aresetn		"pins" clk_wiz_I2S/s_axi_aresetn
    connect "pins" axi_periph_interconn/M03_ARESETN 			"pins" rst_global/peripheral_aresetn
    connect "pins" axi_periph_interconn/M03_ACLK  				"pins" $SYSTEM_CLOCK
} else {
  connect "pins" $i2s_clk_instance_name/locked "pins" rst_global/dcm_locked
}
connect "pins" rst_global/slowest_sync_clk 	"pins" $i2s_clk_instance_name/clk_24Mhz

#------------------------ Connections FAUST IP--------------------

for {set i 0} {$i < $FAUST_INPUTS} {incr i} {
    connect "pins" syfala/in_ch$i\_V "pins" i2s_transceiver_0/ch$i\_data_rx
}
for {set i 0} {$i < $FAUST_OUTPUTS} {incr i} {
    connect "pins" syfala/out_ch$i\_V         "pins" i2s_transceiver_0/ch$i\_data_tx
    connect "pins" syfala/out_ch$i\_V_ap_vld  "pins" i2s_transceiver_0/out_ch$i\_V_ap_vld
}

connect "pins" syfala/ap_done  	"pins" i2s_transceiver_0/ap_done
connect "pins" syfala/ap_start 	"pins" i2s_transceiver_0/rdy
connect "pins" syfala/mute      "pins" sw0/Dout
connect "pins" syfala/bypass    "pins" sw1/Dout
connect "ports" debug_btn       "pins" syfala/debugBtn
connect "pins" syfala/outGPIO   "ports" syfala_out_debug0
connect "pins" syfala/out_ch0_V_ap_vld  "ports" syfala_out_debug1

if {$FAUST_OUTPUTS >= 2} {
    connect "pins" syfala/out_ch1_V_ap_vld "ports" syfala_out_debug2
}

connect "pins" syfala/ap_start "ports" syfala_out_debug3

#------------------------ Connections CODEC 1 to X--------------------
for {set i 1} {($i <= $NCHANNELS_MAX/2) && ($i <= $maxPhysicalCodec)} {incr i} {
    connect "ports" CODEC$i\_mclk					"pins" $i2s_clk_instance_name/clk_24Mhz
    connect "ports" CODEC$i\_bclk					"pins" i2s_transceiver_0/sclk
    connect "ports" CODEC$i\_ws						"pins" i2s_transceiver_0/ws

    connect "ports" CODEC$i\_bclk_GND				"pins" GND/dout
    connect "ports" CODEC$i\_mclk_GND				"pins" GND/dout
    connect "ports" CODEC$i\_ws_GND					"pins" GND/dout
}

#------------------------ Connections CODEC 2 to X--------------------
for {set i 2} {($i <= $FAUST_INPUTS/2) && ($i <= $maxPhysicalCodec)} {incr i} {
    connect "ports" CODEC$i\_sd_rx					"pins" i2s_transceiver_0/sd_ch[expr {($i*2)-2}]\_ch[expr {($i*2)-1}]\_rx
}
for {set i 2} {($i <= $FAUST_OUTPUTS/2) && ($i <= $maxPhysicalCodec)} {incr i} {
    connect "ports" CODEC$i\_sd_tx					"pins" i2s_transceiver_0/sd_ch[expr {($i*2)-2}]\_ch[expr {($i*2)-1}]\_tx
}
#------------------------ Connections CODEC 1 and internal_codec (SSM for Zybo, ADAU for Genesys)--------------------
if { $FAUST_INPUTS != 0 } {
  connect "ports" CODEC1_sd_rx										"pins" mux_2to1_0/inA
  connect "ports" internal_codec_sd_rx 						"pins" mux_2to1_0/inB
  connect "pins" i2s_transceiver_0/sd_ch0_ch1_rx	"pins" mux_2to1_0/outMux
}
if { $FAUST_OUTPUTS != 0 } {
  connect "ports" CODEC1_sd_tx										"pins" i2s_transceiver_0/sd_ch0_ch1_tx
  connect "ports" internal_codec_sd_tx												"pins" i2s_transceiver_0/sd_ch0_ch1_tx
}

connect "ports" internal_codec_ws_tx												"pins" i2s_transceiver_0/ws
connect "ports" internal_codec_bclk												"pins" i2s_transceiver_0/sclk
connect "ports" internal_codec_mclk 												"pins" $i2s_clk_instance_name/clk_24Mhz
if { $BOARD == "Z10" || $BOARD == "Z20" } {
    connect "ports" internal_codec_ws_rx												"pins" i2s_transceiver_0/ws
    connect "ports" internal_codec_out_mute 										"pins" vdd33/dout
}

#------------------------ Connections Transceiver/FAUST Other--------------------
connect "pins" mux_2to1_0/Sel							"pins" sw2/Dout
connect "pins" i2s_transceiver_0/mclk			"pins" $i2s_clk_instance_name/clk_I2S
connect "pins" i2s_transceiver_0/sys_clk 	"pins" $SYSTEM_CLOCK
connect "pins" syfala/ap_rst_n				"pins" rst_global/peripheral_aresetn
connect "pins" i2s_transceiver_0/reset_n 	"pins" rst_global/peripheral_aresetn
connect "pins" i2s_transceiver_0/start 		"pins" vdd33/dout


#------------------------ Connections PS --------------------

if { $BOARD == "Z10" || $BOARD == "Z20" } {

connect "intf_pins" processing_system7_0/S_AXI_HP0 				"intf_pins" axi_mem_interconn/M00_AXI "bd_intf_net"
connect "pins" 			processing_system7_0/M_AXI_GP0_ACLK		"pins" $SYSTEM_CLOCK
connect "pins" 			processing_system7_0/S_AXI_HP0_ACLK		"pins" $SYSTEM_CLOCK
connect "intf_pins" processing_system7_0/DDR							"intf_ports" DDR "bd_intf_net"
connect "intf_pins" processing_system7_0/FIXED_IO					"intf_ports" FIXED_IO "bd_intf_net"
connect "intf_pins" processing_system7_0/IIC_0						"intf_ports" IIC_0 "bd_intf_net"
connect "intf_pins" processing_system7_0/M_AXI_GP0 				"intf_pins" axi_periph_interconn/S00_AXI "bd_intf_net"
connect "pins" 			processing_system7_0/FCLK_RESET0_N		"pins" rst_global/ext_reset_in

#----SPI
connect "pins" processing_system7_0/SPI0_MOSI_O		"ports" spi_MOSI
connect	"pins" processing_system7_0/SPI0_SCLK_O		"ports" spi_clk
connect	"pins" processing_system7_0/SPI0_SS_O			"ports" spi_SS
connect	"pins" processing_system7_0/SPI0_MISO_I		"ports" spi_MISO
connect "pins" processing_system7_0/SPI0_SS_I 		"pins" vdd33/dout


} elseif { $BOARD == "GENESYS" } {

connect "intf_pins" 	zynq_ultra_ps_e_0/S_AXI_HP0_FPD				"intf_pins" axi_mem_interconn/M00_AXI "bd_intf_net"
connect "pins" 				zynq_ultra_ps_e_0/maxihpm0_lpd_aclk		"pins" $SYSTEM_CLOCK
connect "pins" 				zynq_ultra_ps_e_0/saxihp0_fpd_aclk		"pins" $SYSTEM_CLOCK
connect "intf_pins" 	zynq_ultra_ps_e_0/IIC_0								"intf_ports" IIC_0 "bd_intf_net"
connect "intf_pins" 	zynq_ultra_ps_e_0/M_AXI_HPM0_LPD			"intf_pins" axi_periph_interconn/S00_AXI "bd_intf_net"
connect "pins"			 	zynq_ultra_ps_e_0/pl_resetn0					"pins" rst_global/ext_reset_in
#----SPI
connect "pins" zynq_ultra_ps_e_0/emio_spi0_m_o				"ports" spi_MOSI
connect	"pins" zynq_ultra_ps_e_0/emio_spi0_sclk_o			"ports" spi_clk
connect	"pins" zynq_ultra_ps_e_0/emio_spi0_ss_o_n			"ports" spi_SS
connect	"pins" zynq_ultra_ps_e_0/emio_spi0_s_i				"ports" spi_MISO
#connect "pins" zynq_ultra_ps_e_0/emio_spi0_ss_i_n 		"pins" vdd33/dout
}


#------------------------ Connections Interface (other) --------------------
connect "intf_ports" rgb_led 													"intf_pins" axi_gpio_LED/GPIO2 "bd_intf_net"
connect "intf_ports" leds_4bits 											"intf_pins" axi_gpio_LED/GPIO "bd_intf_net"
connect "intf_pins" axi_gpio_LED/S_AXI								"intf_pins" axi_periph_interconn/M00_AXI "bd_intf_net"
connect "intf_pins" syfala/s_axi_control 					"intf_pins" axi_periph_interconn/M01_AXI "bd_intf_net"
connect "intf_pins" axi_gpio_SW/S_AXI 								"intf_pins" axi_periph_interconn/M02_AXI "bd_intf_net"

#------------------------ Connections DDR axi --------------------
connect "intf_pins" syfala/m_axi_ram							"intf_pins" axi_mem_interconn/S00_AXI "bd_intf_net"
if { $BOARD == "Z10" || $BOARD == "Z20" } {

connect "pins" $SYSTEM_CLOCK 		"pins" axi_mem_interconn/ACLK
connect "pins" $SYSTEM_CLOCK 		"pins" axi_mem_interconn/M00_ACLK
connect "pins" $SYSTEM_CLOCK 		"pins" axi_mem_interconn/S00_ACLK
connect "pins" rst_global/peripheral_aresetn			"pins" axi_mem_interconn/ARESETN
connect "pins" rst_global/peripheral_aresetn			"pins" axi_mem_interconn/M00_ARESETN
connect "pins" rst_global/peripheral_aresetn			"pins" axi_mem_interconn/S00_ARESETN

} elseif { $BOARD == "GENESYS" } {

connect "pins" $SYSTEM_CLOCK 		"pins" axi_mem_interconn/aclk
connect "pins" rst_global/peripheral_aresetn			"pins" axi_mem_interconn/aresetn
}

#------------------------ Connections Sys_clk (other)--------------------
connect "pins" $SYSTEM_CLOCK 		"pins" axi_gpio_LED/s_axi_aclk
connect "pins" $SYSTEM_CLOCK 		"pins" axi_gpio_SW/s_axi_aclk
connect "pins" $SYSTEM_CLOCK 		"pins" syfala/ap_clk
connect "pins" $SYSTEM_CLOCK 		"pins" axi_periph_interconn/M00_ACLK
connect "pins" $SYSTEM_CLOCK 		"pins" axi_periph_interconn/M01_ACLK
connect "pins" $SYSTEM_CLOCK 		"pins" axi_periph_interconn/M02_ACLK
connect "pins" $SYSTEM_CLOCK 		"pins" axi_periph_interconn/S00_ACLK
connect "pins" $SYSTEM_CLOCK 		"pins" axi_periph_interconn/ACLK


#------------------------ Connections aresetn (other)--------------------
connect "pins" rst_global/peripheral_aresetn			"pins" axi_gpio_LED/s_axi_aresetn
connect "pins" rst_global/peripheral_aresetn			"pins" axi_gpio_SW/s_axi_aresetn
connect "pins" rst_global/peripheral_aresetn			"pins" axi_periph_interconn/ARESETN
connect "pins" rst_global/peripheral_aresetn			"pins" axi_periph_interconn/M00_ARESETN
connect "pins" rst_global/peripheral_aresetn			"pins" axi_periph_interconn/M01_ARESETN
connect "pins" rst_global/peripheral_aresetn			"pins" axi_periph_interconn/M02_ARESETN
connect "pins" rst_global/peripheral_aresetn			"pins" axi_periph_interconn/S00_ARESETN

#------------------------ Connections Switches --------------------
connect "ports" switches		"pins" axi_gpio_SW/gpio_io_i
connect "ports" switches		"pins" sw0/Din
connect "ports" switches		"pins" sw1/Din
connect "ports" switches		"pins" sw2/Din

#------------------------ Connections MCU --------------------
#https://digilent.com/reference/programmable-logic/genesys-zu/reference-manual#application_section
if { $BOARD == "GENESYS" } {
  connect "ports" vadj_level0		"pins" vdd33/dout
  connect "ports" vadj_level1		"pins" vdd33/dout
  connect "ports" vadj_auton		"pins" vdd33/dout
}

#---------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------- ADDRESS -------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------#
if { $BOARD == "Z10" || $BOARD == "Z20" } {
    if {$clk_dynamic_reconfig} {
        append address "assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces processing_system7_0/Data\] \[get_bd_addr_segs clk_wiz_I2S/s_axi_lite/Reg\] -force\n"
    }
    append address "  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space \[get_bd_addr_spaces syfala/Data_m_axi_ram\] \[get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM\] -force\n"
    append address "  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces processing_system7_0/Data\] \[get_bd_addr_segs axi_gpio_LED/S_AXI/Reg\] -force\n"
    append address "  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces processing_system7_0/Data\] \[get_bd_addr_segs axi_gpio_SW/S_AXI/Reg\] -force\n"
    append address "  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces processing_system7_0/Data\] \[get_bd_addr_segs syfala/s_axi_control/Reg\] -force\n"
} elseif { $BOARD == "GENESYS" } {

    append address "  assign_bd_address -offset 0x000800000000 -range 0x000800000000 -target_address_space \[get_bd_addr_spaces syfala/Data_m_axi_ram\] \[get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_HIGH\] -force\n"
    append address "  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space \[get_bd_addr_spaces syfala/Data_m_axi_ram\] \[get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW\] -force\n"
    append address "  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space \[get_bd_addr_spaces syfala/Data_m_axi_ram\] \[get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI\] -force\n"
    append address "  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces zynq_ultra_ps_e_0/Data\] \[get_bd_addr_segs axi_gpio_LED/S_AXI/Reg\] -force\n"
    append address "  assign_bd_address -offset 0x80010000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces zynq_ultra_ps_e_0/Data\] \[get_bd_addr_segs axi_gpio_SW/S_AXI/Reg\] -force\n"
    append address "  assign_bd_address -offset 0x80020000 -range 0x00010000 -target_address_space \[get_bd_addr_spaces zynq_ultra_ps_e_0/Data\] \[get_bd_addr_segs syfala/s_axi_control/Reg\] -force\n"
  # Exclude Address Segments
    append address "  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space \[get_bd_addr_spaces syfala/Data_m_axi_ram\] \[get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM\]\n"
}


while {[gets $project_file line] >= 0} {

        if {[string first "<<IP_CHECK>>" $line] != -1} {
            puts $generated_project_file $ip_check
        } elseif {[string first "<<GENERATED_PORTS>>" $line] != -1} {
            puts $generated_project_file $ports
        } elseif {[string first "<<GENERATED_CONNECTIONS>>" $line] != -1} {
            puts $generated_project_file $connections
        } elseif {[string first "<<IMPORT_FILES>>" $line] != -1} {
            foreach path $declarations_path {
                puts $generated_project_file " \[file normalize \"$path\" \]\\"
            }
        } elseif {[string first "<<MODULE_NAMES>>" $line] != -1} {
            foreach name $module_names {
                puts $generated_project_file "  $name\\"
            }
        } elseif {[string first "<<CREATED_INSTANCES>>" $line] != -1} {
            puts $generated_project_file $user_instances
            puts $generated_project_file $system_instances
        } elseif {[string first "<<GENERATED_CLOCKWIZ>>" $line] != -1} {
            puts $generated_project_file $clock_instances
        } elseif {[string first "<<GENERATED_ADDRESS>>" $line] != -1} {
            puts $generated_project_file $address
        } elseif {[string first "<<PS_CONFIG>>" $line] != -1} {
            if { $BOARD == "Z10" || $BOARD == "Z20" } {
                set ps_config_file [open "../scripts/bd_res/zybo_ps7.config" r]
            } elseif { $BOARD == "GENESYS" } {
                set ps_config_file [open "../scripts/bd_res/genesys_psu.config" r]
            }
            while {[gets $ps_config_file line_config] >= 0} {
                    puts $generated_project_file $line_config
            }
        } else {
            puts $generated_project_file $line
        }
}
close $project_file
close $generated_project_file

print_ok "Project script file successfully generated"
