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
// CREATED		"Tue Nov 18 00:50:02 2025"

module CRC_16_ANSI(
	clk_i,
	rst_i,
	data_i,
	data_o
);


input wire	clk_i;
input wire	rst_i;
input wire	data_i;
output wire	[15:0] data_o;

wire	[15:0] data_o_ALTERA_SYNTHESIZED;
wire	[15:0] init_value;
wire	not_xor_0;
wire	not_xor_1;
wire	not_xor_10;
wire	not_xor_11;
wire	not_xor_12;
wire	not_xor_13;
wire	not_xor_14;
wire	not_xor_15;
wire	not_xor_2;
wire	not_xor_3;
wire	not_xor_4;
wire	not_xor_5;
wire	not_xor_6;
wire	not_xor_7;
wire	not_xor_8;
wire	not_xor_9;
wire	[15:0] Poly;
wire	XOR_Poly_0;
wire	XOR_Poly_1;
wire	XOR_Poly_10;
wire	XOR_Poly_11;
wire	XOR_Poly_12;
wire	XOR_Poly_13;
wire	XOR_Poly_14;
wire	XOR_Poly_15;
wire	XOR_Poly_2;
wire	XOR_Poly_3;
wire	XOR_Poly_4;
wire	XOR_Poly_5;
wire	XOR_Poly_6;
wire	XOR_Poly_7;
wire	XOR_Poly_8;
wire	XOR_Poly_9;
reg	DFFEA_inst16;
wire	SYNTHESIZED_WIRE_0;
reg	SYNTHESIZED_WIRE_51;
reg	SYNTHESIZED_WIRE_52;
wire	SYNTHESIZED_WIRE_53;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_54;
wire	SYNTHESIZED_WIRE_4;
reg	SYNTHESIZED_WIRE_55;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_14;
reg	SYNTHESIZED_WIRE_56;
wire	SYNTHESIZED_WIRE_17;
reg	SYNTHESIZED_WIRE_57;
wire	SYNTHESIZED_WIRE_20;
reg	SYNTHESIZED_WIRE_58;
wire	SYNTHESIZED_WIRE_23;
reg	SYNTHESIZED_WIRE_59;
wire	SYNTHESIZED_WIRE_26;
reg	SYNTHESIZED_WIRE_60;
wire	SYNTHESIZED_WIRE_29;
reg	SYNTHESIZED_WIRE_61;
wire	SYNTHESIZED_WIRE_32;
reg	SYNTHESIZED_WIRE_62;
wire	SYNTHESIZED_WIRE_35;
reg	SYNTHESIZED_WIRE_63;
wire	SYNTHESIZED_WIRE_38;
reg	SYNTHESIZED_WIRE_64;
wire	SYNTHESIZED_WIRE_41;
reg	SYNTHESIZED_WIRE_65;
wire	SYNTHESIZED_WIRE_44;
reg	SYNTHESIZED_WIRE_66;
wire	SYNTHESIZED_WIRE_47;
reg	SYNTHESIZED_WIRE_67;
wire	SYNTHESIZED_WIRE_50;

assign	SYNTHESIZED_WIRE_0 = 0;
assign	SYNTHESIZED_WIRE_2 = 0;




always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_51 <= init_value[0];
	end
else
	begin
	SYNTHESIZED_WIRE_51 <= data_o_ALTERA_SYNTHESIZED[15];
	end
end


const_8005	b2v_inst1(
	.result(Poly));


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_62 <= init_value[9];
	end
else
	begin
	SYNTHESIZED_WIRE_62 <= data_o_ALTERA_SYNTHESIZED[6];
	end
end


const_ffff	b2v_inst100(
	.result(init_value));


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_63 <= init_value[10];
	end
else
	begin
	SYNTHESIZED_WIRE_63 <= data_o_ALTERA_SYNTHESIZED[5];
	end
end


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_64 <= init_value[11];
	end
