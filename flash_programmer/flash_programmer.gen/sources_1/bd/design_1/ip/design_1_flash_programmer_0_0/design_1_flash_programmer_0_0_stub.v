// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Thu Sep  4 14:08:24 2025
// Host        : agata running 64-bit Ubuntu 24.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/agata/FpgaFlashTester/flash_programmer/flash_programmer.gen/sources_1/bd/design_1/ip/design_1_flash_programmer_0_0/design_1_flash_programmer_0_0_stub.v
// Design      : design_1_flash_programmer_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "design_1_flash_programmer_0_0,flash_programmer,{}" *) (* CORE_GENERATION_INFO = "design_1_flash_programmer_0_0,flash_programmer,{x_ipProduct=Vivado 2025.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=flash_programmer,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,MAX_COUNT=25000000}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) 
(* IP_DEFINITION_SOURCE = "module_ref" *) (* X_CORE_INFO = "flash_programmer,Vivado 2025.1" *) 
module design_1_flash_programmer_0_0(led_light, CLK25MHZ)
/* synthesis syn_black_box black_box_pad_pin="led_light" */
/* synthesis syn_force_seq_prim="CLK25MHZ" */;
  output led_light;
  input CLK25MHZ /* synthesis syn_isclock = 1 */;
endmodule
