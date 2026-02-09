module fifo #(
  parameter int DWIDTH = 32,
  parameter int AWIDTH = 8,
  
  parameter bit SHOWAHEAD = 1,

  parameter int ALMOST_FULL_VALUE  = 2 ** AWIDTH - 3,
  parameter int ALMOST_EMPTY_VALUE = 3,

  parameter bit REGISTER_OUTPUT = 0

)(
  input  logic              clk_i,

  input  logic              srst_i,

  input  logic [DWIDTH-1:0] data_i,

  input  logic              wrreq_i,
  input  logic              rdreq_i,

  output logic [DWIDTH-1:0] q_o,

  output logic              empty_o,
  output logic              full_o,

  output logic [AWIDTH-1:0] usedw_o,

  output logic              almost_full_o,
  output logic              almost_empty_o
);

  localparam PTR_W = AWIDTH + 1;

  logic              full_o_next;
  logic              empty_o_next;

  logic              almost_full_o_next;
  logic              almost_empty_o_next;
  
  logic              hold_last_q;

  logic [AWIDTH-1:0] usedw_next;

  logic [PTR_W-1:0]  wr_idx;
  logic [PTR_W-1:0]  rd_idx;

  logic [PTR_W-1:0]  wr_idx_next;
  logic [PTR_W-1:0]  rd_idx_next;

  logic [PTR_W-1:0]  mem_rd_idx;

  mem #(
    .DWIDTH    ( DWIDTH                 ),
    .AWIDTH    ( AWIDTH                 )
  ) mem (
    .clk_i     ( clk_i                  ),

    .data_i    ( data_i                 ),

    .wr_addr_i ( wr_idx[AWIDTH-1:0]     ),
    .wr_ena_i  ( wrreq_i                ),

    .rd_addr_i ( mem_rd_idx[AWIDTH-1:0] ),

    .data_o    ( q_o                    )
  );

  assign wr_idx_next = wr_idx + ( (wrreq_i && !full_o)  ? PTR_W'(1) : PTR_W'(0) );

  assign rd_idx_next = rd_idx + ( (rdreq_i && !empty_o) ? PTR_W'(1) : PTR_W'(0) );
  
  assign full_o_next  = ( rd_idx_next[AWIDTH-1:0] == wr_idx_next[AWIDTH-1:0] ) &&
                        ( rd_idx_next[PTR_W-1]    != wr_idx_next[PTR_W-1]   );

  assign empty_o_next = ( rd_idx_next == wr_idx );

  assign almost_full_o_next  = ( usedw_next >= ALMOST_FULL_VALUE )  || full_o_next;

  assign almost_empty_o_next = ( usedw_next <  ALMOST_EMPTY_VALUE ) && !full_o_next;

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        wr_idx <= '0;
      else
        wr_idx <= wr_idx_next;
    end

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        rd_idx <= '0;
      else
        rd_idx <= rd_idx_next;
    end

  always_comb
    begin
      if ( usedw_o == 1 && rdreq_i )
        mem_rd_idx = rd_idx;
      else if ( hold_last_q )
        mem_rd_idx = rd_idx - PTR_W'(1);
      else 
        mem_rd_idx = rd_idx_next;
    end

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        hold_last_q <= 1'b0;
      else
        if( ( usedw_o == 1 ) && ( rdreq_i ) && ( !wrreq_i ) )
          hold_last_q <= 1'b1;
        else if ( wrreq_i )
          hold_last_q <= 1'b0;
    end

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        usedw_o <= '0;
      else
        case ( { wrreq_i, rdreq_i } )
          2'b10:   usedw_o <= usedw_o + AWIDTH'(1);
          2'b01:   usedw_o <= usedw_o - AWIDTH'(1);
          default: usedw_o <= usedw_o;
        endcase
    end

  always_comb
  begin
    usedw_next = usedw_o;
    case ( { wrreq_i, rdreq_i } )
      2'b10:   usedw_next = usedw_o + AWIDTH'(1);
      2'b01:   usedw_next = usedw_o - AWIDTH'(1);
      default: usedw_next = usedw_o;
    endcase
  end

  always_ff @( posedge clk_i )
    begin
      almost_full_o    <= almost_full_o_next;

      almost_empty_o   <= almost_empty_o_next;

      full_o           <= full_o_next;

      empty_o          <= empty_o_next;
    end

endmodule
