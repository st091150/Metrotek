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
// CREATED		"Wed Nov  5 23:49:17 2025"

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
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_7;

assign	SYNTHESIZED_WIRE_7 = 0;




always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[0] <= 0;
	end
else
	begin
	data_delay[0] <= data_no_delay;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[1] <= 0;
	end
else
	begin
	data_delay[1] <= data_delay[0];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[10] <= 0;
	end
else
	begin
	data_delay[10] <= data_delay[9];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[11] <= 0;
	end
else
	begin
	data_delay[11] <= data_delay[10];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[12] <= 0;
	end
else
	begin
	data_delay[12] <= data_delay[11];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[13] <= 0;
	end
else
	begin
	data_delay[13] <= data_delay[12];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[14] <= 0;
	end
else
	begin
	data_delay[14] <= data_delay[13];
	end
end


mux161 	b2v_inst15(
	.SEL3(data_delay_i[3]),
	.GN(SYNTHESIZED_WIRE_7),
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


assign	SYNTHESIZED_WIRE_16 =  ~rst_i;


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[2] <= 0;
	end
else
	begin
	data_delay[2] <= data_delay[1];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[3] <= 0;
	end
else
	begin
	data_delay[3] <= data_delay[2];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[4] <= 0;
	end
else
	begin
	data_delay[4] <= data_delay[3];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[5] <= 0;
	end
else
	begin
	data_delay[5] <= data_delay[4];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[6] <= 0;
	end
else
	begin
	data_delay[6] <= data_delay[5];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[7] <= 0;
	end
else
	begin
	data_delay[7] <= data_delay[6];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[8] <= 0;
	end
else
	begin
	data_delay[8] <= data_delay[7];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_16)
begin
if (!SYNTHESIZED_WIRE_16)
	begin
	data_delay[9] <= 0;
	end
else
	begin
	data_delay[9] <= data_delay[8];
	end
end

assign	data_no_delay = data_i;

endmodule
