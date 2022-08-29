source ../scripts/sylib.tcl
namespace import Xilinx::Boards::*
namespace import Syfala::*

variable PROJECT
variable BOARD_PART
variable BOARD_PROPERTY
variable BOARD_ID

# ARGUMENTS  --------------------------------------------------------------------------------------

set ARGUMENTS	    [lindex $argv 0]
set ZYBO_VERSION    [lindex $ARGUMENTS 0]
set PROJECT_NAME    "syfala_project"

namespace eval Syfala {
    set FIXED_FLOAT_TYPES_C  $Syfala::VHDL_DIR/fixed_float_types_c.vhd
    set FIXED_PKG_C          $Syfala::VHDL_DIR/fixed_pkg_c.vhd
    set FLOAT_PKG_C          $Syfala::VHDL_DIR/float_pkg_c.vhd
    set SINCOS_24            $Syfala::VHDL_DIR/SinCos24.vhd
    set I2S_TRANSCEIVER      $Syfala::VHDL_DIR/i2s_transceiver.vhd
    set MUX_2TO1             $Syfala::VHDL_DIR/mux_2to1.vhd
    set MASTER_XDC           $Syfala::XDC_DIR/master_zybo.xdc
}

set BOARD_PART      [Xilinx::get_board_part $ZYBO_VERSION]
set BOARD_PROPERTY  [Xilinx::get_board_part_full $ZYBO_VERSION]
set BOARD_ID        [Xilinx::get_board_id $ZYBO_VERSION]

set PROJECT_PATH "$PROJECT_NAME"

# PROJECT CREATION  -------------------------------------------------------------------------------

# Create project, store the reference in $PROJECT
create_project $PROJECT_NAME $PROJECT_PATH -part $BOARD_PART -force
set PROJECT [current_project]

set_property -objects $PROJECT -name "board_part" -value $BOARD_PROPERTY
set_property -objects $PROJECT -name "platform.board_id" -value $BOARD_ID
set_property -objects $PROJECT -name "default_lib" -value "xil_defaultlib"
set_property -objects $PROJECT -name "enable_vhdl_2008" -value "1"
set_property -objects $PROJECT -name "ip_cache_permissions" -value "read write"
set_property -objects $PROJECT -name "ip_output_repo" -value "$PROJECT_PATH/.cache/ip"
set_property -objects $PROJECT -name "mem.enable_memory_map_generation" -value "1"
set_property -objects $PROJECT -name "sim.central_dir" -value "$$PROJECT_PATH/.ip_user_files"
set_property -objects $PROJECT -name "sim.ip.auto_export_scripts" -value "1"
set_property -objects $PROJECT -name "simulator_language" -value "Mixed"
set_property -objects $PROJECT -name "target_language" -value "VHDL"
set_property -objects $PROJECT -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY"

# PROJECT SOURCES ---------------------------------------------------------------------------------

# Create 'sources_1' fileset (if doesn't exist)
if {[string equal [get_filesets -quiet sources_1] ""]} {
     create_fileset -srcset sources_1
}
set fset_sources_1 [get_filesets sources_1]

# Import VHDL files, setting their properties
set files [list                                         \
 [file normalize $::Syfala::I2S_TRANSCEIVER]            \
 [file normalize $::Syfala::MUX_2TO1]                   \
 [file normalize $::Syfala::FIXED_FLOAT_TYPES_C]        \
 [file normalize $::Syfala::FIXED_PKG_C]                \
 [file normalize $::Syfala::FLOAT_PKG_C]                \
 [file normalize $::Syfala::SINCOS_24]                  \
 [file normalize $::Faust::ARCH_FPGA_DST_FILE_VHDL]     \
]
set imported_files [import_files -fileset sources_1 $files]

set sources_1_files [get_files -of [get_filesets sources_1]]
set_property -objects $sources_1_files -name "file_type" -value "VHDL"

# Set 'sources_1' fileset properties
set_property -objects $fset_sources_1 -name "top" -value "main_wrapper"

# PROJECT CONSTRS ---------------------------------------------------------------------------------

# Create 'constrs_1' fileset (if doesn't exist)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}
# Set 'constrs_1' fileset object
set fset_constrs_1 [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set f_master_xdc [file normalize $Syfala::MASTER_XDC]
set imported_files [import_files -fileset constrs_1 [list $f_master_xdc]]
set constrs_1_files [get_files -of [get_filesets constrs_1]]
set_property -objects $constrs_1_files -name "file_type" -value "XDC"

# Set 'constrs_1' fileset properties
# set obj [get_filesets constrs_1]

# PROJECT SIM1  -----------------------------------------------------------------------------------

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
     create_fileset -simset sim_1
}

