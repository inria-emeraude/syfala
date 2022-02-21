--------------------------------------------------------------------------------
--
--   FileName:         test_bench_new_i2s.vhd
-------------------------------------------------------------------- 
-- Authors:, Tanguy Risset
-- Begin Date: 7/04/2019
-- Testbench for new i2s modified  version of 
-- DigiKey logic eewiki
-- https://www.digikey.com/eewiki/pages/viewpage.action?pageId=10125324
-- by Adeyemi and then Maxime
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity test_bench_i2s is

end test_bench_i2s ;


architecture logic of test_bench_i2s is
  
  -----------------------------------------------------------------------------
  -- Declare the Component Under Test
  -----------------------------------------------------------------------------
  
  component i2s_transceiver is
    generic(
      mclk_sclk_ratio : integer;
      sclk_ws_ratio   : integer;  
    d_width         : integer );   
    port(
      sys_clk   : in std_logic;
      mclk       : in  std_logic;
      reset_n   : in  std_logic;
      start     : in  std_logic;
      sclk      : out std_logic;          
      ws        : out std_logic;          
      sd_tx     : out std_logic;          
      sd_rx     : in  std_logic;          
      rdy       : out  std_logic;          
      ap_done   : in  std_logic;          
      out_left_V_ap_vld   : in  std_logic; 
      out_right_V_ap_vld  : in  std_logic; 
      l_data_tx : in  std_logic_vector(d_width-1 downto 0);
      r_data_tx : in  std_logic_vector(d_width-1 downto 0); 
      l_data_rx : out std_logic_vector(d_width-1 downto 0); 
      r_data_rx : out std_logic_vector(d_width-1 downto 0)
    );  
  end component i2s_transceiver;

  -----------------------------------------------------------------------------
  -- Testbench Internal Signals
  -----------------------------------------------------------------------------
  file file_VECTORS : text;

  constant d_width : natural := 24;

  signal sys_clk   :  std_logic := '0';
  signal mclk      :  std_logic := '0';
  signal reset_n  :  std_logic := '0';      
  signal start     :  std_logic := '0';
  signal sclk      : std_logic;    --serial clock (or bit clock)
  signal ws        : std_logic;          --word select (or left-right clock)
  signal sd_tx     : std_logic;          --serial data transmit
  signal sd_rx     :  std_logic;          --serial data receive
  signal ap_start  :  std_logic;          
  signal ap_done   :  std_logic;          
  signal rdy   :  std_logic;          
  signal out_left_V_ap_vld :  std_logic;         
  signal out_right_V_ap_vld :  std_logic;         
  signal l_data_tx : std_logic_vector(d_width-1 downto 0);
  signal r_data_tx : std_logic_vector(d_width-1 downto 0); 
  signal l_data_rx : std_logic_vector(d_width-1 downto 0);  
  signal r_data_rx : std_logic_vector(d_width-1 downto 0); 

  signal l_input_to_i2s  : std_logic_vector(d_width-1 downto 0); 
  signal r_input_to_i2s : std_logic_vector(d_width-1 downto 0);  
  signal l_output_from_i2s  : std_logic_vector(d_width-1 downto 0); 
  signal r_output_from_i2s : std_logic_vector(d_width-1 downto 0);  
  signal pair: std_logic;

begin

   -----------------------------------------------------------------------------
  -- Instantiate and Map UUT
  -----------------------------------------------------------------------------
  i2s_transceiver_inst : i2s_transceiver 
    generic map(
      mclk_sclk_ratio => 4,
      sclk_ws_ratio   =>64, 
      d_width         =>24)
  port map(
    sys_clk  =>  sys_clk,
    mclk  =>  mclk,
    reset_n => reset_n,
    start => start,
    sclk => sclk,
    ws => ws,
    sd_tx => sd_tx,
    sd_rx => sd_rx,
    ap_done => ap_done,
    rdy => rdy,
    out_left_V_ap_vld  => out_left_V_ap_vld, 
    out_right_V_ap_vld  => out_right_V_ap_vld,
    l_data_tx => l_data_tx,
    r_data_tx => r_data_tx,
    l_data_rx => l_data_rx,
    r_data_rx => r_data_rx
    );  


  mclk <= not mclk after 40.690 ns;
  --12288 Mhz
  sys_clk <= not sys_clk after 4.16 ns;
  -- 120 Mhz
  reset_n <= '1' after 20 ns;
  start <= '1' after 40 ns;

  
  process(mclk, ws, reset_n,sys_clk)
    variable step : integer :=0;
  begin

    if(reset_n = '0') then              --asynchronous reset
      start      <= '0';               --clear mclk/sclk counter
      sd_rx       <= '0';               --clear sclk/ws counter
      ap_done      <= '0';             --clear serial clock signal
      sd_rx         <= '0';             --clear serial data transmit output
      l_data_tx     <= (others => '0');  --clear left channel received data output
      r_data_tx     <= (others => '0');  --clear right channel received data output
      pair <= '0';
    elsif(sys_clk'event and sys_clk = '1') then 
      start <= '1';
      sd_rx <= sd_tx;
      if (rdy = '1') then
          l_data_tx     <= l_input_to_i2s; 
          r_data_tx     <= l_input_to_i2s;
          out_left_V_ap_vld <= '1';
          out_right_V_ap_vld <= '1';
      else
          out_left_V_ap_vld <= '0';
          out_right_V_ap_vld <= '0';
      end if;     
    end if;     
  end process;  

  ----------------------------------------------------------------
  -- process to emulate sd_rx comming from ssd
  -- -------------------------------------------------------------
  
  --process(mclk, reset_n)
  --  variable step : integer :=0;
  --begin
  --end process
  ---------------------------------------------------------------------------
  -- This procedure reads the file input_vectors.txt which is located in the
  -- simulation project area.
  -- It will read the data in and send it to the ripple-adder component
  -- to perform the operations.  The result is written to the
  -- output_results.txt file, located in the same directory.
  ---------------------------------------------------------------------------
  process
    variable v_ILINE     : line;
    variable sample_read : std_logic_vector(d_width-1 downto 0);
    --variable v_SPACE     : character;
     
  begin
    wait for 20 ns;
    
     file_open(file_VECTORS, "./input_samples.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS,v_ILINE);
      read(v_ILINE, sample_read);
--      read(v_ILINE, v_SPACE);           -- read in the space character
 
      -- Pass the variable to a signal to allow the ripple-carry to use it
      l_input_to_i2s <= sample_read;
      r_input_to_i2s <= sample_read;
 
      wait for 20.8 us;
 
    end loop;
 
    file_close(file_VECTORS);
     
    wait;
  end process;

  
end architecture logic ;
