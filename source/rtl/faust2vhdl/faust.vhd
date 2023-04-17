library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
use work.float_pkg.all;

-- ----------------------------------------------------------------------------
-- ADD ENTITY
-- ----------------------------------------------------------------------------

entity ADD is
generic (
    msb: integer;
    lsb: integer);
port (
    in1: in sfixed(msb downto lsb);
    in2: in sfixed(msb downto lsb);
   out1: out sfixed(msb downto lsb));
end ADD;

architecture behavioral of ADD is
    signal tmp: sfixed(msb downto lsb);
begin
    tmp  <= resize(in1 + in2, msb, lsb);
    out1 <= tmp;
end behavioral;

-- ----------------------------------------------------------------------------
-- MEM ENTITY
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
use work.float_pkg.all;

entity MEM is
generic (
    msb: integer;
    lsb: integer);
port (
    clk: in  std_logic;
    rst: in  std_logic;
    in1: in  sfixed(msb downto lsb);
   out1: out sfixed(msb downto lsb));
end MEM;

architecture behavioral of MEM is
    signal reg: sfixed(msb downto lsb);
begin
    out1 <= reg;
process (clk)
    begin
        if rising_edge(clk) then
           reg <= in1;
        end if;
    end process;
end behavioral;

-- ----------------------------------------------------------------------------
-- FMOD ENTITY
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
use work.float_pkg.all;

entity FMOD is
generic (
    msb: integer;
    lsb: integer);
port (
    in1: in sfixed(msb downto lsb);
    in2: in sfixed(msb downto lsb);
   out1: out sfixed(msb downto lsb));
end FMOD;

architecture behavioral of FMOD is
    signal tmp: sfixed(msb downto lsb);
begin
    tmp <= resize(in1 mod in2, msb, lsb);
   out1 <= tmp;
end behavioral;

-- ----------------------------------------------------------------------------
-- MUL ENTITY
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
use work.float_pkg.all;

entity MUL is
generic (
    msb : integer;
    lsb : integer);
port (
    in1 : in sfixed(msb downto lsb);
    in2 : in sfixed(msb downto lsb);
   out1 : out sfixed(msb downto lsb));
end MUL;

architecture behavioral of MUL is
    signal tmp : sfixed(msb downto lsb);
begin
    tmp  <= resize(in1 * in2, msb, lsb);
    out1 <= tmp;
end behavioral;

-- ----------------------------------------------------------------------------
-- FAUST ENTITY
-- ----------------------------------------------------------------------------

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
  ws                    : in std_logic;
  ap_clk                : in std_logic;
  ap_rst_n              : in std_logic;
  ap_start              : in std_logic;
  ap_done               : out std_logic;
  bypass_dsp            : in std_logic;
  bypass_faust          : in std_logic;
  in_left_V             : in std_logic_vector(23 downto 0);
  in_right_V            : in std_logic_vector(23 downto 0);
  out_left_V_ap_vld     : out std_logic;
  out_right_V_ap_vld    : out std_logic;
  out_left_V            : out std_logic_vector(23 downto 0);
  out_right_V           : out std_logic_vector(23 downto 0));
end FAUST;

architecture logic of FAUST is

-- ----------------------------------------------------------------------------
-- signals
-- ----------------------------------------------------------------------------

signal cmp_proc: std_logic := '0';

signal add_cst: sfixed(8 downto -23) := to_sfixed(0.00459, 8, -23);
signal add_out: sfixed(8 downto -23) := to_sfixed(0, 8, -23);

signal mem_out: sfixed(8 downto -23) := to_sfixed(0, 8, -23);

signal mod_cst: sfixed(8 downto -23) := to_sfixed(1, 8, -23);
signal mod_out: sfixed(8 downto -23) := to_sfixed(0, 8, -23);

signal mul_cst: sfixed(8 downto -23) := to_sfixed(0.125, 8, -23);
signal mul_out: sfixed(8 downto -23) := to_sfixed(0, 8, -23);

-- ----------------------------------------------------------------------------
-- components
-- ----------------------------------------------------------------------------

component ADD is
generic (
    msb: integer;
    lsb: integer);
port (
    in1: in sfixed(msb downto lsb);
    in2: in sfixed(msb downto lsb);
   out1: out sfixed(msb downto lsb));
end component;

component MEM is
generic (
    msb: integer;
    lsb: integer);
port (
    clk: in std_logic;
    rst: in std_logic;
    in1: in  sfixed(msb downto lsb);
   out1: out sfixed(msb downto lsb));
end component;

component FMOD is
generic (
    msb: integer;
    lsb: integer);
port (
    in1: in sfixed(msb downto lsb);
    in2: in sfixed(msb downto lsb);
   out1: out sfixed(msb downto lsb));
end component;

component MUL is
generic (
    msb : integer;
    lsb : integer);
port (
    in1 : in sfixed(msb downto lsb);
    in2 : in sfixed(msb downto lsb);
   out1 : out sfixed(msb downto lsb));
end component;

-- ----------------------------------------------------------------------------
-- main process
-- ----------------------------------------------------------------------------
begin
 process (ap_clk, ap_rst_n, ap_start)
    variable buf    : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
    variable buf32  : sfixed(31 downto 0)  := to_sfixed(0, 31, 0);
    variable slv32  : std_logic_vector(31 downto 0);
    variable clk    : integer := 0;
 begin
    if (ap_rst_n = '0') then
    -- reset every port to 0
        buf   := to_sfixed(0, 8, -23);
        buf32 := to_sfixed(0, 31, 0);
        clk   := 0;
        ap_done <= '0';
        out_left_V_ap_vld  <= '0';
        out_right_V_ap_vld <= '0';
        out_left_V  <= (others => '0');
        out_right_V <= (others => '0');
        slv32 := (others => '0');
   -- on each clock (sys_clock) event
    elsif  (ap_clk'event and ap_clk = '1') then
        if (ap_start = '1') then
            clk := 0;
            cmp_proc <= '0';
        end if;
        if (clk = 1) then
            -- no need to buffer inputs here for this example
            -- directly process outputs
        elsif (clk >= 2) and (clk < 3) then
            cmp_proc <= '1';
            buf   := mul_out;
            buf32 := buf;
            slv32 := to_slv(buf32);
            out_left_V(22 downto 0)  <= slv32(22 downto 0);
            out_left_V(23) <= slv32(31);
            out_right_V(22 downto 0) <= slv32(22 downto 0);
            out_right_V(23) <= slv32(31);
            out_left_V_ap_vld  <= '1';
            out_right_V_ap_vld <= '1';
            ap_done <= '1';
        else
            cmp_proc <= '0';
            out_left_V_ap_vld  <= '0';
            out_right_V_ap_vld <= '0';
            ap_done <= '0';
        end if;
        clk := clk+1;
    end if;
 end process;

-- ----------------------------------------------------------------------------
-- instances
-- ----------------------------------------------------------------------------

ADD_instance: ADD
generic map (
    msb => 8,
    lsb => -23)
port map (
    in1 => mem_out,
    in2 => add_cst,
   out1 => add_out
);

MEM_instance: MEM
generic map (
    msb => 8,
    lsb => -23)
port map (
    clk => cmp_proc,
    rst => ap_rst_n,
    in1 => add_out,
   out1 => mem_out
);

FMOD_instance: FMOD
generic map (
    msb => 8,
    lsb => -23)
port map (
    in1 => add_out,
    in2 => mod_cst,
   out1 => mod_out
);

MUL_instance: MUL
generic map (
    msb => 8,
    lsb => -23)
port map (
    in1 => mod_out,
    in2 => mul_cst,
   out1 => mul_out
);

end logic;
