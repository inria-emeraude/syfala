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
use ieee.numeric_std.all;

entity i2s_transceiver is
generic (
    [HEADER]
);
 --------------------------------------------------------------------------
 -- END OF AUTO GENERATED
port (
    sys_clk : in std_logic;   -- sys_clk (FPGA) 120 MHz
    mclk    : in std_logic;   -- mclk== 4*d_width*fs (12.288  MHZ for F48kHz and 24 bits)
    start   : in std_logic;   -- unused: always 1
    ap_done  : in std_logic;   -- faust computation finished (unused now)
    sclk    : out std_logic;  -- serial clock (or bit clock): Fs*d_width (3.072 Mhz for 48kHz and 24 bits)
    ws      : out std_logic;  -- word select (or left-right clock)
    faust_#L_rd : out std_logic; -- FIFO read enable (left channel)
    faust_#R_rd : out std_logic; -- FIFO read enable (right channel)
    faust_compute  : out std_logic; -- rdy block triggers Faust IP 'ap_start'
    sd_#L_#R_rx : in  std_logic; -- serial data receive
    sd_#L_#R_tx : out std_logic; -- serial data transmit
    from_faust_#L : in std_logic_vector(d_width-1 downto 0); -- left channel data to transmit bit by bit
    from_faust_#R : in std_logic_vector(d_width-1 downto 0); -- right channel data to transmit bit by bit
    from_faust_#L_vld : in std_logic; -- left data from Faust FIFO ready
    from_faust_#R_vld : in std_logic; -- right data from Faust FIFO ready
    to_faust_#L : out std_logic_vector(d_width-1 downto 0); -- left channel data received bit by bit
    to_faust_#L_wr : out std_logic;
    to_faust_#L_full : in std_logic;
    to_faust_#R : out std_logic_vector(d_width-1 downto 0); -- right channel data received bit by bit
    to_faust_#R_wr : out std_logic;
    to_faust_#R_full : in std_logic;
    sample_idx  : out std_logic_vector(31 downto 0);
    reset_n : in std_logic -- asynchronous active low reset
);
    -- Note: NEVER finish the port declaration with a channel-dependent one
    -- this to avoid issues with the last ");" when the line is duplicated with the script)
end i2s_transceiver;

architecture logic of i2s_transceiver is
  signal sclk_int  : std_logic := '0'; --internal serial clock signal
  signal ws_int    : std_logic := '0'; --internal word select signal
  signal ws_int_tx : std_logic := '0'; -- word select shifted by 1 sclk cycle
  signal ws_int_rx : std_logic := '0'; -- doc todo
  signal from_faust_#L_vld_reg : std_logic;  -- left channel data from Faust ready latched
  signal from_faust_#R_vld_reg : std_logic;  -- right channel data from Faust ready latched
  signal to_faust_#L_int : std_logic_vector(d_width-1 downto 0); --internal left channel rx data buffer
  signal to_faust_#R_int : std_logic_vector(d_width-1 downto 0); --internal right channel rx data buffer
  signal from_faust_#L_int     : std_logic_vector(d_width-1 downto 0); --internal left channel tx data buffer
  signal from_faust_#R_int     : std_logic_vector(d_width-1 downto 0); --internal right channel tx data buffer
  signal from_faust_#L_latched : std_logic_vector(d_width-1 downto 0); -- latching faust left
  signal from_faust_#R_latched : std_logic_vector(d_width-1 downto 0); -- latching faust right
  signal faust_rdy       : std_logic := '0';	-- shall trigger ap_start
  signal faust_rdy_reg   : std_logic := '0';	-- used to detect rising edge of rdy1
begin
  -- process clock on sys_clok: detecting Faust output arrival
  -- and start of next Faust computation
  -- set ch#_data_tx_latched signals
  -- also set the rdy (ap_start) signal
process(sys_clk, reset_n)
    variable sample_cnt : integer := 0;
begin
    if (reset_n = '0') then
        -- Asynchronous reset
        from_faust_#L_latched <= (others => '0');
        from_faust_#R_latched <= (others => '0');
        from_faust_#L_vld_reg  <= '0';
        from_faust_#R_vld_reg  <= '0';
        faust_rdy_reg  <= '0';
        faust_compute  <= '0';
        faust_#L_rd    <= '0';
        faust_#R_rd    <= '0';
    elsif (sys_clk'event and sys_clk = '1') then
        -- if there are available samples to read from the FIFOs
        -- send the 'rd_en' signals
        -- latch the audio data
        if (ap_done = '1') then
            -- if faust is done, lower the ap_start signal immediately,
            -- we don't want faust to start re-computing a block of samples just yet
            faust_compute <= '0';
        end if;
        -- if the mclk process is ready to receive new samples from faust
        if (faust_rdy = '1') and (faust_rdy /= faust_rdy_reg) then
            -- if FIFO is not empty, send rd_en and latch faust #L & #R outputs.
            -- increment sample count
            -- if we reach the end of one sample block:
            -- send signal ('ap_start') to the Faust IP to re-start computing
            -- a full block of samples
            faust_#L_rd <= '1';
            faust_#R_rd <= '1';
            to_faust_#L_wr <= '1';
            to_faust_#R_wr <= '1';
            from_faust_#L_latched <= from_faust_#L;
            from_faust_#R_latched <= from_faust_#R;
            to_faust_#L <= to_faust_#L_int;
            to_faust_#R <= to_faust_#R_int;
            if (sample_cnt = nsamples-1) then
                sample_cnt := 0;
                faust_compute <= '1';
            else
                sample_cnt := sample_cnt + 1;
            end if;
        else
            faust_#L_rd <= '0';
            faust_#R_rd <= '0';
            to_faust_#L_wr <= '0';
            to_faust_#R_wr <= '0';
        end if;
        -- update registers
        faust_rdy_reg <= faust_rdy;
        from_faust_#L_vld_reg <= from_faust_#L_vld;
        from_faust_#R_vld_reg <= from_faust_#R_vld;
        sample_idx <= std_logic_vector(to_unsigned(sample_cnt, sample_idx'length)); -- debug sample count
    end if;
end process;
  -- process clock on mclk
  -- 1) building clock: sclk, ws from mclk
  -- 2) setting all other signal
  -- 3) implement a patch to delay sd_right_left_rx read
  -- See Syfala documentation for precise explanation
