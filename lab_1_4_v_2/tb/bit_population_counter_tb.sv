`timescale 1ns/1ns

module bit_population_counter_tb;

  parameter int WIDTH           = 128;

  parameter int SEQ_TEST_NUM    = 1000;
  parameter int RANDOM_TEST_NUM = 10000;

  parameter int FLUSH_TIMEOUT   = 50;


  bit                     clk;
  logic                   srst_i;

  logic [WIDTH-1:0]       data_i;
  logic                   data_val_i;

  logic [$clog2(WIDTH):0] data_o;
  logic                   data_val_o;


  always #5 clk = !clk;

  bit_population_counter #(
    .WIDTH ( WIDTH )
  ) DUT (
    .clk_i       ( clk        ),
    .srst_i      ( srst_i     ),
    .data_i      ( data_i     ),
    .data_val_i  ( data_val_i ),
    .data_o      ( data_o     ),
    .data_val_o  ( data_val_o )
  );

  typedef struct {
    logic [WIDTH-1:0] data;
  } transaction_t;

  transaction_t sent_queue[$];

  function automatic logic [WIDTH-1:0] random_data();
    logic [WIDTH-1:0] result;
    logic [31:0]      temp;

    result = '0;

    for ( int i = 0; i < WIDTH; i += 32 )
      begin
        temp = $urandom;
        for ( int j = 0; j < 32 && (i + j) < WIDTH; j++ )
          result[i + j] = temp[j];
      end

    return result;
  endfunction

  task automatic test_generator( input int n_tests, input bit is_seq );
    transaction_t tr;
    bit           local_val;

    for ( int i = 0; i < n_tests; i++ )
      begin
        tr.data = random_data();

        local_val = is_seq ? 1'b1 : $urandom_range(1, 0);

        data_i     <= tr.data;
        data_val_i <= local_val;

        if ( local_val )
          sent_queue.push_back(tr);

        @( posedge clk );
      end

    data_i     <= '0;
    data_val_i <= 1'b0;
  endtask

  task automatic reference_task();
    transaction_t tr;
    logic [$clog2(WIDTH):0] expected_count;

    forever
      begin
        @( posedge clk );

        if ( data_val_o )
          begin
            if ( sent_queue.size() == 0 )
              begin
                $error("ERROR: DUT asserted data_val_o with empty queue!");
                $stop;
              end

            tr             = sent_queue.pop_front();
            expected_count = $countones(tr.data);

            if ( data_o !== expected_count )
              begin
                $error("Mismatch! Expected %0d, got %0d",
                      expected_count, data_o);
                $stop;
              end
          end
      end
  endtask

  task automatic wait_flush_and_check();
    int timeout = FLUSH_TIMEOUT;

    while ( sent_queue.size() != 0 && timeout > 0 )
      begin
        @( posedge clk );
        timeout--;
      end

    if ( sent_queue.size() != 0 )
      begin
        $error("ERROR: Pipeline flush timeout! Queue size = %0d",
              sent_queue.size());
        $stop;
      end
  endtask

  initial
    begin
      clk        = 0;
      data_i     = '0;
      data_val_i = 1'b0;

      @( posedge clk );
      srst_i <= 1'b1;

      @( posedge clk );
      srst_i <= 1'b0;

      fork
        reference_task();
      join_none

      test_generator(SEQ_TEST_NUM, 1);
      wait_flush_and_check();
      $display("[OK] Seq tests passed");

      test_generator(RANDOM_TEST_NUM, 0);
      wait_flush_and_check();
      $display("[OK] Random  tests passed");

      $display("ALL TESTS PASSED");

      $stop;
    end

endmodule
