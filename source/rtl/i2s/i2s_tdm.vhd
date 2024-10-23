-- i2s transceiver usable as an interface between the built-in SSM codec
-- of the Zybos and a set of i2s digital amps using TDM multiplexing.
-- In the current configuration, the system takes 2 audio inputs
-- and has 32 audio outputs. Samples are coded on 16 bits and SR is 48825.

library ieee;
use ieee.std_logic_1164.all;

entity i2s_transceiver is
generic (
    tdm_mclk_sclk_ratio : integer := 2; -- clock ratio for TDM amps
    [HEADER]
);
port (
-------------------------------------------------------------------------------
    sys_clk   : in  std_logic;  -- sys_clk (FPGA) 125 MHz
    mclk      : in  std_logic;  -- mclk== 4*d_width*fs (12.5  MHZ for F48.825kHz and 16 bits)
    reset_n   : in  std_logic;  -- asynchronous active low reset
    start     : in std_logic;
-------------------------------------------------------------------------------
    tdm_sclk   : out std_logic;  -- TDM bit clock
    tdm_ws     : out std_logic;  -- TDM word select
    tdm_tx_#T1 : out std_logic;  -- TDM tx (SCRIPTED)
-------------------------------------------------------------------------------
    ssm_sclk   : out std_logic;  -- SSM bit clock
    ssm_ws     : out std_logic;  -- SSM word select
    ssm_sd_#L_#R_rx  : in std_logic;   -- SSM rx pin
-------------------------------------------------------------------------------
    to_faust_#L : out std_logic_vector(d_width-1 downto 0);   -- left audio in
    to_faust_#R : out std_logic_vector(d_width-1 downto 0);   -- right audio in
-------------------------------------------------------------------------------
    from_faust_#L : in std_logic_vector(d_width-1 downto 0); -- left channel data to transmit bit by bit
    from_faust_#R : in std_logic_vector(d_width-1 downto 0); -- right channel data to transmit bit by bit
    from_faust_#L_ap_vld : in std_logic; -- left data from Faust ready
    from_faust_#R_ap_vld : in std_logic; -- right data from Faust ready
-------------------------------------------------------------------------------
    rdy : out  std_logic -- handshake for Faust IP
);
end i2s_transceiver;

architecture logic of i2s_transceiver is
    signal ssm_sclk_int         : std_logic := '0'; -- internal SSM serial clock
    signal ssm_ws_int           : std_logic := '0'; -- internal SSM word select
    signal rdy1                 : std_logic := '0'; -- shall trigger ap_start
    signal rdy1_reg             : std_logic := '0'; -- used to detect rising edge of rdy1
-------------------------------------------------------------------------------
    signal tdm_sclk_int  : std_logic := '0'; -- internal TDM serial clock
    signal tdm_ws_int    : std_logic := '0'; -- internat TDM word select
    signal tdm_sd_tx_buffer_#T1: std_logic_vector(127 downto 0);
    signal tdm_sd_tx_buffer_int_#T1: std_logic_vector(127 downto 0);
-------------------------------------------------------------------------------
    signal to_faust_#L_int      : std_logic_vector(d_width-1 downto 0); -- internal left channel tx data buffer
    signal to_faust_#R_int      : std_logic_vector(d_width-1 downto 0); -- internal right channel tx data buffer
-------------------------------------------------------------------------------
    signal from_faust_#L_int     : std_logic_vector(d_width-1 downto 0); --internal left channel tx data buffer
    signal from_faust_#R_int     : std_logic_vector(d_width-1 downto 0); --internal right channel tx data buffer
    signal from_faust_#L_ap_vld_reg : std_logic;  -- data from Faust ready latched
    signal from_faust_#R_ap_vld_reg : std_logic;  -- data from Faust ready latched
    signal from_faust_#L_latched : std_logic_vector(d_width-1 downto 0); -- latching faust left
    signal from_faust_#R_latched : std_logic_vector(d_width-1 downto 0); -- latching faust right
