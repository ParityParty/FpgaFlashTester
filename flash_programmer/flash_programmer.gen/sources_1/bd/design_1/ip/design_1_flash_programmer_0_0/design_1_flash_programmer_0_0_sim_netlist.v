// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Thu Sep  4 14:08:24 2025
// Host        : agata running 64-bit Ubuntu 24.04.3 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/agata/FpgaFlashTester/flash_programmer/flash_programmer.gen/sources_1/bd/design_1/ip/design_1_flash_programmer_0_0/design_1_flash_programmer_0_0_sim_netlist.v
// Design      : design_1_flash_programmer_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_flash_programmer_0_0,flash_programmer,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "flash_programmer,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module design_1_flash_programmer_0_0
   (led_light,
    CLK25MHZ);
  output led_light;
  input CLK25MHZ;

  wire CLK25MHZ;
  wire led_light;

  design_1_flash_programmer_0_0_flash_programmer inst
       (.CLK25MHZ(CLK25MHZ),
        .led_light(led_light));
endmodule

(* ORIG_REF_NAME = "flash_programmer" *) 
module design_1_flash_programmer_0_0_flash_programmer
   (led_light,
    CLK25MHZ);
  output led_light;
  input CLK25MHZ;

  wire CLK25MHZ;
  wire [31:0]counter;
  wire \counter_reg[16]_i_1_n_0 ;
  wire \counter_reg[16]_i_1_n_1 ;
  wire \counter_reg[16]_i_1_n_2 ;
  wire \counter_reg[16]_i_1_n_3 ;
  wire \counter_reg[16]_i_1_n_4 ;
  wire \counter_reg[16]_i_1_n_5 ;
  wire \counter_reg[16]_i_1_n_6 ;
  wire \counter_reg[16]_i_1_n_7 ;
  wire \counter_reg[24]_i_1_n_0 ;
  wire \counter_reg[24]_i_1_n_1 ;
  wire \counter_reg[24]_i_1_n_2 ;
  wire \counter_reg[24]_i_1_n_3 ;
  wire \counter_reg[24]_i_1_n_4 ;
  wire \counter_reg[24]_i_1_n_5 ;
  wire \counter_reg[24]_i_1_n_6 ;
  wire \counter_reg[24]_i_1_n_7 ;
  wire \counter_reg[31]_i_1_n_2 ;
  wire \counter_reg[31]_i_1_n_3 ;
  wire \counter_reg[31]_i_1_n_4 ;
  wire \counter_reg[31]_i_1_n_5 ;
  wire \counter_reg[31]_i_1_n_6 ;
  wire \counter_reg[31]_i_1_n_7 ;
  wire \counter_reg[8]_i_1_n_0 ;
  wire \counter_reg[8]_i_1_n_1 ;
  wire \counter_reg[8]_i_1_n_2 ;
  wire \counter_reg[8]_i_1_n_3 ;
  wire \counter_reg[8]_i_1_n_4 ;
  wire \counter_reg[8]_i_1_n_5 ;
  wire \counter_reg[8]_i_1_n_6 ;
  wire \counter_reg[8]_i_1_n_7 ;
  wire led_light;
  wire led_light_0;
  wire led_light_i_2_n_0;
  wire led_light_i_3_n_0;
  wire led_light_i_4_n_0;
  wire led_light_i_5_n_0;
  wire led_light_i_6_n_0;
  wire led_light_i_7_n_0;
  wire [31:0]p_1_in;
  wire state;
  wire state_i_1_n_0;
  wire [7:6]\NLW_counter_reg[31]_i_1_CO_UNCONNECTED ;
  wire [7:7]\NLW_counter_reg[31]_i_1_O_UNCONNECTED ;

  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \counter[0]_i_1 
       (.I0(counter[0]),
        .O(p_1_in[0]));
  FDSE #(
    .INIT(1'b0)) 
    \counter_reg[0] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[0]),
        .Q(counter[0]),
        .S(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[10] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[10]),
        .Q(counter[10]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[11] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[11]),
        .Q(counter[11]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[12] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[12]),
        .Q(counter[12]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[13] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[13]),
        .Q(counter[13]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[14] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[14]),
        .Q(counter[14]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[15] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[15]),
        .Q(counter[15]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[16] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[16]),
        .Q(counter[16]),
        .R(led_light_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY8 \counter_reg[16]_i_1 
       (.CI(\counter_reg[8]_i_1_n_0 ),
        .CI_TOP(1'b0),
        .CO({\counter_reg[16]_i_1_n_0 ,\counter_reg[16]_i_1_n_1 ,\counter_reg[16]_i_1_n_2 ,\counter_reg[16]_i_1_n_3 ,\counter_reg[16]_i_1_n_4 ,\counter_reg[16]_i_1_n_5 ,\counter_reg[16]_i_1_n_6 ,\counter_reg[16]_i_1_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(p_1_in[16:9]),
        .S(counter[16:9]));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[17] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[17]),
        .Q(counter[17]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[18] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[18]),
        .Q(counter[18]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[19] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[19]),
        .Q(counter[19]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[1] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[1]),
        .Q(counter[1]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[20] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[20]),
        .Q(counter[20]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[21] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[21]),
        .Q(counter[21]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[22] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[22]),
        .Q(counter[22]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[23] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[23]),
        .Q(counter[23]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[24] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[24]),
        .Q(counter[24]),
        .R(led_light_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY8 \counter_reg[24]_i_1 
       (.CI(\counter_reg[16]_i_1_n_0 ),
        .CI_TOP(1'b0),
        .CO({\counter_reg[24]_i_1_n_0 ,\counter_reg[24]_i_1_n_1 ,\counter_reg[24]_i_1_n_2 ,\counter_reg[24]_i_1_n_3 ,\counter_reg[24]_i_1_n_4 ,\counter_reg[24]_i_1_n_5 ,\counter_reg[24]_i_1_n_6 ,\counter_reg[24]_i_1_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(p_1_in[24:17]),
        .S(counter[24:17]));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[25] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[25]),
        .Q(counter[25]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[26] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[26]),
        .Q(counter[26]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[27] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[27]),
        .Q(counter[27]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[28] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[28]),
        .Q(counter[28]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[29] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[29]),
        .Q(counter[29]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[2] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[2]),
        .Q(counter[2]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[30] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[30]),
        .Q(counter[30]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[31] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[31]),
        .Q(counter[31]),
        .R(led_light_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY8 \counter_reg[31]_i_1 
       (.CI(\counter_reg[24]_i_1_n_0 ),
        .CI_TOP(1'b0),
        .CO({\NLW_counter_reg[31]_i_1_CO_UNCONNECTED [7:6],\counter_reg[31]_i_1_n_2 ,\counter_reg[31]_i_1_n_3 ,\counter_reg[31]_i_1_n_4 ,\counter_reg[31]_i_1_n_5 ,\counter_reg[31]_i_1_n_6 ,\counter_reg[31]_i_1_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_counter_reg[31]_i_1_O_UNCONNECTED [7],p_1_in[31:25]}),
        .S({1'b0,counter[31:25]}));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[3] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[3]),
        .Q(counter[3]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[4] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[4]),
        .Q(counter[4]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[5] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[5]),
        .Q(counter[5]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[6] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[6]),
        .Q(counter[6]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[7] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[7]),
        .Q(counter[7]),
        .R(led_light_0));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[8] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[8]),
        .Q(counter[8]),
        .R(led_light_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY8 \counter_reg[8]_i_1 
       (.CI(counter[0]),
        .CI_TOP(1'b0),
        .CO({\counter_reg[8]_i_1_n_0 ,\counter_reg[8]_i_1_n_1 ,\counter_reg[8]_i_1_n_2 ,\counter_reg[8]_i_1_n_3 ,\counter_reg[8]_i_1_n_4 ,\counter_reg[8]_i_1_n_5 ,\counter_reg[8]_i_1_n_6 ,\counter_reg[8]_i_1_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(p_1_in[8:1]),
        .S(counter[8:1]));
  FDRE #(
    .INIT(1'b0)) 
    \counter_reg[9] 
       (.C(CLK25MHZ),
        .CE(1'b1),
        .D(p_1_in[9]),
        .Q(counter[9]),
        .R(led_light_0));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    led_light_i_1
       (.I0(led_light_i_2_n_0),
        .I1(led_light_i_3_n_0),
        .I2(led_light_i_4_n_0),
        .I3(led_light_i_5_n_0),
        .I4(led_light_i_6_n_0),
        .I5(led_light_i_7_n_0),
        .O(led_light_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h1)) 
    led_light_i_2
       (.I0(counter[0]),
        .I1(counter[1]),
        .O(led_light_i_2_n_0));
  LUT6 #(
    .INIT(64'h0000000100000000)) 
    led_light_i_3
       (.I0(counter[4]),
        .I1(counter[5]),
        .I2(counter[2]),
        .I3(counter[3]),
        .I4(counter[7]),
        .I5(counter[6]),
        .O(led_light_i_3_n_0));
  LUT6 #(
    .INIT(64'h0002000000000000)) 
    led_light_i_4
       (.I0(counter[11]),
        .I1(counter[10]),
        .I2(counter[8]),
        .I3(counter[9]),
        .I4(counter[13]),
        .I5(counter[12]),
        .O(led_light_i_4_n_0));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    led_light_i_5
       (.I0(counter[16]),
        .I1(counter[17]),
        .I2(counter[14]),
        .I3(counter[15]),
        .I4(counter[19]),
        .I5(counter[18]),
        .O(led_light_i_5_n_0));
  LUT6 #(
    .INIT(64'h0000200000000000)) 
    led_light_i_6
       (.I0(counter[22]),
        .I1(counter[23]),
        .I2(counter[20]),
        .I3(counter[21]),
        .I4(counter[25]),
        .I5(counter[24]),
        .O(led_light_i_6_n_0));
  LUT6 #(
    .INIT(64'h0000000000000001)) 
    led_light_i_7
       (.I0(counter[28]),
        .I1(counter[29]),
        .I2(counter[26]),
        .I3(counter[27]),
        .I4(counter[31]),
        .I5(counter[30]),
        .O(led_light_i_7_n_0));
  FDRE led_light_reg
       (.C(CLK25MHZ),
        .CE(led_light_0),
        .D(state),
        .Q(led_light),
        .R(1'b0));
  LUT1 #(
    .INIT(2'h1)) 
    state_i_1
       (.I0(state),
        .O(state_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    state_reg
       (.C(CLK25MHZ),
        .CE(led_light_0),
        .D(state_i_1_n_0),
        .Q(state),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