# Set 'sim_1' fileset object and its properties
set fset_sim_1 [get_filesets sim_1]
set_property -objects $fset_sim_1 -name "hbs.configure_design_for_hier_access" -value "1"
set_property -objects $fset_sim_1 -name "top" -value "main_wrapper"
set_property -objects $fset_sim_1 -name "top_lib" -value "xil_defaultlib"

# BLOCK DESIGN MAIN  ------------------------------------------------------------------------------

set design_name main

common::send_gid_msg    \
    -ssname BD::TCL     \
    -id 2010            \
    -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

create_bd_design $design_name

set check_errors 0
set list_ips_missing ""
set list_mods_missing ""

# Checking IPs  -----------------------------------------------------------------------------------

set list_check_ips "\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlslice:1.0\
"

proc print_gid { ident type str } {
    common::send_gid_msg -ssname BD::TCL -id $ident -severity $type $str
}

print_gid 2011 INFO \
"Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."


foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if {$ip_obj eq ""} {
     lappend list_ips_missing $ip_vlnv
  }
}
if {$list_ips_missing != ""} {
    catch {
        print_gid 2012 ERROR \
        "The following IPs are not found in the IP Catalog:
        $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project."
        incr check_errors
    }
}

# Check Modules  ----------------------------------------------------------------------------------

set list_check_mods { FAUST i2s_transceiver mux_2to1  }

print_gid 2020 INFO \
"Checking if the following modules exist in the project's sources: $list_check_mods ."

foreach mod_vlnv $list_check_mods {
  if { [can_resolve_reference $mod_vlnv] == 0 } {
     lappend list_mods_missing $mod_vlnv
  }
}

if {$list_mods_missing ne ""} {
    catch {
        print_gid 2021 ERROR \
        "The following module(s) are not found in the project: $list_mods_missing"
    }
    print_gid 2022 INFO \
    "Please add source files for the missing module(s) above."
    incr check_errors
}

if {$check_errors != 0} {
    print_gid 2023 WARNING \
    "Will not continue with creation of design due to the error(s) above."
    return 3
}

variable script_folder
set parentCell [get_bd_cells /]

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
set DDR         [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
set FIXED_IO    [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
set sys_clk     [ create_bd_port -dir I -type clk -freq_hz 125000000 sys_clk ]
set IIC_0       [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_0 ]
set leds_4bits  [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]
set rgb_led     [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 rgb_led ]
set switches    [ create_bd_port -dir I -from 3 -to 0 switches ]

# Create ports
set CODEC1_bclk             [ create_bd_port -dir O CODEC1_bclk ]
set CODEC1_mclk             [ create_bd_port -dir O CODEC1_mclk ]
set CODEC1_sd_rx            [ create_bd_port -dir I CODEC1_sd_rx ]
set CODEC1_sd_tx            [ create_bd_port -dir O CODEC1_sd_tx ]
set CODEC1_ws               [ create_bd_port -dir O CODEC1_ws ]
set CODEC1_bclk_GND         [ create_bd_port -dir O CODEC1_bclk_GND ]
set CODEC1_mclk_GND         [ create_bd_port -dir O CODEC1_mclk_GND ]
set CODEC1_ws_GND           [ create_bd_port -dir O CODEC1_ws_GND ]
set internal_codec_bclk     [ create_bd_port -dir O internal_codec_bclk ]
set internal_codec_mclk     [ create_bd_port -dir O internal_codec_mclk ]
set internal_codec_sd_rx    [ create_bd_port -dir I internal_codec_sd_rx ]
set internal_codec_sd_tx    [ create_bd_port -dir O internal_codec_sd_tx ]
set internal_codec_ws_tx    [ create_bd_port -dir O internal_codec_ws_tx ]
set internal_codec_ws_      [ create_bd_port -dir O internal_codec_ws_rx ]
set internal_codec_out_mute [ create_bd_port -dir O internal_codec_out_mute ]
set spi_MISO                [ create_bd_port -dir I spi_MISO ]
set spi_MOSI                [ create_bd_port -dir O spi_MOSI ]
set spi_SS                  [ create_bd_port -dir O spi_SS ]
set spi_clk                 [ create_bd_port -dir O spi_clk ]
set debug_btn               [ create_bd_port -dir I debug_btn ]


set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
set_property -dict [ list \
    CONFIG.CLKOUT1_JITTER {117.042} \
    CONFIG.CLKOUT1_PHASE_ERROR {94.860} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
    CONFIG.CLKOUT2_JITTER {186.486} \
    CONFIG.CLKOUT2_PHASE_ERROR {94.860} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {12.288} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_JITTER {162.929} \
    CONFIG.CLKOUT3_PHASE_ERROR {94.860} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {24.576} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
    CONFIG.CLK_OUT1_PORT {clk_sys} \
    CONFIG.CLK_OUT2_PORT {I2S_clk} \
    CONFIG.CLK_OUT3_PORT {mclk_24M} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {8.250} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.250} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {84} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {42} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {3} \
    CONFIG.USE_BOARD_FLOW {true} \
    CONFIG.USE_RESET {false} \
] $clk_wiz_0

# Create instance: cst1, and set properties
set cst1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 cst1 ]

