library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
use work.float_pkg.all;

entity ADD_sfixed is
generic (
    msb     : integer;
    lsb     : integer);
port (
   clk     : in std_logic;
   rst     : in std_logic;
   input0  : in  sfixed( msb  downto  lsb );
   input1  : in  sfixed( msb  downto  lsb );
   output0 : out sfixed( msb  downto  lsb ));
end ADD_sfixed;

architecture behavioral of ADD_sfixed is
  signal temp : sfixed(msb downto lsb);
begin
  temp  <= resize(input0 + input1, msb ,  lsb );
  output0 <= temp;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
use work.float_pkg.all;

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

signal    in_left_V_buf  : std_logic_vector (23 downto 0);
signal    in_left_fixed  : sfixed(23 downto 0);
signal    in_left_fixed_24bits : sfixed(0 downto -23);
signal    in_right_V_buf : std_logic_vector (23 downto 0);
signal    in_right_fixed : sfixed(23 downto 0);
signal    in_right_fixed_24bits : sfixed(0 downto -23);
signal    out_left_V_int : std_logic_vector (23 downto 0);
signal    out_right_V_int : std_logic_vector (23 downto 0);
signal    step_cnt  : integer;
signal    left_sigoutput : sfixed(8 downto -23);
signal    left_out_fixed_32bits : sfixed(31 downto 0);
signal    left_out_slv_32bits : std_logic_vector (31 downto 0);
signal    left_out_slv_24bits : std_logic_vector (24 downto 0);
signal    right_sigoutput : sfixed(8 downto -23);
signal    right_out_fixed_32bits : sfixed(31 downto 0);
signal    right_out_slv_32bits : std_logic_vector (31 downto 0);
signal    right_out_slv_24bits : std_logic_vector (24 downto 0);


signal    sig115 : sfixed(8 downto -23);
signal    sig101 : sfixed(8 downto -23);
signal    sig102 : sfixed(8 downto -23);

component ADD_sfixed is
generic (
    msb     : integer;
    lsb     : integer);
port (
   clk     : in std_logic;
   rst     : in std_logic;
   input0  : in  sfixed( msb  downto  lsb );
   input1  : in  sfixed( msb  downto  lsb );
   output0 : out sfixed( msb  downto  lsb ));
end component;


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


in_left_fixed_24bits <= to_sfixed(in_left_V_buf,0,-23);
sig101 <= resize(in_left_fixed_24bits,8,-23);
in_right_fixed_24bits <= to_sfixed(in_right_V_buf,0,-23);
sig102 <= resize(in_right_fixed_24bits,8,-23);

ADD_sfixed_115 : ADD_sfixed
generic map (
    msb => 8,
    lsb => -23 )
port map (
    clk => ap_clk,
    rst => ap_rst_n,
    input0  => sig101,
    input1  => sig102,
    output0 => sig115);


left_sigoutput <= sig115;
left_out_fixed_32bits <= left_sigoutput;
left_out_slv_32bits <= to_slv(left_out_fixed_32bits);
out_left_V_int(22 downto 0) <=  left_out_slv_32bits(22 downto 0);
out_left_V_int(23) <=  left_out_slv_32bits(31);
right_sigoutput <= sig115;
right_out_fixed_32bits <= right_sigoutput;
right_out_slv_32bits <= to_slv(right_out_fixed_32bits);
out_right_V_int(22 downto 0) <= right_out_slv_32bits(22 downto 0);
out_right_V_int(23) <= right_out_slv_32bits(31);
end logic;
