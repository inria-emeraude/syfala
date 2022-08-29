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
  out_right_V           : out std_logic_vector(23 downto 0)
);
end FAUST;

architecture logic of FAUST is
begin
 process (ap_clk, ap_rst_n, ap_start)
    variable mem: integer := 0;
    variable clk: integer := 0;
 begin
    if (ap_rst_n = '0') then
    -- reset every port to 0
        mem                :=  0 ;
        clk                :=  0 ;
        ap_done            <= '0';
        out_left_V_ap_vld  <= '0';
        out_right_V_ap_vld <= '0';
        out_left_V  <= (others => '0');
        out_right_V <= (others => '0');
   -- on each clock (sys_clock) event
    elsif (ap_clk'event and ap_clk = '1') then
        if (ap_start = '1') then
            clk := 0;
        end if;
        if (clk = 1) then
            -- no need to buffer inputs here for this example
            -- directly process outputs
            mem := mem + 2000;
            if (mem = 200000) then
                mem := 0;
            end if;
        end if;
        clk := clk+1;
        if (clk >= 2) and (clk < 3) then
            out_left_V  <= std_logic_vector(to_signed(mem, out_left_V'length));
            out_right_V <= std_logic_vector(to_signed(mem, out_right_V'length));
            out_left_V_ap_vld  <= '1';
            out_right_V_ap_vld <= '1';
            ap_done <= '1';
        else
            out_left_V_ap_vld  <= '0';
            out_right_V_ap_vld <= '0';
            ap_done <= '0';
        end if;
    end if;
 end process;
end logic;
