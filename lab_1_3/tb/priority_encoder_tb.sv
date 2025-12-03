`timescale 1ns/1ns

module priority_encoder_tb;

  parameter WIDTH    = 16;
  parameter TEST_NUM = 1000;
  
  logic             clk_i;

  logic             srst_i;

  logic [WIDTH-1:0] data_i;
  logic             data_val_i;

  logic [WIDTH-1:0] data_left_o;
  logic [WIDTH-1:0] data_right_o;

  logic             data_val_o;

  logic [WIDTH-1:0] data_i_local;
  logic             data_val_i_local;

  always #5 clk_i = !clk_i;

  priority_encoder #(
    .WIDTH         ( WIDTH        )
  ) DUT (
    .clk_i         ( clk_i        ),
    .srst_i        ( srst_i       ),
    .data_i        ( data_i       ),
    .data_val_i    ( data_val_i   ),
    .data_left_o   ( data_left_o  ),
    .data_right_o  ( data_right_o ),
    .data_val_o    ( data_val_o   )
  );

  function automatic logic [WIDTH-1:0] msb_one_hot(logic [WIDTH-1:0] data);
    logic [WIDTH-1:0] one_hot = '0;
    for (int i = WIDTH-1; i >= 0; i--)
      begin
        if (data[i] == 1'b1)
          begin
            one_hot[i] = 1'b1;
            return one_hot;
          end 
      end
    return one_hot;
  endfunction

  function automatic logic [WIDTH-1:0] lsb_one_hot(logic [WIDTH-1:0] data);
    logic [WIDTH-1:0] one_hot = '0;
    for (int i = 0; i < WIDTH; i++)
      begin
        if (data[i] == 1'b1)
          begin
            one_hot[i] = 1'b1;
            return one_hot;
          end 
      end
    return one_hot;
  endfunction

  clocking cb @(posedge clk_i);
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

    logic [WIDTH-1:0] expected_data_left_o;
    logic [WIDTH-1:0] expected_data_right_o;

    $display("data_i=%b data_val_i=%b", data_i_in, data_val_i_in);

    expected_data_left_o  = msb_one_hot(data_i_in);
    expected_data_right_o = lsb_one_hot(data_i_in);

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
      clk_i      = 0;

      data_i     = 0;
      data_val_i = 0;

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
          data_i_local     = $urandom_range(2**WIDTH-1, 0);
          data_val_i_local = $urandom_range(1, 0);

          deserialization_test(data_i_local, data_val_i_local);
        end
        $display("ALL TESTS PASSED");
        $stop;
      end

endmodule