set block_name i2s_transceiver
  set block_cell_name i2s_transceiver_0
  if { [catch {set i2s_transceiver_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
  catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
 return 1
 } elseif { $i2s_transceiver_0 eq "" } {
 catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
 return 1
 }

set block_name mux_2to1
  set block_cell_name mux_2to1_0
  if { [catch {set mux_2to1_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
  catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
 return 1
 } elseif { $mux_2to1_0 eq "" } {
 catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
 return 1
 }

# Create instance: FAUST_0, and set properties
set block_name FAUST
set block_cell_name FAUST_0
if { [catch {set FAUST_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
   return 1
 } elseif { $FAUST_0 eq "" } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
   return 1
 }

# Create instance: axi_gpio_LED, and set properties
set axi_gpio_LED [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_LED ]
set_property -dict [ list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {3} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.GPIO2_BOARD_INTERFACE {rgb_led} \
    CONFIG.GPIO_BOARD_INTERFACE {leds_4bits} \
    CONFIG.USE_BOARD_FLOW {true} \
] $axi_gpio_LED

# Create instance: axi_periph_interconn, and set properties
 set axi_periph_interconn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_periph_interconn ]
 set_property -dict [ list \
 CONFIG.NUM_MI {3} \
 ] $axi_periph_interconn

# Create instance: axi_mem_intercon, and set properties
set axi_mem_interconn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_interconn ]
set_property -dict [ list \
    CONFIG.NUM_MI {1} \
] $axi_mem_interconn


# Create instance: axi_gpio_SW, and set properties
set axi_gpio_SW [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_SW ]
set_property -dict [ list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {0} \
    CONFIG.GPIO_BOARD_INTERFACE {Custom} \
] $axi_gpio_SW

# Create instance: GND, and set properties
set GND [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 GND ]
set_property -dict [ list \
    CONFIG.CONST_VAL {0} \
] $GND

# Create instance: processing_system7_0, and set properties
set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
set_property -dict [ list \
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
CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_CLK0_FREQ {10000000} \
CONFIG.PCW_CLK1_FREQ {10000000} \
CONFIG.PCW_CLK2_FREQ {10000000} \
CONFIG.PCW_CLK3_FREQ {10000000} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_ENET0_ENET0_IO {<Select>} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {0} \
CONFIG.PCW_ENET0_GRP_MDIO_IO {<Select>} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET0_RESET_ENABLE {0} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET1_RESET_ENABLE {0} \
CONFIG.PCW_ENET_RESET_ENABLE {0} \
CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
CONFIG.PCW_ENET_RESET_SELECT {<Select>} \
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
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK_CLK0_BUF {FALSE} \
CONFIG.PCW_FPGA_FCLK0_ENABLE {0} \
CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {<Select>} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE {1} \
CONFIG.PCW_I2C0_GRP_INT_IO {EMIO} \
CONFIG.PCW_I2C0_I2C0_IO {EMIO} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_RESET_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_ENABLE {0} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_I2C_RESET_ENABLE {0} \
CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
CONFIG.PCW_MIO_0_DIRECTION {<Select>} \
CONFIG.PCW_MIO_0_IOTYPE {<Select>} \
CONFIG.PCW_MIO_0_PULLUP {<Select>} \
CONFIG.PCW_MIO_0_SLEW {<Select>} \
CONFIG.PCW_MIO_10_DIRECTION {<Select>} \
CONFIG.PCW_MIO_10_IOTYPE {<Select>} \
CONFIG.PCW_MIO_10_PULLUP {<Select>} \
CONFIG.PCW_MIO_10_SLEW {<Select>} \
CONFIG.PCW_MIO_11_DIRECTION {<Select>} \
CONFIG.PCW_MIO_11_IOTYPE {<Select>} \
CONFIG.PCW_MIO_11_PULLUP {<Select>} \
CONFIG.PCW_MIO_11_SLEW {<Select>} \
CONFIG.PCW_MIO_12_DIRECTION {<Select>} \
CONFIG.PCW_MIO_12_IOTYPE {<Select>} \
CONFIG.PCW_MIO_12_PULLUP {<Select>} \
CONFIG.PCW_MIO_12_SLEW {<Select>} \
CONFIG.PCW_MIO_13_DIRECTION {<Select>} \
CONFIG.PCW_MIO_13_IOTYPE {<Select>} \
CONFIG.PCW_MIO_13_PULLUP {<Select>} \
CONFIG.PCW_MIO_13_SLEW {<Select>} \
CONFIG.PCW_MIO_14_DIRECTION {<Select>} \
CONFIG.PCW_MIO_14_IOTYPE {<Select>} \
CONFIG.PCW_MIO_14_PULLUP {<Select>} \
CONFIG.PCW_MIO_14_SLEW {<Select>} \
CONFIG.PCW_MIO_15_DIRECTION {<Select>} \
CONFIG.PCW_MIO_15_IOTYPE {<Select>} \
CONFIG.PCW_MIO_15_PULLUP {<Select>} \
CONFIG.PCW_MIO_15_SLEW {<Select>} \
CONFIG.PCW_MIO_16_DIRECTION {<Select>} \
CONFIG.PCW_MIO_16_IOTYPE {<Select>} \
CONFIG.PCW_MIO_16_PULLUP {<Select>} \
CONFIG.PCW_MIO_16_SLEW {<Select>} \
CONFIG.PCW_MIO_17_DIRECTION {<Select>} \
CONFIG.PCW_MIO_17_IOTYPE {<Select>} \
CONFIG.PCW_MIO_17_PULLUP {<Select>} \
CONFIG.PCW_MIO_17_SLEW {<Select>} \
CONFIG.PCW_MIO_18_DIRECTION {<Select>} \
CONFIG.PCW_MIO_18_IOTYPE {<Select>} \
CONFIG.PCW_MIO_18_PULLUP {<Select>} \
CONFIG.PCW_MIO_18_SLEW {<Select>} \
CONFIG.PCW_MIO_19_DIRECTION {<Select>} \
CONFIG.PCW_MIO_19_IOTYPE {<Select>} \
CONFIG.PCW_MIO_19_PULLUP {<Select>} \
CONFIG.PCW_MIO_19_SLEW {<Select>} \
CONFIG.PCW_MIO_1_DIRECTION {out} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} \
CONFIG.PCW_MIO_20_DIRECTION {<Select>} \
CONFIG.PCW_MIO_20_IOTYPE {<Select>} \
CONFIG.PCW_MIO_20_PULLUP {<Select>} \
CONFIG.PCW_MIO_20_SLEW {<Select>} \
CONFIG.PCW_MIO_21_DIRECTION {<Select>} \
CONFIG.PCW_MIO_21_IOTYPE {<Select>} \
CONFIG.PCW_MIO_21_PULLUP {<Select>} \
CONFIG.PCW_MIO_21_SLEW {<Select>} \
CONFIG.PCW_MIO_22_DIRECTION {<Select>} \
CONFIG.PCW_MIO_22_IOTYPE {<Select>} \
CONFIG.PCW_MIO_22_PULLUP {<Select>} \
CONFIG.PCW_MIO_22_SLEW {<Select>} \
CONFIG.PCW_MIO_23_DIRECTION {<Select>} \
CONFIG.PCW_MIO_23_IOTYPE {<Select>} \
CONFIG.PCW_MIO_23_PULLUP {<Select>} \
CONFIG.PCW_MIO_23_SLEW {<Select>} \
CONFIG.PCW_MIO_24_DIRECTION {<Select>} \
CONFIG.PCW_MIO_24_IOTYPE {<Select>} \
CONFIG.PCW_MIO_24_PULLUP {<Select>} \
CONFIG.PCW_MIO_24_SLEW {<Select>} \
CONFIG.PCW_MIO_25_DIRECTION {<Select>} \
CONFIG.PCW_MIO_25_IOTYPE {<Select>} \
CONFIG.PCW_MIO_25_PULLUP {<Select>} \
CONFIG.PCW_MIO_25_SLEW {<Select>} \
CONFIG.PCW_MIO_26_DIRECTION {<Select>} \
CONFIG.PCW_MIO_26_IOTYPE {<Select>} \
CONFIG.PCW_MIO_26_PULLUP {<Select>} \
CONFIG.PCW_MIO_26_SLEW {<Select>} \
CONFIG.PCW_MIO_27_DIRECTION {<Select>} \
CONFIG.PCW_MIO_27_IOTYPE {<Select>} \
CONFIG.PCW_MIO_27_PULLUP {<Select>} \
CONFIG.PCW_MIO_27_SLEW {<Select>} \
CONFIG.PCW_MIO_28_DIRECTION {<Select>} \
CONFIG.PCW_MIO_28_IOTYPE {<Select>} \
CONFIG.PCW_MIO_28_PULLUP {<Select>} \
CONFIG.PCW_MIO_28_SLEW {<Select>} \
CONFIG.PCW_MIO_29_DIRECTION {<Select>} \
CONFIG.PCW_MIO_29_IOTYPE {<Select>} \
CONFIG.PCW_MIO_29_PULLUP {<Select>} \
CONFIG.PCW_MIO_29_SLEW {<Select>} \
CONFIG.PCW_MIO_2_DIRECTION {inout} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_2_PULLUP {disabled} \
CONFIG.PCW_MIO_2_SLEW {slow} \
CONFIG.PCW_MIO_30_DIRECTION {<Select>} \
CONFIG.PCW_MIO_30_IOTYPE {<Select>} \
CONFIG.PCW_MIO_30_PULLUP {<Select>} \
CONFIG.PCW_MIO_30_SLEW {<Select>} \
CONFIG.PCW_MIO_31_DIRECTION {<Select>} \
CONFIG.PCW_MIO_31_IOTYPE {<Select>} \
CONFIG.PCW_MIO_31_PULLUP {<Select>} \
CONFIG.PCW_MIO_31_SLEW {<Select>} \
CONFIG.PCW_MIO_32_DIRECTION {<Select>} \
CONFIG.PCW_MIO_32_IOTYPE {<Select>} \
CONFIG.PCW_MIO_32_PULLUP {<Select>} \
CONFIG.PCW_MIO_32_SLEW {<Select>} \
CONFIG.PCW_MIO_33_DIRECTION {<Select>} \
CONFIG.PCW_MIO_33_IOTYPE {<Select>} \
CONFIG.PCW_MIO_33_PULLUP {<Select>} \
CONFIG.PCW_MIO_33_SLEW {<Select>} \
CONFIG.PCW_MIO_34_DIRECTION {<Select>} \
CONFIG.PCW_MIO_34_IOTYPE {<Select>} \
CONFIG.PCW_MIO_34_PULLUP {<Select>} \
CONFIG.PCW_MIO_34_SLEW {<Select>} \
CONFIG.PCW_MIO_35_DIRECTION {<Select>} \
CONFIG.PCW_MIO_35_IOTYPE {<Select>} \
CONFIG.PCW_MIO_35_PULLUP {<Select>} \
CONFIG.PCW_MIO_35_SLEW {<Select>} \
CONFIG.PCW_MIO_36_DIRECTION {<Select>} \
CONFIG.PCW_MIO_36_IOTYPE {<Select>} \
CONFIG.PCW_MIO_36_PULLUP {<Select>} \
CONFIG.PCW_MIO_36_SLEW {<Select>} \
CONFIG.PCW_MIO_37_DIRECTION {<Select>} \
CONFIG.PCW_MIO_37_IOTYPE {<Select>} \
CONFIG.PCW_MIO_37_PULLUP {<Select>} \
CONFIG.PCW_MIO_37_SLEW {<Select>} \
CONFIG.PCW_MIO_38_DIRECTION {<Select>} \
CONFIG.PCW_MIO_38_IOTYPE {<Select>} \
CONFIG.PCW_MIO_38_PULLUP {<Select>} \
CONFIG.PCW_MIO_38_SLEW {<Select>} \
CONFIG.PCW_MIO_39_DIRECTION {<Select>} \
CONFIG.PCW_MIO_39_IOTYPE {<Select>} \
CONFIG.PCW_MIO_39_PULLUP {<Select>} \
CONFIG.PCW_MIO_39_SLEW {<Select>} \
CONFIG.PCW_MIO_3_DIRECTION {inout} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_3_PULLUP {disabled} \
CONFIG.PCW_MIO_3_SLEW {slow} \
CONFIG.PCW_MIO_40_DIRECTION {<Select>} \
CONFIG.PCW_MIO_40_IOTYPE {<Select>} \
CONFIG.PCW_MIO_40_PULLUP {<Select>} \
CONFIG.PCW_MIO_40_SLEW {<Select>} \
CONFIG.PCW_MIO_41_DIRECTION {<Select>} \
CONFIG.PCW_MIO_41_IOTYPE {<Select>} \
CONFIG.PCW_MIO_41_PULLUP {<Select>} \
CONFIG.PCW_MIO_41_SLEW {<Select>} \
CONFIG.PCW_MIO_42_DIRECTION {<Select>} \
CONFIG.PCW_MIO_42_IOTYPE {<Select>} \
CONFIG.PCW_MIO_42_PULLUP {<Select>} \
CONFIG.PCW_MIO_42_SLEW {<Select>} \
CONFIG.PCW_MIO_43_DIRECTION {<Select>} \
CONFIG.PCW_MIO_43_IOTYPE {<Select>} \
CONFIG.PCW_MIO_43_PULLUP {<Select>} \
CONFIG.PCW_MIO_43_SLEW {<Select>} \
CONFIG.PCW_MIO_44_DIRECTION {<Select>} \
CONFIG.PCW_MIO_44_IOTYPE {<Select>} \
CONFIG.PCW_MIO_44_PULLUP {<Select>} \
CONFIG.PCW_MIO_44_SLEW {<Select>} \
CONFIG.PCW_MIO_45_DIRECTION {<Select>} \
CONFIG.PCW_MIO_45_IOTYPE {<Select>} \
CONFIG.PCW_MIO_45_PULLUP {<Select>} \
CONFIG.PCW_MIO_45_SLEW {<Select>} \
CONFIG.PCW_MIO_46_DIRECTION {<Select>} \
CONFIG.PCW_MIO_46_IOTYPE {<Select>} \
CONFIG.PCW_MIO_46_PULLUP {<Select>} \
CONFIG.PCW_MIO_46_SLEW {<Select>} \
CONFIG.PCW_MIO_47_DIRECTION {<Select>} \
CONFIG.PCW_MIO_47_IOTYPE {<Select>} \
CONFIG.PCW_MIO_47_PULLUP {<Select>} \
CONFIG.PCW_MIO_47_SLEW {<Select>} \
CONFIG.PCW_MIO_48_DIRECTION {out} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_48_PULLUP {enabled} \
CONFIG.PCW_MIO_48_SLEW {slow} \
CONFIG.PCW_MIO_49_DIRECTION {in} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_49_PULLUP {enabled} \
CONFIG.PCW_MIO_49_SLEW {slow} \
CONFIG.PCW_MIO_4_DIRECTION {inout} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_4_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {slow} \
CONFIG.PCW_MIO_50_DIRECTION {<Select>} \
CONFIG.PCW_MIO_50_IOTYPE {<Select>} \
CONFIG.PCW_MIO_50_PULLUP {<Select>} \
CONFIG.PCW_MIO_50_SLEW {<Select>} \
CONFIG.PCW_MIO_51_DIRECTION {<Select>} \
CONFIG.PCW_MIO_51_IOTYPE {<Select>} \
CONFIG.PCW_MIO_51_PULLUP {<Select>} \
CONFIG.PCW_MIO_51_SLEW {<Select>} \
CONFIG.PCW_MIO_52_DIRECTION {<Select>} \
CONFIG.PCW_MIO_52_IOTYPE {<Select>} \
CONFIG.PCW_MIO_52_PULLUP {<Select>} \
CONFIG.PCW_MIO_52_SLEW {<Select>} \
CONFIG.PCW_MIO_53_DIRECTION {<Select>} \
CONFIG.PCW_MIO_53_IOTYPE {<Select>} \
CONFIG.PCW_MIO_53_PULLUP {<Select>} \
CONFIG.PCW_MIO_53_SLEW {<Select>} \
CONFIG.PCW_MIO_5_DIRECTION {inout} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_5_PULLUP {disabled} \
CONFIG.PCW_MIO_5_SLEW {slow} \
CONFIG.PCW_MIO_6_DIRECTION {out} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_6_PULLUP {disabled} \
CONFIG.PCW_MIO_6_SLEW {slow} \
CONFIG.PCW_MIO_7_DIRECTION {<Select>} \
CONFIG.PCW_MIO_7_IOTYPE {<Select>} \
CONFIG.PCW_MIO_7_PULLUP {<Select>} \
CONFIG.PCW_MIO_7_SLEW {<Select>} \
CONFIG.PCW_MIO_8_DIRECTION {out} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_8_PULLUP {disabled} \
CONFIG.PCW_MIO_8_SLEW {slow} \
CONFIG.PCW_MIO_9_DIRECTION {<Select>} \
CONFIG.PCW_MIO_9_IOTYPE {<Select>} \
CONFIG.PCW_MIO_9_PULLUP {<Select>} \
CONFIG.PCW_MIO_9_SLEW {<Select>} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {unassigned#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#unassigned#Quad SPI Flash#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#UART 1#UART 1#unassigned#unassigned#unassigned#unassigned} \
CONFIG.PCW_MIO_TREE_SIGNALS {unassigned#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#unassigned#qspi_fbclk#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#tx#rx#unassigned#unassigned#unassigned#unassigned} \
CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
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
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
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
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
CONFIG.PCW_SD0_GRP_CD_IO {<Select>} \
CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SD0_SD0_IO {<Select>} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID {0} \
CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS1_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS2_IO {EMIO} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {6} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART1_BAUD_RATE {115200} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
CONFIG.PCW_UIPARAM_DDR_AL {0} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
CONFIG.PCW_UIPARAM_DDR_BL {8} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.221} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.222} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.217} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.244} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
CONFIG.PCW_UIPARAM_DDR_CL {7} \
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
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
CONFIG.PCW_UIPARAM_DDR_CWL {6} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
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
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
CONFIG.PCW_UIPARAM_DDR_T_RC {48.75} \
CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB0_RESET_ENABLE {0} \
CONFIG.PCW_USB0_RESET_IO {<Select>} \
CONFIG.PCW_USB0_USB0_IO {<Select>} \
CONFIG.PCW_USB1_RESET_ENABLE {0} \
CONFIG.PCW_USB_RESET_ENABLE {0} \
CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
CONFIG.PCW_USB_RESET_SELECT {<Select>} \
CONFIG.PCW_USE_AXI_NONSECURE {0} \
CONFIG.PCW_USE_CROSS_TRIGGER {0} \
CONFIG.PCW_USE_M_AXI_GP0 {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
] $processing_system7_0

# Create instance: rst_global, and set properties
set rst_global [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_global ]

# Create instance: sw0, and set properties
set sw0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw0 ]
set_property -dict [ list     \
CONFIG.DIN_WIDTH {4}         \
] $sw0

