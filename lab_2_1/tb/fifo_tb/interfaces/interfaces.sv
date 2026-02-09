`timescale 1ns/1ns

interface fifo_input_if #( parameter DWIDTH = 8 );
  logic              clk;

  logic              srst;

  logic [DWIDTH-1:0] data;

  logic              wrreq;
  logic              rdreq;
endinterface

interface fifo_output_if #( parameter DWIDTH = 8, parameter AWIDTH = 4 );
  logic              clk;

  logic [DWIDTH-1:0] q;

  logic              empty;
  logic              full;

  logic              almost_empty;
  logic              almost_full;

  logic [AWIDTH-1:0] usedw;
endinterface