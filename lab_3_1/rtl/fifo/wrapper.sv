module wrapper #(
  parameter int   DWIDTH = 8,
  parameter int   AWIDTH = 4,

  parameter logic SHOWAHEAD = 1,

  parameter int   ALMOST_FULL_VALUE  = 1,
  parameter int   ALMOST_EMPTY_VALUE = 1,

  parameter logic REGISTER_OUTPUT = 0
)(
  input  logic              clk_i,
  input  logic              srst_i,

  input  logic [DWIDTH-1:0] data_i_ext,
  input  logic              wrreq_i_ext,
  input  logic              rdreq_i_ext,

  output logic [DWIDTH-1:0] q_o_ext,
  output logic              empty_o_ext,
  output logic              full_o_ext,
  output logic [AWIDTH-1:0] usedw_o_ext,
  output logic              almost_full_o_ext,
  output logic              almost_empty_o_ext
);

  logic [DWIDTH-1:0] data_i_r;
  logic              wrreq_i_r;
  logic              rdreq_i_r;

  logic [DWIDTH-1:0] q_o_int;
  logic              empty_o_int;
  logic              full_o_int;
  logic [AWIDTH-1:0] usedw_o_int;
  logic              almost_full_o_int;
  logic              almost_empty_o_int;

  fifo #(
    .DWIDTH             ( DWIDTH             ),
    .AWIDTH             ( AWIDTH             ),
    .SHOWAHEAD          ( SHOWAHEAD          ),
    .ALMOST_FULL_VALUE  ( ALMOST_FULL_VALUE  ),
    .ALMOST_EMPTY_VALUE ( ALMOST_EMPTY_VALUE ),
    .REGISTER_OUTPUT    ( REGISTER_OUTPUT    )
  ) DUT (
    .clk_i              ( clk_i              ),
    .srst_i             ( srst_i             ),
    .data_i             ( data_i_r           ),
    .wrreq_i            ( wrreq_i_r          ),
    .rdreq_i            ( rdreq_i_r          ),
    .q_o                ( q_o_int            ),
    .empty_o            ( empty_o_int        ),
    .full_o             ( full_o_int         ),
    .usedw_o            ( usedw_o_int        ),
    .almost_full_o      ( almost_full_o_int  ),
    .almost_empty_o     ( almost_empty_o_int )
  );

  always_ff @( posedge clk_i )
    begin
        data_i_r   <= data_i_ext;
        wrreq_i_r  <= wrreq_i_ext;
        rdreq_i_r  <= rdreq_i_ext;

        q_o_ext            <= q_o_int;
        empty_o_ext        <= empty_o_int;
        full_o_ext         <= full_o_int;
        usedw_o_ext        <= usedw_o_int;
        almost_full_o_ext  <= almost_full_o_int;
        almost_empty_o_ext <= almost_empty_o_int;
    end

endmodule