# Create instance: sw1, and set properties
set sw1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw1 ]
set_property -dict [ list	\
    CONFIG.DIN_FROM {1}		\
    CONFIG.DIN_TO {1}		\
    CONFIG.DIN_WIDTH {4}        \
    CONFIG.DOUT_WIDTH {1}       \
] $sw1

# Create instance: sw2, and set properties
set sw2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw2 ]
set_property -dict [ list	\
    CONFIG.DIN_FROM {2}		\
    CONFIG.DIN_TO {2}		\
    CONFIG.DIN_WIDTH {4}        \
    CONFIG.DOUT_WIDTH {1}	\
] $sw2

connect_bd_net [get_bd_ports sys_clk] [get_bd_pins clk_wiz_0/clk_in1]
connect_bd_net [get_bd_pins clk_wiz_0/clk_sys] [get_bd_pins axi_periph_interconn/ACLK] [get_bd_pins axi_periph_interconn/S00_ACLK] [get_bd_pins axi_periph_interconn/M02_ACLK] [get_bd_pins axi_periph_interconn/M01_ACLK] [get_bd_pins axi_periph_interconn/M00_ACLK] [get_bd_pins FAUST_0/ap_clk] [get_bd_pins axi_gpio_SW/s_axi_aclk] [get_bd_pins axi_gpio_LED/s_axi_aclk] [get_bd_pins axi_mem_interconn/S00_ACLK] [get_bd_pins axi_mem_interconn/M00_ACLK] [get_bd_pins axi_mem_interconn/ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins i2s_transceiver_0/sys_clk]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst_global/dcm_locked]
connect_bd_net [get_bd_pins rst_global/slowest_sync_clk] [get_bd_pins clk_wiz_0/I2S_clk] [get_bd_pins i2s_transceiver_0/mclk]

