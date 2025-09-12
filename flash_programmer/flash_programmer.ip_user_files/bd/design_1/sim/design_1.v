//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Fri Sep 12 15:21:16 2025
//Host        : volzotan running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,da_board_cnt=16,da_clkrst_cnt=4,da_zynq_ultra_ps_e_cnt=1,synth_mode=None}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
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
    nand_rnb);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK25MHZ CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK25MHZ, CLK_DOMAIN design_1_CLK25MHZ, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input CLK25MHZ;
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

  wire CLK25MHZ;
  wire debug;
  wire flash_programmer_0_activate;
  wire [7:0]flash_programmer_0_cmd_in;
  wire [7:0]flash_programmer_0_data_in;
  wire flash_programmer_0_nand_enable;
  wire flash_programmer_0_nand_reset;
  wire led_light;
  wire nand_ale;
  wire nand_cle;
  wire [15:0]nand_data;
  wire nand_master_0_busy;
  wire [7:0]nand_master_0_data_out;
  wire nand_nce;
  wire nand_nre;
  wire nand_nwe;
  wire nand_nwp;
  wire nand_rnb;

  design_1_flash_programmer_0_0 flash_programmer_0
       (.activate(flash_programmer_0_activate),
        .busy(nand_master_0_busy),
        .cmd_in(flash_programmer_0_cmd_in),
        .data_in(flash_programmer_0_data_in),
        .data_out(nand_master_0_data_out),
        .debug(debug),
        .i_clock(CLK25MHZ),
        .led_light(led_light),
        .nand_enable(flash_programmer_0_nand_enable),
        .nand_nce(nand_nce),
        .nand_reset(flash_programmer_0_nand_reset));
  design_1_nand_master_0_0 nand_master_0
       (.activate(flash_programmer_0_activate),
        .busy(nand_master_0_busy),
        .clk(CLK25MHZ),
        .cmd_in(flash_programmer_0_cmd_in),
        .data_in(flash_programmer_0_data_in),
        .data_out(nand_master_0_data_out),
        .enable(flash_programmer_0_nand_enable),
        .nand_ale(nand_ale),
        .nand_cle(nand_cle),
        .nand_data(nand_data),
        .nand_nre(nand_nre),
        .nand_nwe(nand_nwe),
        .nand_nwp(nand_nwp),
        .nand_rnb(nand_rnb),
        .nreset(flash_programmer_0_nand_reset));
endmodule
