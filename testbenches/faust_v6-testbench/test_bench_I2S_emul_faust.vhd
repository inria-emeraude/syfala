--------------------------------------------------------------------------------
--
--   FileName:         test_bench_i2s.vhd
-------------------------------------------------------------------- 
-- Authors:, Tanguy Risset
-- Begin Date: 7/04/2019
-- Testbench for modified version of 
-- DigiKey logic eewiki
-- https://www.digikey.com/eewiki/pages/viewpage.action?pageId=10125324
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity test_bench_I2S_emul_faust is

end test_bench_I2S_emul_faust ;


architecture logic of test_bench_I2S_emul_faust is
   CONSTANT bit_width: integer := 24;
   CONSTANT sclk_ws_ratio_cst: integer := 64;
  -----------------------------------------------------------------------------
  -- Declare the Component Under Test
  -----------------------------------------------------------------------------
  
  component emul_faust is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    in_left_V : IN STD_LOGIC_VECTOR (bit_width-1 downto 0);
    in_right_V : IN STD_LOGIC_VECTOR (bit_width-1 downto 0);
    out_left_V : OUT STD_LOGIC_VECTOR (bit_width-1 downto 0);
    out_left_V_ap_vld : OUT STD_LOGIC;
    out_right_V : OUT STD_LOGIC_VECTOR (bit_width-1 downto 0);
    out_right_V_ap_vld : OUT STD_LOGIC
);
end component;


  component i2s_transceiver is
    generic(
      mclk_sclk_ratio : integer;
      sclk_ws_ratio   : integer;  
      d_width         : integer );   
    port(
      sys_clk    : in  std_logic;
      mclk       : in  std_logic;
      reset_n   : in  std_logic;
      start     : in  std_logic;
      sclk      : out std_logic;          
      ws        : out std_logic;          
      sd_tx     : out std_logic;          
      sd_rx     : in  std_logic;          
      rdy       : out  std_logic;          
      ap_done   : in  std_logic;          
      out_left_V_ap_vld : in STD_LOGIC;
      out_right_V_ap_vld : in STD_LOGIC;
      l_data_tx : in  std_logic_vector(bit_width-1 downto 0); 
      r_data_tx : in  std_logic_vector(bit_width-1 downto 0); 
      l_data_rx : out std_logic_vector(bit_width-1 downto 0); 
      r_data_rx : out std_logic_vector(bit_width-1 downto 0);
      ws_cnt_out : out std_logic_vector(7 downto 0);
      word_channel_out :  out  std_logic;  
      bit_cnt_out : out std_logic_vector(7 downto 0)
    );  
  end component i2s_transceiver;

-----------------------------------------------------------------------------
  -- Testbench Internal Signals
  -----------------------------------------------------------------------------
  file file_VECTORS : text;


  signal    sys_clk : STD_LOGIC := '0';
  signal    ap_rst_n : STD_LOGIC :='0';
  signal    ap_start : STD_LOGIC ;
  signal    ap_done : STD_LOGIC;
  signal    ap_idle :  STD_LOGIC;
  signal    ap_ready : STD_LOGIC;
  signal    l_i2s_to_faust : STD_LOGIC_VECTOR (bit_width-1 downto 0);
  signal    r_i2s_to_faust :  STD_LOGIC_VECTOR (bit_width-1 downto 0);
  signal    out_right_V_ap_vld :  STD_LOGIC;
  signal    out_left_V_ap_vld :  STD_LOGIC;

  signal start     : std_logic;          
  signal sclk     : std_logic;          
  signal ws        : std_logic;          --word select (or left-right clock)
  signal mclk      :  std_logic := '0';
  signal sd_tx     : std_logic;          --serial data transmit
  signal sd_rx     :  std_logic;          --serial data receive
  signal l_faust_to_i2s : std_logic_vector(bit_width-1 downto 0);
  signal r_faust_to_i2s : std_logic_vector(bit_width-1 downto 0);
  signal rx_full_word_latched : std_logic_vector(bit_width-1 downto 0); 
  signal rx_full_word  : std_logic_vector(bit_width-1 downto 0); 
  signal word_channel_out :  std_logic;  
  signal ws_cnt_out : std_logic_vector(7 downto 0); 
  signal bit_cnt_out : std_logic_vector(7 downto 0); 
