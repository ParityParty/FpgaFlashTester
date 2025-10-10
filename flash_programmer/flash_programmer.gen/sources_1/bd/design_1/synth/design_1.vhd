--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
--Date        : Fri Oct 10 14:25:28 2025
--Host        : volzotan running 64-bit Ubuntu 20.04.6 LTS
--Command     : generate_target design_1.bd
--Design      : design_1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1 is
  port (
    CLK25MHZ : in STD_LOGIC;
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
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_1 : entity is "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,da_board_cnt=16,da_clkrst_cnt=4,da_zynq_ultra_ps_e_cnt=1,synth_mode=None}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_1 : entity is "design_1.hwdef";
end design_1;

architecture STRUCTURE of design_1 is
  component design_1_flash_programmer_0_0 is
  port (
    led_light : out STD_LOGIC;
    i_clock : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    o_activate : out STD_LOGIC;
    o_cmd : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_address : out STD_LOGIC_VECTOR ( 39 downto 0 );
    o_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    i_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_busy : in STD_LOGIC;
    i_read_done : in STD_LOGIC;
    o_TX_DV : out STD_LOGIC;
    o_TX_Data : out STD_LOGIC_VECTOR ( 55 downto 0 );
    o_TX_Num_Bytes : out STD_LOGIC_VECTOR ( 2 downto 0 );
    i_TX_Active : in STD_LOGIC
  );
  end component design_1_flash_programmer_0_0;
  component design_1_UART_TX_0_0 is
  port (
    i_reset : in STD_LOGIC;
    i_Clk : in STD_LOGIC;
    i_TX_DV : in STD_LOGIC;
    i_TX_Data : in STD_LOGIC_VECTOR ( 55 downto 0 );
    i_TX_Num_Bytes : in STD_LOGIC_VECTOR ( 2 downto 0 );
    o_TX_Active : out STD_LOGIC;
    o_TX_Serial : out STD_LOGIC
  );
  end component design_1_UART_TX_0_0;
  component design_1_clk_wiz_0_0 is
  port (
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component design_1_clk_wiz_0_0;
  component design_1_nand_controller_0_0 is
  port (
    i_clk : in STD_LOGIC;
    i_rst : in STD_LOGIC;
    i_activate : in STD_LOGIC;
    i_cmd : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_address : in STD_LOGIC_VECTOR ( 39 downto 0 );
    i_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    o_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_busy : out STD_LOGIC;
    o_read_done : out STD_LOGIC;
    i_nand_rb : in STD_LOGIC;
    o_nand_we : out STD_LOGIC;
    o_nand_wp : out STD_LOGIC;
    o_nand_cle : out STD_LOGIC;
    o_nand_ale : out STD_LOGIC;
    o_nand_re : out STD_LOGIC;
    io_nand_data : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    o_nand_ce : out STD_LOGIC
  );
  end component design_1_nand_controller_0_0;
  signal UART_TX_0_o_TX_Active : STD_LOGIC;
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal clk_wiz_0_locked : STD_LOGIC;
  signal flash_programmer_0_i_TX_DV : STD_LOGIC;
  signal flash_programmer_0_o_TX_Data : STD_LOGIC_VECTOR ( 55 downto 0 );
  signal flash_programmer_0_o_TX_Num_Bytes : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal flash_programmer_0_o_activate : STD_LOGIC;
  signal flash_programmer_0_o_address : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal flash_programmer_0_o_cmd : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal flash_programmer_0_o_data : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal nand_controller_0_o_busy : STD_LOGIC;
  signal nand_controller_0_o_data : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal nand_controller_0_o_read_done : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of CLK25MHZ : signal is "xilinx.com:signal:clock:1.0 CLK.CLK25MHZ CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of CLK25MHZ : signal is "XIL_INTERFACENAME CLK.CLK25MHZ, CLK_DOMAIN design_1_CLK25MHZ, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of nand_data : signal is "xilinx.com:signal:data:1.0 DATA.NAND_DATA DATA";
  attribute X_INTERFACE_PARAMETER of nand_data : signal is "XIL_INTERFACENAME DATA.NAND_DATA, LAYERED_METADATA undef";
begin
UART_TX_0: component design_1_UART_TX_0_0
     port map (
      i_Clk => clk_wiz_0_clk_out1,
      i_TX_DV => flash_programmer_0_i_TX_DV,
      i_TX_Data(55 downto 0) => flash_programmer_0_o_TX_Data(55 downto 0),
      i_TX_Num_Bytes(2 downto 0) => flash_programmer_0_o_TX_Num_Bytes(2 downto 0),
      i_reset => clk_wiz_0_locked,
      o_TX_Active => UART_TX_0_o_TX_Active,
      o_TX_Serial => uart_tx
    );
clk_wiz_0: component design_1_clk_wiz_0_0
     port map (
      clk_in1 => CLK25MHZ,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => clk_wiz_0_locked
    );
flash_programmer_0: component design_1_flash_programmer_0_0
     port map (
      i_TX_Active => UART_TX_0_o_TX_Active,
      i_busy => nand_controller_0_o_busy,
      i_clock => clk_wiz_0_clk_out1,
      i_data(7 downto 0) => nand_controller_0_o_data(7 downto 0),
      i_read_done => nand_controller_0_o_read_done,
      i_reset => clk_wiz_0_locked,
      led_light => led_light,
      o_TX_DV => flash_programmer_0_i_TX_DV,
      o_TX_Data(55 downto 0) => flash_programmer_0_o_TX_Data(55 downto 0),
      o_TX_Num_Bytes(2 downto 0) => flash_programmer_0_o_TX_Num_Bytes(2 downto 0),
      o_activate => flash_programmer_0_o_activate,
      o_address(39 downto 0) => flash_programmer_0_o_address(39 downto 0),
      o_cmd(7 downto 0) => flash_programmer_0_o_cmd(7 downto 0),
      o_data(7 downto 0) => flash_programmer_0_o_data(7 downto 0)
    );
nand_controller_0: component design_1_nand_controller_0_0
     port map (
      i_activate => flash_programmer_0_o_activate,
      i_address(39 downto 0) => flash_programmer_0_o_address(39 downto 0),
      i_clk => clk_wiz_0_clk_out1,
      i_cmd(7 downto 0) => flash_programmer_0_o_cmd(7 downto 0),
      i_data(7 downto 0) => flash_programmer_0_o_data(7 downto 0),
      i_nand_rb => nand_rb,
      i_rst => clk_wiz_0_locked,
      io_nand_data(7 downto 0) => nand_data(7 downto 0),
      o_busy => nand_controller_0_o_busy,
      o_data(7 downto 0) => nand_controller_0_o_data(7 downto 0),
      o_nand_ale => nand_ale,
      o_nand_ce => nand_ce,
      o_nand_cle => nand_cle,
      o_nand_re => nand_re,
      o_nand_we => nand_we,
      o_nand_wp => nand_wp,
      o_read_done => nand_controller_0_o_read_done
    );
end STRUCTURE;
