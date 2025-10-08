--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
--Date        : Wed Oct  8 15:26:41 2025
--Host        : volzotan running 64-bit Ubuntu 20.04.6 LTS
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    CLK25MHZ : in STD_LOGIC;
    debug : out STD_LOGIC;
    led_light : out STD_LOGIC;
    nand_ale : out STD_LOGIC;
    nand_ce : out STD_LOGIC;
    nand_cle : out STD_LOGIC;
    nand_data : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    nand_rb : in STD_LOGIC;
    nand_re : out STD_LOGIC;
    nand_we : out STD_LOGIC;
    nand_wp : out STD_LOGIC;
    uart_tx : out STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    nand_rb : in STD_LOGIC;
    nand_re : out STD_LOGIC;
    nand_ale : out STD_LOGIC;
    nand_wp : out STD_LOGIC;
    nand_we : out STD_LOGIC;
    nand_cle : out STD_LOGIC;
    debug : out STD_LOGIC;
    led_light : out STD_LOGIC;
    CLK25MHZ : in STD_LOGIC;
    uart_tx : out STD_LOGIC;
    nand_ce : out STD_LOGIC;
    nand_data : inout STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      CLK25MHZ => CLK25MHZ,
      debug => debug,
      led_light => led_light,
      nand_ale => nand_ale,
      nand_ce => nand_ce,
      nand_cle => nand_cle,
      nand_data(7 downto 0) => nand_data(7 downto 0),
      nand_rb => nand_rb,
      nand_re => nand_re,
      nand_we => nand_we,
      nand_wp => nand_wp,
      uart_tx => uart_tx
    );
end STRUCTURE;
