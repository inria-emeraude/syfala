----------------------------------------------------------------------------------
-- Company:
-- Engineer: Jonas Hoepner
--
-- Create Date: 11/10/2023 10:29:01 AM
-- Design Name:
-- Module Name: sd_dac_fifth_fixed - dac_arch_fifth_fixed
-- Project Name: Sigma Delta DAC 5th Order CIFB
--
-- Dependencies: fixed_pkg_c of syfala
--
-- Revision:
-- Revision 1.10 optimisations
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.fixed_pkg.all;
use work.fixed_float_types.ALL;

entity sd_dac_fifth_fixed is

    generic (
        input_bitwidth : integer := 24
    );
    Port ( sd_input  :   in std_logic_vector(input_bitwidth - 1 downto 0) := (others => '0');
           sd_clk    :   in std_logic := '0';
           samp_clk  :   in std_logic := '0';
           sd_output :   out std_logic := '0');
end sd_dac_fifth_fixed;

architecture dac_arch_fifth_fixed of sd_dac_fifth_fixed is
    signal g_1     : sfixed(0 downto -33) := (others => '0');
    signal g_2     : sfixed(0 downto -33) := (others => '0');

    -- constants for a 'CIFB' 5th order DAC with OSR of 1024, 49.152MHZ clk
    constant b1             : sfixed(0 downto -16) := to_sfixed(0.000655501301393187, 0, -16); -- -10 bits unused, this could be optimised!
    constant b2             : sfixed(0 downto -16) := to_sfixed(0.0101777746397065, 0, -16); -- -7 bits unused
    constant b3             : sfixed(0 downto -16) := to_sfixed(0.0739355371404687, 0, -16); -- -4 bits unused
    constant b4             : sfixed(0 downto -16) := to_sfixed(0.316537146899132, 0, -16); -- -2 bits unused
    constant b5             : sfixed(0 downto -16) := to_sfixed(0.807690880911927, 0, -16); -- -1 bits unused

    signal a1               : sfixed(0 downto -16) := (others => '0');
    signal a2               : sfixed(0 downto -16) := (others => '0');
    signal a3               : sfixed(0 downto -16) := (others => '0');
    signal a4               : sfixed(0 downto -16) := (others => '0');
    signal a5               : sfixed(0 downto -16) := (others => '0');
    constant g1             : sfixed(-1 downto -17) := to_sfixed(2.7291119352847e-06, -1, -17); -- -7 bits unused
    constant g2             : sfixed(-1 downto -17) := to_sfixed(7.72907481397869e-06, -1, -17); -- -5 bits unused
    -- constants c are all 1, removed

    signal input_fixed      : sfixed(0 downto -(input_bitwidth-1)) := (others => '0');

