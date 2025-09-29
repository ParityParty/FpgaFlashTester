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


// IP VLNV: xilinx.com:module_ref:nand_controller:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_nand_controller_0_0 (
  i_clk,
  i_rst,
  i_activate,
  i_cmd,
  i_address,
  i_data,
  o_data,
  o_busy,
  o_read_done,
  i_nand_rb,
  o_nand_we,
  o_nand_wp,
  o_nand_cle,
  o_nand_ale,
  o_nand_re,
  io_nand_data
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 i_clk CLK" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME i_clk, ASSOCIATED_RESET i_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_clk_wiz_0_0_clk_out1, INSERT_VIP 0" *)
input wire i_clk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 i_rst RST" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME i_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
input wire i_rst;
input wire i_activate;
input wire [7 : 0] i_cmd;
input wire [39 : 0] i_address;
input wire [7 : 0] i_data;
output wire [7 : 0] o_data;
output wire o_busy;
output wire o_read_done;
input wire i_nand_rb;
output wire o_nand_we;
output wire o_nand_wp;
output wire o_nand_cle;
output wire o_nand_ale;
output wire o_nand_re;
inout wire [7 : 0] io_nand_data;

  nand_controller #(
    .PAGE_SIZE(8640)
  ) inst (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_activate(i_activate),
    .i_cmd(i_cmd),
    .i_address(i_address),
    .i_data(i_data),
    .o_data(o_data),
    .o_busy(o_busy),
    .o_read_done(o_read_done),
    .i_nand_rb(i_nand_rb),
    .o_nand_we(o_nand_we),
    .o_nand_wp(o_nand_wp),
    .o_nand_cle(o_nand_cle),
    .o_nand_ale(o_nand_ale),
    .o_nand_re(o_nand_re),
    .io_nand_data(io_nand_data)
  );
endmodule
