module wrapper #(
  parameter int DWIDTH = 8,
  parameter int AWIDTH = 4
)(
  input  logic              clk_i,

  input  logic [DWIDTH-1:0] data_i_ext,
  input  logic [AWIDTH-1:0] wr_addr_i_ext,
  input  logic              wr_ena_i_ext,
  input  logic [AWIDTH-1:0] rd_addr_i_ext,

  output logic [DWIDTH-1:0] data_o_ext
);

  logic [DWIDTH-1:0] data_i_r;
  logic [AWIDTH-1:0] wr_addr_i_r;
  logic              wr_ena_i_r;
  logic [AWIDTH-1:0] rd_addr_i_r;

  logic [DWIDTH-1:0] data_o_int;

  mem #(
    .DWIDTH    ( DWIDTH       ),
    .AWIDTH    ( AWIDTH       )
  ) DUT (
    .clk_i     ( clk_i        ),
    .data_i    ( data_i_r     ),
    .wr_addr_i ( wr_addr_i_r  ),
    .wr_ena_i  ( wr_ena_i_r   ),
    .rd_addr_i ( rd_addr_i_r  ),
    .data_o    ( data_o_int   )
  );

  always_ff @( posedge clk_i )
    begin
    data_i_r    <= data_i_ext;
    wr_addr_i_r <= wr_addr_i_ext;
    wr_ena_i_r  <= wr_ena_i_ext;
    rd_addr_i_r <= rd_addr_i_ext;

    data_o_ext  <= data_o_int;
    end

endmodule
