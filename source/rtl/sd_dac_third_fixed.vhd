----------------------------------------------------------------------------------
-- Company:
-- Engineer: Jonas Hoepner
--
-- Create Date: 11/10/2023 10:29:01 AM
-- Design Name:
-- Module Name: sd_dac_third_fixed - dac_arch_third_fixed
-- Project Name: Sigma Delta DAC 3rd Order CIFB
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies: fixed_pkg_c of syfala
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.fixed_pkg.all;
use work.fixed_float_types.ALL;


entity sd_dac_third_fixed is
    generic (
        input_bitwidth : integer := 24
    );
    Port ( sd_input  : in std_logic_vector (input_bitwidth-1 downto 0) := (others => '0');
           sd_clk  : in  std_logic := '0';
           samp_clk : in std_logic := '0';
           sd_output  : out std_logic := '0');
end sd_dac_third_fixed;

architecture dac_arch_third_fixed of sd_dac_third_fixed is
    
    -- constants for a 'CIFB' 3rd order DAC with OSR of 56
    constant b1             : sfixed(0 downto -30) := to_sfixed(0.0449411368199289, 0,-30);
    constant b2             : sfixed(0 downto -30) := to_sfixed(0.279027823027399, b1);
    constant b3             : sfixed(0 downto -30) := to_sfixed(0.806278941184786, b1);
    --constant b4             : integer := 1;
    signal a1               : sfixed(0 downto -30) := (others => '0'); -- the ax need a sign bit
    signal a2               : sfixed(0 downto -30) := to_sfixed(0, a1);
    signal a3               : sfixed(0 downto -30) := to_sfixed(0, a1);
    constant g              : sfixed(0 downto -30) := to_sfixed(0.0135818037697094, b1);
    --constant c1             : integer := 1;
    --constant c2             : integer := 1;
    --constant c3             : integer := 1;

    signal input_fixed      : sfixed(0 downto -(input_bitwidth-1)) := (others => '0');

begin dac_proc_third_fixed: process(sd_clk)
    -- int* means integrator
    variable int1             : sfixed(4 downto -30) := (others => '0');
    variable int2             : sfixed(4 downto -30) := (others => '0');
    variable int3             : sfixed(4 downto -30) := (others => '0');
    variable g1               : sfixed(4 downto -30) := (others => '0');

    -- un* are the temp values while calculating the current output
    variable un1              : sfixed(4 downto -30) := (others => '0');
    variable un2              : sfixed(4 downto -30) := (others => '0');
    variable un3              : sfixed(4 downto -30) := (others => '0');
    variable un4              : sfixed(4 downto -30) := (others => '0');

    begin
        if rising_edge(sd_clk) then
            -- for algorithm see DSToolbox.pdf page 36, CIFB Structure Odd Order
            un1  := resize(arg=>(input_fixed * b1), size_res=>un1, round_style=>fixed_truncate);
            un1 := resize(arg=>(un1 + a1), size_res=>un1, round_style=>fixed_truncate);
            int1 := resize(arg=>(int1 + un1), size_res=>int1, round_style=>fixed_truncate);
            un1  := int1;-- * c1;

            un2 := resize(arg=>(input_fixed * b2), size_res=>un2, round_style=>fixed_truncate);
            un2 := resize(arg=>(un2 - g1 + un1 + a2), size_res=>un2, round_style=>fixed_truncate);
            int2 := resize(arg=>(int2 + un2), size_res=>int2, round_style=>fixed_truncate);
            un2 := int2;-- * c2;

            un3 := resize(arg=>(input_fixed * b3), size_res=>un3, round_style=>fixed_truncate);
            un3 := resize(arg=>(un3 + un2 + a3), size_res=>un3, round_style=>fixed_truncate);
            int3 := resize(arg=>(int3 + un3), size_res=>int3, round_style=>fixed_truncate);
            g1 := resize(arg=>(int3 * g), size_res=>g1, round_style=>fixed_truncate);
            un3 := int3;-- * c3;

            un4 := resize(arg=>(input_fixed + un3), size_res=>un4, round_style=>fixed_truncate); -- input_fixed * b4

            -- calculate comparator output and feedback values
            if (un4 < 0) then
                sd_output <= '0';
                
                a1 <= b1;
                a2 <= b2;
                a3 <= b3;
                --a1 := resize(arg=>(b1), size_res=>a1, round_style=>fixed_truncate);
               -- a2 := resize(arg=>(b2), size_res=>a2, round_style=>fixed_truncate);
                --a3 := resize(arg=>(b3), size_res=>a3, round_style=>fixed_truncate);

            else
                sd_output <= '1';

                a1 <= resize(arg=>(-b1), size_res=>a1, round_style=>fixed_truncate);
                a2 <= resize(arg=>(-b2), size_res=>a2, round_style=>fixed_truncate);
                a3 <= resize(arg=>(-b3), size_res=>a3, round_style=>fixed_truncate);
            end if;

        end if;
    end process;
    
    dac_proc_third_latch: process(samp_clk)
    begin
        if rising_edge(samp_clk) then
            -- sd_input and input_fixed have the same input format.
            --  Example: By rewriting the 2-complement signed 16 bit integer in
            --  a 0 downto -15 sfixed we divide by intmax without actually dividing.
            input_fixed <= to_sfixed(sd_input, 0, -(input_bitwidth-1));
        end if;
    end process;

end dac_arch_third_fixed;