connect_bd_net [get_bd_pins FAUST_0/out_left_V]         [get_bd_pins i2s_transceiver_0/left_data_tx]
connect_bd_net [get_bd_pins FAUST_0/out_left_V_ap_vld]  [get_bd_pins i2s_transceiver_0/out_left_V_ap_vld]
connect_bd_net [get_bd_pins FAUST_0/in_left_V]          [get_bd_pins i2s_transceiver_0/left_data_rx]
connect_bd_net [get_bd_pins FAUST_0/out_right_V]        [get_bd_pins i2s_transceiver_0/right_data_tx]
connect_bd_net [get_bd_pins FAUST_0/out_right_V_ap_vld] [get_bd_pins i2s_transceiver_0/out_right_V_ap_vld]
connect_bd_net [get_bd_pins FAUST_0/in_right_V]         [get_bd_pins i2s_transceiver_0/right_data_rx]
connect_bd_net [get_bd_pins FAUST_0/ap_done]            [get_bd_pins i2s_transceiver_0/ap_done]
connect_bd_net [get_bd_pins FAUST_0/ap_start]           [get_bd_pins i2s_transceiver_0/rdy]
connect_bd_net [get_bd_pins FAUST_0/ws]                 [get_bd_pins i2s_transceiver_0/ws]
connect_bd_net [get_bd_pins FAUST_0/bypass_dsp]         [get_bd_pins sw0/Dout]
connect_bd_net [get_bd_pins FAUST_0/bypass_faust]       [get_bd_pins sw1/Dout]
connect_bd_net [get_bd_pins FAUST_0/ap_rst_n]           [get_bd_pins rst_ps7_0_125M/peripheral_aresetn] [get_bd_pins i2s_transceiver_0/reset_n]

