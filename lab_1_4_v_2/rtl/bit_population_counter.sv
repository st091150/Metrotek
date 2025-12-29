
module bit_population_counter #(
  parameter int WIDTH = 128
)(
  input  logic                   clk_i,
  input  logic                   srst_i,

  input  logic [WIDTH-1:0]       data_i,
  input  logic                   data_val_i,

  output logic [$clog2(WIDTH):0] data_o,
  output logic                   data_val_o
);

  localparam int BLOCK_W_STAGE_1         = 8;
  localparam int BLOCKS_STAGE_1          = WIDTH / BLOCK_W_STAGE_1;
  localparam int LAST_BLOCK_BITS_STAGE_1 = WIDTH % BLOCK_W_STAGE_1;
  localparam int BLOCKS_STAGE_1_TOTAL    = BLOCKS_STAGE_1 + (LAST_BLOCK_BITS_STAGE_1 ? 1 : 0);

  localparam int BLOCK_W_STAGE_2         = 4;
  localparam int BLOCKS_STAGE_2          = BLOCKS_STAGE_1_TOTAL / BLOCK_W_STAGE_2;
  localparam int LAST_BLOCK_BITS_STAGE_2 = BLOCKS_STAGE_1_TOTAL % BLOCK_W_STAGE_2;
  localparam int BLOCKS_STAGE_2_TOTAL    = BLOCKS_STAGE_2 + (LAST_BLOCK_BITS_STAGE_2 ? 1 : 0);

  logic [$clog2(BLOCK_W_STAGE_1):0] pc_stage1   [BLOCKS_STAGE_1_TOTAL];
  logic [$clog2(BLOCK_W_STAGE_1):0] pc_stage1_r [BLOCKS_STAGE_1_TOTAL];

  logic data_val_d1;

  always_comb
    begin
      for ( int b = 0; b < BLOCKS_STAGE_1; b++ )
        begin
          pc_stage1[b] = '0;

          for ( int i = 0; i < BLOCK_W_STAGE_1; i++ )
            pc_stage1[b] += data_i[ ( b * BLOCK_W_STAGE_1) + i ];
        end
      
      if ( LAST_BLOCK_BITS_STAGE_1 )
        begin
          pc_stage1[BLOCKS_STAGE_1] = '0;

          for ( int i = 0; i < LAST_BLOCK_BITS_STAGE_1; i++ )
            pc_stage1[BLOCKS_STAGE_1] += data_i[ ( BLOCKS_STAGE_1 * BLOCK_W_STAGE_1 ) + i ];
        end
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        data_val_d1 <= 1'b0;
      else
        data_val_d1 <= data_val_i;
    end

  always_ff @( posedge clk_i )
    begin
      for ( int b = 0; b < BLOCKS_STAGE_1_TOTAL; b++ )
        pc_stage1_r[b] <= pc_stage1[b];
    end

  logic [$clog2(BLOCK_W_STAGE_1 * BLOCK_W_STAGE_2):0] pc_stage2   [BLOCKS_STAGE_2_TOTAL];
  logic [$clog2(BLOCK_W_STAGE_1 * BLOCK_W_STAGE_2):0] pc_stage2_r [BLOCKS_STAGE_2_TOTAL];

  logic data_val_d2;

  always_comb
    begin
      for ( int b = 0; b < BLOCKS_STAGE_2; b++ )
        begin
          pc_stage2[b] = '0;

          for ( int i = 0; i < BLOCK_W_STAGE_2; i++ )
            pc_stage2[b] += pc_stage1_r[ ( b * BLOCK_W_STAGE_2 ) + i ];
        end

      if ( LAST_BLOCK_BITS_STAGE_2 )
        begin
          pc_stage2[BLOCKS_STAGE_2] = '0;

          for ( int i = 0; i < LAST_BLOCK_BITS_STAGE_2; i++ )
            pc_stage2[BLOCKS_STAGE_2] += pc_stage1_r[ ( BLOCKS_STAGE_2 * BLOCK_W_STAGE_2 ) + i ];
        end
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        data_val_d2 <= 1'b0;
      else
        data_val_d2 <= data_val_d1;
    end

  always_ff @( posedge clk_i )
    begin
      for ( int b = 0; b < BLOCKS_STAGE_2_TOTAL; b++ )
        pc_stage2_r[b] <= pc_stage2[b];
    end

  logic [$clog2(WIDTH):0] pop_count;

  always_comb
    begin
      pop_count = '0;

      for ( int b = 0; b < BLOCKS_STAGE_2_TOTAL; b++ )
        pop_count += pc_stage2_r[b];
    end

  always_ff @( posedge clk_i ) 
    begin
      if ( srst_i )
        data_val_o <= 1'b0;
      else
        data_val_o <= data_val_d2;
    end

  always_ff @( posedge clk_i ) 
    data_o <= pop_count;

endmodule
