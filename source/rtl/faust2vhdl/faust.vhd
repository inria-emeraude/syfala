-- ======= ENTITIES =========
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;

entity RegisterSeriesLogic is
	generic (
		n: natural := 5
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in std_logic;
		data_out: out std_logic
	);
end entity RegisterSeriesLogic;

architecture Behavioral of RegisterSeriesLogic is
	type register_array is array(0 to n - 1) of std_logic;
	signal registers: register_array := (others => '0');
begin
	process (clock, reset)
	begin
		if reset = '0' then
			registers <= (others => '0');
		elsif rising_edge(clock) then
			for i in n - 1 downto 1 loop
				registers(i) <= registers(i - 1);
			end loop;
			registers(0) <= data_in;
		end if;
	end process;
	data_out <= registers(n - 1);
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;

entity MulSFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end entity MulSFixed8_m23;

architecture Behavioral of MulSFixed8_m23 is
begin
	data_out <= resize ( data_in_0 * data_in_1 , 8, -23);
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
entity DelaySFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end entity DelaySFixed8_m23;

architecture Behavioral of DelaySFixed8_m23 is
begin
	data_out <= data_in_0;
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
entity OneSampleDelaySFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		write_enable: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end entity OneSampleDelaySFixed8_m23;

architecture Behavioral of OneSampleDelaySFixed8_m23 is
signal data : sfixed(8 downto -23);
begin
	process (clock, reset)
	begin
		if (reset = '0') then
			data <= to_sfixed(0, 8, -23);
		elsif (clock'event and clock = '1') then
			if (write_enable = '1') then
				data <= data_in_0;
			end if;
		end if;
	end process;
	data_out <= data;
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;

entity RemSFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end entity RemSFixed8_m23;

architecture Behavioral of RemSFixed8_m23 is
begin
	data_out <= resize ( data_in_0 mod data_in_1 , 8, -23);
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;

entity AddSFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end entity AddSFixed8_m23;

architecture Behavioral of AddSFixed8_m23 is
begin
	data_out <= resize ( data_in_0 + data_in_1 , 8, -23);
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;

entity RegisterSeriesSFixed8_m23 is
	generic (
		n: natural := 5
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end entity RegisterSeriesSFixed8_m23;

architecture Behavioral of RegisterSeriesSFixed8_m23 is
	type register_array is array(0 to n - 1) of sfixed(8 downto -23);
	signal registers: register_array := (others => (others => '0'));
begin
	process (clock, reset)
	begin
		if reset = '0' then
			registers <= (others => (others => '0'));
		elsif rising_edge(clock) then
			for i in n - 1 downto 1 loop
				registers(i) <= registers(i - 1);
			end loop;
			registers(0) <= data_in;
		end if;
	end process;
	data_out <= registers(n - 1);
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;

entity RegisterSeriesInteger is
	generic (
		n: natural := 1
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in integer;
		data_out: out integer
	);
end entity RegisterSeriesInteger;

architecture Behavioral of RegisterSeriesInteger is
	type register_array is array(0 to n - 1) of integer;
	signal registers: register_array := (others => 0);
begin
	process (clock, reset)
	begin
		if reset = '0' then
			registers <= (others => 0);
		elsif rising_edge(clock) then
			for i in n - 1 downto 1 loop
				registers(i) <= registers(i - 1);
			end loop;
			registers(0) <= data_in;
		end if;
	end process;
	data_out <= registers(n - 1);
end architecture Behavioral;



-- ======= FAUST IP =========
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.fixed_pkg.all;
entity mydsp is
port (
	ws : in std_logic;
	ap_clk : in std_logic;
	ap_rst_n : in std_logic;
	ap_start : in std_logic;
	bypass_dsp : in std_logic;
	bypass_faust : in std_logic;
	ap_done : out std_logic;
	audio_out_0 : out std_logic_vector(23 downto 0);
	audio_out_ap_vld_0 : out std_logic;
	audio_out_1 : out std_logic_vector(23 downto 0);
	audio_out_ap_vld_1 : out std_logic
);
end mydsp;
architecture DSP of mydsp is

-- ======= SIGNALS ==========
signal RegisterSeriesLogic_0 : std_logic := '0';
signal MulSFixed8_m23_0 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal constant_0 : sfixed(8 downto -23) := to_sfixed(0.125, 8, -23);
signal DelaySFixed8_m23_0 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal OneSampleDelaySFixed8_m23_0 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesLogic_1 : std_logic := '0';
signal RemSFixed8_m23_0 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal AddSFixed8_m23_0 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal DelaySFixed8_m23_1 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal constant_1 : integer := 1;
signal constant_2 : sfixed(8 downto -23) := to_sfixed(0.00916667, 8, -23);
signal constant_3 : sfixed(8 downto -23) := to_sfixed(1, 8, -23);
signal constant_4 : integer := 0;
signal RegisterSeriesSFixed8_m23_0 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesSFixed8_m23_1 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesSFixed8_m23_2 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesSFixed8_m23_3 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesSFixed8_m23_4 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesSFixed8_m23_5 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesInteger_0 : integer := 0;
signal RegisterSeriesSFixed8_m23_6 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesSFixed8_m23_7 : sfixed(8 downto -23) := to_sfixed(0, 8, -23);
signal RegisterSeriesInteger_1 : integer := 0;

signal registers_0 : std_logic;
signal registers_1 : std_logic;
signal registers_2 : sfixed(8 downto -23);
signal registers_3 : sfixed(8 downto -23);
signal registers_4 : sfixed(8 downto -23);
signal registers_5 : sfixed(8 downto -23);
signal registers_6 : sfixed(8 downto -23);
signal registers_7 : sfixed(8 downto -23);
signal registers_8 : integer;
signal registers_9 : sfixed(8 downto -23);
signal registers_10 : sfixed(8 downto -23);
signal registers_11 : integer;

signal aud_out_0 : std_logic_vector (31 downto 0);

signal aud_out_1 : std_logic_vector (31 downto 0);
signal converted_registers_11 : sfixed(8 downto -23) := to_sfixed(registers_11, 8, -23);
signal converted_registers_8 : sfixed(8 downto -23) := to_sfixed(registers_8, 8, -23);

-- ======= COMPONENTS =======
component RegisterSeriesLogic is
	generic (
		n: natural := 5
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in std_logic;
		data_out: out std_logic
	);
end component RegisterSeriesLogic;

component MulSFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end component MulSFixed8_m23;

component DelaySFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end component DelaySFixed8_m23;

component OneSampleDelaySFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		write_enable: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end component OneSampleDelaySFixed8_m23;

component RemSFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end component RemSFixed8_m23;

component AddSFixed8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in sfixed(8 downto -23);
		data_in_1: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end component AddSFixed8_m23;

component RegisterSeriesSFixed8_m23 is
	generic (
		n: natural := 5
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in sfixed(8 downto -23);
		data_out: out sfixed(8 downto -23)
	);
end component RegisterSeriesSFixed8_m23;

component RegisterSeriesInteger is
	generic (
		n: natural := 1
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in integer;
		data_out: out integer
	);
end component RegisterSeriesInteger;



begin

-- ======= DATA FLOW EQUATIONS IN =======

-- ======= PORT MAPPINGS ====
pm_OneSampleDelaySFixed8_m23_0 : OneSampleDelaySFixed8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		write_enable => registers_1,
		data_in_0 => RemSFixed8_m23_0,
		data_out => OneSampleDelaySFixed8_m23_0
	);

pm_DelaySFixed8_m23_0 : DelaySFixed8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in_0 => registers_5,
		data_in_1 => converted_registers_11,
		data_out => DelaySFixed8_m23_0
	);

