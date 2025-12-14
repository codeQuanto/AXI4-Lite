module axi4lite_simple_test_tb;

  logic                      A_CLK;
  logic                      A_RSTn;
  // AW channel
  logic                      AW_VALID;
  logic                      AW_READY;
  logic [AXI_ADDR_WIDTH-1:0] AW_ADDR;
  // logic [2:0]                AW_PROT;
  // W channel
  logic                      W_VALID;
  logic                      W_READY;
  logic [AXI_DATA_WIDTH-1:0] W_DATA;
  // inout  logic [AXI_STRB_WIDTH-1:0] W_STRB;
  // B channel
  logic                      B_VALID;
  logic                      B_READY;
  logic [1:0]                B_RESP;
  // AR channel
  logic                      AR_VALID;
  logic                      AR_READY;
  logic [AXI_ADDR_WIDTH-1:0] AR_ADDR;
  // logic [2:0]                AR_PROT;
  // R channel
  logic                      R_VALID;
  logic                      R_READY;
  logic [AXI_DATA_WIDTH-1:0] R_DATA;
  logic [1:0]                R_RESP;


  // Create a clock
  always #10 A_CLK = ~A_CLK;

  /*
  axi4lite_if axi_if (
    .A_CLK (clk),
    .A_RSTn (rst)
  );
  */

  axi4lite_slave dut (
    .A_CLK    (A_CLK),
    .A_RSTn   (A_RSTn),
    .AW_VALID (AW_VALID),
    .AW_READY (AW_READY),
    .AW_ADDR  (AW_ADDR),
    .W_VALID  (W_VALID),
    .W_READY  (W_READY),
    .W_DATA   (W_DATA),
    .B_VALID  (B_VALID),
    .B_READY  (B_READY),
    .B_RESP   (B_RESP),
    .AR_VALID (AR_VALID),
    .AR_READY (AR_READY),
    .AR_ADDR  (AR_ADDR),
    .R_VALID  (R_VALID),
    .R_READY  (R_READY),
    .R_DATA   (R_DATA),
    .R_RESP   (R_RESP)
  );

  initial begin
    #2  A_RSTn = 1'b0;
    #10 A_RSTn = 1'b1;
    #18 AR_VALID = 1'b1;
        AR_ADDR  = 'b1;
        //AR_PROT  = 3'b0;
    #20 R_READY  = 1'b1;
        AR_VALID = 1'b0;
    #20 R_READY  = 1'b0;
    #20 AW_VALID = 1'b1;
        AW_ADDR  = 'b1;
        //AW_PROT  = 3'b0;
        W_VALID  = 1'b1;
        W_DATA   = 'b1;
        //W_STRB   = 4'b0;
    #20 AW_VALID = 1'b0;
        W_VALID  = 1'b0;
        B_READY  = 1'b1;
    #20 B_READY  = 1'b0;
    // check if value was wrote into memory
    #20 AR_VALID = 1'b1;
        AR_ADDR  = 'b1;
        //AR_PROT  = 3'b0;
    #20 R_READY  = 1'b1;
        AR_VALID = 1'b0;
    #20 R_READY  = 1'b0;
    #50 $finish();

  end

endmodule