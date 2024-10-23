----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 01/30/2024 12:53:51 PM
-- Design Name:
-- Module Name: clock_divider - Behavioral
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



-- this is not a usual clock divider. Due to a suspected bug in the Faust IP (as long as sample clock is high,
--  the IP outputs samples as fast as possible), this only gives out a pulse when count = divide_by.
-- This also means, that no clock cycle is used to set the output to zero again, as this will happen automatically.
-- So to produce a 625kHz Clock from a 5 MHz input, a divider of 8 is used, not 4, to account for the behaviour of this code.




----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity clock_divider is
port ( clk,reset: in std_logic;
clock_out: out std_logic);
end Clock_Divider;

architecture bhv of clock_divider is

signal count: integer := 1;
signal tmp : std_logic := '0';
signal divide_by : unsigned(7 downto 0) := "00000100"; -- 8 --"10000010"; -- 130--
begin

    process(clk,reset)
    begin
        tmp <= '0';
        if(reset='1') then
            count<=1;
            tmp<='0';
        elsif(clk'event and clk='1') then
            count <=count+1;
            if (count = divide_by) then
                tmp <= NOT tmp;
                count <= 1;
            end if;
        end if;
        clock_out <= tmp;
    end process;

end bhv;
