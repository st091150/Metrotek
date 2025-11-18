`timescale 1ns/1ns



module CRC_16_ANSI_tb;

  parameter TEST_NUM = 10;
  parameter INPUT_DATA_LEN = 10;

  logic        clk;

  logic        data_i;
  logic        rst_i;

  logic [15:0] data_o;

  function automatic logic [15:0] crc16_update(
      input logic [15:0] crc_in,
      input logic bit_in
  );
      logic [15:0] crc;
      logic fb;

      crc = crc_in;

      fb = crc[0] ^ bit_in;
      crc = crc >> 1;
      if (fb)
         crc = crc ^ 16'h8005;

      return crc;
  endfunction

  clocking cb @(posedge clk);
      output data_i;
      output rst_i;

      input  data_o;
  endclocking

  initial
    forever
      #5 clk = !clk;

  initial 
    begin
      clk             = 0;

      data_i          = 0;
      rst_i           = 1;
    end
  
  CRC_16_ANSI DUT (
    .clk_i         ( clk          ),
    .data_i        ( data_i       ),
    .rst_i         ( rst_i        ),
    .data_o        ( data_o       )
  );

  initial 
    begin
      for( int i = 0; i < TEST_NUM; i = i + 1 )
        begin
          automatic logic [15:0] crc_ref = 16'hFFFF;
          @( cb );
          $display("TEST %0d", i);
          cb.rst_i <= 1;
          @( cb );
          cb.rst_i <= 0;

          for ( int j = 0; j < INPUT_DATA_LEN; j = j + 1 )
            begin
              cb.data_i <= $urandom_range(1, 0);
              @( cb );
              crc_ref = crc16_update(crc_ref, cb.data_i);
              $display("Cycle %0d  expected CRC: bin=%b | hex=%h, data_o: bin=%b | hex=%h",
                        j, crc_ref, crc_ref, cb.data_o, cb.data_o);
              if (cb.data_o !== crc_ref) 
                begin
                  $error("ERROR at cycle %0d: Expected CRC=%h, Got=%h",
                  j, crc_ref, cb.data_o);
                  $stop;
                end
            end
        end
        $display("ALL TESTS PASSED");
        $stop;
    end

endmodule


