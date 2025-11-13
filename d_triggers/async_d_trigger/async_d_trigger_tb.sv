`timescale 1ns/1ns

module async_d_trigger_tb;
  logic clk;
  logic rst_i;
  logic d_i;
  logic q_o;

  async_d_trigger DUT (
      .clk_i ( clk   ),
      .rst_i ( rst_i ),
      .d_i   ( d_i   ),
      .q_o   ( q_o   )
  );

  always #5 clk = ~clk;

  initial
     begin
       clk   = 0;
       rst_i = 0;
       d_i   = 0;
     end

  initial 
    begin
      $display("DFF ASYNC TESTS");

      // rst = 1 => q_o = 0
      rst_i = 1;
      d_i   = 1;

      @( posedge clk );
      #1;
      if( q_o == 1 )
        $error("FAIL: q_o = 1 & rst = 1");

      // rst = 0 => q_o = d_i
      rst_i = 0;
      d_i   = 1; 
      @( posedge clk );
      #1;
      if( q_o == 0 )
        begin
          $error("FAIL: q_o = 0 & rst = 0");
          $stop;
        end

      d_i = 0; 
      @( posedge clk );
      #1;
      if( q_o == 1 )
        begin
          $error("FAIL: q_o = 1 && rst = 0");
          $stop;
        end

      // reset inside the clock cycle
      d_i = 1; 
      @( posedge clk ); // q_o = 1
      #1
      rst_i = 1;
      #1;
      if( q_o == 1 )
        begin
          $error("FAIL: q_o has't changed within the clock cycle");
          $stop;
        end
      @( posedge clk );
      #1;
      if( q_o == 1 )
        begin
          $error("FAIL: q_o = 1 && rst=1");
          $stop;
        end

      $display("ALL TESTS PASSED");
      $stop;
    end
endmodule
