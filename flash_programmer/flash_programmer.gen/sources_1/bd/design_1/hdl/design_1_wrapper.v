//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Tue Sep 30 17:04:12 2025
//Host        : volzotan running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (CLK25MHZ,
    debug,
    led_light,
    nand_ale,
    nand_ce,
    nand_cle,
    nand_data,
    nand_rb,
    nand_re,
    nand_we,
    nand_wp,
    uart_tx);
  input CLK25MHZ;
  output debug;
  output led_light;
  output nand_ale;
  output [1:0]nand_ce;
  output nand_cle;
  inout [7:0]nand_data;
  input nand_rb;
  output nand_re;
  output nand_we;
  output nand_wp;
  output uart_tx;

  wire CLK25MHZ;
  wire debug;
  wire led_light;
  wire nand_ale;
  wire [1:0]nand_ce;
  wire nand_cle;
  wire [7:0]nand_data;
  wire nand_rb;
  wire nand_re;
  wire nand_we;
  wire nand_wp;
  wire uart_tx;

  design_1 design_1_i
       (.CLK25MHZ(CLK25MHZ),
        .debug(debug),
        .led_light(led_light),
        .nand_ale(nand_ale),
        .nand_ce(nand_ce),
        .nand_cle(nand_cle),
        .nand_data(nand_data),
        .nand_rb(nand_rb),
        .nand_re(nand_re),
        .nand_we(nand_we),
        .nand_wp(nand_wp),
        .uart_tx(uart_tx));
endmodule
