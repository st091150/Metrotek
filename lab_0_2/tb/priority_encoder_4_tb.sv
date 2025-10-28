`timescale 1ns/1ns

function automatic int find_first_one_idx(logic [3:0] data);
  for (int i = 0; i < 4; i++)
    begin
      if (data[i] == 1'b1)
        return i; 
    end
return -1;
endfunction

function automatic int find_last_one_idx(logic [3:0] data);
  for (int i = 3; i >= 0; i--)
    begin
      if (data[i] == 1'b1)
        return i; 
    end
return -1;
endfunction


module priority_encoder_4_tb;

  parameter NumTests = 20;

  logic clk;

  logic [3:0]      data_i;
  logic            data_val_i;

  logic [3:0]      data_left_o;
  logic [3:0]      data_right_o;

  logic            data_val_o;

  int              first_one_idx;
  int              last_one_idx;

  logic [3:0]      expected_data_left_o;
  logic [3:0]      expected_data_right_o;

  logic            expected_val_o;

  initial
    forever
      #5 clk = !clk;

  initial 
    begin
      clk                   = 0;

      data_i                = 0;
      data_val_i            = 0;

      expected_data_left_o  = 0;
      expected_data_right_o = 0;

      expected_val_o        = 0;
    end

  priority_encoder_4 DUT (
    .clk_150mhz_i  ( clk          ),
    .data_i        ( data_i       ),
    .data_val_i    ( data_val_i   ),
    .data_left_o   ( data_left_o  ),
    .data_right_o  ( data_right_o ),
    .data_val_o    ( data_val_o   )
  );

  initial 
    begin
      for( int i = 1; i < NumTests + 1; i = i + 1 )
        begin
          @(posedge clk );
          $display("TEST %0d", i);

          data_i     = $urandom_range(15, 0);
          data_val_i = $urandom_range(1, 0);

          $display("data_i=%b data_val_i=%b", data_i, data_val_i);

          expected_data_left_o   = '0;
          expected_data_right_o  = '0;

          first_one_idx = find_first_one_idx(data_i);
          last_one_idx  = find_last_one_idx(data_i);

          if(data_val_i && first_one_idx != -1)
            begin
              expected_data_left_o[first_one_idx] = 1'b1;
              expected_data_right_o[last_one_idx] = 1'b1;
            end

          expected_val_o = data_val_i;

          #1 // waiting for output from DUT
          $display("expected_data_right_o=%b, data_right_o=%b", expected_data_right_o, data_right_o);
          $display("expected_data_left_o=%b, data_left_o=%b", expected_data_left_o, data_left_o);
          $display("expected_val_o=%u, data_val_o=%u \n", expected_val_o, data_val_o);

          if (expected_data_left_o !== data_left_o   || 
              expected_data_right_o !== data_right_o ||
              expected_val_o !== data_val_o)
            begin
              $display("FAIL");
              $stop;
            end
        end
        $display("ALL TESTS PASSED");
        $stop;
      end

endmodule
