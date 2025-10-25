// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Sat Oct 25 20:25:19 2025"

module lab_0(
	clk_150mhz_i,
	data0_i,
	data1_i,
	data2_i,
	data3_i,
	direction_i,
	data_o
);


input wire	clk_150mhz_i;
input wire	[1:0] data0_i;
input wire	[1:0] data1_i;
input wire	[1:0] data2_i;
input wire	[1:0] data3_i;
input wire	[1:0] direction_i;
output wire	[1:0] data_o;

wire	[1:0] data_o_ALTERA_SYNTHESIZED;
wire	[1:0] not_direction_i;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;




assign	SYNTHESIZED_WIRE_5 = data0_i[1] & SYNTHESIZED_WIRE_16;

assign	SYNTHESIZED_WIRE_10 = SYNTHESIZED_WIRE_17 & data2_i[0];

assign	SYNTHESIZED_WIRE_7 = data3_i[1] & SYNTHESIZED_WIRE_18;

assign	SYNTHESIZED_WIRE_12 = SYNTHESIZED_WIRE_19 & data1_i[0];

assign	SYNTHESIZED_WIRE_11 = SYNTHESIZED_WIRE_18 & data3_i[0];

assign	not_direction_i[1] =  ~direction_i[1];

assign	not_direction_i[0] =  ~direction_i[0];

assign	SYNTHESIZED_WIRE_16 = not_direction_i[1] & not_direction_i[0];

assign	SYNTHESIZED_WIRE_19 = not_direction_i[1] & direction_i[0];

assign	SYNTHESIZED_WIRE_17 = direction_i[1] & not_direction_i[0];

assign	SYNTHESIZED_WIRE_18 = direction_i[1] & direction_i[0];

assign	data_o_ALTERA_SYNTHESIZED[1] = SYNTHESIZED_WIRE_5 | SYNTHESIZED_WIRE_6 | SYNTHESIZED_WIRE_7 | SYNTHESIZED_WIRE_8;

assign	data_o_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_9 | SYNTHESIZED_WIRE_10 | SYNTHESIZED_WIRE_11 | SYNTHESIZED_WIRE_12;

assign	SYNTHESIZED_WIRE_9 = SYNTHESIZED_WIRE_16 & data0_i[0];

assign	SYNTHESIZED_WIRE_8 = data1_i[1] & SYNTHESIZED_WIRE_19;

assign	SYNTHESIZED_WIRE_6 = data2_i[1] & SYNTHESIZED_WIRE_17;

assign	data_o = data_o_ALTERA_SYNTHESIZED;

endmodule
