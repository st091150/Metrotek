module wrapper #(
  parameter int unsigned BLINK_HALF_PERIOD_MS  = 500,
  parameter int unsigned BLINK_GREEN_TIME_TICK = 3,
  parameter int unsigned RED_YELLOW_MS         = 2000
)(
  input  logic        clk_i,
  input  logic        srst_i,

  input  logic [2:0]  cmd_type_i_ext,
  input  logic        cmd_valid_i_ext,
  input  logic [15:0] cmd_data_i_ext,

  output logic        red_o_ext,
  output logic        yellow_o_ext,
  output logic        green_o_ext
);

  logic [2:0]  cmd_type_i_r;
  logic        cmd_valid_i_r;
  logic [15:0] cmd_data_i_r;

  logic red_o_int;
  logic yellow_o_int;
  logic green_o_int;

  traffic_lights #(
    .BLINK_HALF_PERIOD_MS  ( BLINK_HALF_PERIOD_MS  ),
    .BLINK_GREEN_TIME_TICK ( BLINK_GREEN_TIME_TICK ),
    .RED_YELLOW_MS         ( RED_YELLOW_MS         )
  ) DUT (
    .clk_i       ( clk_i        ),
    .srst_i      ( srst_i       ),
    .cmd_type_i  ( cmd_type_i_r ),
    .cmd_valid_i ( cmd_valid_i_r),
    .cmd_data_i  ( cmd_data_i_r ),
    .red_o       ( red_o_int    ),
    .yellow_o    ( yellow_o_int ),
    .green_o     ( green_o_int  )
  );

  always_ff @( posedge clk_i )
    begin
      cmd_type_i_r  <= cmd_type_i_ext;
      cmd_valid_i_r <= cmd_valid_i_ext;
      cmd_data_i_r  <= cmd_data_i_ext;

      red_o_ext     <= red_o_int;
      yellow_o_ext  <= yellow_o_int;
      green_o_ext   <= green_o_int;
    end

endmodule
