`timescale 1ns/1ns

module priority_encoder_tb;

  parameter WIDTH    = 16;
  parameter TEST_NUM = 10000;
  
  logic             clk;

  logic             srst_i;

  logic [WIDTH-1:0] data_i;
  logic             data_val_i;

  logic [WIDTH-1:0] data_left_o;
  logic [WIDTH-1:0] data_right_o;

  logic             data_val_o;

  logic [WIDTH-1:0] data_i_local;
  logic             data_val_i_local;

  always #5 clk = !clk;

  priority_encoder #(
    .WIDTH         ( WIDTH        )
  ) DUT (
    .clk_i         ( clk          ),
    .srst_i        ( srst_i       ),
    .data_i        ( data_i       ),
    .data_val_i    ( data_val_i   ),
    .data_left_o   ( data_left_o  ),
    .data_right_o  ( data_right_o ),
    .data_val_o    ( data_val_o   )
  );

  function automatic int most_left_one_idx(logic [WIDTH-1:0] data);
    for (int i = WIDTH-1; i >= 0; i--)
      begin
        if (data[i] == 1'b1)
          return i; 
      end
    return -1;
  endfunction

  function automatic int most_right_one_idx(logic [WIDTH-1:0] data);
    for (int i = 0; i < WIDTH; i++)
      begin
        if (data[i] == 1'b1)
          return i; 
      end
    return -1;
  endfunction

  clocking cb @(posedge clk);
    output srst_i;

    output data_i;
    output data_val_i;

    input  data_left_o;
    input  data_right_o;
    input  data_val_o;
  endclocking

  task automatic deserialization_test(
    input logic [WIDTH-1:0] data_i_in,
    input bit               data_val_i_in
    );

    int               first_one_idx;
    int               last_one_idx;

    logic [WIDTH-1:0] expected_data_left_o  = '0;
    logic [WIDTH-1:0] expected_data_right_o = '0;

    $display("data_i=%b data_val_i=%b", data_i_in, data_val_i_in);

    first_one_idx = most_left_one_idx(data_i_in);
    last_one_idx  = most_right_one_idx(data_i_in);

    if(data_val_i_in && first_one_idx != -1)
      begin
        expected_data_left_o[first_one_idx] = 1'b1;
        expected_data_right_o[last_one_idx] = 1'b1;
      end

    cb.data_i     <= data_i_in;
    cb.data_val_i <= data_val_i_in;
    
    @( cb );
    if ( cb.data_val_o === 1 )
      begin
        $error("ERROR: expected data_val_o=0, DUT data_val_o=1");
        $stop;
      end

    cb.data_val_i <= 0;

    @( cb );
    if ( data_val_i_in !== cb.data_val_o )
      begin
        $error("ERROR: expected data_val_o=%d, DUT data_val_o=%d", data_val_i_in, cb.data_val_o);
        $stop;
      end

    if( cb.data_val_o )
      begin
        if ( expected_data_left_o !== cb.data_left_o )
          begin
            $error("ERROR: expected data_left_o=%b, DUT data_left_o=%b", expected_data_left_o, cb.data_left_o);
            $stop;
          end

        if ( expected_data_right_o !== cb.data_right_o )
          begin
            $error("ERROR: expected data_right_o=%b, DUT data_right_o=%b", expected_data_right_o, cb.data_right_o);
            $stop;
          end
      end

  endtask

  initial 
    begin
      clk                   = 0;

      data_i                = 0;
      data_val_i            = 0;

      @( cb );
      cb.srst_i <= 1;

      @( cb );
      cb.srst_i <= 0;

      @( cb );
      if ( cb.data_val_o === 1 )
        begin
          $error("ERROR: expected data_val_o=0, DUT data_val_o=1");
          $stop;
        end

      for( int i = 0; i < TEST_NUM; i++ )
        begin
          $display("TEST %0d", i);
          data_i_local = $urandom_range(2**WIDTH-1, 0);
          data_val_i_local = $urandom_range(1, 0);

          deserialization_test(data_i_local, data_val_i_local);
        end
        $display("ALL TESTS PASSED");
        $stop;
      end

endmodule