else
	begin
	SYNTHESIZED_WIRE_64 <= data_o_ALTERA_SYNTHESIZED[4];
	end
end


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_65 <= init_value[12];
	end
else
	begin
	SYNTHESIZED_WIRE_65 <= data_o_ALTERA_SYNTHESIZED[3];
	end
end


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_66 <= init_value[13];
	end
else
	begin
	SYNTHESIZED_WIRE_66 <= data_o_ALTERA_SYNTHESIZED[2];
	end
end


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_67 <= init_value[14];
	end
else
	begin
	SYNTHESIZED_WIRE_67 <= data_o_ALTERA_SYNTHESIZED[1];
	end
end


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	DFFEA_inst16 <= init_value[15];
	end
else
	begin
	DFFEA_inst16 <= data_o_ALTERA_SYNTHESIZED[0];
	end
end


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_52 <= init_value[1];
	end
else
	begin
	SYNTHESIZED_WIRE_52 <= data_o_ALTERA_SYNTHESIZED[14];
	end
end

assign	SYNTHESIZED_WIRE_54 = DFFEA_inst16 ^ data_i;

assign	SYNTHESIZED_WIRE_4 = Poly[15] ^ SYNTHESIZED_WIRE_0;

assign	SYNTHESIZED_WIRE_7 = Poly[14] ^ SYNTHESIZED_WIRE_51;

assign	SYNTHESIZED_WIRE_11 = Poly[13] ^ SYNTHESIZED_WIRE_52;

assign	not_xor_0 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_2;

assign	XOR_Poly_0 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_4;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_56 <= init_value[3];
	end
else
	begin
	SYNTHESIZED_WIRE_56 <= data_o_ALTERA_SYNTHESIZED[12];
	end
end

assign	SYNTHESIZED_WIRE_14 = Poly[12] ^ SYNTHESIZED_WIRE_55;

assign	data_o_ALTERA_SYNTHESIZED[15] = not_xor_0 | XOR_Poly_0;



assign	not_xor_1 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_51;

assign	XOR_Poly_1 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_7;

assign	data_o_ALTERA_SYNTHESIZED[14] = not_xor_1 | XOR_Poly_1;

assign	not_xor_2 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_52;

assign	SYNTHESIZED_WIRE_53 =  ~SYNTHESIZED_WIRE_54;

assign	XOR_Poly_2 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_11;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_58 <= init_value[5];
	end
else
	begin
	SYNTHESIZED_WIRE_58 <= data_o_ALTERA_SYNTHESIZED[10];
	end
end

assign	data_o_ALTERA_SYNTHESIZED[13] = not_xor_2 | XOR_Poly_2;

assign	not_xor_3 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_55;

assign	XOR_Poly_3 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_14;

assign	data_o_ALTERA_SYNTHESIZED[12] = not_xor_3 | XOR_Poly_3;

assign	not_xor_4 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_56;

assign	XOR_Poly_4 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_17;

assign	data_o_ALTERA_SYNTHESIZED[11] = not_xor_4 | XOR_Poly_4;

assign	SYNTHESIZED_WIRE_17 = Poly[11] ^ SYNTHESIZED_WIRE_56;

assign	not_xor_5 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_57;

assign	XOR_Poly_5 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_20;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_55 <= init_value[2];
	end
else
	begin
	SYNTHESIZED_WIRE_55 <= data_o_ALTERA_SYNTHESIZED[13];
	end
end

assign	data_o_ALTERA_SYNTHESIZED[10] = not_xor_5 | XOR_Poly_5;

assign	SYNTHESIZED_WIRE_20 = Poly[10] ^ SYNTHESIZED_WIRE_57;

assign	not_xor_6 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_58;

assign	XOR_Poly_6 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_23;

assign	data_o_ALTERA_SYNTHESIZED[9] = not_xor_6 | XOR_Poly_6;

assign	SYNTHESIZED_WIRE_23 = Poly[9] ^ SYNTHESIZED_WIRE_58;