process(mclk, reset_n)
    -- sclk_cnt: used for clock divider frequencies
    -- mclk/sclk=mclk_sclk_ratio (4) takes only 2 values (0 and 1)
    variable sclk_cnt : integer := 0;
    -- ws_cnt: count each sclk event in half a
    -- ws period: 0 to sclk_ws_ratio (63) that 0-63 when ws=0 and 0-63 when ws=1
    variable ws_cnt   : integer := 0;
    -- counts the bit to be transmitted
    variable bit_cnt  : integer := 0;
    -- used for patch: read sd_right_left_rx one mclk sample later
    variable read_sd_#L_#R_rx_at_next_mclk_sample: integer := 0;
    variable reset_bit_cnt_next_sclk_cycle: integer :=0;

begin
    if (reset_n = '0') then
        -- asynchronous reset --------------------
        sclk_cnt      := 0;
        ws_cnt        := 0;
        bit_cnt       := 0;
        faust_rdy     <= '0';
        sd_#L_#R_tx   <= '0';
        to_faust_#L_int   <= (others => '0');
        to_faust_#R_int   <= (others => '0');
        from_faust_#L_int <= (others => '0');
        from_faust_#R_int <= (others => '0');
        reset_bit_cnt_next_sclk_cycle         := 0;
        read_sd_#L_#R_rx_at_next_mclk_sample  := 0;

    elsif (mclk'event and mclk = '1') and start = '1' then
        -- if no sclk tick, increment
        if (sclk_cnt < mclk_sclk_ratio/2-1) then
            sclk_cnt := sclk_cnt + 1;
            if (read_sd_#L_#R_rx_at_next_mclk_sample = 1) then
                if (ws_int_rx = '0') then
                    to_faust_#L_int <= to_faust_#L_int(d_width-2 downto 0) & sd_#L_#R_rx;
                else
                    to_faust_#R_int <= to_faust_#R_int(d_width-2 downto 0) & sd_#L_#R_rx;
                end if;
                read_sd_#L_#R_rx_at_next_mclk_sample := 0;
            end if;
        else
            -- otherwise, process sclk tick
            sclk_cnt := 0;
            sclk_int <= not sclk_int;
            if (sclk_int = '1') then
                bit_cnt := bit_cnt + 1;
                if (reset_bit_cnt_next_sclk_cycle = 1) then
                    bit_cnt := 0;
                    reset_bit_cnt_next_sclk_cycle := 0;
                end if;
            end if;
            -- from sclk tick, process word select tick
            if (ws_cnt < sclk_ws_ratio-1) then
                -- no tick
                ws_cnt := ws_cnt + 1;
            else -- ws tick
                if (sclk_int = '1') then
                    -- reset counters
                    -- toggle word select
                    ws_cnt := 0;
                    reset_bit_cnt_next_sclk_cycle := 1;
                    ws_int <= not ws_int;
                    -- latches input samples
                    -- and produced output samples
                    if (ws_int = '0') then
                        from_faust_#L_int <= from_faust_#L_latched;
                    else
                    -- falling edge of ws_int: right channel
                        from_faust_#R_int <= from_faust_#R_latched;
                    end if;
                end if;
            end if;
            if (sclk_int = '1') then
                -- sending d_width bits, shifted by 1 sclk cycle with respect to ws
                -- hence bit_cnt counts from 0 to d_width-1
                ws_int_rx <= ws_int;
                if (bit_cnt < d_width) then
                    if (ws_int_tx = '0') then --left channel
                        sd_#L_#R_tx <= from_faust_#L_int(d_width-1);  -- transmit one left channel  bit
                        -- shift data of left channel tx data buffer
                        from_faust_#L_int <= from_faust_#L_int(d_width-2 downto 0) & '0';
                    else
                        sd_#L_#R_tx <= from_faust_#R_int(d_width-1);  --transmit one right channel bit
                        --  shift data of right channel tx data buffer
                        from_faust_#R_int <= from_faust_#R_int(d_width-2 downto 0) & '0';
                    end if;
                end if;
            else -- sckl_int = 0
                ws_int_tx <= ws_int;
                if (bit_cnt < d_width) then --READ ONE BIT
                    read_sd_#L_#R_rx_at_next_mclk_sample := 1;
                end if;
            end if;
            -- sending ap_start to faust when ws_cnt = 3 (arbitrary choice)
            if (ws_cnt = 3) and (ws_int = '1') then
                faust_rdy <= '1';
            else
                faust_rdy <= '0';
            end if;
        end if;  -- mclk rising edge
    end if; -- mclk event
end process;

sclk <= sclk_int; --output serial clock
ws   <= ws_int;   --output word select

end logic;