begin
dac_proc_fifth_fixed: process(sd_clk)
    -- int* means integrator. These variables hold the values of the integrators of the SD loop
    variable int2    : sfixed(2 downto -31) := (others => '0');
    variable int3    : sfixed(4 downto -29) := (others => '0');
    variable int4    : sfixed(4 downto -29) := (others => '0');
    variable int5    : sfixed(6 downto -27) := (others => '0');
    variable int1    : sfixed(2 downto -31) := (others => '0');
    
    -- un* are the temp values while calculating the current output
    variable un3     : sfixed(4 downto -29) := (others => '0');
    variable un4     : sfixed(5 downto -28) := (others => '0');
    variable un5     : sfixed(6 downto -27) := (others => '0');
    variable un6     : sfixed(6 downto -27) := (others => '0');
    variable un2     : sfixed(2 downto -31) := (others => '0');
    variable un1     : sfixed(2 downto -31) := (others => '0');

    begin
        if rising_edge(sd_clk) then
           
            -- the SD loop. For algorithm see DSToolbox.pdf, Page 36, 'CIFB'
            un1 := resize(arg=>(input_fixed * b1), size_res=>un1, round_style=>fixed_truncate);
            un1 := resize(arg=>(un1 + a1), size_res=>un1, round_style=>fixed_truncate);
            int1 := resize(arg=>(int1 + un1), size_res=>int1, round_style=>fixed_truncate);
            un1 := int1;-- * c1;
            
            un2 := resize(arg=>(input_fixed * b2), size_res=>un2, round_style=>fixed_truncate);
            un2 := resize(arg=>(un2 + a2 - g_1 + un1), size_res=>un2, round_style=>fixed_truncate);
            int2 := resize(arg=>(int2 + un2), size_res=>int2, round_style=>fixed_truncate);
            un2 := int2;-- * c2;

            un3  := resize(arg=>(input_fixed * b3), size_res=>un3, round_style=>fixed_truncate);
            un3 := resize(arg=>(un3 + a3), size_res=>un3, round_style=>fixed_truncate);
            int3 := resize(arg=>(int3 + un3), size_res=>int3, round_style=>fixed_truncate);
            g_1 <= resize(arg=>(int3 * g1), size_res=>g_1, round_style=>fixed_truncate);
            un3  := int3;-- * c3;

            un4 := resize(arg=>(input_fixed * b4), size_res=>un4, round_style=>fixed_truncate);
            un4 := resize(arg=>(un4 + a4 - g_2 + un3), size_res=>un4, round_style=>fixed_truncate);
            int4 := resize(arg=>(int4 + un4), size_res=>int4, round_style=>fixed_truncate);
            un4 := int4;-- * c4;

            un5 := resize(arg=>(input_fixed * b5), size_res=>un5, round_style=>fixed_truncate);
            un5 := resize(arg=>(un5 + a5 + un4), size_res=>un5, round_style=>fixed_truncate);
            int5 := resize(arg=>(int5 + un5), size_res=>int5, round_style=>fixed_truncate);
            g_2 <= resize(arg=>(int5 * g2), size_res=>g_2, round_style=>fixed_truncate);
            un5 := int5;-- * c5;

            --                  input_fixed * b6 + un5, but b6 == 1, removed
            un6 := resize(arg=>(input_fixed + un5), size_res=>un6, round_style=>fixed_truncate);

            -- calculate comparator output and feedback values
            if (un6 < 0) then
                sd_output <= '0';
                
                -- removing multiplication by setting a1 depending on the output.
                -- if b will be optimised concerning the wordlength, the commented out code below works
                a1 <= b1;
                a2 <= b2;
                a3 <= b3;
                a4 <= b4;
                a5 <= b5;
                --a1 := resize(arg=>(b1), size_res=>a1, round_style=>fixed_truncate);
                --a2 := resize(arg=>(b2), size_res=>a2, round_style=>fixed_truncate);
                --a3 := resize(arg=>(b3), size_res=>a3, round_style=>fixed_truncate);
                --a4 := resize(arg=>(b4), size_res=>a4, round_style=>fixed_truncate);
                --a5 := resize(arg=>(b5), size_res=>a5, round_style=>fixed_truncate);

            else
                sd_output <= '1';
                
                a1 <= resize(arg=>(-b1), size_res=>a1, round_style=>fixed_truncate);
                a2 <= resize(arg=>(-b2), size_res=>a2, round_style=>fixed_truncate);
                a3 <= resize(arg=>(-b3), size_res=>a3, round_style=>fixed_truncate);
                a4 <= resize(arg=>(-b4), size_res=>a4, round_style=>fixed_truncate);
                a5 <= resize(arg=>(-b5), size_res=>a5, round_style=>fixed_truncate);
            end if;
        end if;
    end process;
    
    dac_proc_fifth_latch: process(samp_clk)
    begin
        if rising_edge(samp_clk) then
            -- sd_input and input_fixed have the same input format.
            --  Example: By rewriting the 2-complement signed 16 bit integer in
            --  a 0 downto -15 sfixed we divide by intmax without actually dividing.
            input_fixed <= to_sfixed(sd_input, 0, -(input_bitwidth-1)); -- Future Work: limit maximum amplitude to 0.5 here
        end if;
    end process;

end dac_arch_fifth_fixed;
