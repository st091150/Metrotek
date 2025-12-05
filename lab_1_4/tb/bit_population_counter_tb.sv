`timescale 1ns/1ns

module bit_population_counter_tb;

  parameter WIDTH        = 16;
  parameter SEQ_TEST_NUM = 100;
  parameter TEST_NUM     = 1000;


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

  clocking cb @( posedge clk );
    output srst_i;

    output data_i;
    output data_val_i;

    input  data_o;
    input  data_val_o;
  endclocking

task automatic count_ones_random_seq_test(
    input int test_num
    );
    
    logic [WIDTH-1:0] data_i_local;

    logic [$clog2(WIDTH):0] expected_bit_count;

    data_i_local = $urandom_range( ( 2**WIDTH ) - 1, 0);

    cb.data_i     <= data_i_local;
    cb.data_val_i <= 1;

    @( cb );
    if ( cb.data_val_o === 1 )
      begin
        $error("ERROR: expected data_val_o: 0, DUT data_val_o: 1");
        $stop;
      end

    for ( int i = 0; i < test_num; i++ )
      begin
        $display("TEST (random_seq): %0d", i);
        $display("data_i=%b data_val_i=%b", data_i_local, 1);

        expected_bit_count = $countones(data_i_local);

        data_i_local = $urandom_range( ( 2**WIDTH ) - 1, 0);

        cb.data_i <= data_i_local;

        @( cb );
        if ( cb.data_val_o === 0 )
          begin
            $error("ERROR: expected data_val_o: 1, DUT data_val_o: 0");
            $stop;
          end

        if ( cb.data_o !== expected_bit_count )
          begin
            $error("ERROR: expected bit count: %d, DUT bit count: %d", expected_bit_count, cb.data_o);
            $stop;
          end
      end

    cb.data_val_i <= 0;

    @( cb );
    if ( cb.data_val_o === 0 )
      begin
        $error("ERROR: expected data_val_o: 1, DUT data_val_o: 0");
        $stop;
      end

    @( cb );
    if ( cb.data_val_o === 1 )
      begin
        $error("ERROR: expected data_val_o: 0, DUT data_val_o: 1");
        $stop;
      end

  endtask

task automatic count_ones_test(
    input logic [WIDTH-1:0] data_i_in,
    input bit               data_val_i_in
    );

    logic [$clog2(WIDTH):0] expected_bit_count;

    cb.data_i     <= data_i_in;
    cb.data_val_i <= data_val_i_in;

    expected_bit_count = $countones(data_i_in);

    @( cb );
    if ( cb.data_val_o !== 0)
      begin
        $error("ERROR: expected data_val_o: 0, DUT data_val_o: 1");
        $stop;
      end

    cb.data_val_i <= 0;

    @( cb );
    if ( cb.data_val_o !== data_val_i_in )
      begin
        $error("ERROR: expected data_val_o: %d, DUT data_val_o: %d", data_val_i_in, cb.data_val_o);
        $stop;
      end

    if ( data_val_i_in )
      begin
      if ( cb.data_o !== expected_bit_count )
        begin
          $error("ERROR: expected bit count: %d, DUT bit count: %d", expected_bit_count, cb.data_o);
          $stop;
        end
      end

  endtask

  initial 
    begin
      logic [WIDTH-1:0] data_i_local;
      logic             data_val_i_local;

      clk                   = 0;

      data_i                = 0;
      data_val_i            = 0;

      @( cb );
      cb.srst_i <= 1;

      @( cb );
      cb.srst_i <= 0;

      $display("TEST (seq)");
      count_ones_random_seq_test(SEQ_TEST_NUM);

      for( int i = 0; i < TEST_NUM; i++ )
        begin
          $display("TEST (random) %0d", i);

          data_i_local     = $urandom_range( ( 2**WIDTH ) - 1, 0);
          data_val_i_local = $urandom_range(1, 0);

          $display("data_i=%b data_val_i=%b", data_i_local, data_val_i_local);

          count_ones_test(data_i_local, data_val_i_local);
        end
        
        $display("ALL TESTS PASSED");
        $stop;
      end

endmodule
