-- i2s transceiver usable as an interface between the built-in SSM codec
-- of the Zybos and a set of i2s digital amps using TDM multiplexing.
-- In the current configuration, the system takes 2 audio inputs
-- and has 32 audio outputs. Samples are coded on 16 bits and SR is 48825.

library ieee;
use ieee.std_logic_1164.all;

entity i2s_transceiver_tdm is
    generic(
        tdm_mclk_sclk_ratio : integer := 2; -- clock ratio for TDM amps
        ssm_mclk_sclk_ratio : integer := 8; -- clock ratio for SSM codec
        d_width         : integer := 16); 
    port(
        sys_clk   : in  std_logic;          -- sys_clk (FPGA) 125 MHz
        mclk      : in  std_logic;          -- mclk== 4*d_width*fs (12.5  MHZ for F48.825kHz and 16 bits)
        reset_n   : in  std_logic;          -- asynchronous active low reset
        start     : in std_logic;
        tdm_sclk      : out std_logic;          -- TDM bit clock
        tdm_ws        : out std_logic;          -- TDM word select
        ssm_sclk      : out std_logic;          -- SSM bit clock
        ssm_ws        : out std_logic;          -- SSM word select
        sd_rx       : in std_logic;             -- SSM rx pin
        sd_tx_0     : out std_logic;            -- TDM tx
        sd_tx_1     : out std_logic;
        sd_tx_2     : out std_logic;
        sd_tx_3     : out std_logic;
        l_data_rx : out std_logic_vector(d_width-1 downto 0);   -- left audio in
        r_data_rx : out std_logic_vector(d_width-1 downto 0);   -- right audio in
        rdy       : out  std_logic;           -- handshake for Faust IP
        V_ap_vld_0  : in  std_logic;          -- new Faust sample ready
        V_ap_vld_1  : in  std_logic;
        V_ap_vld_2  : in  std_logic;
        V_ap_vld_3  : in  std_logic;
        V_ap_vld_4  : in  std_logic;
        V_ap_vld_5  : in  std_logic;
        V_ap_vld_6  : in  std_logic;
        V_ap_vld_7  : in  std_logic;
        V_ap_vld_8  : in  std_logic;
        V_ap_vld_9  : in  std_logic;
        V_ap_vld_10  : in  std_logic;
        V_ap_vld_11  : in  std_logic;
        V_ap_vld_12  : in  std_logic;
        V_ap_vld_13  : in  std_logic;
        V_ap_vld_14  : in  std_logic;
        V_ap_vld_15  : in  std_logic;
        V_ap_vld_16  : in  std_logic;  
        V_ap_vld_17  : in  std_logic;
        V_ap_vld_18  : in  std_logic;
        V_ap_vld_19  : in  std_logic;
        V_ap_vld_20  : in  std_logic;
        V_ap_vld_21  : in  std_logic;
        V_ap_vld_22  : in  std_logic;
        V_ap_vld_23  : in  std_logic;
        V_ap_vld_24  : in  std_logic;
        V_ap_vld_25  : in  std_logic;
        V_ap_vld_26  : in  std_logic;
        V_ap_vld_27  : in  std_logic;
        V_ap_vld_28  : in  std_logic;
        V_ap_vld_29  : in  std_logic;
        V_ap_vld_30  : in  std_logic;
        V_ap_vld_31  : in  std_logic;
        data_tx_0 : in  std_logic_vector(d_width-1 downto 0);   -- Faust samples to be transmitted
        data_tx_1 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_2 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_3 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_4 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_5 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_6 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_7 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_8 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_9 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_10 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_11 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_12 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_13 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_14 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_15 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_16 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_17 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_18 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_19 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_20 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_21 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_22 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_23 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_24 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_25 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_26 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_27 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_28 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_29 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_30 : in  std_logic_vector(d_width-1 downto 0);
        data_tx_31 : in  std_logic_vector(d_width-1 downto 0));
end i2s_transceiver_tdm;

