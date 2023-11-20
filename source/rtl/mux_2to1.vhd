------------------------------------------------------------------------------
-- Authors: POPOFF Maxime        
-- Begin Date: 05/2021

-------------------------------------------------------------------------
-- source: https://startingelectronics.org/software/VHDL-CPLD-course/tut4-multiplexers/
---------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2to1 is
    Port ( Sel : in  STD_LOGIC;
           inA   : in  STD_LOGIC;
           inB   : in  STD_LOGIC;
           outMux   : out STD_LOGIC);
end mux_2to1;

architecture Behavioral of mux_2to1 is
begin
    outMux <= inA when (Sel = '1') else inB;
end Behavioral;
