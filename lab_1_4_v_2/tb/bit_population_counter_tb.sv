`timescale 1ns/1ns

module bit_population_counter_tb;

  parameter WIDTH     = 128;

  parameter TEST_NUM  = 1000;

  bit                     clk;

  logic                   srst_i;

  logic [WIDTH-1:0]       data_i;
  logic                   data_val_i;

  logic [$clog2(WIDTH):0] data_o;
  logic                   data_val_o;

  always #5 clk = !clk;

  bit_population_counter #(
    .WIDTH         ( WIDTH        )
  ) DUT (
    .clk_i         ( clk          ),
    .srst_i        ( srst_i       ),
    .data_i        ( data_i       ),
    .data_val_i    ( data_val_i   ),
    .data_o        ( data_o       ),
    .data_val_o    ( data_val_o   )
  );

  typedef struct {
    logic [WIDTH-1:0] data;
    logic             valid;
  } transaction_t;

  transaction_t sent_queue[$];
  logic         done_gen;

  function automatic logic [WIDTH-1:0] random_data();
    logic [WIDTH-1:0] result;

    logic [31:0] temp;

    result = '0;

    for ( int i = 0; i < WIDTH; i += 32 ) 
      begin
        temp = $urandom;
        
        for ( int j = 0; j < 32 && ( i + j ) < WIDTH; j++ )
          result[i + j] = temp[j];
      end

    return result;
  endfunction

  task automatic generator_task( input int n_tests );
    transaction_t tr;
    done_gen = 0;

    for ( int i = 0; i < n_tests; i++ ) 
      begin
        tr.data  = random_data();
        tr.valid = $urandom_range(1, 0);

        data_i     <= tr.data;
        data_val_i <= tr.valid;

        if ( tr.valid )
          sent_queue.push_back(tr);

        @( posedge clk );
      end

    data_i     <= 0;
    data_val_i <= 0;

    done_gen   <= 1;
  endtask


  task automatic reference_task();
    transaction_t tr;

    logic [$clog2(WIDTH):0] expected_count;

    while ( ( !done_gen ) || ( sent_queue.size() != 0 ) ) 
      begin
        @( posedge clk );
        if ( data_val_o ) 
          begin
            if ( sent_queue.size() == 0 )
              begin
                $error("ERROR: DUT asserted valid, but the queue is empty!");
                $stop;
              end

            tr = sent_queue.pop_front();
            expected_count = $countones(tr.data);

            if ( data_o !== expected_count )
            begin
              $error("Mismatch! Expected: %0d, DUT: %0d", expected_count, data_o);
              $stop;
            end
          end
      end
  endtask

  initial
    begin
      clk        = 0;
      data_i     = 0;
      data_val_i = 0;

      @( posedge clk );
      srst_i <= 1;

      @( posedge clk );
      srst_i <= 0;

      fork
        generator_task(TEST_NUM);
        reference_task();
      join

      $display("ALL TESTS PASSED!");
      $stop;
    end

endmodule