pm_DelaySFixed8_m23_1 : DelaySFixed8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in_0 => registers_4,
		data_in_1 => converted_registers_8,
		data_out => DelaySFixed8_m23_1
	);

pm_AddSFixed8_m23_0 : AddSFixed8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in_0 => registers_7,
		data_in_1 => registers_9,
		data_out => AddSFixed8_m23_0
	);

pm_RemSFixed8_m23_0 : RemSFixed8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in_0 => registers_6,
		data_in_1 => registers_10,
		data_out => RemSFixed8_m23_0
	);

pm_MulSFixed8_m23_0 : MulSFixed8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in_0 => registers_2,
		data_in_1 => registers_3,
		data_out => MulSFixed8_m23_0
	);

pm_RegisterSeriesLogic_0 : RegisterSeriesLogic
	generic map (n => 8)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => ap_start,
		data_out => registers_0
	);

pm_RegisterSeriesLogic_1 : RegisterSeriesLogic
	generic map (n => 3)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => ap_start,
		data_out => registers_1
	);

pm_RegisterSeriesSFixed8_m23_0 : RegisterSeriesSFixed8_m23
	generic map (n => 5)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => constant_0,
		data_out => registers_2
	);

pm_RegisterSeriesSFixed8_m23_1 : RegisterSeriesSFixed8_m23
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => DelaySFixed8_m23_0,
		data_out => registers_3
	);

pm_RegisterSeriesSFixed8_m23_2 : RegisterSeriesSFixed8_m23
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => OneSampleDelaySFixed8_m23_0,
		data_out => registers_4
	);

pm_RegisterSeriesSFixed8_m23_3 : RegisterSeriesSFixed8_m23
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => RemSFixed8_m23_0,
		data_out => registers_5
	);

pm_RegisterSeriesSFixed8_m23_4 : RegisterSeriesSFixed8_m23
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => AddSFixed8_m23_0,
		data_out => registers_6
	);

pm_RegisterSeriesSFixed8_m23_5 : RegisterSeriesSFixed8_m23
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => DelaySFixed8_m23_1,
		data_out => registers_7
	);

pm_RegisterSeriesInteger_0 : RegisterSeriesInteger
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => constant_1,
		data_out => registers_8
	);

pm_RegisterSeriesSFixed8_m23_6 : RegisterSeriesSFixed8_m23
	generic map (n => 2)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => constant_2,
		data_out => registers_9
	);

pm_RegisterSeriesSFixed8_m23_7 : RegisterSeriesSFixed8_m23
	generic map (n => 3)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => constant_3,
		data_out => registers_10
	);

pm_RegisterSeriesInteger_1 : RegisterSeriesInteger
	generic map (n => 4)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => constant_4,
		data_out => registers_11
	);

ap_done <= registers_0;
audio_out_ap_vld_0 <= registers_0;
audio_out_ap_vld_1 <= registers_0;

-- ======= DATA FLOW EQUATIONS OUT =======
aud_out_0 <=  to_Std_Logic_Vector (MulSFixed8_m23_0);
audio_out_0 <=  aud_out_0(23 downto 0);
aud_out_1 <=  to_Std_Logic_Vector (MulSFixed8_m23_0);
audio_out_1 <=  aud_out_1(23 downto 0);

end DSP;
