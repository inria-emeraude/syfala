--------------------------------------------------------------------------------
--
--   FileName:         i2s_transceiver.vhd
--   Dependencies:     none
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 03/29/2019 Scott Larson
--     Initial Public Release
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------
--- Version 2.0 01/02/2022: Adeyemi Gbadamosi, Tanguy Risset, Maxime Popoff
--  Inspired  from DigiKey eewiki,
--  https://www.digikey.com/eewiki/pages/viewpage.action?pageId=10125324
--  added hand shake to buffer input/output sample (ap_hs vivado protocol)
--  added d_width generic for various d_width
--  added a patch for 768kHz (TODO YET HERE°
-------------------------------------------------------------------------


------------How to calculate/change clocks:
--
--    mclk_sclk_ratio = number of mclk periods per sclk period (is always 4)
--    sclk_ws_ratio = number of sclk periods per word select period
--        (depends on bitdepth)
--    d_width  = (real) sample bit depht: 16, 24 or 32
--
--    for d_width = 16, sclk_ws_ratio is 32
--    but for d_width = 24 AND 32, sclk_ws_ratio is 64
--
--     we use  "round_d_width" which is 32 when d_width is 24 or 32
--     sys_clk = system clock= 120MHz, do not really matter
--     mclk = sclk*mclk_sclk_ratio
--     mclk_sclk_ratio=4   SHOULD NOT BE CHANGED
--
--     sclk is the bit clock (should be call bclk or bitclock)
--     we want sclk = Fs*round_d_width*2
--     hence we set mclk = Fs*round_d_width*2*mclk_sclk_ratio
--     so mclk changes with Fs AND d_width
--     and sclk_ws_ratio changes with  d_width:
--     sclk_ws_ratio = round_d_width*2
--
--     As a summary:
--      sys_clock should be approximately 120Mhz
--      if you change Fs, you have to change mclk
--      If you change d_width, you have to change mclk and sclk_ws_ratio
--------------------


library ieee;
use ieee.std_logic_1164.all;

entity i2s_transceiver is
generic (
    tdm_mclk_sclk_ratio : integer := 2;
    [HEADER]
);
 -------------------------------------------------------------------------------
 -- END OF AUTO GENERATED
port (
    sys_clk : in std_logic;   -- sys_clk (FPGA) 120 MHz
    mclk    : in std_logic;   -- mclk== 4*d_width*fs (12.288  MHZ for F48kHz and 24 bits)
    start   : in std_logic;  -- unused: always 1
    rdy     : out  std_logic; -- rdy triggers Faust IP 'ap_start'
-------------------------------------------------------------------------------
    from_eth_#L: in std_logic_vector(d_width-1 downto 0);
    from_eth_#R: in std_logic_vector(d_width-1 downto 0);
    from_eth_#L_ap_vld: in std_logic;
    from_eth_#R_ap_vld: in std_logic;
-------------------------------------------------------------------------------
    from_faust_#L : in std_logic_vector(d_width-1 downto 0); -- left channel data to transmit bit by bit
    from_faust_#R : in std_logic_vector(d_width-1 downto 0); -- right channel data to transmit bit by bit
    from_faust_#L_ap_vld : in std_logic; -- left data from Faust ready
    from_faust_#R_ap_vld : in std_logic; -- right data from Faust ready*
-------------------------------------------------------------------------------
    to_faust_#L : out std_logic_vector(d_width-1 downto 0); -- left channel data received bit by bit
    to_faust_#R : out std_logic_vector(d_width-1 downto 0); -- left channel data received bit by bit
    to_eth_#L : out std_logic_vector(d_width-1 downto 0); -- left channel data received bit by bit
    to_eth_#R : out std_logic_vector(d_width-1 downto 0); -- left channel data received bit by bit
-------------------------------------------------------------------------------
    tdm_sclk   :  out std_logic; -- TDM bit clock
    tdm_ws     :  out std_logic; -- TDM word select
    tdm_tx_#T1 :  out std_logic; -- TDM tx (SCRIPTED)
-------------------------------------------------------------------------------
    ssm_sclk:   out std_logic;     -- SSM bit clock
    ssm_ws:     out std_logic;     -- SSM word select
    ssm_sd_#L_#R_rx : in std_logic;   -- SSM rx pin (SCRIPTED)
    ssm_sd_#L_#R_tx : out std_logic;  -- SSM tx pin (SCRIPTED)
-------------------------------------------------------------------------------
    reset_n : in std_logic -- asynchronous active low reset
);
    --NEVER finish the port declaration with a channel-dependant var. (to avoid issues with the last ");"
    -- when the line is duplicated with the script)
end i2s_transceiver;

architecture logic of i2s_transceiver is
-------------------------------------------------------------------------------
    signal ssm_sclk_int  : std_logic := '0'; --internal serial clock signal
    signal ssm_ws_int    : std_logic := '0'; --internal word select signal
    signal ssm_ws_int_tx : std_logic := '0'; -- word select shifted by 1 sclk cycle
    signal ssm_ws_int_rx : std_logic := '0'; -- doc todo
-------------------------------------------------------------------------------
    signal tdm_sclk_int  : std_logic := '0';
    signal tdm_ws_int    : std_logic := '0';
    signal tdm_sd_tx_buffer_#T1: std_logic_vector(127 downto 0);
    signal tdm_sd_tx_buffer_int_#T1: std_logic_vector(127 downto 0);
-------------------------------------------------------------------------------
    signal from_faust_#L_ap_vld_reg : std_logic;  -- data from Faust ready latched
    signal from_faust_#R_ap_vld_reg : std_logic;  -- data from Faust ready latched
  -------------------------------------------------------------------------------
    signal from_eth_#L_ap_vld_reg: std_logic;
    signal from_eth_#R_ap_vld_reg: std_logic;
    signal from_eth_#L_latched : std_logic_vector(d_width-1 downto 0); -- latching faust left
    signal from_eth_#R_latched : std_logic_vector(d_width-1 downto 0); -- latching faust right
  -------------------------------------------------------------------------------
    signal to_faust_#L_int : std_logic_vector(d_width-1 downto 0); --internal left channel rx data buffer
    signal to_faust_#R_int : std_logic_vector(d_width-1 downto 0); --internal right channel rx data buffer
  -------------------------------------------------------------------------------
    signal from_faust_#L_int     : std_logic_vector(d_width-1 downto 0); --internal left channel tx data buffer
    signal from_faust_#R_int     : std_logic_vector(d_width-1 downto 0); --internal right channel tx data buffer
  -------------------------------------------------------------------------------
    signal from_faust_#L_latched : std_logic_vector(d_width-1 downto 0); -- latching faust left
    signal from_faust_#R_latched : std_logic_vector(d_width-1 downto 0); -- latching faust right
  -------------------------------------------------------------------------------
    signal rdy1       : std_logic:= '0';    -- shall trigger ap_start
    signal rdy1_reg   : std_logic:= '0';    -- used to detect rising edge of rdy1
begin
  -- process clock on sys_clok: detecting Faust output arrival
  -- and start of next Faust computation
  -- set ch#_data_tx_latched signals
  -- also set the rdy (ap_start) signal
-------------------------------------------------------------------------------
process(sys_clk, reset_n)
-------------------------------------------------------------------------------
begin
    ---------------------------------------------------------------------------
    if (reset_n = '0') then
    ---------------------------------------------------------------------------
        -- Asynchronous reset (sys_clk)
        from_faust_#L_latched <= (others => '0');
        from_faust_#R_latched <= (others => '0');
        from_faust_#L_ap_vld_reg  <= '0';
        from_faust_#R_ap_vld_reg  <= '0';
        from_eth_#L_latched <= (others => '0');
        from_eth_#R_latched <= (others => '0');
        from_eth_#L_ap_vld_reg  <= '0';
        from_eth_#R_ap_vld_reg  <= '0';
        to_faust_#L <= (others => '0');
        to_faust_#R <= (others => '0');
        to_eth_#L <= (others => '0');
        to_eth_#R <= (others => '0');
        rdy1_reg <= '0';
        rdy      <= '0';
    ---------------------------------------------------------------------------
    elsif (sys_clk'event and sys_clk = '1') then
    ---------------------------------------------------------------------------
      -- latch left input from faust (at any sys_clk cycle)
        from_faust_#L_ap_vld_reg <= from_faust_#L_ap_vld;
        from_faust_#R_ap_vld_reg <= from_faust_#R_ap_vld;
        from_eth_#L_ap_vld_reg <= from_eth_#L_ap_vld;
        from_eth_#R_ap_vld_reg <= from_eth_#R_ap_vld;
        if (from_eth_#L_ap_vld = '1') and (from_eth_#L_ap_vld_reg /= from_eth_#L_ap_vld) then
            to_faust_#L <= from_eth_#L;
        end if;
        if (from_eth_#R_ap_vld = '1') and (from_eth_#R_ap_vld_reg /= from_eth_#R_ap_vld) then
            to_faust_#R <= from_eth_#R;
        end if;
        if (from_faust_#L_ap_vld = '1') and (from_faust_#L_ap_vld_reg /= from_faust_#L_ap_vld) then
            from_faust_#L_latched <= from_faust_#L;
            to_eth_#L <= from_faust_#L;
        end if;
        if (from_faust_#R_ap_vld = '1') and (from_faust_#R_ap_vld_reg /= from_faust_#R_ap_vld) then
            from_faust_#R_latched <= from_faust_#R;
            to_eth_#R <= from_faust_#R;
        end if;
        -- rdy (i.e. ap_start) detect rising edge of rdy1 (clocked on sys_clk)
        rdy1_reg <= rdy1;
        if (rdy1 = '1') and (rdy1_reg /= rdy1) then
            rdy <= '1';
        else
            rdy <= '0';
        end if;
    end if;
end process;
-------------------------------------------------------------------------------
    -- bit by bit concatenation, done by preprocessor script (see scripts/preprocessor.tcl)
    tdm_sd_tx_buffer_#T2
-------------------------------------------------------------------------------
process(mclk, reset_n)
-------------------------------------------------------------------------------
    variable ssm_sclk_cnt   : integer := 0;     -- SSM counter of master clocks during half period of serial clock
    variable ssm_cnt        : integer := 0;     -- SSM cycles counter
    variable ssm_ws_cnt     : integer := 0;     -- SSM word select counter
    -- used for patch: read sd_right_left_rx one mclk sample later
    variable read_sd_#L_#R_rx_at_next_mclk_sample: integer := 0;
    variable reset_bit_cnt_next_sclk_cycle: integer :=0;
    ---------------------------------------------------------------------------
    variable tdm_sclk_cnt   : integer := 0;     -- TDM counter of master clocks during half period of serial clock
    variable tdm_cnt        : integer := 127;   -- TDM cycles counter
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
    if (reset_n = '0') then
-------------------------------------------------------------------------------
        ssm_sclk_cnt        := 0;
        ssm_cnt             := 0;
        ssm_ws_cnt          := 0;
        ---------------------------
        tdm_sclk_cnt        := 0;
        tdm_cnt             := 0;
        ---------------------------
        rdy1                <= '0';
        ---------------------------
        ssm_sd_#L_#R_tx     <= '0';
        ---------------------------
        to_faust_#L_int   <= (others => '0');
        to_faust_#R_int   <= (others => '0');
        ---------------------------
        from_faust_#L_int <= (others => '0');
        from_faust_#R_int <= (others => '0');
        ---------------------------
        reset_bit_cnt_next_sclk_cycle         := 0;
        read_sd_#L_#R_rx_at_next_mclk_sample  := 0;
-------------------------------------------------------------------------------
    elsif (mclk'event and mclk = '1') and start = '1' then
-------------------------------------------------------------------------------
        -- mclk rising edge (SSM)
        if (ssm_sclk_cnt < mclk_sclk_ratio/2-1) then
            ssm_sclk_cnt := ssm_sclk_cnt + 1;
            if (read_sd_#L_#R_rx_at_next_mclk_sample = 1) then
                if (ssm_ws_int_rx = '0') then
                    to_faust_#L_int <= to_faust_#L_int(d_width-2 downto 0) & ssm_sd_#L_#R_rx;
                else
                    to_faust_#R_int <= to_faust_#R_int(d_width-2 downto 0) & ssm_sd_#L_#R_rx;
                end if;
                read_sd_#L_#R_rx_at_next_mclk_sample := 0;
            end if;
        else
-------------------------------------------------------------------------------
-- SCLK
-------------------------------------------------------------------------------
            -- sclk edge (rising or falling)
            ssm_sclk_cnt := 0;                  --reset sclk_cnt counter
            ssm_sclk_int <= not ssm_sclk_int;   --toggle serial clock at next round
            -- updating bit counter
            if (ssm_sclk_int = '1') then
            -- sclk falling edge
                ssm_cnt := ssm_cnt + 1;
                if (reset_bit_cnt_next_sclk_cycle = 1) then
                    ssm_cnt := 0;
                    reset_bit_cnt_next_sclk_cycle := 0;
                end if;
                ssm_ws_int_rx <= ssm_ws_int;
                if (ssm_cnt < d_width) then
                    if (ssm_ws_int_tx = '0') then
                        --left channel
                        ssm_sd_#L_#R_tx <= from_faust_#L_int(d_width-1);
                        -- transmit one left channel bit
                        -- shift data of left channel tx data buffer
                        from_faust_#L_int <= from_faust_#L_int(d_width-2 downto 0) & '0';
                    else
                        ssm_sd_#L_#R_tx <= from_faust_#R_int(d_width-1);
                        -- transmit one right channel bit
                        -- shift data of right channel tx data buffer
                        from_faust_#R_int <= from_faust_#R_int(d_width-2 downto 0) & '0';
                    end if;
                end if;
            elsif (ssm_sclk_int = '0') then
                ssm_ws_int_tx <= ssm_ws_int;
                if (ssm_cnt < d_width) then
                    read_sd_#L_#R_rx_at_next_mclk_sample := 1;
                end if;
            end if;
-------------------------------------------------------------------------------
-- WORD SELECT
-------------------------------------------------------------------------------
            if (ssm_ws_cnt < sclk_ws_ratio-1) then
                ssm_ws_cnt := ssm_ws_cnt + 1;
            else
          -- changing channel (left or right)
                if (ssm_sclk_int = '1') then
                    -- sclk falling edge
                    -- reset counters
                    ssm_ws_cnt := 0;
                    reset_bit_cnt_next_sclk_cycle := 1;
                    -- latches input samples
                    -- and produced output samples
                    if (ssm_ws_int = '0') then
                        -- ws_int rising edge: left channel
                        from_faust_#L_int <= from_faust_#L_latched;
                    else
                        -- falling edge of ws_int: right channel
                        from_faust_#R_int <= from_faust_#R_latched;
                    end if;
                    ssm_ws_int <= not ssm_ws_int;  --toggle word select
                end if; -- en sdlk falling edge
            end if; -- end changing channel
            -- if (ssm_ws_cnt = 3) and (ssm_ws_int = '1') then
            -- -- sending ap_start to faust when ws_cnt = 3 (arbitrary choice)
            --     rdy1 <= '1';
            -- else
            --     rdy1 <= '0';
            -- end if;
        end if;  -- bit clock
 -------------------------------------------------------------------------------
-- TDM
-------------------------------------------------------------------------------
        if (tdm_sclk_cnt < tdm_mclk_sclk_ratio/2-1) then
            tdm_sclk_cnt := tdm_sclk_cnt + 1;
        else
            tdm_sclk_cnt := 0;
            tdm_sclk_int <= not tdm_sclk_int;
            if (tdm_sclk_int = '1') then
                -- Generate word select for TDM
                if (tdm_cnt = 0) then
                    tdm_ws_int <= '1';
                else
                    tdm_ws_int <= '0';
                end if;
                tdm_tx_#T1 <= tdm_sd_tx_buffer_int_#T1(tdm_cnt);
                -- When buffer filling is completed, sending data:
                if (tdm_cnt = 0) then
                    tdm_sd_tx_buffer_int_#T1 <= tdm_sd_tx_buffer_#T1;
                end if;
                if (tdm_cnt > 0) then
                    tdm_cnt := tdm_cnt - 1;
                    rdy1 <= '0';
                else
                    tdm_cnt := 127;
                    rdy1 <= '1';
                end if;
            end if;
        end if;
    end if; -- mclk event
end process;
-----------------------------------------------------------------------
ssm_sclk    <= ssm_sclk_int; --output serial clock
ssm_ws      <= ssm_ws_int;   --output word select
-----------------------------------------------------------------------
tdm_sclk    <= tdm_sclk_int;
tdm_ws      <= tdm_ws_int;
-----------------------------------------------------------------------
end logic;
