`timescale 1ns/1ns

module deserializer_tb;

  parameter TEST_NUM = 10000;

  bit          clk;

  logic        srst_i;

  logic        data_i;
  logic        data_val_i;

  logic [15:0] deser_data_o;
  logic        deser_data_val_o;

  logic [15:0] data_i_local;

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

  task automatic deserialization_test( input logic [15:0] data_i_in, input bit fixed_data_val_i, input bit is_dut_reset);

    bit          data_val_i_local;
    logic [4:0]  bit_count;

    data_val_i_local =  0;
    bit_count        = '0;
  
    $display("data_i = %b", data_i_in);

    if ( ( is_dut_reset == 1 ) && ( cb.deser_data_val_o === 1 ) )
      begin
        $error("ERROR: Expected deser_data_val_o = 0, DUT deser_data_val_o = 1");
        $display("data_i=%b, bit_count=%d, deser_data_val_o=%b", data_i_in, bit_count, cb.deser_data_val_o);
        $stop;
      end

    while ( bit_count < 16 ) 
      begin
        data_val_i_local = ( fixed_data_val_i ) ? 1'b1 : $urandom_range(1, 0);

        cb.data_val_i <= data_val_i_local;
        cb.data_i     <= data_i_in[15 - bit_count];

        @( cb );
        if ( cb.deser_data_val_o === 1 )
          begin
            if ( ( ( is_dut_reset == 0 ) && ( bit_count != 15 ) && ( bit_count != 0 ) ) ||
                 ( ( is_dut_reset == 1 ) && ( bit_count == 0 ) ) )
              begin
                $error("ERROR: Expected deser_data_val_o = 0, DUT deser_data_val_o = 1");
                $display("data_i=%b, bit_count=%d, deser_data_val_o=%b", data_i_in, bit_count, cb.deser_data_val_o);
                $stop;
              end
          end

        if ( data_val_i_local )
          bit_count = bit_count + 1;
      end

    cb.data_val_i <= 0;

    @( cb );
    if ( cb.deser_data_val_o === 0 )
      begin
        $error("ERROR: Expected deser_data_val_o = 1, DUT deser_data_val_o = 0");
        $display("data_i=%b, bit_count=%d, deser_data_val_o=%b", data_i_in, bit_count, cb.deser_data_val_o);
        $stop;
      end
      
    if ( cb.deser_data_o !== data_i_in )
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

      @( cb );
      cb.srst_i <= 1;

      @( cb );
      cb.srst_i <= 0;

      @( cb );
      $display("setup TEST");
      data_i_local = $urandom_range(16'hFFFF, 0);
      deserialization_test(data_i_local, 1, 1);

      for( int i = 0; i < TEST_NUM; i++ )
        begin
          $display("TEST %0d", i);
          
          data_i_local = $urandom_range(16'hFFFF, 0);

          deserialization_test(data_i_local, 0, 0);
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule
