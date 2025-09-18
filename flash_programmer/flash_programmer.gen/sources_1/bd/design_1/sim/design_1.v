//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Thu Sep 18 15:31:02 2025
//Host        : volzotan running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,da_board_cnt=16,da_clkrst_cnt=4,da_zynq_ultra_ps_e_cnt=1,synth_mode=None}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK25MHZ CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK25MHZ, CLK_DOMAIN design_1_CLK25MHZ, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input CLK25MHZ;
  output debug;
  output led_light;
  output nand_ale;
  output nand_cle;
  inout [15:0]nand_data;
  output [0:0]nand_nce;
  output nand_nre;
  output nand_nwe;
  output nand_nwp;
  input nand_rnb;
  output uart_tx;

  wire CLK25MHZ;
  wire UART_TX_0_o_TX_Active;
  wire UART_TX_0_o_TX_Done;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_locked;
  wire debug;
  wire flash_programmer_0_activate;
  wire [7:0]flash_programmer_0_cmd_in;
  wire [7:0]flash_programmer_0_data_in;
  wire [7:0]flash_programmer_0_i_TX_Byte;
  wire flash_programmer_0_i_TX_DV;
  wire flash_programmer_0_nand_enable;
  wire led_light;
  wire nand_ale;
  wire nand_cle;
  wire [15:0]nand_data;
  wire nand_master_0_busy;
  wire [7:0]nand_master_0_data_out;
  wire [0:0]nand_nce;
  wire nand_nre;
  wire nand_nwe;
  wire nand_nwp;
  wire nand_rnb;
  wire uart_tx;

  design_1_UART_TX_0_0 UART_TX_0
       (.i_Clk(clk_wiz_0_clk_out1),
        .i_TX_Byte(flash_programmer_0_i_TX_Byte),
        .i_TX_DV(flash_programmer_0_i_TX_DV),
        .i_reset(clk_wiz_0_locked),
        .o_TX_Active(UART_TX_0_o_TX_Active),
        .o_TX_Done(UART_TX_0_o_TX_Done),
        .o_TX_Serial(uart_tx));
  design_1_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(CLK25MHZ),
        .clk_out1(clk_wiz_0_clk_out1),
        .locked(clk_wiz_0_locked));
  design_1_flash_programmer_0_0 flash_programmer_0
       (.activate(flash_programmer_0_activate),
        .busy(nand_master_0_busy),
        .cmd_in(flash_programmer_0_cmd_in),
        .data_in(flash_programmer_0_data_in),
        .data_out(nand_master_0_data_out),
        .i_TX_Byte(flash_programmer_0_i_TX_Byte),
        .i_TX_DV(flash_programmer_0_i_TX_DV),
        .i_clock(clk_wiz_0_clk_out1),
        .i_reset(clk_wiz_0_locked),
        .led_light(led_light),
        .nand_enable(flash_programmer_0_nand_enable),
        .nand_nce(nand_nce),
        .o_TX_Active(UART_TX_0_o_TX_Active),
        .o_TX_Done(UART_TX_0_o_TX_Done));
  design_1_nand_master_0_0 nand_master_0
       (.activate(flash_programmer_0_activate),
        .busy(nand_master_0_busy),
        .clk(clk_wiz_0_clk_out1),
        .cmd_in(flash_programmer_0_cmd_in),
        .data_in(flash_programmer_0_data_in),
        .data_out(nand_master_0_data_out),
        .debug(debug),
        .enable(flash_programmer_0_nand_enable),
        .nand_ale(nand_ale),
        .nand_cle(nand_cle),
        .nand_data(nand_data),
        .nand_nre(nand_nre),
        .nand_nwe(nand_nwe),
        .nand_nwp(nand_nwp),
        .nand_rnb(nand_rnb),
        .nreset(clk_wiz_0_locked));
endmodule
