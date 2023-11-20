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

entity test_bench_emul_faust is

end test_bench_emul_faust ;


architecture logic of test_bench_emul_faust is
  
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
    in_left_V : IN STD_LOGIC_VECTOR (23 downto 0);
    in_right_V : IN STD_LOGIC_VECTOR (23 downto 0);
    out_left_V : OUT STD_LOGIC_VECTOR (23 downto 0);
    out_left_V_ap_vld : OUT STD_LOGIC;
    out_right_V : OUT STD_LOGIC_VECTOR (23 downto 0);
    out_right_V_ap_vld : OUT STD_LOGIC
);
end component;

  -----------------------------------------------------------------------------
  -- Testbench Internal Signals
  -----------------------------------------------------------------------------
  file file_VECTORS : text;


signal    ap_clk : STD_LOGIC := '0';
signal    ap_rst_n : STD_LOGIC :='0';
signal    ap_start : STD_LOGIC ;
signal    ap_done : STD_LOGIC;
signal    ap_idle :  STD_LOGIC;
signal    ap_ready : STD_LOGIC;
signal    in_left_V : STD_LOGIC_VECTOR (23 downto 0);
signal    in_right_V :  STD_LOGIC_VECTOR (23 downto 0);
signal    in_left_V_int : STD_LOGIC_VECTOR (23 downto 0);
signal    in_right_V_int :  STD_LOGIC_VECTOR (23 downto 0);
signal    out_left_V :  STD_LOGIC_VECTOR (23 downto 0);
signal    out_left_V_int :  STD_LOGIC_VECTOR (23 downto 0);
signal    out_left_V_ap_vld :  STD_LOGIC;
signal    out_right_V : STD_LOGIC_VECTOR (23 downto 0);
signal    out_right_V_int : STD_LOGIC_VECTOR (23 downto 0);
signal    out_right_V_ap_vld :  STD_LOGIC;
signal    new_sample : STD_LOGIC ;
signal    faust_exec : STD_LOGIC ;

begin

   -----------------------------------------------------------------------------
  -- Instantiate and Map UUT
  -----------------------------------------------------------------------------
  emul_faust_inst : emul_faust
  port map(
    ap_clk => ap_clk,
    ap_rst_n =>ap_rst_n,
    ap_start => ap_start,
    ap_done => ap_done,
    ap_idle => ap_idle,
    ap_ready => ap_ready,
    in_left_V  => in_left_V,
    in_right_V => in_right_V,
    out_left_V => out_left_V,
    out_left_V_ap_vld => out_left_V_ap_vld,
    out_right_V => out_right_V,
    out_right_V_ap_vld => out_right_V_ap_vld
) ;



  
  process(ap_clk,  ap_rst_n)
    variable step : integer :=0;
    variable clock_cnt : integer :=0;
  begin

    if(ap_rst_n = '0') then 
      ap_start <= '0';
      in_left_V  <= (others => '0');
      in_right_V   <= (others => '0');
--      out_left_V   <= (others => '0');
--      out_left_V_ap_vld   <=  '0';
--      out_right_V  <= (others => '0');
--     out_right_V_ap_vld   <= '0';
    elsif(ap_clk'event and ap_clk = '1') then
      -- new sample is used to trigger ap_start
      if (new_sample = '1') then
        clock_cnt := 0;
        faust_exec <= '1';
      else
        clock_cnt := clock_cnt + 1;
      end if;
      -- ap_start is hold until ap_done is set up
      if (faust_exec = '1') and (ap_done = '1')then
        faust_exec <= '0';
      end if;
      if (faust_exec = '1') then
        ap_start <= '1';
      else
        ap_start <= '0';
      end if;
     -- arbitrarily set 30 cycles for stable input data
      if (clock_cnt > 0) and (clock_cnt <30 ) then
        in_left_V <= in_left_V_int;
        in_right_V <= in_right_V_int;
      else
        in_left_V <= "000000000000000000000000";
        in_right_V <= "000000000000000000000000";
      end if;
      if (ap_done = '1') then
        out_right_V_int <=  out_right_V;
        out_left_V_int <=  out_left_V;
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
    variable sample_read : std_logic_vector(23 downto 0);
    --variable v_SPACE     : character;
     
  begin
    wait for 20 ns;
    
     file_open(file_VECTORS, "./input_samples-1.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS,v_ILINE);
      read(v_ILINE, sample_read);
--      read(v_ILINE, v_SPACE);           -- read in the space character
 
      -- Pass the variable to a signal to allow the ripple-carry to use it
      in_left_V_int  <= sample_read;
      in_right_V_int <= sample_read;
      new_sample <= '1';
      wait for 8 ns;
      new_sample <= '0';
        
      wait for 20.8 us;
 
    end loop;
 
    file_close(file_VECTORS);
     
    wait;
  end process;

  ------------------------------------------------------------------------
  --------------   Data flow equation          ---------------------------
  ------------------------------------------------------------------------

    --120 Mhz 
  ap_clk <= not ap_clk after 4 ns;
  ap_rst_n <=  '1' after 2 ns;


end architecture logic ;
