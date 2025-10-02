-- (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- (c) Copyright 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:flash_programmer:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY design_1_flash_programmer_0_0 IS
  PORT (
    led_light : OUT STD_LOGIC;
    i_clock : IN STD_LOGIC;
    i_reset : IN STD_LOGIC;
    o_activate : OUT STD_LOGIC;
    o_cmd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    o_address : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    o_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    i_busy : IN STD_LOGIC;
    i_read_done : IN STD_LOGIC;
    i_command_received : IN STD_LOGIC;
    o_debug : OUT STD_LOGIC;
    o_TX_DV : OUT STD_LOGIC;
    o_TX_Data : OUT STD_LOGIC_VECTOR(55 DOWNTO 0);
    o_TX_Num_Bytes : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_TX_Active : IN STD_LOGIC
  );
END design_1_flash_programmer_0_0;

ARCHITECTURE design_1_flash_programmer_0_0_arch OF design_1_flash_programmer_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF design_1_flash_programmer_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT flash_programmer IS
    GENERIC (
      MAX_COUNT : INTEGER;
      DELAY_MAX_COUNT : INTEGER;
      PAGE_SIZE : INTEGER;
      PAGES_IN_BLOCK : INTEGER;
      BLOCKS_TO_TEST : INTEGER;
      MAX_FAULTS : INTEGER;
      UART_MAX_BYTES : INTEGER
    );
    PORT (
      led_light : OUT STD_LOGIC;
      i_clock : IN STD_LOGIC;
      i_reset : IN STD_LOGIC;
      o_activate : OUT STD_LOGIC;
      o_cmd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_address : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
      o_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      i_busy : IN STD_LOGIC;
      i_read_done : IN STD_LOGIC;
      i_command_received : IN STD_LOGIC;
      o_debug : OUT STD_LOGIC;
      o_TX_DV : OUT STD_LOGIC;
      o_TX_Data : OUT STD_LOGIC_VECTOR(55 DOWNTO 0);
      o_TX_Num_Bytes : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_TX_Active : IN STD_LOGIC
    );
  END COMPONENT flash_programmer;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_MODE : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF i_clock: SIGNAL IS "xilinx.com:signal:clock:1.0 i_clock CLK";
  ATTRIBUTE X_INTERFACE_MODE OF i_clock: SIGNAL IS "slave i_clock";
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_clock: SIGNAL IS "XIL_INTERFACENAME i_clock, ASSOCIATED_RESET i_reset, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_clk_wiz_0_0_clk_out1, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_reset: SIGNAL IS "xilinx.com:signal:reset:1.0 i_reset RST";
  ATTRIBUTE X_INTERFACE_MODE OF i_reset: SIGNAL IS "slave i_reset";
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_reset: SIGNAL IS "XIL_INTERFACENAME i_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0";
BEGIN
  U0 : flash_programmer
    GENERIC MAP (
      MAX_COUNT => 25000,
      DELAY_MAX_COUNT => 3,
      PAGE_SIZE => 8640,
      PAGES_IN_BLOCK => 128,
      BLOCKS_TO_TEST => 1024,
      MAX_FAULTS => 5,
      UART_MAX_BYTES => 7
    )
    PORT MAP (
      led_light => led_light,
      i_clock => i_clock,
      i_reset => i_reset,
      o_activate => o_activate,
      o_cmd => o_cmd,
      o_address => o_address,
      o_data => o_data,
      i_data => i_data,
      i_busy => i_busy,
      i_read_done => i_read_done,
      i_command_received => i_command_received,
      o_debug => o_debug,
      o_TX_DV => o_TX_DV,
      o_TX_Data => o_TX_Data,
      o_TX_Num_Bytes => o_TX_Num_Bytes,
      i_TX_Active => i_TX_Active
    );
END design_1_flash_programmer_0_0_arch;