-------------------------------------------------------------------------------
begin
    -- audio samples latching process: retrieves audio samples from Faust
    process(sys_clk, reset_n)
    begin
        if (reset_n = '0') then -- Asynchronous reset
            from_faust_#L_latched <= (others => '0');
            from_faust_#R_latched <= (others => '0');
            from_faust_#L_ap_vld_reg <= '0';
            from_faust_#R_ap_vld_reg <= '0';
            rdy1_reg <= '0';
            rdy <= '0';
        elsif (sys_clk' event and sys_clk = '1')  then
            -- system clock rising:
            -- latch input from faust(at any sys_clk cycle)
            from_faust_#L_ap_vld_reg <= from_faust_#L_ap_vld;
            from_faust_#R_ap_vld_reg <= from_faust_#R_ap_vld;

            if (from_faust_#L_ap_vld = '1') and (from_faust_#L_ap_vld_reg /= from_faust_#L_ap_vld) then
                from_faust_#L_latched <= from_faust_#L;
            end if;
            if (from_faust_#R_ap_vld = '1') and (from_faust_#R_ap_vld_reg /= from_faust_#R_ap_vld) then
                from_faust_#R_latched <= from_faust_#R;
            end if;
            -- rdy detect rising edge of rdy1 (clocked on sys_clk)
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
    -- codecs transmission process
    process(mclk, reset_n)
        variable tdm_sclk_cnt : integer := 0;  -- TDM counter of master clocks during half period of serial clock
        variable ssm_sclk_cnt : integer := 0;  -- SSM counter of master clocks during half period of serial clock
        variable tdm_cnt : integer := 127; -- TDM cycles counter TODO potential culrpit
        variable ssm_cnt : integer := 0; -- SSM cycles counter
    begin
        if (reset_n = '0') then    -- asynchronous reset
            tdm_sclk_cnt  := 0;    -- clear mclk/sclk counter
            ssm_sclk_cnt  := 0;    -- clear mclk/sclk counter
            tdm_cnt       := 127;
            tdm_tx_#T1    <= '0';     -- clear serial data transmit output
            rdy1 <= '0';

        elsif (mclk'event and mclk = '1') and start = '1' then
            -- Fetching audio intputs (SSM)
            if (ssm_sclk_cnt < mclk_sclk_ratio/2-1) then  --less than half period of sclk
                ssm_sclk_cnt := ssm_sclk_cnt + 1;       --increment mclk/sclk counter
            else                              --half period of sclk. Sur changement de front de sclk (bclk)
                ssm_sclk_cnt := 0;                  --reset mclk/sclk counter
                ssm_sclk_int <= not ssm_sclk_int;       --toggle serial clock

                if (ssm_sclk_int = '1') then --edge of sclk
                    if (ssm_cnt > 0 and ssm_cnt < d_width)  then
                        to_faust_#L_int <= to_faust_#L_int(d_width-2 downto 0) & ssm_sd_#L_#R_rx;
                    else
                        to_faust_#R_int <= to_faust_#R_int(d_width-2 downto 0) & ssm_sd_#L_#R_rx;
                    end if;
                    -- generating word select for SSM
                    if (ssm_cnt = d_width-1) then
                        ssm_ws_int <= '1';
                    elsif (ssm_cnt = d_width*2-1) then
                        ssm_ws_int <= '0';
                    end if;

                    if (ssm_cnt = 2) then
                        to_faust_#L <= to_faust_#L_int;
                        to_faust_#R <= to_faust_#R_int;
                        rdy1 <= '1'; -- rdy happens upon a new buffer
                    else
                        rdy1 <= '0';
                    end if;

                    if (ssm_cnt < d_width*2-1) then
                        ssm_cnt := ssm_cnt + 1;
                    else
                        ssm_cnt := 0;
                    end if;
                end if;
            end if;

            -- Generating audio outputs
            if (tdm_sclk_cnt < tdm_mclk_sclk_ratio/2-1) then  --less than half period of sclk
                tdm_sclk_cnt := tdm_sclk_cnt + 1;       --increment mclk/sclk counter
            else                              --half period of sclk. Sur changement de front de sclk (bclk)
                tdm_sclk_cnt := 0;                  --reset mclk/sclk counter
                tdm_sclk_int <= not tdm_sclk_int;       --toggle serial clock

                if (tdm_sclk_int = '1') then --edge of sclk
                    -- generating word select for TDM
                    if(tdm_cnt = 0) then
                        tdm_ws_int <= '1';
                    else
                        tdm_ws_int <= '0';
                    end if;
                    tdm_tx_#T1 <= tdm_sd_tx_buffer_int_#T1(tdm_cnt);
                    -- When buffer filling is completed, sendind data
                    if (tdm_cnt = 0) then
                        tdm_sd_tx_buffer_int_#T1 <= tdm_sd_tx_buffer_#T1;
                    end if;
                    if (tdm_cnt > 0) then
                        tdm_cnt := tdm_cnt - 1;
                    else
                        tdm_cnt := 127;
                    end if;
                end if;
            end if;
        end if;
    end process;

    tdm_sclk <= tdm_sclk_int;  -- output serial clock
    tdm_ws <= tdm_ws_int;      -- output word select
    ssm_sclk <= ssm_sclk_int;
    ssm_ws <= ssm_ws_int;

end logic;
