module traffic_lights #(
  parameter int unsigned BLINK_HALF_PERIOD_MS  = 500,
  parameter int unsigned BLINK_GREEN_TIME_TICK = 3,
  parameter int unsigned RED_YELLOW_MS         = 2000
)(
  input  logic        clk_i,

  input  logic        srst_i,

  input  logic [2:0]  cmd_type_i,
  input  logic        cmd_valid_i,
  input  logic [15:0] cmd_data_i,

  output logic        red_o,
  output logic        yellow_o,
  output logic        green_o
);

  localparam int unsigned CLK_FREQ_HZ = 2000;
  localparam int unsigned MS_TO_TICKS = CLK_FREQ_HZ / 1000;
  localparam int unsigned BLINK_HALF_PERIOD_TICKS = ( ( BLINK_HALF_PERIOD_MS * MS_TO_TICKS ) == 0 ) ? 1 : ( BLINK_HALF_PERIOD_MS * MS_TO_TICKS );

  localparam int unsigned DEFAULT_MS = 1;

  localparam int unsigned RED_YELLOW_TICKS  = RED_YELLOW_MS * MS_TO_TICKS;
  localparam int unsigned GREEN_BLINK_TICKS = 2 * BLINK_HALF_PERIOD_MS * BLINK_GREEN_TIME_TICK * MS_TO_TICKS;

  function [31:0] ms_to_ticks( input [15:0] ms );
    return ( ms == 0 ) ? 2 : ( ms * MS_TO_TICKS );
  endfunction

  enum logic [2:0] {
    IDLE_S,
    RED_S,
    RED_YELLOW_S,
    YELLOW_S,
    GREEN_S,
    GREEN_BLINK_S,
    NOTRANSITION_S
  } state, next_state;

  // --------------------------------------------------------------------------
  // Light period durations (configurable)
  // --------------------------------------------------------------------------
  logic [31:0] green_periods_ticks;
  logic [31:0] red_periods_ticks;
  logic [31:0] yellow_periods_ticks;

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        begin
          green_periods_ticks  <= ms_to_ticks(DEFAULT_MS);
          red_periods_ticks    <= ms_to_ticks(DEFAULT_MS);
          yellow_periods_ticks <= ms_to_ticks(DEFAULT_MS);
        end
      else if ( ( state == NOTRANSITION_S ) && cmd_valid_i )
        begin
          case ( cmd_type_i )
            3'd3: green_periods_ticks  <= ms_to_ticks(cmd_data_i);
            3'd4: red_periods_ticks    <= ms_to_ticks(cmd_data_i);
            3'd5: yellow_periods_ticks <= ms_to_ticks(cmd_data_i);
          endcase
        end
    end

  // --------------------------------------------------------------------------
  // FSM state timer
  // --------------------------------------------------------------------------
  logic [31:0] state_timer;
  logic        timer_expired;

  // Signals for FSM event and transition
  logic fsm_event;
  logic is_transition;

  assign fsm_event     = timer_expired || cmd_valid_i;
  assign is_transition = fsm_event     && ( state != next_state );

  // State timer update
  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        state_timer <= ms_to_ticks(DEFAULT_MS) - 1;
      else if ( is_transition )
        case ( next_state )
          RED_S:         state_timer <= red_periods_ticks - 1;
          RED_YELLOW_S:  state_timer <= RED_YELLOW_TICKS - 1;
          YELLOW_S:      state_timer <= yellow_periods_ticks - 1;
          GREEN_S:       state_timer <= green_periods_ticks - 1;
          GREEN_BLINK_S: state_timer <= GREEN_BLINK_TICKS - 1;

          // no timer-based transitions: IDLE_S, NOTRANSITION_S 
          default: ;
        endcase
      else if ( state_timer != 0 )
        state_timer <= state_timer - 1;
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        timer_expired <= 0;
      else
        timer_expired <= ( state_timer == 1 );
    end

  // --------------------------------------------------------------------------
  // Green blinking logic
  // --------------------------------------------------------------------------
  logic [31:0] blink_counter;
  logic        blink_state;

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        blink_state <= 1'b0;
      else if ( is_transition )
        blink_state <= 1'b0;
      else if ( blink_counter == 1 )
        blink_state <= ~blink_state;
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        blink_counter <= 0;
      else if ( is_transition )
        blink_counter <= BLINK_HALF_PERIOD_TICKS;
      else if ( state == GREEN_BLINK_S || state == NOTRANSITION_S )
        begin
          if ( blink_counter == 0 )
            blink_counter <= BLINK_HALF_PERIOD_TICKS - 1;
          else
            blink_counter <= blink_counter - 1;
        end
    end

  // --------------------------------------------------------------------------
  // FSM state update (FSM 3 process)
  // --------------------------------------------------------------------------
  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        state <= RED_S;
      else if ( fsm_event )
        state <= next_state;
    end

  always_comb
    begin
      next_state = state;

      if ( cmd_valid_i )
        begin
          case ( cmd_type_i )
            3'd0:
              begin
                if( state == IDLE_S || state == NOTRANSITION_S )
                  next_state = RED_S;
              end
            3'd1:    next_state = IDLE_S;
            3'd2:    next_state = NOTRANSITION_S;
            default: next_state = state;
          endcase
        end
      else
        begin
          case ( state )
            RED_S:          next_state = RED_YELLOW_S;
            RED_YELLOW_S:   next_state = GREEN_S;
            GREEN_S:        next_state = GREEN_BLINK_S;
            GREEN_BLINK_S:  next_state = YELLOW_S;
            YELLOW_S:       next_state = RED_S;
            NOTRANSITION_S: next_state = state;
            IDLE_S:         next_state = state;
          endcase
        end
    end

  logic [2:0] lights_ff;
  assign {red_o, yellow_o, green_o} = lights_ff;

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        lights_ff <= 3'b000;
      else
        begin
          case( state )
            RED_S:          lights_ff <= 3'b100;
            RED_YELLOW_S:   lights_ff <= 3'b110;
            GREEN_S:        lights_ff <= 3'b001;
            YELLOW_S:       lights_ff <= 3'b010;
            GREEN_BLINK_S:  lights_ff <= {2'b00, blink_state};
            NOTRANSITION_S: lights_ff <= {1'b0, blink_state, 1'b0};
            IDLE_S:         lights_ff <= 3'b000;
            default:        lights_ff <= 3'b100;
          endcase
        end
    end

endmodule
