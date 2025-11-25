module deserializer (
  input  logic        clk_i,

  input  logic        srst_i,

  input  logic        data_i,
  input  logic        data_val_i,

  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

  logic [4:0] bit_count = '0;

  assign deser_data_val_o = ( bit_count == 5'd16 ) ? 1'd1 : 1'd0;

  always_ff @( posedge clk_i )
    begin
      if ( data_val_i )
        deser_data_o <= { deser_data_o[14:0], data_i };
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        bit_count <= '0;
      else
        begin
          if ( data_val_i )
            begin
              if ( bit_count == 5'd16 )
                bit_count <= 5'd1;
              else
                bit_count <= bit_count + 5'd1;
            end
        end
    end

endmodule