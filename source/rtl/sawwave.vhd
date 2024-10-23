----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2024 10:18:19 AM
-- Design Name: 
-- Module Name: sawwave - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- to be able to use signed

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sawwave is
    Port ( sys_clk : in STD_LOGIC;
           samp_clk : in STD_LOGIC;
           saw_out : out STD_LOGIC_VECTOR (7 downto 0));
end sawwave;

architecture Behavioral of sawwave is
    signal counter      : unsigned(7 downto 0) := (others => '0'); --std_logic_vector (15 downto 0) := (others => '0');
 
begin dac_proc: process(sys_clk, samp_clk)
    begin
        if rising_edge(samp_clk) then 
            counter <= counter + 1;
            saw_out <= std_logic_vector(counter);
            
        end if;

end process;
end Behavioral;