architecture logic of i2s_transceiver_tdm is
    signal tdm_sclk_int         : std_logic := '0'; -- internal TDM serial clock
    signal ssm_sclk_int         : std_logic := '0'; -- internal SSM serial clock
    signal tdm_ws_int           : std_logic := '0'; -- internat TDM word select
    signal ssm_ws_int           : std_logic := '0'; -- internal SSM word select
    signal rdy1                 : std_logic := '0'; -- shall trigger ap_start
    signal rdy1_reg             : std_logic := '0'; -- used to detect rising edge of rdy1
    signal sd_tx_buffer_0       : std_logic_vector(127 downto 0); -- fomatted internal buffers to be latched before transmission
    signal sd_tx_buffer_1       : std_logic_vector(127 downto 0);
    signal sd_tx_buffer_2       : std_logic_vector(127 downto 0);
    signal sd_tx_buffer_3       : std_logic_vector(127 downto 0);
    signal sd_tx_buffer_int_0   : std_logic_vector(127 downto 0); -- latched internal buffers to be transmitted to TDM
    signal sd_tx_buffer_int_1   : std_logic_vector(127 downto 0);
    signal sd_tx_buffer_int_2   : std_logic_vector(127 downto 0);
    signal sd_tx_buffer_int_3   : std_logic_vector(127 downto 0);
    signal l_data_rx_int        : std_logic_vector(d_width-1 downto 0); -- internal left channel tx data buffer
    signal r_data_rx_int        : std_logic_vector(d_width-1 downto 0); -- internal right channel tx data buffer
    signal V_ap_vld_reg_0       : std_logic; -- vld signal for latching Faust samples
    signal V_ap_vld_reg_1       : std_logic;
    signal V_ap_vld_reg_2       : std_logic;
    signal V_ap_vld_reg_3       : std_logic;
    signal V_ap_vld_reg_4       : std_logic;
    signal V_ap_vld_reg_5       : std_logic;
    signal V_ap_vld_reg_6       : std_logic;
    signal V_ap_vld_reg_7       : std_logic;
    signal V_ap_vld_reg_8       : std_logic;
    signal V_ap_vld_reg_9       : std_logic;
    signal V_ap_vld_reg_10      : std_logic;
    signal V_ap_vld_reg_11      : std_logic;
    signal V_ap_vld_reg_12      : std_logic;
    signal V_ap_vld_reg_13      : std_logic;
    signal V_ap_vld_reg_14      : std_logic;
    signal V_ap_vld_reg_15      : std_logic;
    signal V_ap_vld_reg_16      : std_logic;
    signal V_ap_vld_reg_17      : std_logic;
    signal V_ap_vld_reg_18      : std_logic;
    signal V_ap_vld_reg_19      : std_logic;
    signal V_ap_vld_reg_20      : std_logic;
    signal V_ap_vld_reg_21      : std_logic;
    signal V_ap_vld_reg_22      : std_logic;
    signal V_ap_vld_reg_23      : std_logic;
    signal V_ap_vld_reg_24      : std_logic;
    signal V_ap_vld_reg_25      : std_logic;
    signal V_ap_vld_reg_26      : std_logic;
    signal V_ap_vld_reg_27      : std_logic;
    signal V_ap_vld_reg_28      : std_logic;
    signal V_ap_vld_reg_29      : std_logic;
    signal V_ap_vld_reg_30      : std_logic;
    signal V_ap_vld_reg_31      : std_logic;
    signal data_tx_latched_0 : std_logic_vector(d_width-1 downto 0); -- Faust samples
    signal data_tx_latched_1 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_2 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_3 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_4 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_5 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_6 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_7 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_8 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_9 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_10 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_11 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_12 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_13 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_14 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_15 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_16 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_17 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_18 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_19 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_20 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_21 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_22 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_23 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_24 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_25 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_26 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_27 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_28 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_29 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_30 : std_logic_vector(d_width-1 downto 0);
    signal data_tx_latched_31 : std_logic_vector(d_width-1 downto 0);

