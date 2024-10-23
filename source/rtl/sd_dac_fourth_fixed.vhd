----------------------------------------------------------------------------------
-- Company:
-- Engineer: Jonas Hoepner
--
-- Create Date: 11/10/2023 10:29:01 AM
-- Design Name:
-- Module Name: sd_dac_fourth_fixed - dac_arch_fourth_fixed
-- Project Name: Sigma Delta DAC 3rd Order CIFB
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies: fixed_pkg_c of syfala
--
-- Revision:
-- Revision 1.00 working
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.fixed_pkg.all;
use work.fixed_float_types.all;


entity sd_dac_fourth_fixed is
    generic (
        input_bitwidth : integer := 24
    );  
    Port ( sd_input  : in std_logic_vector (input_bitwidth-1 downto 0) := (others => '0');
           sd_clk  : in  std_logic := '0';
           samp_clk : in  std_logic := '0';
           sd_output  : out std_logic := '0');
end sd_dac_fourth_fixed;

architecture dac_arch_fourth_fixed of sd_dac_fourth_fixed is
    

    -- constants for a 'CIFB' 4th order DAC with OSR of 40
    constant b1             : sfixed(0 downto -16) := to_sfixed(0.00558801725278081, 0, -16);
    constant b2             : sfixed(0 downto -16) := to_sfixed(0.064765192285358, b1);
    constant b3             : sfixed(0 downto -16) := to_sfixed(0.296312903546539 , b1);
    constant b4             : sfixed(0 downto -16) := to_sfixed(0.815080314644325, b1);

    signal a1      : sfixed(0 downto -16) := (others => '0'); --
    signal a2      : sfixed(0 downto -16) := to_sfixed(0, a1); --
    signal a3      : sfixed(0 downto -16) := to_sfixed(0, a1); --
    signal a4      : sfixed(0 downto -16) := to_sfixed(0, a1); --
    constant g1             : sfixed(-1 downto -17) := to_sfixed(0.00262609907035275, -1, -17);
    constant g2             : sfixed(-1 downto -17) := to_sfixed(0.0167680880462108, g1);
    
    signal g_1              : sfixed(0 downto -26) := (others => '0');
    signal g_2              : sfixed(0 downto -26) := (others => '0');
    --constant c1             : integer := 1;
    --constant c2             : integer := 1;
    --constant c3             : integer := 1;

    signal input_fixed      : sfixed(0 downto -(input_bitwidth-1)) := (others => '0');

begin dac_proc_fourth_fixed: process(sd_clk)
    -- int* means integrator
    variable int1             : sfixed(0 downto -26) := (others => '0');
    variable int2             : sfixed(0 downto -26) := (others => '0');
    variable int3             : sfixed(1 downto -25) := (others => '0');
    variable int4             : sfixed(3 downto -23) := (others => '0');


    -- un* are the temp values while calculating the current output
    variable un2              : sfixed(0 downto -26) := (others => '0');
    variable un3              : sfixed(1 downto -25) := (others => '0');
    variable un4              : sfixed(2 downto -24) := (others => '0');
    variable un5              : sfixed(4 downto -22) := (others => '0');
    variable un1              : sfixed(0 downto -26) := (others => '0');
    begin
        if rising_edge(sd_clk) then

            -- for algorithm see DSToolbox.pdf page 36, CIFB Structure Odd Order
            un1 := resize(arg=>(input_fixed * b1), size_res=>un1, round_style=>fixed_truncate);
            un1 := resize(arg=>(un1 + a1 - g_1), size_res=>un1, round_style=>fixed_truncate);
            int1 := resize(arg=>(int1 + un1), size_res=>int1, round_style=>fixed_truncate);
            un1 := int1;-- * c2;
            
            un2  := resize(arg=>(input_fixed * b2), size_res=>un2, round_style=>fixed_truncate);
            un2 := resize(arg=>(un2 + a2), size_res=>un2, round_style=>fixed_truncate);
            int2 := resize(arg=>(int2 + un2), size_res=>int2, round_style=>fixed_truncate);
            g_1 <= resize(arg=>(int2 * g1), size_res=>g_1, round_style=>fixed_truncate);
            un2  := int2;-- * c1;

            un3 := resize(arg=>(input_fixed * b3), size_res=>un3, round_style=>fixed_truncate);
            un3 := resize(arg=>(un3 + a3 - g_2 + un2), size_res=>un3, round_style=>fixed_truncate);
            int3 := resize(arg=>(int3 + un3), size_res=>int3, round_style=>fixed_truncate);
            un3 := int3;-- * c2;

            un4 := resize(arg=>(input_fixed * b4), size_res=>un4, round_style=>fixed_truncate);
            un4 := resize(arg=>(un4 + a4 + un3), size_res=>un4, round_style=>fixed_truncate);
            int4 := resize(arg=>(int4 + un4), size_res=>int4, round_style=>fixed_truncate);
            g_2 <= resize(arg=>(int4 * g2), size_res=>g_2, round_style=>fixed_truncate);
            un4 := int4;-- * c3;

            un5 := resize(arg=>(input_fixed + un4), size_res=>un5, round_style=>fixed_truncate); -- input_fixed * b5, but b5 == 1

            -- calculate comparator output and feedback values
            if (un5 < 0) then
                sd_output <= '0';
                
                a1 <= b1;
                a2 <= b2;
                a3 <= b3;
                a4 <= b4;
                --a1 := resize(arg=>(b1), size_res=>a1, round_style=>fixed_truncate);
                --a2 := resize(arg=>(b2), size_res=>a2, round_style=>fixed_truncate);
                --a3 := resize(arg=>(b3), size_res=>a3, round_style=>fixed_truncate);
                --a4 := resize(arg=>(b4), size_res=>a4, round_style=>fixed_truncate);

            else
                sd_output <= '1';

                a1 <= resize(arg=>(-b1), size_res=>a1, round_style=>fixed_truncate);
                a2 <= resize(arg=>(-b2), size_res=>a2, round_style=>fixed_truncate);
                a3 <= resize(arg=>(-b3), size_res=>a3, round_style=>fixed_truncate);
                a4 <= resize(arg=>(-b4), size_res=>a4, round_style=>fixed_truncate);
            end if;
        end if;
    end process;


dac_proc_fourth_latch: process(samp_clk)
    begin
        if rising_edge(samp_clk) then
            -- sd_input and input_fixed have the same input format.
            --  Example: By rewriting the 2-complement signed 16 bit integer in
            --  a 0 downto -15 sfixed we divide by intmax without actually dividing.
            input_fixed <= to_sfixed(sd_input, 0, -(input_bitwidth-1));
        end if;
    end process;
end dac_arch_fourth_fixed;
