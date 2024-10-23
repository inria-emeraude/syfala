
################################################################
# This is a generated script based on design: main
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source main_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# clock_divider, mux_2to1, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_fifth_fixed, sd_dac_first

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART digilentinc.com:zybo-z7-20:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name main

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:hls:syfala:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
clock_divider\
mux_2to1\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_fifth_fixed\
sd_dac_first\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  set IIC_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_0 ]

  set leds_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]

  set rgb_led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 rgb_led ]


  # Create ports
  set CODEC10_sd_rx [ create_bd_port -dir O CODEC10_sd_rx ]
  set CODEC10_sd_tx [ create_bd_port -dir O CODEC10_sd_tx ]
  set CODEC11_sd_rx [ create_bd_port -dir O CODEC11_sd_rx ]
  set CODEC11_sd_tx [ create_bd_port -dir O CODEC11_sd_tx ]
  set CODEC12_sd_rx [ create_bd_port -dir O CODEC12_sd_rx ]
  set CODEC12_sd_tx [ create_bd_port -dir O CODEC12_sd_tx ]
  set CODEC13_sd_rx [ create_bd_port -dir O CODEC13_sd_rx ]
  set CODEC13_sd_tx [ create_bd_port -dir O CODEC13_sd_tx ]
  set CODEC1_sd_rx [ create_bd_port -dir O CODEC1_sd_rx ]
  set CODEC1_sd_tx [ create_bd_port -dir O CODEC1_sd_tx ]
  set CODEC2_sd_rx [ create_bd_port -dir O CODEC2_sd_rx ]
  set CODEC2_sd_tx [ create_bd_port -dir O CODEC2_sd_tx ]
  set CODEC3_sd_rx [ create_bd_port -dir O CODEC3_sd_rx ]
  set CODEC3_sd_tx [ create_bd_port -dir O CODEC3_sd_tx ]
  set CODEC4_sd_rx [ create_bd_port -dir O CODEC4_sd_rx ]
  set CODEC4_sd_tx [ create_bd_port -dir O CODEC4_sd_tx ]
  set CODEC5_sd_rx [ create_bd_port -dir O CODEC5_sd_rx ]
  set CODEC5_sd_tx [ create_bd_port -dir O CODEC5_sd_tx ]
  set CODEC6_sd_rx [ create_bd_port -dir O CODEC6_sd_rx ]
  set CODEC6_sd_tx [ create_bd_port -dir O CODEC6_sd_tx ]
  set CODEC7_sd_rx [ create_bd_port -dir O CODEC7_sd_rx ]
  set CODEC7_sd_tx [ create_bd_port -dir O CODEC7_sd_tx ]
  set CODEC8_sd_rx [ create_bd_port -dir O CODEC8_sd_rx ]
  set CODEC8_sd_tx [ create_bd_port -dir O CODEC8_sd_tx ]
  set CODEC9_sd_rx [ create_bd_port -dir O CODEC9_sd_rx ]
  set CODEC9_sd_tx [ create_bd_port -dir O CODEC9_sd_tx ]
  set board_clk [ create_bd_port -dir I -type clk -freq_hz 125000000 board_clk ]
  set debug_btn [ create_bd_port -dir I debug_btn ]
  set internal_codec_mclk [ create_bd_port -dir O internal_codec_mclk ]
  set internal_codec_out_mute [ create_bd_port -dir O -from 0 -to 0 internal_codec_out_mute ]
  set spi_MISO [ create_bd_port -dir I spi_MISO ]
  set spi_MOSI [ create_bd_port -dir O spi_MOSI ]
  set spi_SS [ create_bd_port -dir O spi_SS ]
  set spi_clk [ create_bd_port -dir O spi_clk ]
  set switches [ create_bd_port -dir I -from 3 -to 0 switches ]
  set syfala_out_debug0 [ create_bd_port -dir O syfala_out_debug0 ]
  set syfala_out_debug1 [ create_bd_port -dir O syfala_out_debug1 ]
  set syfala_out_debug3 [ create_bd_port -dir O syfala_out_debug3 ]

  # Create instance: GND, and set properties
  set GND [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 GND ]
  set_property CONFIG.CONST_VAL {0} $GND


  # Create instance: axi_gpio_LED, and set properties
  set axi_gpio_LED [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_LED ]
  set_property -dict [list \
    CONFIG.GPIO2_BOARD_INTERFACE {rgb_led} \
    CONFIG.GPIO_BOARD_INTERFACE {leds_4bits} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_gpio_LED


  # Create instance: axi_gpio_SW, and set properties
  set axi_gpio_SW [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_SW ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {0} \
    CONFIG.GPIO_BOARD_INTERFACE {Custom} \
  ] $axi_gpio_SW


  # Create instance: axi_mem_interconn, and set properties
  set axi_mem_interconn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_interconn ]
  set_property CONFIG.NUM_MI {1} $axi_mem_interconn


  # Create instance: axi_periph_interconn, and set properties
  set axi_periph_interconn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_periph_interconn ]
  set_property CONFIG.NUM_MI {3} $axi_periph_interconn


  # Create instance: clk_wiz_sys_clk, and set properties
  set clk_wiz_sys_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_sys_clk ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {130.680} \
    CONFIG.CLKOUT1_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
    CONFIG.CLKOUT2_JITTER {249.501} \
    CONFIG.CLKOUT2_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {5} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_JITTER {203.896} \
    CONFIG.CLKOUT3_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {13.9} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLKOUT4_JITTER {173.367} \
    CONFIG.CLKOUT4_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {31.25} \
    CONFIG.CLKOUT4_USED {true} \
    CONFIG.CLKOUT5_JITTER {163.597} \
    CONFIG.CLKOUT5_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {41.66667} \
    CONFIG.CLKOUT5_USED {true} \
    CONFIG.CLKOUT6_JITTER {238.790} \
    CONFIG.CLKOUT6_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {6.25} \
    CONFIG.CLKOUT6_USED {true} \
    CONFIG.CLKOUT7_JITTER {208.210} \
    CONFIG.CLKOUT7_PHASE_ERROR {122.096} \
    CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {12.5} \
    CONFIG.CLKOUT7_USED {true} \
    CONFIG.CLK_OUT1_PORT {sys_clk} \
    CONFIG.CLK_OUT2_PORT {five_mhz_clk} \
    CONFIG.CLK_OUT3_PORT {sd_clk} \
    CONFIG.CLK_OUT4_PORT {faster3125_sd_clk} \
    CONFIG.CLK_OUT5_PORT {ef4166_sd_clk} \
    CONFIG.CLK_OUT6_PORT {slow6144_sd_clk} \
    CONFIG.CLK_OUT7_PORT {slow125_sd_clk} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {125} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {45} \
    CONFIG.MMCM_CLKOUT3_DIVIDE {20} \
    CONFIG.MMCM_CLKOUT4_DIVIDE {15} \
    CONFIG.MMCM_CLKOUT5_DIVIDE {100} \
    CONFIG.MMCM_CLKOUT6_DIVIDE {50} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {7} \
    CONFIG.PRIM_IN_FREQ {125} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {false} \
  ] $clk_wiz_sys_clk


  # Create instance: clock_divider_0, and set properties
  set block_name clock_divider
  set block_cell_name clock_divider_0
  if { [catch {set clock_divider_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $clock_divider_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mux_2to1_0, and set properties
  set block_name mux_2to1
  set block_cell_name mux_2to1_0
  if { [catch {set mux_2to1_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mux_2to1_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {667} \
    CONFIG.PCW_CLK0_FREQ {10000000} \
    CONFIG.PCW_CLK1_FREQ {10000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
    CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
    CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
    CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
    CONFIG.PCW_EN_4K_TIMER {0} \
    CONFIG.PCW_EN_CLK0_PORT {0} \
    CONFIG.PCW_EN_EMIO_I2C0 {1} \
    CONFIG.PCW_EN_EMIO_SPI0 {1} \
    CONFIG.PCW_EN_ENET0 {0} \
    CONFIG.PCW_EN_GPIO {0} \
    CONFIG.PCW_EN_I2C0 {1} \
    CONFIG.PCW_EN_QSPI {1} \
    CONFIG.PCW_EN_SDIO0 {0} \
    CONFIG.PCW_EN_SPI0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_EN_USB0 {0} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0} \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C0_I2C0_IO {EMIO} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_1_PULLUP {enabled} \
    CONFIG.PCW_MIO_1_SLEW {slow} \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_2_SLEW {slow} \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_3_SLEW {slow} \
    CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_48_PULLUP {enabled} \
    CONFIG.PCW_MIO_48_SLEW {slow} \
    CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_49_PULLUP {enabled} \
    CONFIG.PCW_MIO_49_SLEW {slow} \
    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_4_SLEW {slow} \
    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_5_SLEW {slow} \
    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_6_SLEW {slow} \
    CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_8_SLEW {slow} \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {unassigned#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#unassigned#Quad SPI Flash#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#UART\
1#UART 1#unassigned#unassigned#unassigned#unassigned} \
    CONFIG.PCW_MIO_TREE_SIGNALS {unassigned#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#unassigned#qspi_fbclk#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#tx#rx#unassigned#unassigned#unassigned#unassigned}\
\
    CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.221} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.222} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.217} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.244} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.050} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.044} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.035} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.100} \
    CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
    CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
    CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
    CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {0} \
    CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
    CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
    CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
    CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
    CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
    CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
    CONFIG.PCW_UIPARAM_DDR_AL {0} \
    CONFIG.PCW_UIPARAM_DDR_BL {8} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.221} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.222} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.217} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.244} \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {18.8} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {80.4535} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {18.8} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {80.4535} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {18.8} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {80.4535} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {18.8} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {80.4535} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {22.8} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {105.056} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {27.9} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {66.904} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {22.9} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {89.1715} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {29.4} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {113.63} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.050} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.044} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.035} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.100} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {22.8} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {98.503} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {27.9} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {68.5855} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {22.9} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {90.295} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {29.4} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {103.977} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
    CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
    CONFIG.PCW_USE_AXI_NONSECURE {0} \
    CONFIG.PCW_USE_CROSS_TRIGGER {0} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
  ] $processing_system7_0


  # Create instance: rst_global, and set properties
  set rst_global [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_global ]

  # Create instance: sd_dac_fifth_fixed_0, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_0
  if { [catch {set sd_dac_fifth_fixed_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_1, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_1
  if { [catch {set sd_dac_fifth_fixed_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_2, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_2
  if { [catch {set sd_dac_fifth_fixed_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_2 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_3, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_3
  if { [catch {set sd_dac_fifth_fixed_3 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_3 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_4, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_4
  if { [catch {set sd_dac_fifth_fixed_4 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_4 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_5, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_5
  if { [catch {set sd_dac_fifth_fixed_5 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_5 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_6, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_6
  if { [catch {set sd_dac_fifth_fixed_6 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_6 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_7, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_7
  if { [catch {set sd_dac_fifth_fixed_7 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_7 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_8, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_8
  if { [catch {set sd_dac_fifth_fixed_8 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_8 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_9, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_9
  if { [catch {set sd_dac_fifth_fixed_9 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_9 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_10, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_10
  if { [catch {set sd_dac_fifth_fixed_10 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_10 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_11, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_11
  if { [catch {set sd_dac_fifth_fixed_11 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_11 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_12, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_12
  if { [catch {set sd_dac_fifth_fixed_12 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_12 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_13, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_13
  if { [catch {set sd_dac_fifth_fixed_13 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_13 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_14, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_14
  if { [catch {set sd_dac_fifth_fixed_14 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_14 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_15, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_15
  if { [catch {set sd_dac_fifth_fixed_15 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_15 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_16, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_16
  if { [catch {set sd_dac_fifth_fixed_16 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_16 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_17, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_17
  if { [catch {set sd_dac_fifth_fixed_17 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_17 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_18, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_18
  if { [catch {set sd_dac_fifth_fixed_18 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_18 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_19, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_19
  if { [catch {set sd_dac_fifth_fixed_19 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_19 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_20, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_20
  if { [catch {set sd_dac_fifth_fixed_20 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_20 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_21, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_21
  if { [catch {set sd_dac_fifth_fixed_21 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_21 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_22, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_22
  if { [catch {set sd_dac_fifth_fixed_22 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_22 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_23, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_23
  if { [catch {set sd_dac_fifth_fixed_23 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_23 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_24, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_24
  if { [catch {set sd_dac_fifth_fixed_24 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_24 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_25, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_25
  if { [catch {set sd_dac_fifth_fixed_25 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_25 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_26, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_26
  if { [catch {set sd_dac_fifth_fixed_26 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_26 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_fifth_fixed_27, and set properties
  set block_name sd_dac_fifth_fixed
  set block_cell_name sd_dac_fifth_fixed_27
  if { [catch {set sd_dac_fifth_fixed_27 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_fifth_fixed_27 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sd_dac_first_0, and set properties
  set block_name sd_dac_first
  set block_cell_name sd_dac_first_0
  if { [catch {set sd_dac_first_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sd_dac_first_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sw0, and set properties
  set sw0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw0 ]
  set_property CONFIG.DIN_WIDTH {4} $sw0


  # Create instance: sw1, and set properties
  set sw1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {4} \
    CONFIG.DOUT_WIDTH {1} \
  ] $sw1


  # Create instance: sw2, and set properties
  set sw2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {4} \
    CONFIG.DOUT_WIDTH {1} \
  ] $sw2


  # Create instance: syfala, and set properties
  set syfala [ create_bd_cell -type ip -vlnv xilinx.com:hls:syfala:1.0 syfala ]

  # Create instance: vdd33, and set properties
  set vdd33 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vdd33 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_gpio_LED_GPIO [get_bd_intf_ports leds_4bits] [get_bd_intf_pins axi_gpio_LED/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_LED_GPIO2 [get_bd_intf_ports rgb_led] [get_bd_intf_pins axi_gpio_LED/GPIO2]
  connect_bd_intf_net -intf_net axi_mem_interconn_M00_AXI [get_bd_intf_pins axi_mem_interconn/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_periph_interconn_M00_AXI [get_bd_intf_pins axi_gpio_LED/S_AXI] [get_bd_intf_pins axi_periph_interconn/M00_AXI]
  connect_bd_intf_net -intf_net axi_periph_interconn_M01_AXI [get_bd_intf_pins axi_periph_interconn/M01_AXI] [get_bd_intf_pins syfala/s_axi_control]
  connect_bd_intf_net -intf_net axi_periph_interconn_M02_AXI [get_bd_intf_pins axi_gpio_SW/S_AXI] [get_bd_intf_pins axi_periph_interconn/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_IIC_0 [get_bd_intf_ports IIC_0] [get_bd_intf_pins processing_system7_0/IIC_0]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_periph_interconn/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net syfala_m_axi_ram [get_bd_intf_pins axi_mem_interconn/S00_AXI] [get_bd_intf_pins syfala/m_axi_ram]

  # Create port connections
  connect_bd_net -net board_clk_1 [get_bd_ports board_clk] [get_bd_pins clk_wiz_sys_clk/clk_in1]
  connect_bd_net -net clk_wiz_sys_clk_five_mhz_clk [get_bd_pins clk_wiz_sys_clk/five_mhz_clk] [get_bd_pins rst_global/slowest_sync_clk]
  connect_bd_net -net clk_wiz_sys_clk_locked [get_bd_pins clk_wiz_sys_clk/locked] [get_bd_pins rst_global/dcm_locked]
  connect_bd_net -net clk_wiz_sys_clk_sd_clk [get_bd_pins clk_wiz_sys_clk/sd_clk] [get_bd_pins sd_dac_fifth_fixed_1/sd_clk] [get_bd_pins sd_dac_fifth_fixed_10/sd_clk] [get_bd_pins sd_dac_fifth_fixed_11/sd_clk] [get_bd_pins sd_dac_fifth_fixed_12/sd_clk] [get_bd_pins sd_dac_fifth_fixed_13/sd_clk] [get_bd_pins sd_dac_fifth_fixed_14/sd_clk] [get_bd_pins sd_dac_fifth_fixed_15/sd_clk] [get_bd_pins sd_dac_fifth_fixed_16/sd_clk] [get_bd_pins sd_dac_fifth_fixed_17/sd_clk] [get_bd_pins sd_dac_fifth_fixed_18/sd_clk] [get_bd_pins sd_dac_fifth_fixed_19/sd_clk] [get_bd_pins sd_dac_fifth_fixed_2/sd_clk] [get_bd_pins sd_dac_fifth_fixed_20/sd_clk] [get_bd_pins sd_dac_fifth_fixed_21/sd_clk] [get_bd_pins sd_dac_fifth_fixed_22/sd_clk] [get_bd_pins sd_dac_fifth_fixed_23/sd_clk] [get_bd_pins sd_dac_fifth_fixed_24/sd_clk] [get_bd_pins sd_dac_fifth_fixed_25/sd_clk] [get_bd_pins sd_dac_fifth_fixed_26/sd_clk] [get_bd_pins sd_dac_fifth_fixed_27/sd_clk] [get_bd_pins sd_dac_fifth_fixed_3/sd_clk] [get_bd_pins sd_dac_fifth_fixed_4/sd_clk] [get_bd_pins sd_dac_fifth_fixed_5/sd_clk] [get_bd_pins sd_dac_fifth_fixed_6/sd_clk] [get_bd_pins sd_dac_fifth_fixed_7/sd_clk] [get_bd_pins sd_dac_fifth_fixed_8/sd_clk] [get_bd_pins sd_dac_fifth_fixed_9/sd_clk]
  connect_bd_net -net clk_wiz_sys_clk_slow125_sd_clk [get_bd_pins clk_wiz_sys_clk/slow125_sd_clk] [get_bd_pins sd_dac_fifth_fixed_0/sd_clk]
  connect_bd_net -net clk_wiz_sys_clk_slow6144_sd_clk [get_bd_pins clk_wiz_sys_clk/slow6144_sd_clk] [get_bd_pins clock_divider_0/clk]
  connect_bd_net -net clk_wiz_sys_clk_sys_clk [get_bd_pins axi_gpio_LED/s_axi_aclk] [get_bd_pins axi_gpio_SW/s_axi_aclk] [get_bd_pins axi_mem_interconn/ACLK] [get_bd_pins axi_mem_interconn/M00_ACLK] [get_bd_pins axi_mem_interconn/S00_ACLK] [get_bd_pins axi_periph_interconn/ACLK] [get_bd_pins axi_periph_interconn/M00_ACLK] [get_bd_pins axi_periph_interconn/M01_ACLK] [get_bd_pins axi_periph_interconn/M02_ACLK] [get_bd_pins axi_periph_interconn/S00_ACLK] [get_bd_pins clk_wiz_sys_clk/sys_clk] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins sd_dac_fifth_fixed_0/sys_clk] [get_bd_pins sd_dac_fifth_fixed_1/sys_clk] [get_bd_pins sd_dac_fifth_fixed_10/sys_clk] [get_bd_pins sd_dac_fifth_fixed_11/sys_clk] [get_bd_pins sd_dac_fifth_fixed_12/sys_clk] [get_bd_pins sd_dac_fifth_fixed_13/sys_clk] [get_bd_pins sd_dac_fifth_fixed_14/sys_clk] [get_bd_pins sd_dac_fifth_fixed_15/sys_clk] [get_bd_pins sd_dac_fifth_fixed_16/sys_clk] [get_bd_pins sd_dac_fifth_fixed_17/sys_clk] [get_bd_pins sd_dac_fifth_fixed_18/sys_clk] [get_bd_pins sd_dac_fifth_fixed_19/sys_clk] [get_bd_pins sd_dac_fifth_fixed_2/sys_clk] [get_bd_pins sd_dac_fifth_fixed_20/sys_clk] [get_bd_pins sd_dac_fifth_fixed_21/sys_clk] [get_bd_pins sd_dac_fifth_fixed_22/sys_clk] [get_bd_pins sd_dac_fifth_fixed_23/sys_clk] [get_bd_pins sd_dac_fifth_fixed_24/sys_clk] [get_bd_pins sd_dac_fifth_fixed_25/sys_clk] [get_bd_pins sd_dac_fifth_fixed_26/sys_clk] [get_bd_pins sd_dac_fifth_fixed_27/sys_clk] [get_bd_pins sd_dac_fifth_fixed_3/sys_clk] [get_bd_pins sd_dac_fifth_fixed_4/sys_clk] [get_bd_pins sd_dac_fifth_fixed_5/sys_clk] [get_bd_pins sd_dac_fifth_fixed_6/sys_clk] [get_bd_pins sd_dac_fifth_fixed_7/sys_clk] [get_bd_pins sd_dac_fifth_fixed_8/sys_clk] [get_bd_pins sd_dac_fifth_fixed_9/sys_clk] [get_bd_pins sd_dac_first_0/sys_clk] [get_bd_pins syfala/ap_clk]
  connect_bd_net -net clock_divider_0_clock_out [get_bd_pins clock_divider_0/clock_out] [get_bd_pins syfala/ap_start]
  connect_bd_net -net debug_btn_1 [get_bd_ports debug_btn]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_global/ext_reset_in]
  connect_bd_net -net processing_system7_0_SPI0_MOSI_O [get_bd_ports spi_MOSI] [get_bd_pins processing_system7_0/SPI0_MOSI_O]
  connect_bd_net -net processing_system7_0_SPI0_SCLK_O [get_bd_ports spi_clk] [get_bd_pins processing_system7_0/SPI0_SCLK_O]
  connect_bd_net -net processing_system7_0_SPI0_SS_O [get_bd_ports spi_SS] [get_bd_pins processing_system7_0/SPI0_SS_O]
  connect_bd_net -net rst_global_peripheral_aresetn [get_bd_pins axi_gpio_LED/s_axi_aresetn] [get_bd_pins axi_gpio_SW/s_axi_aresetn] [get_bd_pins axi_mem_interconn/ARESETN] [get_bd_pins axi_mem_interconn/M00_ARESETN] [get_bd_pins axi_mem_interconn/S00_ARESETN] [get_bd_pins axi_periph_interconn/ARESETN] [get_bd_pins axi_periph_interconn/M00_ARESETN] [get_bd_pins axi_periph_interconn/M01_ARESETN] [get_bd_pins axi_periph_interconn/M02_ARESETN] [get_bd_pins axi_periph_interconn/S00_ARESETN] [get_bd_pins rst_global/peripheral_aresetn] [get_bd_pins syfala/ap_rst_n]
  connect_bd_net -net sd_dac_fifth_fixed_0_sd_output [get_bd_ports CODEC4_sd_rx] [get_bd_pins sd_dac_fifth_fixed_0/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_10_sd_output [get_bd_ports CODEC11_sd_rx] [get_bd_pins sd_dac_fifth_fixed_10/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_11_sd_output [get_bd_ports CODEC10_sd_tx] [get_bd_pins sd_dac_fifth_fixed_11/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_12_sd_output [get_bd_ports CODEC10_sd_rx] [get_bd_pins sd_dac_fifth_fixed_12/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_13_sd_output [get_bd_ports CODEC11_sd_tx] [get_bd_pins sd_dac_fifth_fixed_13/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_14_sd_output [get_bd_ports CODEC13_sd_rx] [get_bd_pins sd_dac_fifth_fixed_14/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_15_sd_output [get_bd_ports CODEC12_sd_tx] [get_bd_pins sd_dac_fifth_fixed_15/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_16_sd_output [get_bd_ports CODEC13_sd_tx] [get_bd_pins sd_dac_fifth_fixed_16/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_17_sd_output [get_bd_ports CODEC12_sd_rx] [get_bd_pins sd_dac_fifth_fixed_17/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_18_sd_output [get_bd_ports CODEC6_sd_rx] [get_bd_pins sd_dac_fifth_fixed_18/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_19_sd_output [get_bd_ports CODEC7_sd_rx] [get_bd_pins sd_dac_fifth_fixed_19/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_1_sd_output [get_bd_ports CODEC2_sd_rx] [get_bd_pins sd_dac_fifth_fixed_1/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_20_sd_output [get_bd_ports CODEC7_sd_tx] [get_bd_pins sd_dac_fifth_fixed_20/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_21_sd_output [get_bd_ports CODEC6_sd_tx] [get_bd_pins sd_dac_fifth_fixed_21/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_22_sd_output [get_bd_ports CODEC9_sd_rx] [get_bd_pins sd_dac_fifth_fixed_22/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_23_sd_output [get_bd_ports CODEC8_sd_rx] [get_bd_pins sd_dac_fifth_fixed_23/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_24_sd_output [get_bd_ports CODEC8_sd_tx] [get_bd_pins sd_dac_fifth_fixed_24/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_25_sd_output [get_bd_ports CODEC9_sd_tx] [get_bd_pins sd_dac_fifth_fixed_25/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_26_sd_output [get_bd_ports syfala_out_debug3] [get_bd_pins sd_dac_fifth_fixed_26/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_27_sd_output [get_bd_ports syfala_out_debug0] [get_bd_pins sd_dac_fifth_fixed_27/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_2_sd_output [get_bd_ports CODEC3_sd_tx] [get_bd_pins sd_dac_fifth_fixed_2/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_3_sd_output [get_bd_ports CODEC3_sd_rx] [get_bd_pins sd_dac_fifth_fixed_3/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_4_sd_output [get_bd_ports CODEC4_sd_tx] [get_bd_pins sd_dac_fifth_fixed_4/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_5_sd_output [get_bd_ports CODEC1_sd_rx] [get_bd_pins sd_dac_fifth_fixed_5/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_6_sd_output [get_bd_ports CODEC1_sd_tx] [get_bd_pins sd_dac_fifth_fixed_6/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_7_sd_output [get_bd_ports syfala_out_debug1] [get_bd_pins sd_dac_fifth_fixed_7/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_8_sd_output [get_bd_ports CODEC5_sd_rx] [get_bd_pins sd_dac_fifth_fixed_8/sd_output]
  connect_bd_net -net sd_dac_fifth_fixed_9_sd_output [get_bd_ports CODEC5_sd_tx] [get_bd_pins sd_dac_fifth_fixed_9/sd_output]
  connect_bd_net -net sd_dac_first_0_sd_output [get_bd_ports CODEC2_sd_tx] [get_bd_pins sd_dac_first_0/sd_output]
  connect_bd_net -net spi_MISO_1 [get_bd_ports spi_MISO] [get_bd_pins processing_system7_0/SPI0_MISO_I]
  connect_bd_net -net sw0_Dout [get_bd_pins sw0/Dout] [get_bd_pins syfala/mute]
  connect_bd_net -net sw1_Dout [get_bd_pins sw1/Dout] [get_bd_pins syfala/bypass]
  connect_bd_net -net sw2_Dout [get_bd_pins mux_2to1_0/Sel] [get_bd_pins sw2/Dout]
  connect_bd_net -net switches_1 [get_bd_ports switches] [get_bd_pins axi_gpio_SW/gpio_io_i] [get_bd_pins sw0/Din] [get_bd_pins sw1/Din] [get_bd_pins sw2/Din]
  connect_bd_net -net syfala_audio_out_0 [get_bd_pins sd_dac_fifth_fixed_0/sd_input] [get_bd_pins sd_dac_fifth_fixed_1/sd_input] [get_bd_pins sd_dac_fifth_fixed_10/sd_input] [get_bd_pins sd_dac_fifth_fixed_11/sd_input] [get_bd_pins sd_dac_fifth_fixed_12/sd_input] [get_bd_pins sd_dac_fifth_fixed_13/sd_input] [get_bd_pins sd_dac_fifth_fixed_14/sd_input] [get_bd_pins sd_dac_fifth_fixed_15/sd_input] [get_bd_pins sd_dac_fifth_fixed_16/sd_input] [get_bd_pins sd_dac_fifth_fixed_17/sd_input] [get_bd_pins sd_dac_fifth_fixed_18/sd_input] [get_bd_pins sd_dac_fifth_fixed_19/sd_input] [get_bd_pins sd_dac_fifth_fixed_2/sd_input] [get_bd_pins sd_dac_fifth_fixed_20/sd_input] [get_bd_pins sd_dac_fifth_fixed_21/sd_input] [get_bd_pins sd_dac_fifth_fixed_22/sd_input] [get_bd_pins sd_dac_fifth_fixed_23/sd_input] [get_bd_pins sd_dac_fifth_fixed_24/sd_input] [get_bd_pins sd_dac_fifth_fixed_25/sd_input] [get_bd_pins sd_dac_fifth_fixed_26/sd_input] [get_bd_pins sd_dac_fifth_fixed_27/sd_input] [get_bd_pins sd_dac_fifth_fixed_3/sd_input] [get_bd_pins sd_dac_fifth_fixed_4/sd_input] [get_bd_pins sd_dac_fifth_fixed_5/sd_input] [get_bd_pins sd_dac_fifth_fixed_6/sd_input] [get_bd_pins sd_dac_fifth_fixed_7/sd_input] [get_bd_pins sd_dac_fifth_fixed_8/sd_input] [get_bd_pins sd_dac_fifth_fixed_9/sd_input] [get_bd_pins sd_dac_first_0/sd_input] [get_bd_pins syfala/audio_out_0]
  connect_bd_net -net syfala_audio_out_0_ap_vld [get_bd_pins sd_dac_fifth_fixed_0/samp_clk] [get_bd_pins sd_dac_fifth_fixed_1/samp_clk] [get_bd_pins sd_dac_fifth_fixed_10/samp_clk] [get_bd_pins sd_dac_fifth_fixed_11/samp_clk] [get_bd_pins sd_dac_fifth_fixed_12/samp_clk] [get_bd_pins sd_dac_fifth_fixed_13/samp_clk] [get_bd_pins sd_dac_fifth_fixed_14/samp_clk] [get_bd_pins sd_dac_fifth_fixed_15/samp_clk] [get_bd_pins sd_dac_fifth_fixed_16/samp_clk] [get_bd_pins sd_dac_fifth_fixed_17/samp_clk] [get_bd_pins sd_dac_fifth_fixed_18/samp_clk] [get_bd_pins sd_dac_fifth_fixed_19/samp_clk] [get_bd_pins sd_dac_fifth_fixed_2/samp_clk] [get_bd_pins sd_dac_fifth_fixed_20/samp_clk] [get_bd_pins sd_dac_fifth_fixed_21/samp_clk] [get_bd_pins sd_dac_fifth_fixed_22/samp_clk] [get_bd_pins sd_dac_fifth_fixed_23/samp_clk] [get_bd_pins sd_dac_fifth_fixed_24/samp_clk] [get_bd_pins sd_dac_fifth_fixed_25/samp_clk] [get_bd_pins sd_dac_fifth_fixed_26/samp_clk] [get_bd_pins sd_dac_fifth_fixed_27/samp_clk] [get_bd_pins sd_dac_fifth_fixed_3/samp_clk] [get_bd_pins sd_dac_fifth_fixed_4/samp_clk] [get_bd_pins sd_dac_fifth_fixed_5/samp_clk] [get_bd_pins sd_dac_fifth_fixed_6/samp_clk] [get_bd_pins sd_dac_fifth_fixed_7/samp_clk] [get_bd_pins sd_dac_fifth_fixed_8/samp_clk] [get_bd_pins sd_dac_fifth_fixed_9/samp_clk] [get_bd_pins sd_dac_first_0/samp_clock] [get_bd_pins syfala/audio_out_0_ap_vld]
  connect_bd_net -net vdd33_dout [get_bd_ports internal_codec_out_mute] [get_bd_pins processing_system7_0/SPI0_SS_I] [get_bd_pins vdd33/dout]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_LED/S_AXI/Reg] -force
  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_SW/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs syfala/s_axi_control/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces syfala/Data_m_axi_ram] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


