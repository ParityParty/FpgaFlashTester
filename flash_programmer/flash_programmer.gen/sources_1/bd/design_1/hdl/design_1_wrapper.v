//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Wed Sep 17 12:53:17 2025
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
    nand_cle,
    nand_data,
    nand_nce,
    nand_nre,
    nand_nwe,
    nand_nwp,
    nand_rnb,
    uart_tx);
  input CLK25MHZ;
  output debug;
  output led_light;
  output nand_ale;
  output nand_cle;
  inout [15:0]nand_data;
  output nand_nce;
  output nand_nre;
  output nand_nwe;
  output nand_nwp;
  input nand_rnb;
  output uart_tx;

  wire CLK25MHZ;
  wire debug;
  wire led_light;
  wire nand_ale;
  wire nand_cle;
  wire [15:0]nand_data;
  wire nand_nce;
  wire nand_nre;
  wire nand_nwe;
  wire nand_nwp;
  wire nand_rnb;
  wire uart_tx;

  design_1 design_1_i
       (.CLK25MHZ(CLK25MHZ),
        .debug(debug),
        .led_light(led_light),
        .nand_ale(nand_ale),
        .nand_cle(nand_cle),
        .nand_data(nand_data),
        .nand_nce(nand_nce),
        .nand_nre(nand_nre),
        .nand_nwe(nand_nwe),
        .nand_nwp(nand_nwp),
        .nand_rnb(nand_rnb),
        .uart_tx(uart_tx));
endmodule
