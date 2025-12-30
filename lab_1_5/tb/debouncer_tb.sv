`timescale 1ns/1ns

module debouncer_tb;

  parameter int CLK_FREQ_MHZ   = 150;
  parameter int GLITCH_TIME_NS = 100;
  
  localparam int GLITCH_CYCLES = ( CLK_FREQ_MHZ * GLITCH_TIME_NS ) / 1000;
  
  logic clk_i;

  logic key_i;
  logic key_pressed_stb_o;

  debouncer #(
    .CLK_FREQ_MHZ      ( CLK_FREQ_MHZ      ),
    .GLITCH_TIME_NS    ( GLITCH_TIME_NS    )
  ) DUT (
    .clk_i             ( clk_i             ),
    .key_i             ( key_i             ),
    .key_pressed_stb_o ( key_pressed_stb_o )
  );

  always #( 1000 / ( 2 * CLK_FREQ_MHZ ) ) clk_i = ~clk_i;

  task automatic check_strobe_n( input int n );
    begin
      repeat (n)
        begin
          @( posedge clk_i );
          if ( key_pressed_stb_o !== 0 )
            begin
              $error("Error: Expected key_pressed_stb_o: 0, DUT key_pressed_stb_o: 1");
              $stop();
            end
        end
    end
  endtask

  task automatic idle_state();
    begin
      key_i = 1'b1;

      check_strobe_n(GLITCH_CYCLES);
    end
  endtask

  task automatic clean_press();
    begin
      key_i = 1'b0;

      check_strobe_n(GLITCH_CYCLES + 2);

      @( posedge clk_i )

      if ( key_pressed_stb_o !== 1 )
        begin
          $error("Clean press error: Expected key_pressed_stb_o: 1, DUT key_pressed_stb_o: 0");
          $stop();
        end
      
      @( posedge clk_i );

      idle_state();
    end
  endtask

  task automatic glitch_press();
    begin
      key_i = 1'b1;

      repeat (3) 
        begin
          key_i = 1'b0;
          check_strobe_n(GLITCH_CYCLES/4);

          key_i = 1'b1;
          check_strobe_n(GLITCH_CYCLES/4);
        end

      key_i = 1'b0;
      check_strobe_n(GLITCH_CYCLES + 2);

      @( posedge clk_i );

      if ( key_pressed_stb_o !== 1 )
        begin
          $error("Glitch press error: Expected key_pressed_stb_o: 1, DUT key_pressed_stb_o: 0");
          $stop();
        end
      
      @( posedge clk_i );

      idle_state();
    end
  endtask

  task automatic long_press();
    begin
      int strobe_counter = 0;
      key_i = 1'b0;
      
      for ( int i = 0; i < GLITCH_CYCLES * 3; i++ )
        begin
          @( posedge clk_i );

          if( key_pressed_stb_o === 1 )
            begin
              strobe_counter++;
              if ( strobe_counter > 1 )
                begin
                  $error("Long press error: expected exactly 1 key_pressed_stb_o pulse, got %0d", strobe_counter);
                  $stop();
                end
            end
        end

      if ( strobe_counter == 0 )
        begin
          $error("Long press error: expected exactly 1 key_pressed_stb_o pulse, got 0");
          $stop();
        end
    end
  endtask

  initial
    begin
      clk_i = 0;

      key_i = 1;

      @( posedge clk_i );

      idle_state();

      clean_press();
      $display("Clean press test passed");

      glitch_press();
      $display("Glitch press test passed");

      long_press();
      $display("Long press test passed");

      idle_state();

      $display("ALL TESTS PASSED");
      $stop;
    end

endmodule
