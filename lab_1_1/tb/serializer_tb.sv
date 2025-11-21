`timescale 1ns/1ns

module serializer_tb;

  parameter TEST_NUM = 20;

  logic         clk;

  logic         srst_i;
  logic [15:0]  data_i;
  logic [3:0]   data_mod_i;
  logic         data_val_i;

  logic         ser_data_o;
  logic         ser_data_val_o;
  logic         busy_o;

  logic [15:0]  data_i_tb;
  logic [15:0]  expected_data_o;
  logic [15:0]  output_data_o;

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

  initial 
    begin
      clk             =  0;

      srst_i          =  1;
      data_i          = '0;
      data_mod_i      = '0;
      data_val_i      =  0;

      data_i_tb       = '0;
      expected_data_o = '0;
      output_data_o   = '0;
    end

  always
    begin
      #5 
      clk    = ~clk;
      data_i = $urandom_range(16'hFFFF, 0);
    end

  
  clocking cb @(posedge clk);
    output data_i;
    output data_mod_i;
    output srst_i;

    input ser_data_o;
    input ser_data_val_o;
    input busy_o;
  endclocking

  initial 
    begin
      int num_bits;
      for( int i = 0; i < TEST_NUM; i = i + 1 )
        begin
          @( cb )
          cb.srst_i <= 1;
          @( cb );
          cb.srst_i <= 0;
          $display("TEST %0d", i);

          data_mod_i = $urandom_range(15,0);
          data_val_i = $urandom_range(1, 0);

          @( cb )
          cb.data_i     <= data_i;
          cb.data_mod_i <= data_mod_i;

          output_data_o   = '0;
          data_i_tb       = '0;
          expected_data_o = '0;
          
          if( data_val_i == 1 )
            begin
              data_i_tb = data_i;
              if ( data_mod_i == 0 )
                expected_data_o = data_i_tb;
              else
                for ( int k = 0; k < data_mod_i; k++ ) 
                    expected_data_o[15-k] = data_i_tb[15-k];
            end
          else
            expected_data_o = '0;

          num_bits = (data_mod_i == 0) ? 16 : data_mod_i;
          for (int t = 0; t < num_bits; t++) 
            begin
              @(cb);
              if (cb.ser_data_val_o === 1 && cb.busy_o === 1)
                  output_data_o[15 - t] = cb.ser_data_o;
            end

          $display("data_i = %b, data_mod_i = %d, data_val_i = %d, expected_data_o = %b",
                    data_i_tb, data_mod_i, data_val_i, expected_data_o);

          for ( int k = 0; k < data_mod_i ; k++ ) 
            begin
            if ( expected_data_o[15 - k] != output_data_o[15 - k] )
              begin
                $error("ERROR: Expected data_o = %b, DUT data_o = %b",
                        expected_data_o, output_data_o);
                $stop;
              end
            end
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule
