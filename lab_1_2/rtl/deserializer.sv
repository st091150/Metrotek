module deserializer (
  input  logic        clk_i,

  input  logic        srst_i,

  input  logic        data_i,
  input  logic        data_val_i,

  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

  logic [3:0] bit_count;

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        bit_count <= '0;
      else 
        if ( data_val_i )
          bit_count <= bit_count + 4'b1;
    end

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        deser_data_val_o <= 0;
      else
        deser_data_val_o <= ( data_val_i && bit_count == 15 );
    end

  always_ff @( posedge clk_i )
    begin
      if ( data_val_i )
        deser_data_o <= { deser_data_o[14:0], data_i };
    end

endmodule