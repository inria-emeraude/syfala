library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- to be able to use signed

entity sd_dac_first is
    Port (  sys_clk         : in  std_logic := '0';
            samp_clock      : in std_logic := '0';
            input           : in std_logic_vector (15 downto 0) := (others => '0');
            output          : out std_logic := '0');
end sd_dac_first;

architecture dac_arch of sd_dac_first is
    signal input_latched    : std_logic_vector (15 downto 0) := (others => '0');
    signal dac_accum        : signed(18 downto 0) := (others => '0');
    signal dac_feedback     : std_logic := '0';
    signal feedback_val     : signed(18 downto 0) := to_signed(32767,19);
    
begin dac_proc: process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if(samp_clock = '1') then
                input_latched <= input;
            end if;
            if dac_feedback = '1' then
                dac_accum <= dac_accum + signed(input_latched) - feedback_val;
            else
                dac_accum <= dac_accum + signed(input_latched) + feedback_val;
            end if;
            if dac_accum < 0 then
                output <= '0';
                dac_feedback <= '0';
            else
                output <= '1';
                dac_feedback <= '1';
            end if;
        end if;
    end process;
end dac_arch;
