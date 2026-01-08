`timescale 1us/1us

module traffic_lights_tb;

  localparam BLINK_HALF_PERIOD_MS  = 1;
  localparam BLINK_GREEN_TIME_TICK = 2;
  localparam RED_YELLOW_MS         = 1;

  localparam CLK_FREQ_HZ = 2000;
  localparam CLK_PERIOD_US = 1_000_000 / CLK_FREQ_HZ;
  localparam MS_TO_TICKS = CLK_FREQ_HZ / 1000;

  localparam DEFAULT_MS = 1;

  logic        clk_i;

  logic        srst_i;

  logic [2:0]  cmd_type_i;
  logic        cmd_valid_i;
  logic [15:0] cmd_data_i;

  logic        red_o;
  logic        yellow_o;
  logic        green_o;

  traffic_lights #(
    .BLINK_HALF_PERIOD_MS  ( BLINK_HALF_PERIOD_MS  ),
    .BLINK_GREEN_TIME_TICK ( BLINK_GREEN_TIME_TICK ),
    .RED_YELLOW_MS         ( RED_YELLOW_MS         )
  ) DUT (
    .clk_i       ( clk_i       ),
    .srst_i      ( srst_i      ),
    .cmd_type_i  ( cmd_type_i  ),
    .cmd_valid_i ( cmd_valid_i ),
    .cmd_data_i  ( cmd_data_i  ),
    .red_o       ( red_o       ),
    .yellow_o    ( yellow_o    ),
    .green_o     ( green_o     )
  );

  initial clk_i = 0;

  always #(CLK_PERIOD_US/2) clk_i = ~clk_i;

  function int ms_to_ticks( input int ms );
    return ( ms <= 0 ) ? 1 : ( ms * MS_TO_TICKS );
  endfunction

  task automatic check_outputs_stable (
    input logic red_exp,
    input logic yellow_exp,
    input logic green_exp,
    input int   ticks
  );
    begin
      for ( int i = 0; i < ticks; i++ )
        begin
          @( posedge clk_i );
          if ( ( red_o    !== red_exp    ) || 
               ( yellow_o !== yellow_exp ) ||
               ( green_o  !== green_exp  ) )
            begin
              $error("Expected RYG = %b%b%b, Got RYG = %b%b%b",
                      red_exp, yellow_exp, green_exp, red_o, yellow_o, green_o);
              $stop;
            end
        end
    end
  endtask

  task automatic check_idle_state ( input int ticks );
    check_outputs_stable(0, 0, 0, ticks);
  endtask

  task automatic send_cmd (
    input logic [2:0] cmd
  );
    begin
      @( posedge clk_i );
      cmd_type_i  <= cmd;
      cmd_valid_i <= 1'b1;

      @( posedge clk_i );
      cmd_valid_i <= 1'b0;
    end
  endtask

  task automatic set_color_times(
      input int red_ms,
      input int yellow_ms,
      input int green_ms
  );
    begin
      $display("=== Setting color times RED=%0d, YELLOW=%0d, GREEN=%0d ===", red_ms, yellow_ms, green_ms);

      // NOTRANSITION_S
      send_cmd(3'd2);
      @( posedge clk_i );

      // RED
      cmd_data_i <= red_ms;
      send_cmd(3'd4);
      @( posedge clk_i );

      // YELLOW
      cmd_data_i <= yellow_ms;
      send_cmd(3'd5);
      @( posedge clk_i );

      // GREEN
      cmd_data_i <= green_ms;
      send_cmd(3'd3);
      @( posedge clk_i );

      // RED_S
      send_cmd(3'd0);
      @( posedge clk_i );

      $display("=== Color times set complete ===");
    end
  endtask

  task automatic check_cmd_transitions( input int red_ms );
    begin
      $display("=== CMD TRANSITION TEST ===");

      $display("CMD OFF");

      // 1. OFF_S
      send_cmd(3'd1);

      @( posedge clk_i );
      check_idle_state(10);

      // 2. OFF_S → NOTRANSITION_S
      $display("CMD NOTRANSITION_S");

      send_cmd(3'd2);

      @( posedge clk_i );
      check_blink(
        "yellow",
        0,
        ms_to_ticks(BLINK_HALF_PERIOD_MS),
        ms_to_ticks(2 * BLINK_HALF_PERIOD_MS)
      );

      // 3. NOTRANSITION_S → RED_S (START)
      $display("CMD START (RED)");

      send_cmd(3'd0);

      // 4. OFF_S from GREEN_S
      $display("CMD OFF_S from GREEN_S");

      @( posedge clk_i );
      check_outputs_stable(1, 0, 0, ms_to_ticks(red_ms));        // RED
      check_outputs_stable(1, 1, 0, ms_to_ticks(RED_YELLOW_MS)); // RED_YELLOW
      check_outputs_stable(0, 0, 1, ms_to_ticks(1));             // GREEN

      send_cmd(3'd1); // OFF_S

      @( posedge clk_i );
      check_idle_state(10);

      $display("=== CMD TRANSITION TEST PASSED ===");
    end
  endtask

  task automatic check_off_state_transitions( input int red_ms, input int yellow_ms, input int green_ms );
    begin
      $display("CMD OFF");

      // 1. OFF_S
      send_cmd(3'd1);

      @( posedge clk_i );
      check_idle_state(10);

      // 2. OFF_S → RED_S (START)
      $display("CMD START (RED)");

      send_cmd(3'd0);

      // 3. OFF_S from RED_S
      $display("CMD OFF_S from RED_S");

      @( posedge clk_i );
      check_outputs_stable(1, 0, 0, ms_to_ticks(1)); // RED

      // 4. OFF_S
      send_cmd(3'd1);

      @( posedge clk_i );
      check_idle_state(10);

      send_cmd(3'd1); // OFF

      @( posedge clk_i );
      check_idle_state(10);

      // 5. OFF_S → RED_S (START)
      $display("CMD START (RED)");

      send_cmd(3'd0);

      // 6. OFF_S from YELLOW_S
      $display("CMD OFF_S from RED_YELLOW_S");

      @( posedge clk_i );
      check_outputs_stable(1, 0, 0, ms_to_ticks(red_ms)); // RED
      check_outputs_stable(1, 1, 0, ms_to_ticks(1));      // RED_YELLOW

      // 7. OFF_S
      send_cmd(3'd1);

      @( posedge clk_i );
      check_idle_state(10);

      send_cmd(3'd1); // OFF

      @( posedge clk_i );
      check_idle_state(10);

      // 8. OFF_S → RED_S (START)
      $display("CMD START (RED)");

      send_cmd(3'd0);

      // 9. OFF_S from GREEN_BLINK_S
      $display("CMD OFF_S from GREEN_BLINK_S");

      @( posedge clk_i );
      check_outputs_stable(1, 0, 0, ms_to_ticks(red_ms));        // RED
      check_outputs_stable(1, 1, 0, ms_to_ticks(RED_YELLOW_MS)); // RED_YELLOW
      check_outputs_stable(0, 0, 1, ms_to_ticks(green_ms));      // GREEN
      check_blink(
        "green",
        0,
        ms_to_ticks(BLINK_HALF_PERIOD_MS),
        ms_to_ticks(2 * BLINK_HALF_PERIOD_MS)
      );

      // 10. OFF_S
      send_cmd(3'd1);

      @( posedge clk_i );
      check_idle_state(10);

      send_cmd(3'd1); // OFF

      @( posedge clk_i );
      check_idle_state(10);

      $display("=== OFF_S TESTS PASSED ===");
    end
  endtask

  task automatic check_blink (
    input string light_name,
    input logic  start_value,
    input int    blink_interval,
    input int    total_ticks
  );
  logic expected;
  int   cnt;

  begin
    expected = start_value;
    cnt      = 0;

    for ( int i = 0; i < total_ticks; i++ )
      begin
        @( posedge clk_i );

        case ( light_name )
          "red":
            if ( red_o !== expected )
              begin
                $error("RED blink error at tick %0d: expected=%b got=%b",
                        i, expected, red_o);
                $stop;
              end

          "yellow":
            if ( yellow_o !== expected )
              begin
                $error("YELLOW blink error at tick %0d: expected=%b got=%b",
                        i, expected, yellow_o);
                $stop;
              end

          "green":
            if ( green_o !== expected )
              begin
                $error("GREEN blink error at tick %0d: expected=%b got=%b",
                        i, expected, green_o);
                $stop;
              end

          default:
            begin
              $error("Unknown light_name = %s", light_name);
              $stop;
            end
        endcase

        cnt++;
        if ( cnt == blink_interval )
          begin
            cnt      = 0;
            expected = ~expected;
          end
      end
    end
  endtask

  task automatic check_normal_mode (
    input int red_ms,
    input int yellow_ms,
    input int green_ms,
    input int red_yellow_ms,
    input int cycles
  );
    begin
      $display(
        "=== SEQUENCE TEST (red_ms=%0d, yellow_ms=%0d, green_ms=%0d,  red_yellow_ms=%0d, cycles=%0d) ===",
        red_ms, yellow_ms, green_ms, red_yellow_ms, cycles
      );

      for ( int c = 0; c < cycles; c++ )
        begin
          $display("--- CYCLE %0d ---", c + 1);

          $display("CHECK RED");
          check_outputs_stable(1, 0, 0, ms_to_ticks(red_ms));

          $display("CHECK RED_YELLOW");
          check_outputs_stable(1, 1, 0, ms_to_ticks(red_yellow_ms));

          $display("CHECK GREEN");
          check_outputs_stable(0, 0, 1, ms_to_ticks(green_ms));

          $display("CHECK GREEN_BLINK");
          check_blink(
            "green",
            0,
            ms_to_ticks(BLINK_HALF_PERIOD_MS),
            ms_to_ticks(2 * BLINK_HALF_PERIOD_MS * BLINK_GREEN_TIME_TICK)
          );

          $display("CHECK YELLOW");
          check_outputs_stable(0, 1, 0, ms_to_ticks(yellow_ms));
        end

      $display("=== ALL %0d SEQUENCES PASSED ===", cycles);
    end
  endtask

  task reset_test;
    begin
      srst_i = 1;

      cmd_type_i = 0;
      cmd_valid_i = 0;
      cmd_data_i = 0;

      @( posedge clk_i );
      srst_i = 0;

      @( posedge clk_i );
      @( posedge clk_i );
      if ( red_o !== 1 || yellow_o !== 0 || green_o !== 0 )
        begin
          $display("RESET STATE FAILED");
          $error("Expected RYG = 100, Got RYG = %b%b%b",
                  red_o, yellow_o, green_o);
          $stop;
        end
    end
  endtask

  task automatic test_restart_normal_mode;
    // RESET
    srst_i = 1;

    cmd_type_i = 0;
    cmd_valid_i = 0;
    cmd_data_i = 0;

    @( posedge clk_i );
    srst_i = 0;

    @( posedge clk_i );
    check_outputs_stable(1,0,0, ms_to_ticks(DEFAULT_MS));

    send_cmd(3'd0); // restart_normal_mode
    @( posedge clk_i );

    for ( int i = 0; i < 5; i++ )
      begin
        @( posedge clk_i );
        if ( ( red_o    !== 1'b1    ) && 
             ( yellow_o !== 1'b0    ) &&
             ( green_o  !== 1'b0    ) )
          begin
            $error("Expected RYG != %b%b%b",
                    red_o, yellow_o, green_o);
            $stop;
          end
      end
  endtask

  initial
    begin
      srst_i = 1;

      cmd_type_i = 0;
      cmd_valid_i = 0;
      cmd_data_i = 0;

      @( posedge clk_i );
      srst_i = 0;

      @( posedge clk_i );
      $display("=== NORMAL MODE TEST (DEFAULT_MS=%0d) ===", DEFAULT_MS);
      check_normal_mode(DEFAULT_MS, DEFAULT_MS, DEFAULT_MS, RED_YELLOW_MS, 3);

      $display("=== CMD TRANSITIONS TEST (DEFAULT RED_MS=%0d) ===", DEFAULT_MS);
      check_cmd_transitions(DEFAULT_MS);

      $display("=== SET COLOR TIMES ===");
      // RED=4ms, YELLOW=2ms, GREEN=7ms
      set_color_times(4, 2, 7); 

      $display("=== NORMAL MODE TEST (NEW TIMES) ===");
      check_normal_mode(4, 2, 7, RED_YELLOW_MS, 3);

      $display("=== CMD TRANSITIONS TEST (NEW RED_MS=2) ===");
      check_cmd_transitions(4);

      $display("=== SET COLOR TIMES (ZERO VALUES) ===");
      // DUT should correctly handle the minimum value (1ms {2 tick})
      set_color_times(0, 0, 0);
      check_normal_mode(1, 1, 1, RED_YELLOW_MS, 2);

      $display("=== RESET TEST ===");
      reset_test();

      $display("=== TEST: RESTART NORMAL MODE ===");
      test_restart_normal_mode();

      $display("=== OFF_S TESTS ===");
      check_off_state_transitions(DEFAULT_MS, DEFAULT_MS, DEFAULT_MS);

      $display("ALL TESTS PASSED!");
      $stop;
    end

endmodule

