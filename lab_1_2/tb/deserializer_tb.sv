`timescale 1ns/1ns

module deserializer_tb;

  parameter TEST_NUM = 1000;

  bit          clk;

  logic        srst_i;

  logic        data_i;
  logic        data_val_i;

  logic [15:0] deser_data_o;
  logic        deser_data_val_o;

  logic [15:0] data_i_local;
  bit          data_val_i_local;

  logic [4:0]  bit_count;

  deserializer DUT (
    .clk_i            ( clk              ),
    .srst_i           ( srst_i           ),
    .data_i           ( data_i           ),
    .data_val_i       ( data_val_i       ),
    .deser_data_o     ( deser_data_o     ),
    .deser_data_val_o ( deser_data_val_o )
  );

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    output srst_i;

    output data_i;
    output data_val_i;

    input  deser_data_o;
    input  deser_data_val_o;
  endclocking

  task automatic deserialization_test( input logic [15:0] data_i_in, input bit is_dut_reset);
    data_val_i_local =  0;
    bit_count        = '0;
  
    $display("data_i = %b", data_i_in);

    @( cb );
    while ( bit_count < 16 ) 
      begin
        data_val_i_local = $urandom_range(1, 0);

        cb.data_val_i <= data_val_i_local;
        cb.data_i     <= data_i_in[15 - bit_count];

        if ( data_val_i_local )
          bit_count = bit_count + 1;

        /*
          If the DUT has been reset (is_dut_reset == 1), then deser_data_val_o must be 0
          during the first iteration, because no bits have been deserialized yet.

          If the DUT was NOT reset before this test (is_dut_reset == 0), then deser_data_val_o
          must be 1 on the first iteration, because the DUT is holding valid data
          from the previous deserialization test.
        */
        @( cb );
        if ( is_dut_reset )
          begin
            if ( cb.deser_data_val_o === 1 )
              begin
                $error( "ERROR: deser_data_val_o asserted prematurely!)" );
                $display("bit_count = %0d (number of bits sent), 16 bits expected",
                          bit_count );
                $stop;
              end
          end
        else
          begin
            if ( ( bit_count > 1 ) && ( cb.deser_data_val_o === 1 ) )
              begin
                $error( "ERROR: deser_data_val_o asserted prematurely! \n bit_count = %0d (number of bits sent), 16 bits expected.",
                         bit_count );
                $stop;
              end
          end
      end

    cb.data_val_i <= 0;
    
    @( cb );
    @( cb );
    if (cb.deser_data_val_o === 0 )
      begin
        $error("ERROR: Expected deser_data_val_o = 1, DUT deser_data_val_o = 0");
        $display("data_i=%b, bit_count=%d, deser_data_val_o=%b", data_i_in, bit_count, cb.deser_data_val_o);
        $stop;
      end
    if ( cb.deser_data_o != data_i_in )
      begin
        $error("ERROR: Expected deser_data_o = %b, DUT deser_data_o = %b", data_i_in, deser_data_o);
        $stop;
      end

  endtask

  initial 
    begin
      srst_i       =  0;
      
      data_i       =  0;
      data_val_i   =  0;
      data_i_local = '0;

      @( cb );
      cb.srst_i <= 1;
      cb.data_val_i <= 0;

      @( cb );
      cb.srst_i <= 0;

      @( cb );
      $display("setup TEST");
      data_i_local = $urandom_range(16'hFFFF, 0);
      deserialization_test(data_i_local, 1);

      for( int i = 0; i < TEST_NUM; i++ )
        begin
          $display("TEST %0d", i);
          
          data_i_local = $urandom_range(16'hFFFF, 0);

          deserialization_test(data_i_local, 0);
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule
