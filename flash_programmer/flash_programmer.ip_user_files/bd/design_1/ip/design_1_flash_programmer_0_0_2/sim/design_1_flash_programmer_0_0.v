// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:flash_programmer:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_flash_programmer_0_0 (
  led_light,
  i_clock,
  i_reset,
  data_out,
  data_in,
  busy,
  activate,
  cmd_in,
  nand_enable,
  i_TX_DV,
  i_TX_Byte,
  o_TX_Active,
  o_TX_Done,
  nand_nce
);

output wire led_light;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 i_clock CLK" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME i_clock, ASSOCIATED_RESET i_reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_clk_wiz_0_0_clk_out1, INSERT_VIP 0" *)
input wire i_clock;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 i_reset RST" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME i_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
input wire i_reset;
input wire [7 : 0] data_out;
output wire [7 : 0] data_in;
input wire busy;
output wire activate;
output wire [7 : 0] cmd_in;
output wire nand_enable;
output wire i_TX_DV;
output wire [7 : 0] i_TX_Byte;
input wire o_TX_Active;
input wire o_TX_Done;
output wire nand_nce;

  flash_programmer #(
    .MAX_COUNT(25000),
    .DELAY_MAX_COUNT(3),
    .PAGE_SIZE(8640),
    .PAGES_IN_BLOCK(128),
    .BLOCKS_TO_TEST(1024)
  ) inst (
    .led_light(led_light),
    .i_clock(i_clock),
    .i_reset(i_reset),
    .data_out(data_out),
    .data_in(data_in),
    .busy(busy),
    .activate(activate),
    .cmd_in(cmd_in),
    .nand_enable(nand_enable),
    .i_TX_DV(i_TX_DV),
    .i_TX_Byte(i_TX_Byte),
    .o_TX_Active(o_TX_Active),
    .o_TX_Done(o_TX_Done),
    .nand_nce(nand_nce)
  );
endmodule
