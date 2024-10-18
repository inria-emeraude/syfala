library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- to be able to use signed
use work.fixed_pkg.ALL;
use work.fixed_float_types.fixed_truncate;

entity sd_dac_first_fixed is
    Port (  sys_clk         : in  std_logic := '0';
            sd_clk          : in std_logic := '0';
            samp_clk      : in std_logic := '0';
            sd_input        : in std_logic_vector (15 downto 0) := (others => '0');
            sd_output       : out std_logic := '0');
end sd_dac_first_fixed;

architecture dac_arch_fixed of sd_dac_first_fixed is
    signal dac_accum        : sfixed(3 downto -12) := (others => '0');
    signal input_fixed      : sfixed(3 downto -12) := (others => '0');
    signal dac_feedback     : std_logic := '0';
    constant max            : sfixed(15 downto 0) := to_sfixed(32767, 15, 0);

begin dac_proc: process(sys_clk, sd_clk)
    begin
        if rising_edge(sd_clk) then
            if dac_feedback = '1' then
                dac_accum <= resize(arg=>(dac_accum + input_fixed - 1), size_res=>dac_accum, round_style=>fixed_truncate);
            else
                dac_accum <= resize(arg=>(dac_accum + input_fixed + 1), size_res=>dac_accum, round_style=>fixed_truncate);
            end if;
            if dac_accum < 0 then
                sd_output <= '0';
                dac_feedback <= '0';
            else
                sd_output <= '1';
                dac_feedback <= '1';
            end if;
        end if;
    end process;


dac_proc_first_latch: process(samp_clk)
    begin
        if rising_edge(samp_clk) then
            input_fixed <= resize(arg=>(to_sfixed(signed(sd_input), max) / max), size_res=>input_fixed, round_style=>fixed_truncate);
        end if;
    end process;
end dac_arch_fixed;
