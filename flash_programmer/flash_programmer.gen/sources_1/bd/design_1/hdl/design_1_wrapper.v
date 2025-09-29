//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Sat Sep 27 17:19:52 2025
//Host        : agata running 64-bit Ubuntu 24.04.3 LTS
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
    nand_cle,
    nand_data,
    nand_nce,
    nand_re,
    nand_rnb,
    nand_we,
    nand_wp,
    uart_tx);
  input CLK25MHZ;
  output debug;
  output led_light;
  output nand_ale;
  output nand_cle;
  inout [7:0]nand_data;
  output [0:0]nand_nce;
  output nand_re;
  input nand_rnb;
  output nand_we;
  output nand_wp;
  output uart_tx;

  wire CLK25MHZ;
  wire debug;
  wire led_light;
  wire nand_ale;
  wire nand_cle;
  wire [7:0]nand_data;
  wire [0:0]nand_nce;
  wire nand_re;
  wire nand_rnb;
  wire nand_we;
  wire nand_wp;
  wire uart_tx;

  design_1 design_1_i
       (.CLK25MHZ(CLK25MHZ),
        .debug(debug),
        .led_light(led_light),
        .nand_ale(nand_ale),
        .nand_cle(nand_cle),
        .nand_data(nand_data),
        .nand_nce(nand_nce),
        .nand_re(nand_re),
        .nand_rnb(nand_rnb),
        .nand_we(nand_we),
        .nand_wp(nand_wp),
        .uart_tx(uart_tx));
endmodule
