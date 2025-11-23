`timescale 1ns/1ns

module serializer_tb;

  parameter TEST_NUM = 20;

  bit          clk;

  logic        srst_i;

  logic [15:0] data_i;
  logic [3:0]  data_mod_i;
  logic        data_val_i;

  logic        ser_data_o;
  logic        ser_data_val_o;

  logic        busy_o;

  logic [15:0] data_i_local;
  logic [15:0] data_i_fixed;
  logic [3:0]  data_mod_i_local;
  logic        data_val_i_local;

  logic [15:0] expected_data_o;
  logic [15:0] output_data_o;

  int           num_bits;
  serializer DUT (
    .clk_i          ( clk            ),
    .srst_i         ( srst_i         ),
    .data_i         ( data_i         ),
    .data_mod_i     ( data_mod_i     ),
    .data_val_i     ( data_val_i     ),
    .ser_data_o     ( ser_data_o     ),
    .ser_data_val_o ( ser_data_val_o ),
    .busy_o         ( busy_o         )
  );

  always #5 clk = ~clk;

  initial 
    begin
      forever 
        begin
          @(posedge clk) 
          data_i_local <= $urandom_range(16'hFFFF, 0);
        end
    end

  clocking cb @(posedge clk);
    output data_i;
    output data_mod_i;
    output data_val_i;

    output srst_i;

    input ser_data_o;
    input ser_data_val_o;

    input busy_o;
  endclocking

  initial 
    begin
      srst_i           =  1;
      
      data_i           =  0;
      data_mod_i       = '0;
      data_val_i       =  0;

      data_i_local     = '0;
      data_i_fixed     = '0;
      data_mod_i_local = '0;
      data_val_i_local =  0;

      for( int i = 0; i < TEST_NUM; i++ )
        begin
          expected_data_o = '0;
          output_data_o   = '0;

          @( cb )
          cb.srst_i <= 1;

          @( cb );
          cb.srst_i <= 0;
          $display("TEST %0d", i);

          data_mod_i_local = $urandom_range(15, 0);
          data_val_i_local = $urandom_range(1, 0);

          @ ( cb );
          cb.data_i     <= data_i_local;
          cb.data_mod_i <= data_mod_i_local;
          cb.data_val_i <= data_val_i_local;

          if( cb.busy_o === 1 )
            begin
              $error("ERROR: Expected busy_o = 0, DUT busy_o = 1");
              $stop;
            end

          if( data_val_i_local )
            begin
              data_i_fixed = data_i_local;

              if ( data_mod_i_local == 0 )
                expected_data_o = data_i_fixed;
              else if ( data_mod_i_local <= 2 )
                expected_data_o = '0;
              else
                for ( int k = 0; k < data_mod_i_local; k++ ) 
                    expected_data_o[15-k] = data_i_fixed[15-k];
            end
          else
            expected_data_o = '0;
          
          @( cb )
            cb.data_val_i <= 0;

          $display("data_i = %b, data_mod_i = %d, data_val_i = %d, expected_data_o = %b",
                    data_i_fixed, data_mod_i_local, data_val_i_local, expected_data_o);

          num_bits = ( data_mod_i_local == 0 ) ? 16 : data_mod_i_local;

          for (int t = 0; t < num_bits; t++) 
            begin
              @( cb );
              if ( data_val_i_local && ( data_mod_i_local !== 1 ) && ( data_mod_i_local !== 2 ) && ( cb.busy_o === 0 ) )
                begin
                  $error("ERROR: Expected busy_o = 1, DUT busy_o = 0");
                  $stop;
                end
              if ( cb.ser_data_val_o === 1 )
                begin
                  if ( ( num_bits == 1 ) || ( num_bits == 2 ) )
                    begin
                      $error("ERROR: Expected ser_data_val_o = 0 when data_mod_i in [1, 2], DUT ser_data_val_o = 1");
                      $stop;
                    end
                  output_data_o[15 - t] = cb.ser_data_o;
                  if( output_data_o[15 - t] != expected_data_o[15 - t] )
                    begin
                      $error("ERROR: Expected data_o = %b, DUT data_o = %b, on idx=%d",
                        expected_data_o, output_data_o, 15 - t);
                      $stop;
                    end
                end
            end
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule
