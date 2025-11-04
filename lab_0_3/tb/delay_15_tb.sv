`timescale 1ns/1ns

module delay_15_tb;

  parameter NumTests = 50;

  logic clk;

  logic            data_i;
  logic [3:0]      data_delay_i;
  logic            rst_i;

  logic            data_o;

  logic            val_o;
  initial
    forever
      #5 clk = !clk;

  initial 
    begin
      clk                   = 0;

      data_i                = 0;
      data_delay_i          = 0;
      rst_i                 = 1;

      val_o                 = 0;
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
      for( int i = 1; i < NumTests + 1; i = i + 1 )
        begin
          @( posedge clk );
          $display("TEST %0d", i);

          data_i       = $urandom_range(1, 0);
          data_delay_i = $urandom_range(15, 0);
          rst_i        = 1;
          val_o        = 0;

          $display("data_i=%d data_delay_i=%d", data_i, data_delay_i);
          for ( int j = 0; j < 16; j = j + 1 )
            begin
              @( posedge clk );
              #1 // waiting for output from DUT
              if( data_o === 1)
                begin
                  if ( j >= data_delay_i)
                    begin
                      if (j === data_delay_i)
                        val_o = 1;
                    end
                  else
                    begin
                      $display("data_delay_i=%d data_o=%d delay=%2d", data_delay_i, data_o, j);
                      $display("FAIL");
                      $stop;
                    end
                end
            end
          if( data_i === 1 && val_o === 0 )
            begin
              $display("FAIL");
              $stop;
            end
          @( negedge clk );
          rst_i = 0;
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule
