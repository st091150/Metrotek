`timescale 1ns/1ns

module mem_tb;

  localparam int DWIDTH = 32;
  localparam int AWIDTH = 8;
  localparam int DEPTH  = 2 ** AWIDTH;

  logic              clk_i;

  logic [DWIDTH-1:0] data_i;

  logic [AWIDTH-1:0] wr_addr_i;
  logic              wr_ena_i;

  logic [AWIDTH-1:0] rd_addr_i;

  logic [DWIDTH-1:0] data_o;

  mem #(
    .DWIDTH    ( DWIDTH    ),
    .AWIDTH    ( AWIDTH    )
  ) dut (
    .clk_i     ( clk_i     ),
    .data_i    ( data_i    ),
    .wr_addr_i ( wr_addr_i ),
    .wr_ena_i  ( wr_ena_i  ),
    .rd_addr_i ( rd_addr_i ),
    .data_o    ( data_o    )
  );

  initial clk_i = 0;
  always #5 clk_i = ~clk_i;

  initial
    begin
      wr_ena_i  = 0;
      data_i    = '0;
      wr_addr_i = '0;
      rd_addr_i = '0;

      @( posedge clk_i );

      $display("=== WRITE ===");

      wr_ena_i <= 1;
      for ( int i = 0; i < DEPTH; i++ )
        begin
          @( posedge clk_i );
          wr_addr_i <= i[AWIDTH-1:0];
          data_i    <= i[DWIDTH-1:0];
        end

      @( posedge clk_i );
      wr_ena_i <= 0;

      $display("=== READ & CHECK ===");

      for ( int i = 0; i < DEPTH; i++ )
        begin
          rd_addr_i <= i[AWIDTH-1:0];

          @( posedge clk_i );
          @( posedge clk_i );

          if ( data_o !== i[DWIDTH-1:0] )
            begin
              $error("ERROR: addr=%0d exp=%0h got=%0h",
                      i, i[DWIDTH-1:0], data_o);
              $stop;
            end
          else
            $display("OK: addr=%0d data=%0h", i, data_o);
        end

      $display("=== READ & WRITE (SIMULTANEOUS) ===");

      wr_ena_i  <= 1;

      wr_addr_i <= AWIDTH'(0);
      data_i    <= DWIDTH'(1);

      for ( int i = 1; i < DEPTH; i++ )
        begin
          @( posedge clk_i);
          rd_addr_i <= AWIDTH'(i - 1);

          @( posedge clk_i);
          @( posedge clk_i );

          if ( data_o !== i[DWIDTH-1:0] )
            begin
              $error("READ ERROR: rd_addr=%0d exp=%0h got=%0h",
                      i - 1, i[DWIDTH-1:0], data_o);
              $stop;
            end
          else
            $display("OK: addr=%0d data=%0h", i - 1, data_o);

          wr_addr_i <= i[AWIDTH-1:0];
          data_i    <= DWIDTH'(i + 1);

        end

      wr_ena_i <= 0;

      $display("=== TEST FINISHED ===");
      $stop;
    end

endmodule
