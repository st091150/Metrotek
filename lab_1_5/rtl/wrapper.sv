module wrapper #(
  parameter int CLK_FREQ_MHZ   = 150,
  parameter int GLITCH_TIME_NS = 100
)(
  input  logic clk_i,
  input  logic key_i_ext,
  output logic key_pressed_stb_o_ext
);

  logic key_i_r;
  logic key_pressed_stb_o_int;

  debouncer #(
    .CLK_FREQ_MHZ   ( CLK_FREQ_MHZ   ),
    .GLITCH_TIME_NS ( GLITCH_TIME_NS )
  ) DUT (
    .clk_i             ( clk_i                 ),
    .key_i             ( key_i_r               ),
    .key_pressed_stb_o ( key_pressed_stb_o_int )
  );

  always_ff @( posedge clk_i )
    begin
      key_i_r               <= key_i_ext;
      key_pressed_stb_o_ext <= key_pressed_stb_o_int;
    end

endmodule
