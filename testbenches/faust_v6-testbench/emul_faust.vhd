library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity emul_faust is
  generic(
    d_width         : integer := 24);   --data width
port (
  ap_clk : IN STD_LOGIC;
  ap_rst_n : IN STD_LOGIC;
  ap_start : IN STD_LOGIC;
  ap_done : OUT STD_LOGIC;
  ap_idle : OUT STD_LOGIC;
  ap_ready : OUT STD_LOGIC;
  in_left_V : IN STD_LOGIC_VECTOR (d_width-1 downto 0);
  in_right_V : IN STD_LOGIC_VECTOR (d_width-1 downto 0);
  out_left_V : OUT STD_LOGIC_VECTOR (d_width-1 downto 0);
  out_left_V_ap_vld : OUT STD_LOGIC;
  out_right_V : OUT STD_LOGIC_VECTOR (d_width-1 downto 0);
  out_right_V_ap_vld : OUT STD_LOGIC
);
end emul_faust;

architecture logic of emul_faust is


signal    in_left_V_buf : STD_LOGIC_VECTOR (d_width-1 downto 0);
signal    in_right_V_buf :  STD_LOGIC_VECTOR (d_width-1 downto 0);
signal    out_left_V_int : STD_LOGIC_VECTOR (d_width-1 downto 0);
signal    out_right_V_int :  STD_LOGIC_VECTOR (d_width-1 downto 0);
signal    step_cnt : integer  ;  
signal    ap_start_reg : STD_LOGIC  ;  

begin



  
  process(ap_clk, ap_rst_n)
    variable clock_cnt : integer := 0;  

    variable date_ap_vld1 : integer := 30;
  begin
    
    if(ap_rst_n = '0') then
      step_cnt <= 0;
      clock_cnt := 0;
      ap_done <= '0';
      ap_idle <='0';
      out_left_V   <= (others => '0');
      out_left_V_ap_vld   <= '0';
      out_right_V  <= (others => '0');
      out_right_V_ap_vld <=   '0' ;
    elsif(ap_clk'event and ap_clk = '1') then
      -- trick used to detect rising edge of ap_start ('event does not work)
      ap_start_reg <= ap_start;
      if (ap_start = '1') and (ap_start_reg /= ap_start) then
        clock_cnt := 0;
      end if;
      -- loading (buffering) input data
      if (clock_cnt = 1) then
        step_cnt <= step_cnt + 1;
        in_left_V_buf <= in_left_V;
        in_right_V_buf <= in_right_V;
      end if; 
      clock_cnt := clock_cnt+1;
      
      -- Say faust has read all input at cycle 20 and keeps ready until cycle 400 
      if (clock_cnt > 0) and (clock_cnt <2)  then
        ap_ready <= '1';
        -- emul BYPASS
        out_right_V_int <= in_right_V_buf;
        out_left_V_int <= in_left_V_buf;
      else 
        ap_ready <= '0';
      end if;

     
      
      -- Say faust left output is ready at data_ap_vld1 and right next cycke
      if (clock_cnt >= date_ap_vld1) and (clock_cnt < date_ap_vld1+1)  then
        out_left_V_ap_vld <= '1'; 
        out_left_V <= out_left_V_int;   
      elsif (clock_cnt >= date_ap_vld1+1) and (clock_cnt < date_ap_vld1+2)  then
        out_right_V <= out_right_V_int;   
        out_right_V_ap_vld <= '1';    
        out_left_V_ap_vld <= '0';    
        ap_done <= '1';    
      else
        ap_done <= '0';
        out_right_V_ap_vld <= '0';    
        out_left_V_ap_vld <= '0';    
      end if;

     end if;          
  end process;



 end logic;
