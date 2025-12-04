module wrapper #(
  parameter WIDTH = 16
)(
  input  logic                   clk,
  input  logic                   srst_i,

  input  logic [WIDTH-1:0]       data_i_ext,
  input  logic                   data_val_i_ext,

  output logic [$clog2(WIDTH):0] data_o_ext,
  output logic                   data_val_o_ext
);

  logic [WIDTH-1:0]       data_i_r;
  logic                   data_val_i_r;

  logic [$clog2(WIDTH):0] data_o_int;
  logic                   data_val_o_int;

  bit_population_counter #(
    .WIDTH( WIDTH )
  ) DUT (
      .clk_i        ( clk              ),
      .srst_i       ( srst_i           ),
      .data_i       ( data_i_r         ),
      .data_val_i   ( data_val_i_r     ),
      .data_o       ( data_o_int       ),
      .data_val_o   ( data_val_o_int   )
    );

  always_ff @( posedge clk ) 
    begin
        data_i_r       <= data_i_ext;
        data_val_i_r   <= data_val_i_ext;
        
        data_o_ext     <= data_o_int;
        data_val_o_ext <= data_val_o_int;
    end

endmodule
