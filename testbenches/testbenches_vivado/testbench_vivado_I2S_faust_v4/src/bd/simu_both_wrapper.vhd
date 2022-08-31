--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Mon May  4 11:35:21 2020
--Host        : bata running 64-bit Ubuntu 18.04.3 LTS
--Command     : generate_target simu_both_wrapper.bd
--Design      : simu_both_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity simu_both_wrapper is
  port (
    bclk : out STD_LOGIC;
    bclkpmod : out STD_LOGIC;
    bypass_dsp : in STD_LOGIC;
    bypass_faust : in STD_LOGIC;
    mclk : out STD_LOGIC;
    mclkpmod : out STD_LOGIC;
    reset_btn : in STD_LOGIC;
    sd_rx : in STD_LOGIC;
    sd_rxpmod : out STD_LOGIC;
    sd_tx : out STD_LOGIC;
    sd_txpmod : out STD_LOGIC;
    sys_clk : in STD_LOGIC;
    ws_rx : out STD_LOGIC;
    ws_tx : out STD_LOGIC;
    wspmod : out STD_LOGIC
  );
end simu_both_wrapper;

architecture STRUCTURE of simu_both_wrapper is
  component simu_both is
  port (
    bypass_dsp : in STD_LOGIC;
    bypass_faust : in STD_LOGIC;
    sys_clk : in STD_LOGIC;
    reset_btn : in STD_LOGIC;
    bclkpmod : out STD_LOGIC;
    bclk : out STD_LOGIC;
    ws_tx : out STD_LOGIC;
    ws_rx : out STD_LOGIC;
    sd_tx : out STD_LOGIC;
    sd_txpmod : out STD_LOGIC;
    sd_rx : in STD_LOGIC;
    sd_rxpmod : out STD_LOGIC;
    mclk : out STD_LOGIC;
    mclkpmod : out STD_LOGIC;
    wspmod : out STD_LOGIC
  );
  end component simu_both;
begin
simu_both_i: component simu_both
     port map (
      bclk => bclk,
      bclkpmod => bclkpmod,
      bypass_dsp => bypass_dsp,
      bypass_faust => bypass_faust,
      mclk => mclk,
      mclkpmod => mclkpmod,
      reset_btn => reset_btn,
      sd_rx => sd_rx,
      sd_rxpmod => sd_rxpmod,
      sd_tx => sd_tx,
      sd_txpmod => sd_txpmod,
      sys_clk => sys_clk,
      ws_rx => ws_rx,
      ws_tx => ws_tx,
      wspmod => wspmod
    );
end STRUCTURE;