connect_bd_net [get_bd_ports CODEC1_mclk] [get_bd_pins clk_wiz_0/mclk_24M] [get_bd_ports internal_codec_mclk]
connect_bd_net [get_bd_ports CODEC1_bclk] [get_bd_pins i2s_transceiver_0/sclk] [get_bd_ports internal_codec_bclk]
connect_bd_net [get_bd_ports CODEC1_ws] [get_bd_pins i2s_transceiver_0/ws] [get_bd_ports internal_codec_ws_rx] [get_bd_ports internal_codec_ws_tx]
connect_bd_net [get_bd_ports CODEC1_bclk_GND] [get_bd_pins GND/dout] [get_bd_ports CODEC1_ws_GND] [get_bd_ports CODEC1_mclk_GND]
connect_bd_net [get_bd_ports CODEC1_sd_rx] [get_bd_pins mux_2to1_0/inA]
connect_bd_net [get_bd_ports CODEC1_sd_tx] [get_bd_pins i2s_transceiver_0/sd_right_left_tx] [get_bd_ports internal_codec_sd_tx]
connect_bd_net [get_bd_pins i2s_transceiver_0/sd_right_left_rx] [get_bd_pins mux_2to1_0/outMux]
connect_bd_net [get_bd_ports internal_codec_sd_rx] [get_bd_pins mux_2to1_0/inB]
connect_bd_net [get_bd_ports internal_codec_out_mute] [get_bd_pins cst1/dout] [get_bd_pins processing_system7_0/SPI0_SS_I] [get_bd_pins i2s_transceiver_0/start]
connect_bd_net [get_bd_pins mux_2to1_0/Sel] [get_bd_pins sw2/Dout]
connect_bd_net [get_bd_pins rst_global/peripheral_aresetn] [get_bd_pins axi_periph_interconn/S00_ARESETN] [get_bd_pins axi_periph_interconn/M02_ARESETN] [get_bd_pins axi_periph_interconn/M01_ARESETN] [get_bd_pins axi_periph_interconn/M00_ARESETN] [get_bd_pins axi_periph_interconn/ARESETN] [get_bd_pins axi_gpio_SW/s_axi_aresetn] [get_bd_pins axi_gpio_LED/s_axi_aresetn] [get_bd_pins axi_mem_interconn/S00_ARESETN] [get_bd_pins axi_mem_interconn/M00_ARESETN] [get_bd_pins axi_mem_interconn/ARESETN] [get_bd_pins i2s_transceiver_0/reset_n]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/S_AXI_HP0] [get_bd_intf_pins axi_mem_interconn/M00_AXI]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/DDR] [get_bd_intf_ports DDR]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/FIXED_IO] [get_bd_intf_ports FIXED_IO]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/IIC_0] [get_bd_intf_ports IIC_0]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins axi_periph_interconn/S00_AXI]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_global/ext_reset_in]
connect_bd_net [get_bd_pins processing_system7_0/SPI0_MOSI_O] [get_bd_ports spi_MOSI]
connect_bd_net [get_bd_pins processing_system7_0/SPI0_SCLK_O] [get_bd_ports spi_clk]
connect_bd_net [get_bd_pins processing_system7_0/SPI0_SS_O] [get_bd_ports spi_SS]
connect_bd_net [get_bd_pins processing_system7_0/SPI0_MISO_I] [get_bd_ports spi_MISO]
connect_bd_intf_net [get_bd_intf_ports rgb_led] [get_bd_intf_pins axi_gpio_LED/GPIO2]
connect_bd_intf_net [get_bd_intf_ports leds_4bits] [get_bd_intf_pins axi_gpio_LED/GPIO]
connect_bd_intf_net [get_bd_intf_pins axi_gpio_LED/S_AXI] [get_bd_intf_pins axi_periph_interconn/M00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_gpio_SW/S_AXI] [get_bd_intf_pins axi_periph_interconn/M02_AXI]
connect_bd_net [get_bd_ports switches] [get_bd_pins sw2/Din] [get_bd_pins sw1/Din] [get_bd_pins sw0/Din] [get_bd_pins axi_gpio_SW/gpio_io_i]

