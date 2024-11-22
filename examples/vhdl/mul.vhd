
-- ======= ENTITIES =========
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.float_pkg.all;

entity MulReal8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in float(8 downto -23);
		data_in_1: in float(8 downto -23);
		data_out: out float(8 downto -23)
	);
end entity MulReal8_m23;

architecture Behavioral of MulReal8_m23 is
begin
	data_out <= data_in_0 * data_in_1;
end architecture Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.float_pkg.all;

entity RegisterSeriesReal8_m23 is
	generic (
		n: natural := 1
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in float(8 downto -23);
		data_out: out float(8 downto -23)
	);
end entity RegisterSeriesReal8_m23;

architecture Behavioral of RegisterSeriesReal8_m23 is
	type register_array is array(0 to n - 1) of float(8 downto -23);
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



-- ======= FAUST IP =========
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.fixed_float_types.all;
use work.float_pkg.all;
entity mydsp is
port (
	ws : in std_logic;
	ap_clk : in std_logic;
	ap_rst_n : in std_logic;
	ap_start : in std_logic;
	bypass_dsp : in std_logic;
	bypass_faust : in std_logic;
	ap_done : out std_logic;
	audio_in_0 : in std_logic_vector(23 downto 0);
	audio_in_1 : in std_logic_vector(23 downto 0);
	audio_out_0 : out std_logic_vector(23 downto 0);
	audio_out_ap_vld_0 : out std_logic
);
end mydsp;
architecture DSP of mydsp is

-- ======= SIGNALS ==========
signal MulReal8_m23_0 : float(8 downto -23) := to_float(0, 8, 23);
signal aud_in_0 : float (8 downto -23);
signal aud_in_1 : float (8 downto -23);
signal RegisterSeriesReal8_m23_0 : float(8 downto -23) := to_float(0, 8, 23);

signal aud_out_0 : std_logic_vector (31 downto 0);

signal registers_0 : float(8 downto -23);

-- ======= COMPONENTS =======
component MulReal8_m23 is
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in_0: in float(8 downto -23);
		data_in_1: in float(8 downto -23);
		data_out: out float(8 downto -23)
	);
end component MulReal8_m23;

component RegisterSeriesReal8_m23 is
	generic (
		n: natural := 1
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in float(8 downto -23);
		data_out: out float(8 downto -23)
	);
end component RegisterSeriesReal8_m23;



begin

-- ======= DATA FLOW EQUATIONS IN =======

aud_in_0 <= to_float ("00000000" & audio_in_0, 8, 23);

aud_in_1 <= to_float ("00000000" & audio_in_1, 8, 23);


-- ======= PORT MAPPINGS ====
pm_MulReal8_m23_0 : MulReal8_m23
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in_0 => aud_in_0,
		data_in_1 => aud_in_1,
		data_out => MulReal8_m23_0
	);

pm_RegisterSeriesReal8_m23_0 : RegisterSeriesReal8_m23
	generic map (n => 1)
	port map (
		clock => ap_clk,
		reset => ap_rst_n,
		data_in => MulReal8_m23_0,
		data_out => registers_0
	);

ap_done <= ap_start;
audio_out_ap_vld_0 <= ap_start;

-- ======= DATA FLOW EQUATIONS OUT =======
aud_out_0 <=  to_Std_Logic_Vector (registers_0);
audio_out_0 <=  aud_out_0(23 downto 0);


end DSP;