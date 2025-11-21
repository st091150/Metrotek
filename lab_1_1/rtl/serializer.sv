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
  logic [4:0]  val_bits;
  logic        working;

  function automatic logic [4:0] calc_val_bits(input logic [3:0] mod);
      if (mod == 0)
          return 5'd16;
      else if (mod <= 16)
          return mod;
      else
          return 5'd16;
  endfunction

  always_ff @( posedge clk_i )
    begin
      if (srst_i) 
        begin
          shift_reg       <= '0;
          val_bits        <= '0;
          working         <= '0;
          ser_data_o      <= '0;
          ser_data_val_o  <= '0;
        end
      else
        begin
          if (!working)
            begin
              if (data_val_i)
                begin
                  logic [4:0] new_val_bits;
                  new_val_bits = calc_val_bits(data_mod_i);
                  if (new_val_bits != 0)
                    begin
                      working   <= 1;

                      ser_data_o     <= data_i[15];
                      ser_data_val_o <= 1;

                      val_bits  <= new_val_bits - 5'd1;

                      shift_reg <= {data_i[14:0], 1'b0};
                    end
                end
            end
          else
            begin
              ser_data_o <= shift_reg[15];

              val_bits   <= val_bits - 5'd1;

              shift_reg  <= {shift_reg[14:0], 1'b0};

              if (val_bits == 0)
                begin
                  working        <= 0;
                  ser_data_val_o <= 0;
                end
            end
        end
    end

  assign busy_o = working;

endmodule
