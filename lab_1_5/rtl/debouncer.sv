module debouncer #(
  parameter int CLK_FREQ_MHZ   = 150,
  parameter int GLITCH_TIME_NS = 100
)(
  input  logic clk_i,
  input  logic key_i,
  output logic key_pressed_stb_o
);

  localparam int GLITCH_CYCLES_RAW = ( CLK_FREQ_MHZ * GLITCH_TIME_NS ) / 1000;
  localparam int GLITCH_CYCLES     = ( GLITCH_CYCLES_RAW == 0 ) ? 1 : GLITCH_CYCLES_RAW;

  logic [$clog2(GLITCH_CYCLES):0] glitch_counter = '0;

  logic key_stable  = 1'b1;
  
  logic key_sync_0  = 1'b1;
  logic key_sync_1  = 1'b1;

  always_ff @( posedge clk_i )
    begin
      key_sync_0 <= key_i;
      key_sync_1 <= key_sync_0;
    end

  always_ff @( posedge clk_i )
    begin
      if ( ( key_sync_1 == key_stable ) || ( glitch_counter + 1 == GLITCH_CYCLES ) )
        glitch_counter <= 0;
      else
        glitch_counter <= glitch_counter + 1'b1;
    end

  always_ff @( posedge clk_i )
    begin
      key_pressed_stb_o <= 1'b0;

      if ( ( key_sync_1 != key_stable ) && ( glitch_counter + 1 == GLITCH_CYCLES ) )
        begin
          key_stable <= key_sync_1;

          if (key_sync_1 == 1'b0)
            key_pressed_stb_o <= 1'b1;
        end
    end

endmodule
