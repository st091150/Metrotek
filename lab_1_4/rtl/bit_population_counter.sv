module bit_population_counter #(
  parameter WIDTH = 16
)(
  input  logic                   clk_i,

  input  logic                   srst_i,

  input  logic [WIDTH-1:0]       data_i,
  input  logic                   data_val_i,

  output logic [$clog2(WIDTH):0] data_o,
  output logic                   data_val_o
);

  logic [$clog2(WIDTH):0] bit_counter;

  always_ff @( posedge clk_i )
    begin
      if ( srst_i )
        data_val_o <= 1'b0;
      else
        begin
          data_val_o <= ( !data_val_o && data_val_i );
          data_o     <= bit_counter;
        end
    end

  always_comb
    begin
      logic [WIDTH-1:0] data_i_local;
    
      data_i_local = data_i;
      bit_counter  = '0;
      
      if ( data_val_i )
        begin
          for ( int i = 0; i < WIDTH; i++ ) 
            begin
              if ( data_i_local[i] == 1'b1 )
                bit_counter = bit_counter + 1'b1;
            end
        end
    end

endmodule