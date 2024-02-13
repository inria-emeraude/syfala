
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
# i2s_transceiver, mux_2to1

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART digilentinc.com:zybo-z7-20:part0:1.0 [current_project]
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
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:hls:eth_audio:1.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:hls:syfala:1.0\
xilinx.com:ip:xlconstant:1.1\
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
i2s_transceiver\
mux_2to1\
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

  set IIC_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_1 ]

  set leds_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]

  set rgb_led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 rgb_led ]


  # Create ports
  set CODEC1_sd_rx [ create_bd_port -dir I CODEC1_sd_rx ]
  set CODEC1_sd_tx [ create_bd_port -dir O CODEC1_sd_tx ]
  set board_clk [ create_bd_port -dir I -type clk -freq_hz 125000000 board_clk ]
  set debug_btn [ create_bd_port -dir I debug_btn ]
  set external_codec_bclk [ create_bd_port -dir O external_codec_bclk ]
  set external_codec_mclk [ create_bd_port -dir O external_codec_mclk ]
  set external_codec_ws [ create_bd_port -dir O external_codec_ws ]
  set internal_codec_bclk [ create_bd_port -dir O internal_codec_bclk ]
  set internal_codec_mclk [ create_bd_port -dir O internal_codec_mclk ]
  set internal_codec_out_mute [ create_bd_port -dir O -from 0 -to 0 internal_codec_out_mute ]
  set internal_codec_sd_rx [ create_bd_port -dir I internal_codec_sd_rx ]
  set internal_codec_sd_tx [ create_bd_port -dir O internal_codec_sd_tx ]
  set internal_codec_ws_rx [ create_bd_port -dir O internal_codec_ws_rx ]
  set internal_codec_ws_tx [ create_bd_port -dir O internal_codec_ws_tx ]
  set spi_MISO [ create_bd_port -dir I spi_MISO ]
  set spi_MOSI [ create_bd_port -dir O spi_MOSI ]
  set spi_SS [ create_bd_port -dir O spi_SS ]
  set spi_clk [ create_bd_port -dir O spi_clk ]
  set switches [ create_bd_port -dir I -from 3 -to 0 switches ]
  set syfala_out_debug0 [ create_bd_port -dir O syfala_out_debug0 ]
  set syfala_out_debug1 [ create_bd_port -dir O syfala_out_debug1 ]
  set syfala_out_debug2 [ create_bd_port -dir O syfala_out_debug2 ]
  set syfala_out_debug3 [ create_bd_port -dir O syfala_out_debug3 ]

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
  set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
  ] $axi_mem_interconn


  # Create instance: axi_periph_interconn, and set properties
  set axi_periph_interconn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_periph_interconn ]
  set_property CONFIG.NUM_MI {4} $axi_periph_interconn


  # Create instance: clk_wiz_I2S, and set properties
  set clk_wiz_I2S [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_I2S ]
  set_property -dict [list \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.2885835} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {24.577167} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLK_OUT1_PORT {clk_I2S} \
    CONFIG.CLK_OUT2_PORT {clk_24Mhz} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.PRIM_IN_FREQ {122.885835} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {false} \
  ] $clk_wiz_I2S


  # Create instance: clk_wiz_sys_clk, and set properties
  set clk_wiz_sys_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_sys_clk ]
  set_property -dict [list \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {122.885835} \
    CONFIG.CLK_OUT1_PORT {sys_clk} \
    CONFIG.PRIM_IN_FREQ {125} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.USE_RESET {false} \
  ] $clk_wiz_sys_clk


  # Create instance: eth_audio_0, and set properties
  set eth_audio_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:eth_audio:1.0 eth_audio_0 ]

  # Create instance: i2s_transceiver_0, and set properties
  set block_name i2s_transceiver
  set block_cell_name i2s_transceiver_0
  if { [catch {set i2s_transceiver_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $i2s_transceiver_0 eq "" } {
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
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
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
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_I2C0 {1} \
    CONFIG.PCW_EN_EMIO_I2C1 {1} \
    CONFIG.PCW_EN_EMIO_SPI0 {1} \
    CONFIG.PCW_EN_ENET0 {0} \
    CONFIG.PCW_EN_GPIO {0} \
    CONFIG.PCW_EN_I2C0 {1} \
    CONFIG.PCW_EN_I2C1 {1} \
    CONFIG.PCW_EN_QSPI {1} \
    CONFIG.PCW_EN_SDIO0 {1} \
    CONFIG.PCW_EN_SPI0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_EN_USB0 {0} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0} \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C0_I2C0_IO {EMIO} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C1_I2C1_IO {EMIO} \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_1_PULLUP {enabled} \
    CONFIG.PCW_MIO_1_SLEW {slow} \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_2_SLEW {slow} \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_3_SLEW {slow} \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_40_PULLUP {enabled} \
    CONFIG.PCW_MIO_40_SLEW {slow} \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_41_PULLUP {enabled} \
    CONFIG.PCW_MIO_41_SLEW {slow} \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_42_PULLUP {enabled} \
    CONFIG.PCW_MIO_42_SLEW {slow} \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_43_PULLUP {enabled} \
    CONFIG.PCW_MIO_43_SLEW {slow} \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_44_PULLUP {enabled} \
    CONFIG.PCW_MIO_44_SLEW {slow} \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_45_PULLUP {enabled} \
    CONFIG.PCW_MIO_45_SLEW {slow} \
    CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_47_PULLUP {enabled} \
    CONFIG.PCW_MIO_47_SLEW {slow} \
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
    CONFIG.PCW_MIO_TREE_PERIPHERALS {unassigned#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#unassigned#Quad SPI Flash#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#SD\
0#SD 0#SD 0#SD 0#SD 0#SD 0#unassigned#SD 0#UART 1#UART 1#unassigned#unassigned#unassigned#unassigned} \
    CONFIG.PCW_MIO_TREE_SIGNALS {unassigned#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#unassigned#qspi_fbclk#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#clk#cmd#data[0]#data[1]#data[2]#data[3]#unassigned#cd#tx#rx#unassigned#unassigned#unassigned#unassigned}\
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
    CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
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
    CONFIG.PCW_USE_S_AXI_HP1 {0} \
  ] $processing_system7_0


  # Create instance: rst_global, and set properties
  set rst_global [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_global ]

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
  connect_bd_intf_net -intf_net axi_periph_interconn_M03_AXI [get_bd_intf_pins axi_periph_interconn/M03_AXI] [get_bd_intf_pins eth_audio_0/s_axi_control]
  connect_bd_intf_net -intf_net eth_audio_0_m_axi_ram [get_bd_intf_pins axi_mem_interconn/S01_AXI] [get_bd_intf_pins eth_audio_0/m_axi_ram]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_IIC_0 [get_bd_intf_ports IIC_0] [get_bd_intf_pins processing_system7_0/IIC_0]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_periph_interconn/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net syfala_m_axi_ram [get_bd_intf_pins axi_mem_interconn/S00_AXI] [get_bd_intf_pins syfala/m_axi_ram]

  # Create port connections
  connect_bd_net -net CODEC1_sd_rx_1 [get_bd_ports CODEC1_sd_rx] [get_bd_pins mux_2to1_0/inA]
  connect_bd_net -net board_clk_1 [get_bd_ports board_clk] [get_bd_pins clk_wiz_sys_clk/clk_in1]
  connect_bd_net -net clk_wiz_I2S_clk_24Mhz [get_bd_ports external_codec_mclk] [get_bd_ports internal_codec_mclk] [get_bd_pins clk_wiz_I2S/clk_24Mhz] [get_bd_pins rst_global/slowest_sync_clk]
  connect_bd_net -net clk_wiz_I2S_clk_I2S [get_bd_pins clk_wiz_I2S/clk_I2S] [get_bd_pins i2s_transceiver_0/mclk]
  connect_bd_net -net clk_wiz_I2S_locked [get_bd_pins clk_wiz_I2S/locked] [get_bd_pins rst_global/dcm_locked]
  connect_bd_net -net clk_wiz_sys_clk_sys_clk [get_bd_pins axi_gpio_LED/s_axi_aclk] [get_bd_pins axi_gpio_SW/s_axi_aclk] [get_bd_pins axi_mem_interconn/ACLK] [get_bd_pins axi_mem_interconn/M00_ACLK] [get_bd_pins axi_mem_interconn/S00_ACLK] [get_bd_pins axi_mem_interconn/S01_ACLK] [get_bd_pins axi_periph_interconn/ACLK] [get_bd_pins axi_periph_interconn/M00_ACLK] [get_bd_pins axi_periph_interconn/M01_ACLK] [get_bd_pins axi_periph_interconn/M02_ACLK] [get_bd_pins axi_periph_interconn/M03_ACLK] [get_bd_pins axi_periph_interconn/S00_ACLK] [get_bd_pins clk_wiz_I2S/clk_in1] [get_bd_pins clk_wiz_sys_clk/sys_clk] [get_bd_pins eth_audio_0/ap_clk] [get_bd_pins i2s_transceiver_0/sys_clk] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins syfala/ap_clk]
  connect_bd_net -net debug_btn_1 [get_bd_ports debug_btn] [get_bd_pins syfala/debug]

proc connect {args} {
    set cmd ""
    if {[lcontains "intf_pins" $args] ||
        [lcontains "intf_ports" $args]}  {
         set cmd "connect_bd_intf_net "
    } else {
         set cmd "connect_bd_net "
    }
    for {set n 0} {$n < [llength $args]} {incr n 2} {
         set t [lindex $args $n]
         set c [lindex $args [expr $n+1]]
         append cmd "\[get_bd_$t $c\] "
    }
    print_info $cmd
    eval $cmd
}

# ---------------------------------------------------
foreach_n $::rt::nchannels_i {{n} {
# ---------------------------------------------------
# 1. From eth_audio to i2s
connect "pins" eth_audio_0/audio_out_$n             \
        "pins" i2s_transceiver_0/from_eth_ch$n

connect "pins" eth_audio_0/audio_out_$n\_ap_vld      \
        "pins" i2s_transceiver_0/from_eth_ch$n\_ap_vld

# 2. From i2s to faust
connect "pins" syfala/audio_in_$n                   \
        "pins" i2s_transceiver_0/to_faust_ch$n
}}
# ---------------------------------------------------
foreach_n $::rt::nchannels_o {{n} {
# ---------------------------------------------------
# 3. from faust to i2s
connect "pins" syfala/audio_out_$n                  \
        "pins" i2s_transceiver_0/from_faust_ch$n
# ---------------------------------------------------
connect "pins" syfala/audio_out_$n\_ap_vld          \
        "pins" i2s_transceiver_0/from_faust_ch$n\_ap_vld

# 4 from i2s to eth_audio
if {$::rt::ethernet_no_output} {
    # ---------------------------------------------------
    connect "pins" i2s_transceiver_0/to_eth_ch$n        \
            "pins" eth_audio_0/audio_in_$n
    # ---------------------------------------------------
}
}}

#  connect_bd_net -net eth_audio_0_audio_out0 [get_bd_pins eth_audio_0/audio_out0] [get_bd_pins i2s_transceiver_0/from_eth_ch0]
#  connect_bd_net -net eth_audio_0_audio_out0_ap_vld [get_bd_pins eth_audio_0/audio_out0_ap_vld] [get_bd_pins i2s_transceiver_0/from_eth_ch0_ap_vld]
#  connect_bd_net -net eth_audio_0_audio_out1 [get_bd_pins eth_audio_0/audio_out1] [get_bd_pins i2s_transceiver_0/from_eth_ch1]
#  connect_bd_net -net eth_audio_0_audio_out1_ap_vld [get_bd_pins eth_audio_0/audio_out1_ap_vld] [get_bd_pins i2s_transceiver_0/from_eth_ch1_ap_vld]


  connect_bd_net -net i2s_transceiver_0_rdy [get_bd_ports syfala_out_debug3] [get_bd_pins eth_audio_0/ap_start] [get_bd_pins i2s_transceiver_0/rdy] [get_bd_pins syfala/ap_start]
  connect_bd_net -net i2s_transceiver_0_sclk [get_bd_ports external_codec_bclk] [get_bd_ports internal_codec_bclk] [get_bd_pins i2s_transceiver_0/sclk]
  connect_bd_net -net i2s_transceiver_0_sd_ch0_ch1_tx [get_bd_ports CODEC1_sd_tx] [get_bd_ports internal_codec_sd_tx] [get_bd_pins i2s_transceiver_0/sd_ch0_ch1_tx]

#  connect_bd_net -net i2s_transceiver_0_to_eth_ch0 [get_bd_pins eth_audio_0/audio_in0] [get_bd_pins i2s_transceiver_0/to_eth_ch0]
#  connect_bd_net -net i2s_transceiver_0_to_eth_ch1 [get_bd_pins eth_audio_0/audio_in1] [get_bd_pins i2s_transceiver_0/to_eth_ch1]
#  connect_bd_net -net i2s_transceiver_0_to_faust_ch0 [get_bd_pins i2s_transceiver_0/to_faust_ch0] [get_bd_pins syfala/audio_in_0]
#  connect_bd_net -net i2s_transceiver_0_to_faust_ch1 [get_bd_pins i2s_transceiver_0/to_faust_ch1] [get_bd_pins syfala/audio_in_1]
  connect_bd_net -net i2s_transceiver_0_ws [get_bd_ports external_codec_ws] [get_bd_ports internal_codec_ws_rx] [get_bd_ports internal_codec_ws_tx] [get_bd_pins i2s_transceiver_0/ws]
  connect_bd_net -net internal_codec_sd_rx_1 [get_bd_ports internal_codec_sd_rx] [get_bd_pins mux_2to1_0/inB]
  connect_bd_net -net mux_2to1_0_outMux [get_bd_pins i2s_transceiver_0/sd_ch0_ch1_rx] [get_bd_pins mux_2to1_0/outMux]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_global/ext_reset_in]
  connect_bd_net -net processing_system7_0_SPI0_MOSI_O [get_bd_ports spi_MOSI] [get_bd_pins processing_system7_0/SPI0_MOSI_O]
  connect_bd_net -net processing_system7_0_SPI0_SCLK_O [get_bd_ports spi_clk] [get_bd_pins processing_system7_0/SPI0_SCLK_O]
  connect_bd_net -net processing_system7_0_SPI0_SS_O [get_bd_ports spi_SS] [get_bd_pins processing_system7_0/SPI0_SS_O]
  connect_bd_net -net rst_global_peripheral_aresetn [get_bd_pins axi_gpio_LED/s_axi_aresetn] [get_bd_pins axi_gpio_SW/s_axi_aresetn] [get_bd_pins axi_mem_interconn/ARESETN] [get_bd_pins axi_mem_interconn/M00_ARESETN] [get_bd_pins axi_mem_interconn/S00_ARESETN] [get_bd_pins axi_mem_interconn/S01_ARESETN] [get_bd_pins axi_periph_interconn/ARESETN] [get_bd_pins axi_periph_interconn/M00_ARESETN] [get_bd_pins axi_periph_interconn/M01_ARESETN] [get_bd_pins axi_periph_interconn/M02_ARESETN] [get_bd_pins axi_periph_interconn/M03_ARESETN] [get_bd_pins axi_periph_interconn/S00_ARESETN] [get_bd_pins eth_audio_0/ap_rst_n] [get_bd_pins i2s_transceiver_0/reset_n] [get_bd_pins rst_global/peripheral_aresetn] [get_bd_pins syfala/ap_rst_n]
  connect_bd_net -net spi_MISO_1 [get_bd_ports spi_MISO] [get_bd_pins processing_system7_0/SPI0_MISO_I]
  connect_bd_net -net sw0_Dout [get_bd_pins sw0/Dout] [get_bd_pins syfala/mute]
  connect_bd_net -net sw1_Dout [get_bd_pins sw1/Dout] [get_bd_pins syfala/bypass]
  connect_bd_net -net sw2_Dout [get_bd_pins mux_2to1_0/Sel] [get_bd_pins sw2/Dout]
  connect_bd_net -net switches_1 [get_bd_ports switches] [get_bd_pins axi_gpio_SW/gpio_io_i] [get_bd_pins sw0/Din] [get_bd_pins sw1/Din] [get_bd_pins sw2/Din]
  connect_bd_net -net syfala_ap_done [get_bd_pins i2s_transceiver_0/ap_done] [get_bd_pins syfala/ap_done]
#  connect_bd_net -net syfala_audio_out_0 [get_bd_pins i2s_transceiver_0/from_faust_ch0] [get_bd_pins syfala/audio_out_0]
#  connect_bd_net -net syfala_audio_out_0_ap_vld [get_bd_pins i2s_transceiver_0/from_faust_ch0_ap_vld] [get_bd_pins syfala/audio_out_0_ap_vld]
#  connect_bd_net -net syfala_audio_out_1 [get_bd_pins i2s_transceiver_0/from_faust_ch1] [get_bd_pins syfala/audio_out_1]
#  connect_bd_net -net syfala_audio_out_1_ap_vld [get_bd_pins i2s_transceiver_0/from_faust_ch1_ap_vld] [get_bd_pins syfala/audio_out_1_ap_vld]
  connect_bd_net -net vdd33_dout [get_bd_ports internal_codec_out_mute] [get_bd_pins i2s_transceiver_0/start] [get_bd_pins processing_system7_0/SPI0_SS_I] [get_bd_pins vdd33/dout]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces eth_audio_0/Data_m_axi_ram] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_LED/S_AXI/Reg] -force
  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_SW/S_AXI/Reg] -force
  assign_bd_address -offset 0x40030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs eth_audio_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs syfala/s_axi_control/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces syfala/Data_m_axi_ram] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_gid_msg -ssname BD::TCL -id 2053 -severity "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

