`timescale 1ns/1ns

class fifo_env #( 
    parameter      DWIDTH = 8,
    parameter      AWIDTH = 4,
    parameter type fifo_event_t 
  );

  virtual fifo_input_if  #( .DWIDTH(DWIDTH) )  in_vif;

  virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) dut_out_vif;
  virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) gold_out_vif; 

  fifo_driver  #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) driver;

  fifo_monitor #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .fifo_event_t(fifo_event_t) ) dut_monitor;
  fifo_monitor #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .fifo_event_t(fifo_event_t) ) golden_monitor;

  fifo_scoreboard #( .fifo_event_t(fifo_event_t) ) scoreboard;

  function new(
    virtual fifo_input_if  #(DWIDTH)        in_vif,
    virtual fifo_output_if #(DWIDTH,AWIDTH) dut_out_vif,
    virtual fifo_output_if #(DWIDTH,AWIDTH) gold_out_vif
  );
    this.in_vif       = in_vif;
    this.dut_out_vif  = dut_out_vif;
    this.gold_out_vif = gold_out_vif;

    driver         = new(in_vif);
    dut_monitor    = new(dut_out_vif);
    golden_monitor = new(gold_out_vif);
    scoreboard     = new();
  endfunction

  task run();
    fork
      dut_monitor.run();
      golden_monitor.run();
      scoreboard.run();
    join_none
  endtask

  task connect_scoreboard();
    scoreboard.dut_events    = dut_monitor.fifo_events;
    scoreboard.golden_events = golden_monitor.fifo_events;
  endtask
endclass