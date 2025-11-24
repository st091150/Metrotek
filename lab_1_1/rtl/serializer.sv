module serializer (
  input  logic        clk_i,

  input  logic        srst_i,

  input  logic [15:0] data_i,
  input  logic [3:0]  data_mod_i,
  input  logic        data_val_i,

  output logic        ser_data_o,
  output logic        ser_data_val_o,

  output logic        busy_o
);

  logic [15:0] shift_reg;

  logic [4:0]  val_bits_init;
  logic [4:0]  val_bits;

  logic        working;

  function automatic logic [4:0] calc_val_bits( input logic [3:0] mod );
      if ( mod == 0 )
        return 5'd16;
      else if ( mod <= 2 )
        return 0;
      else
        return mod;
  endfunction

  assign val_bits_init  = calc_val_bits( data_mod_i );
  
  assign busy_o         = working;

  assign ser_data_val_o = working;
  assign ser_data_o     = shift_reg[15];

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        val_bits <= '0;
      else
        if ( !working )
          begin
            if ( data_val_i && val_bits_init )
              val_bits <= val_bits_init - 5'd1;
          end
        else
          val_bits <= val_bits - 5'd1;
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        working <= 0;
      else
        if ( !working )
          begin
            if ( data_val_i && val_bits_init )
              working <= 1;
          end
        else
          if ( !val_bits )
            working <= 0;
    end

  always_ff @( posedge clk_i )
    begin
      if ( !working )
        begin
          if ( data_val_i && val_bits_init )
            shift_reg <= data_i;
        end
      else
        shift_reg <= {shift_reg[14:0], 1'b0};
    end

endmodule