library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_pkg.all;

entity FAUST is
port (
  ws : in std_logic;
  ap_clk : in std_logic;
  ap_rst_n : in std_logic;
  ap_start : in std_logic;
  ap_done : out std_logic;
  bypass_dsp : in std_logic;
  bypass_faust : in std_logic;
  in_left_V : in std_logic_vector (23 downto 0);
  in_right_V : in std_logic_vector (23 downto 0);
  out_left_V_ap_vld : out std_logic;
  out_right_V_ap_vld : out std_logic;
  out_left_V : out std_logic_vector (23 downto 0);
  out_right_V : out std_logic_vector (23 downto 0));
end FAUST;
architecture logic of FAUST is

signal    in_left_V_buf   : std_logic_vector (23 downto 0);
signal    in_left_fixed   : sfixed(23 downto 0);
signal    in_right_V_buf  :  std_logic_vector (23 downto 0);
signal    out_left_V_int  : std_logic_vector (23 downto 0);
signal    out_left_fixed  : sfixed(23 downto 0);
signal    out_right_V_int :  std_logic_vector (23 downto 0);
signal    step_cnt  : integer;
signal    sigoutput : sfixed(23 downto 0);

signal    sig0x7fbb64001a90 : sfixed(1 downto -22);
signal    sig0x7fbb64001b80 : sfixed(1 downto -22);


begin

 process(ap_clk, ap_rst_n, ap_start)
   variable clock_cnt : integer := 0;
   variable date_ap_vld1 : integer := 3;
 begin

   if(ap_rst_n = '0') then
     step_cnt <= 0;
     clock_cnt := 0;
     ap_done <= '0';
     out_left_V   <= (others => '0');
     out_left_V_ap_vld   <= '0';
     out_right_V  <= (others => '0');
     out_right_V_ap_vld <=   '0' ;
   elsif(ap_clk'event and ap_clk = '1') then
     if (ap_start = '1') then
       clock_cnt := 0;
     end if;
     -- loading (buffering) input data
     if (clock_cnt = 1) then
       --step_cnt <= step_cnt + 1;
       in_left_V_buf <= in_left_V;
       in_right_V_buf <= in_right_V;
     end if;
     clock_cnt := clock_cnt+1;
     -- Say faust left output is ready
     if (clock_cnt >= 2) and (clock_cnt < 3)  then
       out_left_V_ap_vld <= '1';
       out_left_V <= out_left_V_int;
       out_right_V_ap_vld <= '1';
       out_right_V <=  out_right_V_int;
       ap_done <= '1';
     else
       ap_done <= '0';
       out_right_V_ap_vld <= '0';
       out_left_V_ap_vld <= '0';
     end if;
   end if;
 end process;
 ------------------------------------------------------------------------
 --------------   Data flow equation          ---------------------------
 ------------------------------------------------------------------------


sig0x7fbb64001a90 <= to_sfixed(in_left_V_buf,0,-23);
sig0x7fbb64001b80 <= to_sfixed(in_right_V_buf,0,-23);


 sigoutput <= sig0x7fbb64001a90;
-- sigoutput <= resize(sig0x7fbb64001a90,1,-22);
 
out_left_V_int <= to_slv(sigoutput);

out_right_V_int <= to_slv(sigoutput);

end logic;
