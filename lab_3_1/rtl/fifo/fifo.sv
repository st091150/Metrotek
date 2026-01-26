module fifo #(
  parameter int   DWIDTH = 32,
  parameter int   AWIDTH = 8,
  
  parameter logic SHOWAHEAD = 1,

  parameter int   ALMOST_FULL_VALUE  = 2 ** AWIDTH - 3,
  parameter int   ALMOST_EMPTY_VALUE = 3,

  parameter logic REGISTER_OUTPUT = 0
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

  logic [PTR_W-1:0]  wr_idx_delay_reg;

  logic              wrreq_delay_reg;
  logic              rdreq_delay_reg;

  logic [DWIDTH-1:0] q_delay_reg;

  logic [PTR_W-1:0]  q_rd_idx;

  logic              hold_last_q;

  logic [DWIDTH-1:0] mem_q;
  
  logic [PTR_W-1:0]  wr_idx;
  logic [PTR_W-1:0]  rd_idx_flag;


  mem #(
    .DWIDTH    ( DWIDTH              ),
    .AWIDTH    ( AWIDTH              )
  ) mem (
    .clk_i     ( clk_i               ),

    .data_i    ( data_i              ),

    .wr_addr_i ( wr_idx[AWIDTH-1:0]  ),
    .wr_ena_i  ( wrreq_i             ),

    .rd_addr_i ( q_rd_idx[AWIDTH-1:0]  ),

    .data_o    ( mem_q               )
  );

  assign full_o  = ( rd_idx_flag[AWIDTH-1:0] == wr_idx[AWIDTH-1:0] ) &&
                   ( rd_idx_flag[PTR_W-1]    != wr_idx[PTR_W-1]    );

  assign empty_o = ( rd_idx_flag == wr_idx_delay_reg );

  assign almost_full_o  = ( usedw_o >= ALMOST_FULL_VALUE )  || ( full_o  );
  
  assign almost_empty_o = ( usedw_o <  ALMOST_EMPTY_VALUE ) && ( !full_o ) ;

  assign q_o = ( (  wrreq_i           ||   wrreq_delay_reg         ) &&
               ( ( !rdreq_delay_reg ) || ( usedw_o == AWIDTH'(1) ) ) ) ? q_delay_reg : mem_q;

  assign q_rd_idx = ( hold_last_q ) ? rd_idx_flag - AWIDTH'(1) : rd_idx_flag;

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        wr_idx <= '0;
      else
        if( ( wrreq_i ) && ( !full_o ) )
          wr_idx <= wr_idx + PTR_W'(1);
    end

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        rd_idx_flag <= '0;
      else
        if( ( rdreq_i ) && ( !empty_o ) )
          rd_idx_flag <= rd_idx_flag + PTR_W'(1);
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

  always_ff @( posedge clk_i )
    begin
      wrreq_delay_reg  <= wrreq_i;
      
      rdreq_delay_reg  <= rdreq_i;

      wr_idx_delay_reg <= wr_idx;

      q_delay_reg      <= mem_q;
    end

endmodule