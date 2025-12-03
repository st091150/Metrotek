module wrapper #(
  parameter WIDTH = 16
)(
  input  logic             clk,
  input  logic             srst_i,

  input  logic [WIDTH-1:0] data_i_ext,
  input  logic             data_val_i_ext,

  output logic [WIDTH-1:0] data_left_o_ext,
  output logic [WIDTH-1:0] data_right_o_ext,
  output logic             data_val_o_ext
);

  logic [WIDTH-1:0] data_i_r;
  logic             data_val_i_r;

  logic [WIDTH-1:0] data_left_o_int;
  logic [WIDTH-1:0] data_right_o_int;
  logic             data_val_o_int;

  priority_encoder #(
    .WIDTH( WIDTH )
  ) DUT (
      .clk_i        ( clk              ),
      .srst_i       ( srst_i           ),
      .data_i       ( data_i_r         ),
      .data_val_i   ( data_val_i_r     ),
      .data_left_o  ( data_left_o_int  ),
      .data_right_o ( data_right_o_int ),
      .data_val_o   ( data_val_o_int   )
    );

  always_ff @( posedge clk ) 
    begin
      if ( srst_i )
        data_val_i_r <= 1'b0;
      else
        begin
          data_i_r     <= data_i_ext;
          data_val_i_r <= data_val_i_ext;
        end
    end

  always_ff @(posedge clk) 
    begin
      if ( srst_i )
        data_val_o_ext <= 1'b0;
      else
        begin
          data_left_o_ext  <= data_left_o_int;
          data_right_o_ext <= data_right_o_int;
          data_val_o_ext   <= data_val_o_int;
        end
    end

endmodule