# Create address segments
assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_LED/S_AXI/Reg] -force
assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_SW/S_AXI/Reg] -force

# FOLLOW-UP -----------------------------------------------------------------------------------

set_property REGISTERED_WITH_MANAGER "1" [get_files main.bd ]
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files main.bd ]

#call make_wrapper to create wrapper files
if { [get_property IS_LOCKED [ get_files -norecurse main.bd] ] == 1  } {
  import_files -fileset sources_1 [file normalize "$Syfala::BUILD_DIR/syfala_project/syfala_project.gen/sources_1/bd/main/hdl/main_wrapper.vhd" ]
} else {
  set wrapper_path [make_wrapper -fileset sources_1 -files [ get_files -norecurse main.bd] -top]
  add_files -norecurse -fileset sources_1 $wrapper_path
}
# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
     create_run -name synth_1 -part $BOARD_PART			\
                -flow {Vivado Synthesis 2020}		\
                -strategy "Vivado Synthesis Defaults"	\
                -report_strategy {No Reports}			\
                -constrset constrs_1				\
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2020" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
     create_run -name impl_1 -part $BOARD_PART			\
                -flow {Vivado Implementation 2020}		\
                -strategy "Vivado Implementation Defaults"	\
                -report_strategy {No Reports}			\
                -constrset constrs_1				\
                -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2020" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj

set obj [get_runs impl_1]
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]
