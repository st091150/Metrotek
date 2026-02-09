module mem #(
  parameter int DWIDTH = 32,
  parameter int AWIDTH = 8
)(
  input  logic              clk_i,

  input  logic [DWIDTH-1:0] data_i,

  input  logic [AWIDTH-1:0] wr_addr_i,
  input  logic              wr_ena_i,

  input  logic [AWIDTH-1:0] rd_addr_i,

  output logic [DWIDTH-1:0] data_o
);

  localparam int DEPTH = 2 ** AWIDTH;

  (* ramstyle = "M10K" *)
  logic [DWIDTH-1:0] mem [DEPTH-1:0];

  always_ff @( posedge clk_i ) 
    begin
      if ( wr_ena_i )
        mem[wr_addr_i] <= data_i;

      data_o <= mem[rd_addr_i];
    end

endmodule
