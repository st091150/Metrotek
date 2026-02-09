`timescale 1ns/1ns

class fifo_scoreboard #( parameter type fifo_event_t );
  mailbox #(fifo_event_t) dut_events;
  mailbox #(fifo_event_t) golden_events;

  function new();
    dut_events    = new();
    golden_events = new();
  endfunction

  task run();
    fifo_event_t dut_evt;
    fifo_event_t gold_evt;

    forever
      begin
        dut_events.get(dut_evt);

        golden_events.get(gold_evt);

        check(dut_evt, gold_evt);
      end
  endtask

  task check( fifo_event_t dut, fifo_event_t golden );
    bit is_errors = 0;

    if ( dut.q !== golden.q )
      begin
        $error("q mismatch! DUT=%0h GOLD=%0h", dut.q, golden.q);
        is_errors = 1;
      end

    if ( dut.empty !== golden.empty )
      begin
        $error("empty mismatch! DUT=%0b GOLD=%0b", dut.empty, golden.empty);
        is_errors = 1;
      end

    if ( dut.full !== golden.full )
      begin
        $error("full mismatch! DUT=%0b GOLD=%0b", dut.full, golden.full);
        is_errors = 1;
      end

    if ( dut.almost_empty !== golden.almost_empty )
      begin
        $error("almost_empty mismatch! DUT=%0b GOLD=%0b", dut.almost_empty, golden.almost_empty);
        is_errors = 1;
      end

    if ( dut.almost_full !== golden.almost_full )
      begin
        $error("almost_full mismatch! DUT=%0b GOLD=%0b", dut.almost_full, golden.almost_full);
        is_errors = 1;
      end

    if ( dut.usedw !== golden.usedw )
      begin
        $error("usedw mismatch! DUT=%0d GOLD=%0d", dut.usedw, golden.usedw);
        is_errors = 1;
      end

    if ( is_errors )
      $stop;

  endtask

endclass