// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Thu Sep 11 10:55:01 2025
// Host        : agata running 64-bit Ubuntu 24.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/agata/FpgaFlashTester/flash_programmer/flash_programmer.gen/sources_1/bd/design_1/ip/design_1_flash_programmer_0_0_1/design_1_flash_programmer_0_0_stub.v
// Design      : design_1_flash_programmer_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "design_1_flash_programmer_0_0,flash_programmer,{}" *) (* CORE_GENERATION_INFO = "design_1_flash_programmer_0_0,flash_programmer,{x_ipProduct=Vivado 2025.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=flash_programmer,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,MAX_COUNT=25000,DELAY_MAX_COUNT=25000000,PAGE_SIZE=8640,PAGES_IN_BLOCK=128,BLOCKS_TO_TEST=64}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) 
(* IP_DEFINITION_SOURCE = "module_ref" *) (* X_CORE_INFO = "flash_programmer,Vivado 2025.1" *) 
module design_1_flash_programmer_0_0(led_light, i_clock, uart_tx, debug, i_reset, 
  nand_cle, nand_ale, nand_nwe, nand_nwp, nand_nce, nand_nre, nand_rnb, nand_data)
/* synthesis syn_black_box black_box_pad_pin="led_light,uart_tx,debug,i_reset,nand_cle,nand_ale,nand_nwe,nand_nwp,nand_nce,nand_nre,nand_rnb,nand_data[15:0]" */
/* synthesis syn_force_seq_prim="i_clock" */;
  output led_light;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 i_clock CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME i_clock, ASSOCIATED_RESET i_reset, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_clk_wiz_0_0_clk_out, INSERT_VIP 0" *) input i_clock /* synthesis syn_isclock = 1 */;
  output uart_tx;
  output debug;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 i_reset RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME i_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input i_reset;
  output nand_cle;
  output nand_ale;
  output nand_nwe;
  output nand_nwp;
  output nand_nce;
  output nand_nre;
  input nand_rnb;
  inout [15:0]nand_data;
endmodule
