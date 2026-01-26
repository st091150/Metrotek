`timescale 1ns/1ns

interface fifo_input_if #( parameter DWIDTH = 8 );
  logic              clk;

  logic              srst;

  logic [DWIDTH-1:0] data;

  logic              wrreq;
  logic              rdreq;
endinterface

interface fifo_output_if #( parameter DWIDTH = 8, parameter AWIDTH = 4 );
  logic              clk;

  logic [DWIDTH-1:0] q;

  logic              empty;
  logic              full;

  logic              almost_empty;
  logic              almost_full;

  logic [AWIDTH-1:0] usedw;
endinterface

class fifo_driver #( parameter DWIDTH = 8, parameter AWIDTH = 4 );
  virtual fifo_input_if #( .DWIDTH(DWIDTH) ) vif;

  function new ( virtual fifo_input_if #( .DWIDTH(DWIDTH) ) vif );
    this.vif = vif;
  endfunction

  task write( input logic [DWIDTH-1:0] data );
    vif.wrreq <= 1;
    vif.data  <= data;

    @( posedge vif.clk );
    vif.wrreq <= 0;
  endtask

  task read();
    vif.rdreq <= 1;

    @( posedge vif.clk );
    vif.rdreq <= 0;
  endtask

  task write_read_simul( input logic [DWIDTH-1:0] data );
    vif.data  <= data;

    vif.wrreq <= 1;
    vif.rdreq <= 1;

    @( posedge vif.clk );
    vif.wrreq <= 0;
    vif.rdreq <= 0;
  endtask
endclass

class fifo_monitor #( 
    parameter      DWIDTH = 8,
    parameter      AWIDTH = 4,
    parameter type fifo_event_t 
  );
  
  virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) vif;
  
  mailbox #( fifo_event_t ) fifo_events;

  function new( virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) vif );
    this.vif = vif;
    fifo_events = new();
  endfunction

  task run();
    fifo_event_t fifo_event;

    forever
      begin
        @( posedge vif.clk );

        fifo_event.q            = vif.q;
        fifo_event.empty        = vif.empty;
        fifo_event.full         = vif.full;
        fifo_event.almost_empty = vif.almost_empty;
        fifo_event.almost_full  = vif.almost_full;
        fifo_event.usedw        = vif.usedw;

        fifo_events.put(fifo_event);
      end
  endtask
endclass

class fifo_scoreboard #( parameter type fifo_event_t );
  mailbox #(fifo_event_t) dut_events;
  mailbox #(fifo_event_t) golden_events;

  function new();
    dut_events    = new();
    golden_events = new();
  endfunction

  task run();
    fifo_event_t dut_evt;
    fifo_event_t gold_evt;

    forever
      begin
        dut_events.get(dut_evt);

        golden_events.get(gold_evt);

        check(dut_evt, gold_evt);
      end
  endtask

  task check( fifo_event_t dut, fifo_event_t golden );
    bit is_errors = 0;

    if ( dut.q !== golden.q )
      begin
        $error("q mismatch! DUT=%0h GOLD=%0h", dut.q, golden.q);
        is_errors = 1;
      end

    if ( dut.empty !== golden.empty )
      begin
        $error("empty mismatch! DUT=%0b GOLD=%0b", dut.empty, golden.empty);
        is_errors = 1;
      end

    if ( dut.full !== golden.full )
      begin
        $error("full mismatch! DUT=%0b GOLD=%0b", dut.full, golden.full);
        is_errors = 1;
      end

    if ( dut.almost_empty !== golden.almost_empty )
      begin
        $error("almost_empty mismatch! DUT=%0b GOLD=%0b", dut.almost_empty, golden.almost_empty);
        is_errors = 1;
      end

    if ( dut.almost_full !== golden.almost_full )
      begin
        $error("almost_full mismatch! DUT=%0b GOLD=%0b", dut.almost_full, golden.almost_full);
        is_errors = 1;
      end

    if ( dut.usedw !== golden.usedw )
      begin
        $error("usedw mismatch! DUT=%0d GOLD=%0d", dut.usedw, golden.usedw);
        is_errors = 1;
      end

    if ( is_errors )
      $stop;

  endtask

endclass

class fifo_env #( 
    parameter      DWIDTH = 8,
    parameter      AWIDTH = 4,
    parameter type fifo_event_t 
  );

  virtual fifo_input_if  #( .DWIDTH(DWIDTH) )  in_vif;

  virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) dut_out_vif;
  virtual fifo_output_if #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) gold_out_vif; 

  fifo_driver  #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH) ) driver;

  fifo_monitor #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .fifo_event_t(fifo_event_t) ) dut_monitor;
  fifo_monitor #( .DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .fifo_event_t(fifo_event_t) ) golden_monitor;

  fifo_scoreboard #( .fifo_event_t(fifo_event_t) ) scoreboard;

  function new(
    virtual fifo_input_if  #(DWIDTH)        in_vif,
    virtual fifo_output_if #(DWIDTH,AWIDTH) dut_out_vif,
    virtual fifo_output_if #(DWIDTH,AWIDTH) gold_out_vif
  );
    this.in_vif       = in_vif;
    this.dut_out_vif  = dut_out_vif;
    this.gold_out_vif = gold_out_vif;

    driver         = new(in_vif);
    dut_monitor    = new(dut_out_vif);
    golden_monitor = new(gold_out_vif);
    scoreboard     = new();
  endfunction

  task run();
    fork
      dut_monitor.run();
      golden_monitor.run();
      scoreboard.run();
    join_none
  endtask

  task connect_scoreboard();
    scoreboard.dut_events    = dut_monitor.fifo_events;
    scoreboard.golden_events = golden_monitor.fifo_events;
  endtask
endclass

module fifo_tb;
  parameter DWIDTH = 32;
  parameter AWIDTH = 8;

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

      automatic logic do_write = 0;
      automatic logic do_read  = 0;

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

      while ( !gold_out_vif.full )
        begin
          data_wr = $urandom_range(2**DWIDTH-1, 0);
          env.driver.write(data_wr); 
          @( posedge in_vif.clk );
        end

      $display("### TEST 2: Read until empty ###");
      while ( !gold_out_vif.empty )
        begin
          env.driver.read();
          @( posedge in_vif.clk );
        end

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("### TEST 3: Random writes and reads ###");

      for ( int i = 0; i < 50; i++ )
      begin
        do_write = $urandom_range(0,1);
        do_read  = $urandom_range(0,1);

        if ( ( do_write ) && ( !gold_out_vif.full ) )
          begin
            data_wr = $urandom_range(2**DWIDTH-1, 0);
            env.driver.write(data_wr);
          end

        if ( ( do_read ) && ( !gold_out_vif.empty ) )
          env.driver.read();

        @( posedge in_vif.clk );
      end

      $display("[ TEST 3 ]: Read until empty ###");
      while ( !gold_out_vif.empty )
        begin
          env.driver.read();
          @( posedge in_vif.clk );
        end

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("### TEST 4: Simul read/write ###");

      env.driver.write($urandom_range(2**DWIDTH-1, 0));

      @( posedge in_vif.clk );
      env.driver.write_read_simul($urandom_range(2**DWIDTH-1, 0));

      $display("[ TEST 4 ]: Read until empty ###");

      @( posedge in_vif.clk );
      while ( !gold_out_vif.empty )
        begin
          env.driver.read();
          @( posedge in_vif.clk );
        end

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("### TEST 5: Random writes and reads (with wr/rd simul) ###");

      for ( int i = 0; i < RANDOM_TESTS_NUM; i++ )
      begin
        do_write = $urandom_range(0,1);
        do_read  = $urandom_range(0,1);

        data_wr = $urandom_range(2**DWIDTH-1, 0);

        if ( ( do_write ) && ( !gold_out_vif.full ) && ( do_read ) && ( !gold_out_vif.empty ) )
          env.driver.write_read_simul(data_wr);
        else if ( ( do_write ) && ( !gold_out_vif.full ) )
          env.driver.write(data_wr);
        else if ( ( do_read ) && ( !gold_out_vif.empty ) )
          env.driver.read();

        @( posedge in_vif.clk );
      end

      $display("[ TEST 5 ]: Read until empty ###");
      while ( !gold_out_vif.empty )
        begin
          env.driver.read();
          @( posedge in_vif.clk );
        end

      repeat ( 10 )
        @( posedge in_vif.clk );

      $display("All tests completed successfully!");
      $stop;
    end
endmodule

