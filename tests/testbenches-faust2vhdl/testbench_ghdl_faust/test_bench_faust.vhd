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
use work.fixed_pkg.all;

entity test_bench_faust is

end test_bench_faust ;


architecture logic of test_bench_faust is
   CONSTANT bit_width: integer := 24;
   CONSTANT sclk_ws_ratio_cst: integer := 64;
  -----------------------------------------------------------------------------
  -- Declare the Component Under Test
  -----------------------------------------------------------------------------
  
   component FAUST is
     port (
       ws : in std_logic;
       ap_clk : in std_logic;
       ap_rst_n : in std_logic;
       ap_start : in std_logic;
       ap_done : out std_logic;
       bypass_dsp : in std_logic;
       bypass_faust : in std_logic;
       in_left_V : IN STD_LOGIC_VECTOR (bit_width-1 downto 0);
       in_right_V : IN STD_LOGIC_VECTOR (bit_width-1 downto 0);
       out_left_V : OUT STD_LOGIC_VECTOR (bit_width-1 downto 0);
       out_left_V_ap_vld : OUT STD_LOGIC;
       out_right_V : OUT STD_LOGIC_VECTOR (bit_width-1 downto 0);
       out_right_V_ap_vld : OUT STD_LOGIC
       );
   end component;



-----------------------------------------------------------------------------
  -- Testbench Internal Signals
  -----------------------------------------------------------------------------
  file file_VECTORS : text;
  file file_RES : text;


  signal    ws : STD_LOGIC := '0';
  signal    bypass_dsp : STD_LOGIC := '0';
  signal    bypass_faust : STD_LOGIC := '0';
  signal    sys_clk : STD_LOGIC := '0';
  signal    ap_rst_n : STD_LOGIC :='0';
  signal    ap_start : STD_LOGIC ;
  signal    ap_done : STD_LOGIC;
  signal    l_i2s_to_faust : STD_LOGIC_VECTOR (bit_width-1 downto 0):="000000000000000000000000";
  signal    r_i2s_to_faust :  STD_LOGIC_VECTOR (bit_width-1 downto 0):="000000000000000000000000";
  signal    out_right_V_ap_vld :  STD_LOGIC;
  signal    out_left_V_ap_vld :  STD_LOGIC;
  signal    out_right_V_ap_vld_reg :  STD_LOGIC;
  signal    out_left_V_ap_vld_reg :  STD_LOGIC;

  signal start     : std_logic;          
  signal sclk     : std_logic;          
  signal mclk      :  std_logic := '0';
  signal sd_tx     : std_logic;          --serial data transmit
  signal sd_rx     :  std_logic;          --serial data receive
  signal l_faust_to_i2s : std_logic_vector(bit_width-1 downto 0):="000000000000000000000000";
  signal r_faust_to_i2s : std_logic_vector(bit_width-1 downto 0) :="000000000000000000000000";
  signal l_faust_to_i2s_latched : std_logic_vector(bit_width-1 downto 0):="000000000000000000000000";
  signal r_faust_to_i2s_latched : std_logic_vector(bit_width-1 downto 0) :="000000000000000000000000";
  signal rx_full_word_latched : std_logic_vector(bit_width-1 downto 0):="000000000000000000000000"; 
  signal rx_full_word  : std_logic_vector(bit_width-1 downto 0):="000000000000000000000000"; 
  signal word_channel_out :  std_logic;  
  signal bit_cnt_out : std_logic_vector(7 downto 0); 
begin

   -----------------------------------------------------------------------------
  -- Instantiate and Map UUT
  -----------------------------------------------------------------------------
  faust_inst : faust
  port map(
    ws => ws,
    bypass_dsp => bypass_dsp,
    bypass_faust => bypass_faust,
    ap_clk => sys_clk,
    ap_rst_n =>ap_rst_n,
    ap_start => ap_start,
    ap_done => ap_done,
    in_left_V  => l_i2s_to_faust,
    in_right_V => r_i2s_to_faust,
    out_left_V => l_faust_to_i2s,
    out_left_V_ap_vld => out_left_V_ap_vld,
    out_right_V => r_faust_to_i2s,
    out_right_V_ap_vld => out_right_V_ap_vld
) ;
  

  process(sys_clk)
  variable ws_cnt_out : integer := 0; 
  begin
    if (sys_clk'event) then
      out_left_V_ap_vld_reg <= out_left_V_ap_vld;
      if  (out_left_V_ap_vld = '1') and
        (out_left_V_ap_vld_reg /= out_left_V_ap_vld) then
        l_faust_to_i2s_latched <= l_faust_to_i2s;
      end if;
    
      out_right_V_ap_vld_reg <= out_right_V_ap_vld;
      if  (out_right_V_ap_vld = '1') and
        (out_right_V_ap_vld_reg /= out_right_V_ap_vld) then
        r_faust_to_i2s_latched <= r_faust_to_i2s;
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
    variable v_RLINE     : line;
    variable sample_read : std_logic_vector(bit_width-1 downto 0);
    variable sample_write : std_logic_vector(bit_width-1 downto 0);
    variable cpt: integer:=0;
    --variable v_SPACE     : character;
     
  begin
    wait for 1.3 us;
    
    file_open(file_VECTORS, "./input_samples.txt",read_mode);
    file_open(file_RES, "./output_samples.txt",  write_mode);
    cpt:=0;
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS,v_ILINE);
      read(v_ILINE, sample_read);
      if (cpt>1) then
        write(v_RLINE, l_faust_to_i2s);
        writeline(file_RES, v_RLINE);   
        write(v_RLINE, r_faust_to_i2s);
        writeline(file_RES, v_RLINE);   
      end if;
      cpt:=cpt+1; -- remove XXX first sample

-- Pass the variable to a signal to allow the ripple-carry to use it
      rx_full_word_latched  <= sample_read;
      l_i2s_to_faust <= sample_read;
      r_i2s_to_faust <= sample_read;
      ap_start <= '1';
      wait for 8 ns;
      ap_start <= '0';
      
      wait for 20.83 us;
 
    end loop;
 
    file_close(file_VECTORS);
     
    wait;
  end process;

  ------------------------------------------------------------------------
  --------------   Data flow equation          ---------------------------
  ------------------------------------------------------------------------

  --sys_clk 120 Mhz 
  sys_clk <= not sys_clk after 4 ns;
  -- mclk: 12.288 :> p=81.38ns" after 40.69 ns;"
  mclk <= not mclk after 40.69 ns;
  -- ws: 48kHz  :> T=20.83us" after 10.041us;"
  ws <= not ws after 10.041 us;
  ap_rst_n <=  '1' after 20 ns;
  start <= '1' after 40 ns;


end architecture logic ;
