`timescale 1ns/1ns

`include "interfaces/interfaces.sv"
`include "agents/fifo_driver.sv"
`include "agents/fifo_monitor.sv"
`include "agents/fifo_scoreboard.sv"
`include "env/fifo_env.sv"

module fifo_tb;
  parameter DWIDTH = 8;
  parameter AWIDTH = 2;

  parameter ALMOST_EMPTY_VALUE = 3;
  parameter ALMOST_FULL_VALUE  = 2 ** AWIDTH - 3;

  parameter RANDOM_TESTS_NUM  = 10000;

  logic clk;

  fifo_input_if  #( .DWIDTH(DWIDTH) ) in_vif();

  fifo_output_if #( .DWIDTH(DWIDTH) , .AWIDTH(AWIDTH) ) dut_out_vif();
  fifo_output_if #( .DWIDTH(DWIDTH) , .AWIDTH(AWIDTH) ) gold_out_vif();

  fifo #(
    .DWIDTH             ( DWIDTH                   ),
    .AWIDTH             ( AWIDTH                   ),
    .ALMOST_EMPTY_VALUE ( ALMOST_EMPTY_VALUE       ),
    .ALMOST_FULL_VALUE  ( ALMOST_FULL_VALUE        )
  ) DUT (
    .clk_i              ( in_vif.clk               ),

    .srst_i             ( in_vif.srst              ),

    .data_i             ( in_vif.data              ),
    .wrreq_i            ( in_vif.wrreq             ),
    .rdreq_i            ( in_vif.rdreq             ),

    .q_o                ( dut_out_vif.q            ),

    .empty_o            ( dut_out_vif.empty        ),
    .full_o             ( dut_out_vif.full         ),

    .almost_empty_o     ( dut_out_vif.almost_empty ),
    .almost_full_o      ( dut_out_vif.almost_full  ),

    .usedw_o            ( dut_out_vif.usedw        )
  );

  scfifo #(
    .lpm_width               ( DWIDTH                    ),
    .lpm_widthu              ( AWIDTH                    ),
    .lpm_numwords            ( 2 ** AWIDTH               ),
    .lpm_showahead           ( "ON"                      ),
    .lpm_type                ( "scfifo"                  ),
    .lpm_hint                ( "RAM_BLOCK_TYPE=M10K"     ),
    .intended_device_family  ( "Cyclone V"               ),
    .underflow_checking      ( "ON"                      ),
    .overflow_checking       ( "ON"                      ),
    .allow_rwcycle_when_full ( "OFF"                     ),
    .use_eab                 ( "ON"                      ),
    .add_ram_output_register ( "OFF"                     ),
    .almost_full_value       ( ALMOST_FULL_VALUE         ),
    .almost_empty_value      ( ALMOST_EMPTY_VALUE        ),
    .maximum_depth           ( 0                         ),
    .enable_ecc              ( "FALSE"                   )
  ) golden_model (
    .clock                   ( in_vif.clk                ),

    .sclr                    ( in_vif.srst               ),

    .data                    ( in_vif.data               ),
    .wrreq                   ( in_vif.wrreq              ),
    .rdreq                   ( in_vif.rdreq              ),

    .q                       ( gold_out_vif.q            ),

    .empty                   ( gold_out_vif.empty        ),
    .full                    ( gold_out_vif.full         ),
    
    .almost_empty            ( gold_out_vif.almost_empty ),
    .almost_full             ( gold_out_vif.almost_full  ),

    .usedw                   ( gold_out_vif.usedw        ),

    .aclr(),
    .eccstatus()
  );

  initial
    clk = 0;

  always
    begin
      #5;
      clk = ~clk;

      in_vif.clk       = clk;
      dut_out_vif.clk  = clk;
      gold_out_vif.clk = clk;
    end

  typedef struct {
    logic [DWIDTH-1:0] q;
    logic              empty;
    logic              full;
    logic              almost_empty;
    logic              almost_full;
    logic [AWIDTH-1:0] usedw;
  } fifo_event_t;

  fifo_env #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .fifo_event_t(fifo_event_t) ) env;

  initial
    begin
      logic [DWIDTH-1:0] data_wr;

      static logic do_write = 0;
      static logic do_read  = 0;
      
      // Reset
      in_vif.srst  <= 1;
      
      in_vif.wrreq <= 0;
      in_vif.rdreq <= 0;
      @( posedge in_vif.clk );

      in_vif.srst <= 0;
      @( posedge in_vif.clk );

      env = new(in_vif, dut_out_vif, gold_out_vif);
      env.connect_scoreboard();

      fork
        env.run();
      join_none

      $display("### TEST 1: Write until golden_model full ###");

      repeat ( 2 ** AWIDTH )
        begin
          data_wr = $urandom_range(2**DWIDTH-1, 0);
          env.driver.write(data_wr);
        end

      $display("### TEST 2: Read until empty ###");
      repeat ( 2 ** AWIDTH )
        env.driver.read();

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("### TEST 3: Random writes and reads ###");

      for ( int i = 0; i < 50; i++ )
      begin
        do_write = $urandom_range(0,1);
        do_read  = $urandom_range(0,1);

        if ( ( do_write ) && ( gold_out_vif.usedw < ( 2 ** AWIDTH ) - 1 ) )
          begin
            data_wr = $urandom_range(2**DWIDTH-1, 0);
            env.driver.write(data_wr);
          end

        if ( ( do_read ) && ( gold_out_vif.usedw > 1 || gold_out_vif.full ) )
          env.driver.read();
      end

      $display("[ TEST 3 ]: Read until empty ###");
      while ( gold_out_vif.usedw > 1 || gold_out_vif.full )
        env.driver.read();

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("### TEST 4: Simul read/write ###");

      repeat ( 3 )
        env.driver.write(data_wr);

      repeat ( 10 )
        env.driver.write_read_simul($urandom_range(2**DWIDTH-1, 0));

      repeat ( 3 )
        env.driver.read();

      $display("[ TEST 4 ]: Read until empty ###");

      while ( gold_out_vif.usedw > 1 || gold_out_vif.full )
        env.driver.read();

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("### TEST 5: Random writes and reads (with wr/rd simul) ###");

      for ( int i = 0; i < RANDOM_TESTS_NUM; i++ )
      begin
        do_write = $urandom_range(0,1);
        do_read  = $urandom_range(0,1);

        data_wr = $urandom_range(2**DWIDTH-1, 0);

        if ( ( do_write ) && ( gold_out_vif.usedw < ( 2 ** AWIDTH ) - 1 ) &&
             ( do_read  ) && ( gold_out_vif.usedw > 1 || gold_out_vif.full ) )
          env.driver.write_read_simul(data_wr);
        else if ( ( do_write ) && ( gold_out_vif.usedw != ( 2 ** AWIDTH ) - 1 ) )
          env.driver.write(data_wr);
        else if ( ( do_read ) && ( gold_out_vif.usedw > 1 || gold_out_vif.full ) )
          env.driver.read();

      end

      $display("[ TEST 5 ]: Read until empty ###");

      while ( gold_out_vif.usedw > 1 || gold_out_vif.full )
        env.driver.read();

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("All tests completed successfully!");
      $stop;
    end
endmodule

