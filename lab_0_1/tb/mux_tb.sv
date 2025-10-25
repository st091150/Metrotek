`timescale 1ns/1ns

module mux_tb;

  parameter NumTests = 10;

  logic clk;

  logic [1:0]      data0_i;
  logic [1:0]      data1_i;
  logic [1:0]      data2_i;
  logic [1:0]      data3_i;

  logic [3:0][1:0] comb_data;

  logic [1:0]      direction_i;

  logic [1:0]      expected_data;
  logic [1:0]      data_o;

  initial
    forever
      #5 clk = !clk;

  initial 
    begin
      clk           = 0;

      data0_i       = 0;
      data1_i       = 0;
      data2_i       = 0;
      data3_i       = 0;

      comb_data     = 0;

      direction_i   = 0;

      expected_data = 0;
    end

  lab_0 DUT (
    .clk_150mhz_i  ( clk          ),
    .data0_i       ( data0_i      ),
    .data1_i       ( data1_i      ),
    .data2_i       ( data2_i      ),
    .data3_i       ( data3_i      ),
    .direction_i   ( direction_i  ),
    .data_o        ( data_o       )
  );

  initial 
    begin
      for( int i = 1; i < NumTests + 1; i = i + 1 )
        begin
          @(posedge clk );
          $display("TEST %0d", i);

          data0_i = $urandom_range(3,0);
          data1_i = $urandom_range(3,0);
          data2_i = $urandom_range(3,0);
          data3_i = $urandom_range(3,0);

          $display("data0_i=%u data1_i=%u", data0_i, data1_i);
          $display("data2_i=%u data3_i=%u", data2_i, data3_i);

          direction_i = $urandom_range(3,0);

          $display("dir=%u", direction_i);

          comb_data = {data3_i, data2_i, data1_i, data0_i};

          expected_data = comb_data[direction_i];

          #1 // waiting for output(data_o) from DUT 
          $display("expected=%u, output=%u \n", expected_data, data_o);

          if (expected_data !== data_o)
            begin
              $display("FAIL");
              $stop;
            end
        end
        $display("ALL TESTS PASSED");
        $stop;
      end

endmodule