begin

   -----------------------------------------------------------------------------
  -- Instantiate and Map UUT
  -----------------------------------------------------------------------------
  emul_faust_inst : emul_faust
  port map(
    ap_clk => sys_clk,
    ap_rst_n =>ap_rst_n,
    ap_start => ap_start,
    ap_done => ap_done,
    ap_idle => ap_idle,
    ap_ready => ap_ready,
    in_left_V  => l_i2s_to_faust,
    in_right_V => r_i2s_to_faust,
    out_left_V => l_faust_to_i2s,
    out_left_V_ap_vld => out_left_V_ap_vld,
    out_right_V => r_faust_to_i2s,
    out_right_V_ap_vld => out_right_V_ap_vld
) ;
     -----------------------------------------------------------------------------
  -- Instantiate and Map UUT
  -----------------------------------------------------------------------------
  i2s_transceiver_inst : i2s_transceiver 
    generic map(
      mclk_sclk_ratio => 4,
      sclk_ws_ratio   =>sclk_ws_ratio_cst, 
      d_width         =>bit_width)
  port map(
    sys_clk  =>  sys_clk,
    mclk  =>  mclk,
    reset_n => ap_rst_n,
    start => start,
    sclk => sclk,
    ws => ws,
    sd_tx => sd_tx,
    sd_rx => sd_rx,
    rdy => ap_start,
    ap_done => ap_done,
    out_left_V_ap_vld => out_left_V_ap_vld,
    out_right_V_ap_vld => out_right_V_ap_vld,
    l_data_tx => l_faust_to_i2s,
    r_data_tx => r_faust_to_i2s,
    l_data_rx => l_i2s_to_faust,
    r_data_rx => r_i2s_to_faust,
    word_channel_out => word_channel_out,
    ws_cnt_out => ws_cnt_out,
    bit_cnt_out => bit_cnt_out
    );  

  

  process(sclk,  ap_rst_n,ws)
  begin
  	if(ap_rst_n = '0') then 
	elsif(falling_edge(sclk)) then
	  	sd_rx <=  rx_full_word(bit_width-1) after 16 ns;
		 if( ws_cnt_out > "00000001") then
			rx_full_word <= rx_full_word(bit_width-2 downto 0) & '0';  --shift data of right channel tx data buffer  
		else
			rx_full_word<=rx_full_word_latched;
		end if;
	end if;
  end process;  

  ----------------------------------------------------------------
  -- process to emulate sd_rx comming from ssd
  -- -------------------------------------------------------------
  
  ---------------------------------------------------------------------------
  -- This procedure reads the file input_vectors.txt which is located in the
  -- simulation project area.
  -- It will read the data in and send it to the ripple-adder component
  -- to perform the operations.  The result is written to the
  -- output_results.txt file, located in the same directory.
  ---------------------------------------------------------------------------
  process
    variable v_ILINE     : line;
    variable sample_read : std_logic_vector(bit_width-1 downto 0);
    --variable v_SPACE     : character;
     
  begin
    wait for 1.3 us;
    
     file_open(file_VECTORS, "./input_samples.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS,v_ILINE);
      read(v_ILINE, sample_read);

 
      -- Pass the variable to a signal to allow the ripple-carry to use it
      rx_full_word_latched  <= sample_read;
      --in_right_V_int <= sample_read;
      --ap_start <= '1';
      --wait for 8 ns;
      --ap_start <= '0';
      
      wait for 1.3 us;
 
    end loop;
 
    file_close(file_VECTORS);
     
    wait;
  end process;

  ------------------------------------------------------------------------
  --------------   Data flow equation          ---------------------------
  ------------------------------------------------------------------------

  --sys_clk 120 Mhz 
  sys_clk <= not sys_clk after 4 ns;
  -- mclk: 98.304 Mhz :> p=10.173ns" after 5.086 ns;"
  mclk <= not mclk after 5.086 ns;
  ap_rst_n <=  '1' after 2 ns;
  start <= '1' after 40 ns;


end architecture logic ;
