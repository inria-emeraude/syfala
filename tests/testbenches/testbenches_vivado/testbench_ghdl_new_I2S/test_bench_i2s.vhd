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
      sys_clk       : in  std_logic;
      mclk       : in  std_logic;
      reset_n   : in  std_logic;
      start     : in  std_logic;
      sclk      : out std_logic;          
      ws        : out std_logic;          
      sd_tx     : out std_logic;          
      sd_rx     : in  std_logic;          
      rdy       : out  std_logic;          
      ap_done   : in  std_logic;          
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

  signal sys_clk      :  std_logic := '0';
  signal mclk      :  std_logic := '0';
  signal  reset_n   :  std_logic := '0';      
  signal start     :  std_logic := '0';
  signal sclk      : std_logic;          --serial clock (or bit clock)
  signal ws        : std_logic;          --word select (or left-right clock)
  signal sd_tx     : std_logic;          --serial data transmit
  signal sd_rx     :  std_logic;          --serial data receive
  signal ap_start  :  std_logic;          
  signal ap_done   :  std_logic;          
  signal l_data_tx : std_logic_vector(d_width-1 downto 0);
  signal l_data_tx_TB : std_logic_vector(d_width-1 downto 0);
  signal r_data_tx : std_logic_vector(d_width-1 downto 0); 
  signal r_data_tx_TB : std_logic_vector(d_width-1 downto 0); 
  signal l_data_rx : std_logic_vector(d_width-1 downto 0);  
  signal r_data_rx : std_logic_vector(d_width-1 downto 0); 

  signal l_faust_to_i2s  : std_logic_vector(d_width-1 downto 0); 
  signal r_faust_to_i2s : std_logic_vector(d_width-1 downto 0);  
--  signal l_i2s_to_faust  : std_logic_vector(d_width-1 downto 0); 
--  signal r_i2s_to_faust : std_logic_vector(d_width-1 downto 0);  
  signal sclk_reg : std_logic;
  signal ap_start_reg : std_logic;

  signal data_read_by_faust_r  : std_logic_vector(d_width-1 downto 0); 
  signal data_read_by_faust_l  : std_logic_vector(d_width-1 downto 0); 
  signal data_read_by_i2s_r  : std_logic_vector(d_width-1 downto 0); 
  signal data_read_by_i2s_l  : std_logic_vector(d_width-1 downto 0); 

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
    rdy => ap_start,
    ap_done => ap_done,          
    l_data_tx => l_data_tx,
    r_data_tx => r_data_tx,
    l_data_rx => l_data_rx,
    r_data_rx => r_data_rx
    );  


  --sys_clk 120 Mhz 
  sys_clk <= not sys_clk after 4 ns;
  --12288 Mhz
  mclk <= not mclk after 40.690 ns;
  reset_n <= '1' after 20 ns;
  start <= '1' after 40 ns;

  
  process(sys_clk, reset_n)
    variable clock_cnt : integer :=0;
    variable date_ap_done : integer := 300;
  begin

    if(reset_n = '0') then              --asynchronous reset
      start      <= '0';               --clear mclk/sclk counter
--      sd_rx       <= '0';               --clear sclk/ws counter
--      ap_done      <= '0';             --clear serial clock signal
--      sd_rx         <= '0';             --clear serial data transmit output
      l_data_tx     <= (others => '0');  --clear left channel received data output
      r_data_tx     <= (others => '0');  --clear right channel received data output
    elsif(sys_clk'event and sys_clk = '1')  then  --system clock rising
      start <= '1';
      clock_cnt := clock_cnt + 1;
      --emulating faust result at date_ap_done=100 cycles 
      if (clock_cnt >= date_ap_done) and (clock_cnt < date_ap_done+1)  then
        ap_done <= '1';    
        data_read_by_i2s_r <= r_faust_to_I2S;
        data_read_by_i2s_l <= l_faust_to_I2S;
      else
        ap_done <= '0';
      end if;

      -- trick to send always same alternate values on sd_rx
      --sclk_reg <= sclk;
      --if (sclk = '1') and (sclk_reg /= sclk) then
      --  sd_rx <= not sd_rx;
      -- end if; 
      ---------------------------------------
      -- trick to send what we received
      sd_rx <= sd_tx;
      --sd_rx <= '0';
      
      -- sample input and output data on rd='1'
      ap_start_reg <= ap_start;
      if (ap_start = '1') and (ap_start_reg /= ap_start)  then
        assert false
          report "setting clock_cnt to 0"
          severity NOTE;
        clock_cnt := 0;
        data_read_by_faust_r <= r_data_rx;
        data_read_by_faust_l <= l_data_rx;
        l_data_tx     <= l_faust_to_I2S; 
        r_data_tx     <= l_faust_to_I2S;  
      end if;
      
    end if;     
  end process;  

  ----------------------------------------------------------------
  -- TODO: process to emulate sd_rx comming from ssd (not working currently)
  -- -------------------------------------------------------------  
 --  process(mclk, sclk, ws, reset_n)
--     variable sclk_cnt : integer :=0;
--     variable ws_cnt : integer :=0;
--     variable mclk_sclk_ratio : integer := 4;   --number of mclk periods per sclk period
--     variable sclk_ws_ratio   : integer := 64;  --number of sclk periods per word select period

--   begin

--     if(reset_n = '0') then              --asynchronous reset
-- --      sd_rx <= '0';
--       sclk_cnt      := 0;               --clear mclk/sclk counter
--       ws_cnt        := 0;               --clear sclk/ws counter
--     elsif(mclk'event and mclk = '1') then
--       if (ap_start = '1') and (ap_start_reg /= ap_start)  then
--         l_data_tx_TB     <= l_faust_to_I2S; 
--         r_data_tx_TB     <= l_faust_to_I2S;
--       else
--         if(sclk_cnt < mclk_sclk_ratio/2-1) then  --less than half period of sclk
--           sclk_cnt := sclk_cnt + 1;       --increment mclk/sclk counter
--         else                              --half period of sclk
--           sclk_cnt := 0;                  --reset mclk/sclk counter
--           ws_cnt := ws_cnt + 1;         --increment sclk/ws counter
--           if(ws_cnt < sclk_ws_ratio-1) then  --less than half period of ws
--             if(sclk = '1' and ws_cnt > 1 and ws_cnt < d_width*2+3) then  --falling edge of sclk during data word
--               if(ws = '1') then       --right channel
-- --                sd_rx         <= r_data_tx_TB(d_width-1);  --transmit serial data bit
-- --                r_data_tx_TB <= r_data_tx_TB(d_width-2 downto 0) & '0';  --shift data of right channel tx data buffer
--               else                        --left channel
-- --                sd_rx         <= l_data_tx_TB(d_width-1);  --transmit serial data bit
-- --                      l_data_tx_TB <= l_data_tx_TB(d_width-2 downto 0) & '0';  --shift data of left channel tx data buffer
--               end if;
--             else
--              -- sd_rx <= '0';
--             end if;
--           else                            --half period of ws
--             ws_cnt        := 0;           --reset sclk/ws counter
--           end if;
--         end if; 
--       end if; 
--     end if; 
--   end process;


        
  ---------------------------------------------------
  --  process to emulate data comming from Faust IP
  -- -------------------------------------------------------------  
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
      l_faust_to_i2s <= sample_read;
      r_faust_to_i2s <= sample_read;
 
      wait for 20.8 us;
 
    end loop;
 
    file_close(file_VECTORS);
     
    wait;
  end process;

  
end architecture logic ;
