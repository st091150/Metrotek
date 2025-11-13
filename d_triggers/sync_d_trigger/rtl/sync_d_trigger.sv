module sync_d_trigger (
    input  logic clk_i,
    input  logic rst_i,
    input  logic d_i,

    output logic q_o
);

  always_ff @(posedge clk_i)
   begin
     if (rst_i)
       q_o <= 1'b0;
     else
       q_o <= d_i;
    end

endmodule