assign	not_xor_7 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_59;

assign	XOR_Poly_7 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_26;

assign	data_o_ALTERA_SYNTHESIZED[8] = not_xor_7 | XOR_Poly_7;

assign	not_xor_8 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_60;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_57 <= init_value[4];
	end
else
	begin
	SYNTHESIZED_WIRE_57 <= data_o_ALTERA_SYNTHESIZED[11];
	end
end

assign	XOR_Poly_8 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_29;

assign	data_o_ALTERA_SYNTHESIZED[7] = not_xor_8 | XOR_Poly_8;

assign	not_xor_9 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_61;

assign	XOR_Poly_9 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_32;

assign	data_o_ALTERA_SYNTHESIZED[6] = not_xor_9 | XOR_Poly_9;

assign	not_xor_10 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_62;

assign	XOR_Poly_10 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_35;

assign	data_o_ALTERA_SYNTHESIZED[5] = not_xor_10 | XOR_Poly_10;

assign	not_xor_11 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_63;

assign	XOR_Poly_11 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_38;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_59 <= init_value[6];
	end
else
	begin
	SYNTHESIZED_WIRE_59 <= data_o_ALTERA_SYNTHESIZED[9];
	end
end

assign	data_o_ALTERA_SYNTHESIZED[4] = not_xor_11 | XOR_Poly_11;

assign	not_xor_12 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_64;

assign	XOR_Poly_12 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_41;

assign	data_o_ALTERA_SYNTHESIZED[3] = not_xor_12 | XOR_Poly_12;

assign	not_xor_13 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_65;

assign	XOR_Poly_13 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_44;

assign	data_o_ALTERA_SYNTHESIZED[2] = not_xor_13 | XOR_Poly_13;

assign	not_xor_14 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_66;

assign	XOR_Poly_14 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_47;

assign	data_o_ALTERA_SYNTHESIZED[1] = not_xor_14 | XOR_Poly_14;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_60 <= init_value[7];
	end
else
	begin
	SYNTHESIZED_WIRE_60 <= data_o_ALTERA_SYNTHESIZED[8];
	end
end

assign	SYNTHESIZED_WIRE_26 = Poly[8] ^ SYNTHESIZED_WIRE_59;

assign	not_xor_15 = SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_67;

assign	XOR_Poly_15 = SYNTHESIZED_WIRE_54 & SYNTHESIZED_WIRE_50;

assign	data_o_ALTERA_SYNTHESIZED[0] = not_xor_15 | XOR_Poly_15;

assign	SYNTHESIZED_WIRE_29 = Poly[7] ^ SYNTHESIZED_WIRE_60;

assign	SYNTHESIZED_WIRE_32 = Poly[6] ^ SYNTHESIZED_WIRE_61;

assign	SYNTHESIZED_WIRE_35 = Poly[5] ^ SYNTHESIZED_WIRE_62;

assign	SYNTHESIZED_WIRE_38 = Poly[4] ^ SYNTHESIZED_WIRE_63;

assign	SYNTHESIZED_WIRE_41 = Poly[3] ^ SYNTHESIZED_WIRE_64;

assign	SYNTHESIZED_WIRE_44 = Poly[2] ^ SYNTHESIZED_WIRE_65;


always@(posedge clk_i or posedge rst_i)
begin
if (rst_i)
	begin
	SYNTHESIZED_WIRE_61 <= init_value[8];
	end
else
	begin
	SYNTHESIZED_WIRE_61 <= data_o_ALTERA_SYNTHESIZED[7];
	end
end

assign	SYNTHESIZED_WIRE_47 = Poly[1] ^ SYNTHESIZED_WIRE_66;

assign	SYNTHESIZED_WIRE_50 = Poly[0] ^ SYNTHESIZED_WIRE_67;

assign	data_o = data_o_ALTERA_SYNTHESIZED;

endmodule