begin
    -- audio samples latching process: retrieves audio samples from Faust
    process(sys_clk, reset_n)
    begin
        if(reset_n = '0') then              --asynchronous reset
            data_tx_latched_0 <= (others => '0');
            data_tx_latched_1 <= (others => '0');
            data_tx_latched_2 <= (others => '0');
            data_tx_latched_3 <= (others => '0');
            data_tx_latched_4 <= (others => '0');
            data_tx_latched_5 <= (others => '0');
            data_tx_latched_6 <= (others => '0');
            data_tx_latched_7 <= (others => '0');
            data_tx_latched_8 <= (others => '0');
            data_tx_latched_9 <= (others => '0');
            data_tx_latched_10 <= (others => '0');
            data_tx_latched_11 <= (others => '0');
            data_tx_latched_12 <= (others => '0');
            data_tx_latched_13 <= (others => '0');
            data_tx_latched_14 <= (others => '0');
            data_tx_latched_15 <= (others => '0');
            data_tx_latched_16 <= (others => '0');
            data_tx_latched_17 <= (others => '0');
            data_tx_latched_18 <= (others => '0');
            data_tx_latched_19 <= (others => '0');
            data_tx_latched_20 <= (others => '0');
            data_tx_latched_21 <= (others => '0');
            data_tx_latched_22 <= (others => '0');
            data_tx_latched_23 <= (others => '0');
            data_tx_latched_24 <= (others => '0');
            data_tx_latched_25 <= (others => '0');
            data_tx_latched_26 <= (others => '0');
            data_tx_latched_27 <= (others => '0');
            data_tx_latched_28 <= (others => '0');
            data_tx_latched_29 <= (others => '0');
            data_tx_latched_30 <= (others => '0');
            data_tx_latched_31 <= (others => '0');
            V_ap_vld_reg_0 <= '0';
            V_ap_vld_reg_1 <= '0';
            V_ap_vld_reg_2 <= '0';
            V_ap_vld_reg_3 <= '0';
            V_ap_vld_reg_4 <= '0';
            V_ap_vld_reg_5 <= '0';
            V_ap_vld_reg_6 <= '0';
            V_ap_vld_reg_7 <= '0';
            V_ap_vld_reg_8 <= '0';
            V_ap_vld_reg_9 <= '0';
            V_ap_vld_reg_10 <= '0';
            V_ap_vld_reg_11 <= '0';
            V_ap_vld_reg_12 <= '0';
            V_ap_vld_reg_13 <= '0';
            V_ap_vld_reg_14 <= '0';
            V_ap_vld_reg_15 <= '0';
            V_ap_vld_reg_16 <= '0';
            V_ap_vld_reg_17 <= '0';
            V_ap_vld_reg_18 <= '0';
            V_ap_vld_reg_19 <= '0';
            V_ap_vld_reg_20 <= '0';
            V_ap_vld_reg_21 <= '0';
            V_ap_vld_reg_22 <= '0';
            V_ap_vld_reg_23 <= '0';
            V_ap_vld_reg_24 <= '0';
            V_ap_vld_reg_25 <= '0';
            V_ap_vld_reg_26 <= '0';
            V_ap_vld_reg_27 <= '0';
            V_ap_vld_reg_28 <= '0';
            V_ap_vld_reg_29 <= '0';
            V_ap_vld_reg_30 <= '0';
            V_ap_vld_reg_31 <= '0';
            rdy1_reg <= '0';
            rdy <= '0';
        elsif(sys_clk' event and sys_clk = '1')  then	--system clock rising
            -- latch input from faust(at any sys_clk cycle) 
            V_ap_vld_reg_0 <= V_ap_vld_0;
            if (V_ap_vld_0 = '1') and (V_ap_vld_reg_0 /= V_ap_vld_0) then
                data_tx_latched_0 <= data_tx_0;
            end if;
            V_ap_vld_reg_1 <= V_ap_vld_1;
            if (V_ap_vld_1 = '1') and (V_ap_vld_reg_1 /= V_ap_vld_1) then
                data_tx_latched_1 <= data_tx_1;
            end if;
            V_ap_vld_reg_2 <= V_ap_vld_2;
            if (V_ap_vld_2 = '1') and (V_ap_vld_reg_2 /= V_ap_vld_2) then
                data_tx_latched_2 <= data_tx_2;
            end if;
            V_ap_vld_reg_3 <= V_ap_vld_3;
            if (V_ap_vld_3 = '1') and (V_ap_vld_reg_3 /= V_ap_vld_3) then
                data_tx_latched_3 <= data_tx_3;
            end if;
            V_ap_vld_reg_4 <= V_ap_vld_4;
            if (V_ap_vld_4 = '1') and (V_ap_vld_reg_4 /= V_ap_vld_4) then
                data_tx_latched_4 <= data_tx_4;
            end if;
            V_ap_vld_reg_5 <= V_ap_vld_5;
            if (V_ap_vld_5 = '1') and (V_ap_vld_reg_5 /= V_ap_vld_5) then
                data_tx_latched_5 <= data_tx_5;
            end if;
            V_ap_vld_reg_6 <= V_ap_vld_6;
            if (V_ap_vld_6 = '1') and (V_ap_vld_reg_6 /= V_ap_vld_6) then
                data_tx_latched_6 <= data_tx_6;
            end if;
            V_ap_vld_reg_7 <= V_ap_vld_7;
            if (V_ap_vld_7 = '1') and (V_ap_vld_reg_7 /= V_ap_vld_7) then
                data_tx_latched_7 <= data_tx_7;
            end if;
            V_ap_vld_reg_8 <= V_ap_vld_8;
            if (V_ap_vld_8 = '1') and (V_ap_vld_reg_8 /= V_ap_vld_8) then
                data_tx_latched_8 <= data_tx_8;
            end if;
            V_ap_vld_reg_9 <= V_ap_vld_9;
            if (V_ap_vld_9 = '1') and (V_ap_vld_reg_9 /= V_ap_vld_9) then
                data_tx_latched_9 <= data_tx_9;
            end if;
            V_ap_vld_reg_10 <= V_ap_vld_10;
            if (V_ap_vld_10 = '1') and (V_ap_vld_reg_10 /= V_ap_vld_10) then
                data_tx_latched_10 <= data_tx_10;
            end if;
            V_ap_vld_reg_11 <= V_ap_vld_11;
            if (V_ap_vld_11 = '1') and (V_ap_vld_reg_11 /= V_ap_vld_11) then
                data_tx_latched_11 <= data_tx_11;
            end if;
            V_ap_vld_reg_12 <= V_ap_vld_12;
            if (V_ap_vld_12 = '1') and (V_ap_vld_reg_12 /= V_ap_vld_12) then
                data_tx_latched_12 <= data_tx_12;
            end if;
            V_ap_vld_reg_13 <= V_ap_vld_13;
            if (V_ap_vld_13 = '1') and (V_ap_vld_reg_13 /= V_ap_vld_13) then
                data_tx_latched_13 <= data_tx_13;
            end if;
            V_ap_vld_reg_14 <= V_ap_vld_14;
            if (V_ap_vld_14 = '1') and (V_ap_vld_reg_14 /= V_ap_vld_14) then
                data_tx_latched_14 <= data_tx_14;
            end if;
            V_ap_vld_reg_15 <= V_ap_vld_15;
            if (V_ap_vld_15 = '1') and (V_ap_vld_reg_15 /= V_ap_vld_15) then
                data_tx_latched_15 <= data_tx_15;
            end if;
            V_ap_vld_reg_16 <= V_ap_vld_16;
            if (V_ap_vld_16 = '1') and (V_ap_vld_reg_16 /= V_ap_vld_16) then
                data_tx_latched_16 <= data_tx_16;
            end if;
            V_ap_vld_reg_17 <= V_ap_vld_17;
            if (V_ap_vld_17 = '1') and (V_ap_vld_reg_17 /= V_ap_vld_17) then
                data_tx_latched_17 <= data_tx_17;
            end if;
            V_ap_vld_reg_18 <= V_ap_vld_18;
            if (V_ap_vld_18 = '1') and (V_ap_vld_reg_18 /= V_ap_vld_18) then
                data_tx_latched_18 <= data_tx_18;
            end if;
            V_ap_vld_reg_19 <= V_ap_vld_19;
            if (V_ap_vld_19 = '1') and (V_ap_vld_reg_19 /= V_ap_vld_19) then
                data_tx_latched_19 <= data_tx_19;
            end if;
            V_ap_vld_reg_20 <= V_ap_vld_20;
            if (V_ap_vld_20 = '1') and (V_ap_vld_reg_20 /= V_ap_vld_20) then
                data_tx_latched_20 <= data_tx_20;
            end if;
            V_ap_vld_reg_21 <= V_ap_vld_21;
            if (V_ap_vld_21 = '1') and (V_ap_vld_reg_21 /= V_ap_vld_21) then
                data_tx_latched_21 <= data_tx_21;
            end if;
            V_ap_vld_reg_22 <= V_ap_vld_22;
            if (V_ap_vld_22 = '1') and (V_ap_vld_reg_22 /= V_ap_vld_22) then
                data_tx_latched_22 <= data_tx_22;
            end if;
            V_ap_vld_reg_23 <= V_ap_vld_23;
            if (V_ap_vld_23 = '1') and (V_ap_vld_reg_23 /= V_ap_vld_23) then
                data_tx_latched_23 <= data_tx_23;
            end if;
            V_ap_vld_reg_24 <= V_ap_vld_24;
            if (V_ap_vld_24 = '1') and (V_ap_vld_reg_24 /= V_ap_vld_24) then
                data_tx_latched_24 <= data_tx_24;
            end if;
            V_ap_vld_reg_25 <= V_ap_vld_25;
            if (V_ap_vld_25 = '1') and (V_ap_vld_reg_25 /= V_ap_vld_25) then
                data_tx_latched_25 <= data_tx_25;
            end if;
            V_ap_vld_reg_26 <= V_ap_vld_26;
            if (V_ap_vld_26 = '1') and (V_ap_vld_reg_26 /= V_ap_vld_26) then
                data_tx_latched_26 <= data_tx_26;
            end if;
            V_ap_vld_reg_27 <= V_ap_vld_27;
            if (V_ap_vld_27 = '1') and (V_ap_vld_reg_27 /= V_ap_vld_27) then
                data_tx_latched_27 <= data_tx_27;
            end if;
            V_ap_vld_reg_28 <= V_ap_vld_28;
            if (V_ap_vld_28 = '1') and (V_ap_vld_reg_28 /= V_ap_vld_28) then
                data_tx_latched_28 <= data_tx_28;
            end if;
            V_ap_vld_reg_29 <= V_ap_vld_29;
            if (V_ap_vld_29 = '1') and (V_ap_vld_reg_29 /= V_ap_vld_29) then
                data_tx_latched_29 <= data_tx_29;
            end if;
            V_ap_vld_reg_30 <= V_ap_vld_30;
            if (V_ap_vld_30 = '1') and (V_ap_vld_reg_30 /= V_ap_vld_30) then
                data_tx_latched_30 <= data_tx_30;
            end if;
            V_ap_vld_reg_31 <= V_ap_vld_31;
            if (V_ap_vld_31 = '1') and (V_ap_vld_reg_31 /= V_ap_vld_31) then
                data_tx_latched_31 <= data_tx_31;
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

    sd_tx_buffer_0 <= data_tx_latched_0 & data_tx_latched_1 & data_tx_latched_2 & 
        data_tx_latched_3 & data_tx_latched_4 & data_tx_latched_5 & data_tx_latched_6 & data_tx_latched_7;
    sd_tx_buffer_1 <= data_tx_latched_8 & data_tx_latched_9 & data_tx_latched_10 & 
        data_tx_latched_11 & data_tx_latched_12 & data_tx_latched_13 & data_tx_latched_14 & data_tx_latched_15 ;
    sd_tx_buffer_2 <= data_tx_latched_16 & data_tx_latched_17 & data_tx_latched_18 & 
        data_tx_latched_19 & data_tx_latched_20 & data_tx_latched_21 & data_tx_latched_22 & data_tx_latched_23 ;
    sd_tx_buffer_3 <= data_tx_latched_24 & data_tx_latched_25 & data_tx_latched_26 & 
        data_tx_latched_27 & data_tx_latched_28 & data_tx_latched_29 & data_tx_latched_30 & data_tx_latched_31 ;
  
    -- codecs transmission process
    process(mclk, reset_n)
        variable tdm_sclk_cnt : integer := 0;  -- TDM counter of master clocks during half period of serial clock
        variable ssm_sclk_cnt : integer := 0;  -- SSM counter of master clocks during half period of serial clock
        variable tdm_cnt   : integer := 127; -- TDM cycles counter TODO potential culrpit
        variable ssm_cnt : integer := 0; -- SSM cycles counter
    begin
        if(reset_n = '0') then              --asynchronous reset         
            tdm_sclk_cnt      := 0;               --clear mclk/sclk counter
            ssm_sclk_cnt      := 0;               --clear mclk/sclk counter
            tdm_cnt       := 127;
            sd_tx_0 <= '0';             --clear serial data transmit output
            sd_tx_1 <= '0';
            sd_tx_2 <= '0';
            sd_tx_3 <= '0';
            rdy1 <= '0';
            
        elsif(mclk'event and mclk = '1') and start = '1' then
            
            -- Fetching audio intputs (SSM)
            if(ssm_sclk_cnt < ssm_mclk_sclk_ratio/2-1) then  --less than half period of sclk
                ssm_sclk_cnt := ssm_sclk_cnt + 1;       --increment mclk/sclk counter
            else                              --half period of sclk. Sur changement de front de sclk (bclk)
                ssm_sclk_cnt := 0;                  --reset mclk/sclk counter
                ssm_sclk_int <= not ssm_sclk_int;       --toggle serial clock
                
                if(ssm_sclk_int = '1') then --edge of sclk
                    if(ssm_cnt > 0 and ssm_cnt < d_width)  then
                        l_data_rx_int <= l_data_rx_int(d_width-2 downto 0) & sd_rx;
                    else
                        r_data_rx_int <= r_data_rx_int(d_width-2 downto 0) & sd_rx;
                    end if;
                    
                    -- generating word select for SSM
                    if(ssm_cnt = d_width-1) then
                        ssm_ws_int <= '1';
                    elsif(ssm_cnt = d_width*2-1) then
                        ssm_ws_int <= '0';
                    end if;
                    
                    if(ssm_cnt = 2) then
                        l_data_rx <= l_data_rx_int;
                        r_data_rx <= r_data_rx_int;
                        rdy1 <= '1'; -- rdy happens upon a new buffer
                    else
                        rdy1 <= '0';
                    end if;
                    
                    if(ssm_cnt < d_width*2-1) then
                        ssm_cnt := ssm_cnt + 1;
                    else
                        ssm_cnt := 0;
                    end if;
                end if;
            end if;
            
            -- Generating audio outputs
            if(tdm_sclk_cnt < tdm_mclk_sclk_ratio/2-1) then  --less than half period of sclk
                tdm_sclk_cnt := tdm_sclk_cnt + 1;       --increment mclk/sclk counter
            else                              --half period of sclk. Sur changement de front de sclk (bclk)
                tdm_sclk_cnt := 0;                  --reset mclk/sclk counter
                tdm_sclk_int <= not tdm_sclk_int;       --toggle serial clock
                
                if(tdm_sclk_int = '1') then --edge of sclk
        
                    -- generating word select for TDM
                    if(tdm_cnt = 0) then
                        tdm_ws_int <= '1';
                    else
                        tdm_ws_int <= '0';
                    end if;   
                    
                    sd_tx_0 <= sd_tx_buffer_int_0(tdm_cnt);
                    sd_tx_1 <= sd_tx_buffer_int_1(tdm_cnt);
                    sd_tx_2 <= sd_tx_buffer_int_2(tdm_cnt);
                    sd_tx_3 <= sd_tx_buffer_int_3(tdm_cnt);      
                    
                    -- When buffer filling is completed, sendind data
                    if(tdm_cnt = 0) then
                        sd_tx_buffer_int_0 <= sd_tx_buffer_0;
                        sd_tx_buffer_int_1 <= sd_tx_buffer_1;
                        sd_tx_buffer_int_2 <= sd_tx_buffer_2;
                        sd_tx_buffer_int_3 <= sd_tx_buffer_3;
                    end if;
          
                    if(tdm_cnt > 0) then
                        tdm_cnt := tdm_cnt - 1;
                    else
                        tdm_cnt := 127;
                    end if;
                end if; 
            end if;
        end if;
    end process;
    
    tdm_sclk <= tdm_sclk_int;                     --output serial clock
    tdm_ws <= tdm_ws_int;                       --output word select
    ssm_sclk <= ssm_sclk_int;
    ssm_ws <= ssm_ws_int;

end logic;
