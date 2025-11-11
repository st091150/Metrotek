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
// CREATED		"Fri Nov  7 17:09:04 2025"

module delay_15(
	data_i,
	rst_i,
	clk_i,
	data_delay_i,
	data_o
);


input wire	data_i;
input wire	rst_i;
input wire	clk_i;
input wire	[3:0] data_delay_i;
output wire	data_o;

reg	[14:0] data_delay;
wire	data_no_delay;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_30;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_24;
wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_28;
wire	SYNTHESIZED_WIRE_29;

assign	SYNTHESIZED_WIRE_6 = 0;




always@(posedge clk_i)
begin
	begin
	data_delay[0] <= data_no_delay;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[1] <= SYNTHESIZED_WIRE_0;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[10] <= SYNTHESIZED_WIRE_1;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[11] <= SYNTHESIZED_WIRE_2;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[12] <= SYNTHESIZED_WIRE_3;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[13] <= SYNTHESIZED_WIRE_4;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[14] <= SYNTHESIZED_WIRE_5;
	end
end


mux161 	b2v_inst15(
	.SEL3(data_delay_i[3]),
	.GN(SYNTHESIZED_WIRE_6),
	.IN0(data_no_delay),
	.SEL0(data_delay_i[0]),
	.SEL1(data_delay_i[1]),
	.SEL2(data_delay_i[2]),
	.IN3(data_delay[2]),
	.IN2(data_delay[1]),
	.IN1(data_delay[0]),
	.IN6(data_delay[5]),
	.IN5(data_delay[4]),
	.IN4(data_delay[3]),
	.IN9(data_delay[8]),
	.IN8(data_delay[7]),
	.IN7(data_delay[6]),
	.IN11(data_delay[10]),
	.IN12(data_delay[11]),
	.IN10(data_delay[9]),
	.IN15(data_delay[14]),
	.IN14(data_delay[13]),
	.IN13(data_delay[12]),
	.OUT1(data_o));

assign	data_no_delay = data_i & SYNTHESIZED_WIRE_30;


assign	SYNTHESIZED_WIRE_0 = data_delay[0] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_10 = data_delay[1] & SYNTHESIZED_WIRE_30;


always@(posedge clk_i)
begin
	begin
	data_delay[2] <= SYNTHESIZED_WIRE_10;
	end
end

assign	SYNTHESIZED_WIRE_21 = data_delay[2] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_24 = data_delay[3] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_25 = data_delay[4] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_26 = data_delay[5] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_27 = data_delay[6] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_28 = data_delay[7] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_29 = data_delay[8] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_1 = data_delay[9] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_2 = data_delay[10] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_3 = data_delay[11] & SYNTHESIZED_WIRE_30;


always@(posedge clk_i)
begin
	begin
	data_delay[3] <= SYNTHESIZED_WIRE_21;
	end
end

assign	SYNTHESIZED_WIRE_4 = data_delay[12] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_5 = data_delay[13] & SYNTHESIZED_WIRE_30;

assign	SYNTHESIZED_WIRE_30 =  ~rst_i;


always@(posedge clk_i)
begin
	begin
	data_delay[4] <= SYNTHESIZED_WIRE_24;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[5] <= SYNTHESIZED_WIRE_25;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[6] <= SYNTHESIZED_WIRE_26;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[7] <= SYNTHESIZED_WIRE_27;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[8] <= SYNTHESIZED_WIRE_28;
	end
end


always@(posedge clk_i)
begin
	begin
	data_delay[9] <= SYNTHESIZED_WIRE_29;
	end
end


endmodule
