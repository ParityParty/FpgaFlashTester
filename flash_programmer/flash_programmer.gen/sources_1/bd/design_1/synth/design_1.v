//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Tue Sep 30 11:52:19 2025
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
    nand_ce,
    nand_cle,
    nand_data,
    nand_rb,
    nand_re,
    nand_we,
    nand_wp,
    uart_tx);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK25MHZ CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK25MHZ, CLK_DOMAIN design_1_CLK25MHZ, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input CLK25MHZ;
  output debug;
  output led_light;
  output nand_ale;
  output [0:0]nand_ce;
  output nand_cle;
  inout [7:0]nand_data;
  input nand_rb;
  output nand_re;
  output nand_we;
  output nand_wp;
  output uart_tx;

  wire CLK25MHZ;
  wire UART_TX_0_o_TX_Active;
  wire UART_TX_0_o_TX_Done;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_locked;
  wire [7:0]flash_programmer_0_i_TX_Byte;
  wire flash_programmer_0_i_TX_DV;
  wire flash_programmer_0_o_activate;
  wire [39:0]flash_programmer_0_o_address;
  wire [7:0]flash_programmer_0_o_cmd;
  wire [7:0]flash_programmer_0_o_data;
  wire led_light;
  wire nand_ale;
  wire [0:0]nand_ce;
  wire nand_cle;
  wire nand_controller_0_o_busy;
  wire [7:0]nand_controller_0_o_data;
  wire nand_controller_0_o_read_done;
  wire [7:0]nand_data;
  wire nand_rb;
  wire nand_re;
  wire nand_we;
  wire nand_wp;
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
       (.i_TX_Active(UART_TX_0_o_TX_Active),
        .i_TX_Done(UART_TX_0_o_TX_Done),
        .i_busy(nand_controller_0_o_busy),
        .i_clock(clk_wiz_0_clk_out1),
        .i_data(nand_controller_0_o_data),
        .i_read_done(nand_controller_0_o_read_done),
        .i_reset(clk_wiz_0_locked),
        .led_light(led_light),
        .o_TX_Byte(flash_programmer_0_i_TX_Byte),
        .o_TX_DV(flash_programmer_0_i_TX_DV),
        .o_activate(flash_programmer_0_o_activate),
        .o_address(flash_programmer_0_o_address),
        .o_cmd(flash_programmer_0_o_cmd),
        .o_data(flash_programmer_0_o_data),
        .o_nand_nce(nand_ce));
  design_1_nand_controller_0_0 nand_controller_0
       (.i_activate(flash_programmer_0_o_activate),
        .i_address(flash_programmer_0_o_address),
        .i_clk(clk_wiz_0_clk_out1),
        .i_cmd(flash_programmer_0_o_cmd),
        .i_data(flash_programmer_0_o_data),
        .i_nand_rb(nand_rb),
        .i_rst(clk_wiz_0_locked),
        .io_nand_data(nand_data),
        .o_busy(nand_controller_0_o_busy),
        .o_data(nand_controller_0_o_data),
        .o_nand_ale(nand_ale),
        .o_nand_cle(nand_cle),
        .o_nand_re(nand_re),
        .o_nand_we(nand_we),
        .o_nand_wp(nand_wp),
        .o_read_done(nand_controller_0_o_read_done));
endmodule
