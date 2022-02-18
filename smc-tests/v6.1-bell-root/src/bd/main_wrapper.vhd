--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Wed Oct 13 13:04:46 2021
--Host        : maxime-Latitude-7410 running 64-bit Ubuntu 20.04.2 LTS
--Command     : generate_target main_wrapper.bd
--Design      : main_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity main_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    PMOD_bclk : out STD_LOGIC;
    PMOD_bclk_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_mclk : out STD_LOGIC;
    PMOD_mclk_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_sd_rx : in STD_LOGIC;
    PMOD_sd_rx_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_sd_tx : out STD_LOGIC;
    PMOD_sd_tx_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_ws : out STD_LOGIC;
    PMOD_ws_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    SSM_bclk : out STD_LOGIC;
    SSM_mclk : out STD_LOGIC;
    SSM_out_mute : out STD_LOGIC;
    SSM_sd_rx : in STD_LOGIC;
    SSM_sd_tx : out STD_LOGIC;
    SSM_ws_rx : out STD_LOGIC;
    SSM_ws_tx : out STD_LOGIC;
    ack_error : out STD_LOGIC;
    bypass_analog : in STD_LOGIC;
    codecSelect : in STD_LOGIC;
    debugSwitch : in STD_LOGIC;
    resetN : in STD_LOGIC;
    reset_clk : in STD_LOGIC;
    rgb_led_tri_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    sclk : inout STD_LOGIC;
    sclpmod : out STD_LOGIC;
    sdapmod : out STD_LOGIC;
    sdin : inout STD_LOGIC;
    spi_MISO : in STD_LOGIC;
    spi_MOSI : out STD_LOGIC;
    spi_SS : out STD_LOGIC;
    spi_clk : out STD_LOGIC;
    sys_clk : in STD_LOGIC;
    testGPIO1 : out STD_LOGIC;
    testGPIO2 : out STD_LOGIC;
    vol_down : in STD_LOGIC;
    vol_up : in STD_LOGIC
  );
end main_wrapper;

architecture STRUCTURE of main_wrapper is
  component main is
  port (
    PMOD_bclk : out STD_LOGIC;
    PMOD_bclk_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_mclk : out STD_LOGIC;
    PMOD_mclk_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_sd_rx : in STD_LOGIC;
    PMOD_sd_rx_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_sd_tx : out STD_LOGIC;
    PMOD_sd_tx_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    PMOD_ws : out STD_LOGIC;
    PMOD_ws_GND : out STD_LOGIC_VECTOR ( 0 to 0 );
    SSM_bclk : out STD_LOGIC;
    SSM_mclk : out STD_LOGIC;
    SSM_out_mute : out STD_LOGIC;
    SSM_sd_rx : in STD_LOGIC;
    SSM_sd_tx : out STD_LOGIC;
    SSM_ws_rx : out STD_LOGIC;
    SSM_ws_tx : out STD_LOGIC;
    ack_error : out STD_LOGIC;
    bypass_analog : in STD_LOGIC;
    codecSelect : in STD_LOGIC;
    debugSwitch : in STD_LOGIC;
    reset_clk : in STD_LOGIC;
    sclk : inout STD_LOGIC;
    sclpmod : out STD_LOGIC;
    sdapmod : out STD_LOGIC;
    sdin : inout STD_LOGIC;
    spi_MISO : in STD_LOGIC;
    spi_MOSI : out STD_LOGIC;
    spi_SS : out STD_LOGIC;
    spi_clk : out STD_LOGIC;
    sys_clk : in STD_LOGIC;
    testGPIO1 : out STD_LOGIC;
    testGPIO2 : out STD_LOGIC;
    vol_down : in STD_LOGIC;
    vol_up : in STD_LOGIC;
    rgb_led_tri_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    resetN : in STD_LOGIC
  );
  end component main;
begin
main_i: component main
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      PMOD_bclk => PMOD_bclk,
      PMOD_bclk_GND(0) => PMOD_bclk_GND(0),
      PMOD_mclk => PMOD_mclk,
      PMOD_mclk_GND(0) => PMOD_mclk_GND(0),
      PMOD_sd_rx => PMOD_sd_rx,
      PMOD_sd_rx_GND(0) => PMOD_sd_rx_GND(0),
      PMOD_sd_tx => PMOD_sd_tx,
      PMOD_sd_tx_GND(0) => PMOD_sd_tx_GND(0),
      PMOD_ws => PMOD_ws,
      PMOD_ws_GND(0) => PMOD_ws_GND(0),
      SSM_bclk => SSM_bclk,
      SSM_mclk => SSM_mclk,
      SSM_out_mute => SSM_out_mute,
      SSM_sd_rx => SSM_sd_rx,
      SSM_sd_tx => SSM_sd_tx,
      SSM_ws_rx => SSM_ws_rx,
      SSM_ws_tx => SSM_ws_tx,
      ack_error => ack_error,
      bypass_analog => bypass_analog,
      codecSelect => codecSelect,
      debugSwitch => debugSwitch,
      resetN => resetN,
      reset_clk => reset_clk,
      rgb_led_tri_o(2 downto 0) => rgb_led_tri_o(2 downto 0),
      sclk => sclk,
      sclpmod => sclpmod,
      sdapmod => sdapmod,
      sdin => sdin,
      spi_MISO => spi_MISO,
      spi_MOSI => spi_MOSI,
      spi_SS => spi_SS,
      spi_clk => spi_clk,
      sys_clk => sys_clk,
      testGPIO1 => testGPIO1,
      testGPIO2 => testGPIO2,
      vol_down => vol_down,
      vol_up => vol_up
    );
end STRUCTURE;

