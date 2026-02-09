`timescale 1ns/1ns

class fifo_monitor #( 
    parameter      DWIDTH = 8,
    parameter      AWIDTH = 4,
    parameter type fifo_event_t 
  );
  
  virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) vif;
  
  mailbox #( fifo_event_t ) fifo_events;

  function new( virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) vif );
    this.vif = vif;
    fifo_events = new();
  endfunction

  task run();
    fifo_event_t fifo_event;

    forever
      begin
        @( posedge vif.clk );

        fifo_event.q            = vif.q;
        fifo_event.empty        = vif.empty;
        fifo_event.full         = vif.full;
        fifo_event.almost_empty = vif.almost_empty;
        fifo_event.almost_full  = vif.almost_full;
        fifo_event.usedw        = vif.usedw;

        fifo_events.put(fifo_event);
      end
  endtask
endclass