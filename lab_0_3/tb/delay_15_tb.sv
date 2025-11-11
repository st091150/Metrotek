`timescale 1ns/1ns

module delay_15_tb;

  parameter TEST_NUM = 50;
  parameter DELAY_HOLD = 32;

  logic clk;

  logic        data_i;
  logic [3:0]  data_delay_i;
  logic        rst_i;

  logic        data_o;

  logic        queue[$:16];
  logic        queue_top_el;

  int          delay_hold;

  initial
    forever
      #5 clk = !clk;

  default clocking cb @( posedge clk );
  endclocking

  always @( posedge clk )
    begin
      data_i = $urandom_range(1, 0);
  end

  initial 
    begin
      clk                   = 0;

      data_i                = 0;
      data_delay_i          = 0;
      rst_i                 = 1;

      queue_top_el          = 0;
    end
  
  delay_15 DUT (
    .clk_i         ( clk          ),
    .data_i        ( data_i       ),
    .rst_i         ( rst_i        ),
    .data_delay_i  ( data_delay_i ),
    .data_o        ( data_o       )
  );

  initial 
    begin
      for( int i = 0; i < TEST_NUM; i = i + 1 )
        begin
          @( posedge clk );
          $display("TEST %0d", i);

          data_delay_i = $urandom_range(15, 1);
          rst_i        = 1;
          queue.delete();

          @( posedge clk );
          rst_i        = 0;
          $display("data_delay_i=%d delay_hold=%2d", data_delay_i, delay_hold);
          for ( int j = 0; j < DELAY_HOLD; j = j + 1 )
            begin
              @( posedge clk );
              $display("data_i=%1d", data_i);
              ##0 queue.push_back(data_i);
              $display("queue=%p j=%2d data_o=%1d top_el=%1d", queue, j, data_o, queue_top_el);
              if( j >= data_delay_i )
                begin
                  queue_top_el = queue.pop_front();
                  if ( data_o !== queue_top_el)
                    begin
                      $error("data_delay_i=%2d delay_hold=%2d data_o=%2d queue_top_el=%2d j=%2d queue=%p",
                              data_delay_i, delay_hold, data_o, queue_top_el, j, queue);
                      $error("FAIL");
                      $stop;
                    end
                end
            end
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule
