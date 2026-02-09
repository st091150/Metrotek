`timescale 1ns/1ns

class fifo_driver #( parameter DWIDTH = 8, parameter AWIDTH = 4 );
  virtual fifo_input_if #( .DWIDTH(DWIDTH) ) vif;

  function new ( virtual fifo_input_if #( .DWIDTH(DWIDTH) ) vif );
    this.vif = vif;
  endfunction

  task write( input logic [DWIDTH-1:0] data );
    vif.wrreq <= 1;
    vif.data  <= data;

    @( posedge vif.clk );
    vif.wrreq <= 0;
  endtask

  task read();
    vif.rdreq <= 1;

    @( posedge vif.clk );
    vif.rdreq <= 0;
  endtask

  task write_read_simul( input logic [DWIDTH-1:0] data );
    vif.data  <= data;

    vif.wrreq <= 1;
    vif.rdreq <= 1;

    @( posedge vif.clk );
    vif.wrreq <= 0;
    vif.rdreq <= 0;
  endtask
endclass