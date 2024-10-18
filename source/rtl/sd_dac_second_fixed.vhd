----------------------------------------------------------------------------------
-- Company:
-- Engineer: Jonas Hoepner
--
-- Create Date: 12/02/2023 11:15:59 AM
-- Design Name:
-- Module Name: sd_dac_second - dac_arch_second
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use work.fixed_pkg.ALL;
use work.fixed_float_types.all;

entity sd_dac_second_fixed is
    generic (
        input_bitwidth : integer := 24
    );
    Port ( sd_input     : in std_logic_vector (input_bitwidth-1 downto 0) := (others => '0');
           sd_output    : out STD_LOGIC := '0';
           samp_clk   : in STD_LOGIC := '0';
           sd_clk       : in STD_LOGIC := '0'
           );
end sd_dac_second_fixed;

architecture dac_arch_second_fixed of sd_dac_second_fixed is
   signal input_fixed      : sfixed(0 downto -(input_bitwidth-1)) := (others => '0');
    

    -- constants for 2nd order DAC with  OSR 117.64
    constant b1             : sfixed(0 downto -17) := to_sfixed(0.210409174948311, 0, -17);
    constant b2             : sfixed(0 downto -17) := to_sfixed(0.778176639580705, b1);
    --constant b3             : integer := 1;
    signal a1               : sfixed(0 downto -17) := to_sfixed(0, 0, -17); -- ax needs sign bit
    signal a2               : sfixed(0 downto -17) := to_sfixed(0, a1);
    
    constant g              : sfixed(0 downto -17) := to_sfixed(0.00756072435964338, b1);
    signal g1               : sfixed(4 downto -22) := to_sfixed(0, b1);
    --constant c1             : integer := 1;
    --constant c2             : integer := 1;
   

begin
dac_proc_second_fixed: process(sd_clk)
    variable int1    : sfixed(4 downto -22) := to_sfixed(0, 4, -22);
    variable int2    : sfixed(4 downto -22) := to_sfixed(0, int1);

    variable un1    : sfixed(4 downto -22) := to_sfixed(0, int1);
    variable un2    : sfixed(4 downto -22) := to_sfixed(0, int1);
    variable un3    : sfixed(4 downto -22) := to_sfixed(0, int1);
    begin
        if rising_edge(sd_clk) then
            un1 := resize(arg=>(input_fixed * b1 + a1 - g1), size_res=>un1, round_style=>fixed_truncate);
            int1 := resize(arg=>(int1 + un1), size_res=>un1, round_style=>fixed_truncate);
            un1 := int1;-- * c1;

            un2 := resize(arg=>(input_fixed * b2 + a2 + un1), size_res=>un2, round_style=>fixed_truncate);
            int2 := resize(arg=>(int2 + un2), size_res=>int2, round_style=>fixed_truncate);
            g1 <= resize(arg=>(int2 * g), size_res=>un2, round_style=>fixed_truncate);
            un2 := resize(arg=>(int2), size_res=>un2, round_style=>fixed_truncate);-- * c2;

            un3 := resize(arg=>(input_fixed + un2), size_res=>un3, round_style=>fixed_truncate); -- input_fixed  * b3

            -- calculate comparator output and feedback values
            if (un3 < 0) then
                sd_output <= '0';
                
                a1 <= b1;
                a2 <= b2;
                --a1 := resize(arg=>(b1), size_res=>a1, round_style=>fixed_truncate);
                --a2 := resize(arg=>(b2), size_res=>a2, round_style=>fixed_truncate);
            else
                sd_output <= '1';
                a1 <= resize(arg=>-(b1), size_res=>a1, round_style=>fixed_truncate);
                a2 <= resize(arg=>-(b2), size_res=>a2, round_style=>fixed_truncate);
            end if;

        end if;
    end process;

dac_proc_second_latch: process(samp_clk)
    begin
        if rising_edge(samp_clk) then
            -- sd_input and input_fixed have the same input format.
            --  Example: By rewriting the 2-complement signed 16 bit integer in
            --  a 0 downto -15 sfixed we divide by intmax without actually dividing.
            input_fixed <= to_sfixed(sd_input, 0, -(input_bitwidth-1));
        end if;
    end process;

end dac_arch_second_fixed;
