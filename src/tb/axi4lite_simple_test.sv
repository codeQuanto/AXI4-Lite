module axi4lite_simple_test_tb;

  logic                      A_CLK;
  logic                      A_RSTn;

  // Create a clock
  always #10 A_CLK = ~A_CLK;

  axi4lite_if axi_if (
    .A_CLK  (A_CLK),
    .A_RSTn (A_RSTn)
  );

  axi4lite_slave dut (
    .axi_if (axi_if.slave)
  );

  initial begin
    #2  A_RSTn = 1'b0;
    #10 A_RSTn = 1'b1;
    #18 axi_if.AR_VALID = 1'b1;
        axi_if.AR_ADDR  = 'b1;
      //axi_if.AR_PROT  = 3'b0;
    #20 axi_if.R_READY  = 1'b1;
        axi_if.AR_VALID = 1'b0;
    #20 axi_if.R_READY  = 1'b0;
    #20 axi_if.AW_VALID = 1'b1;
        axi_if.AW_ADDR  = 'b1;
      //axi_if.AW_PROT  = 3'b0;
        axi_if.W_VALID  = 1'b1;
        axi_if.W_DATA   = 'b1;
      //axi_if.W_STRB   = 4'b0;
    #20 axi_if.AW_VALID = 1'b0;
        axi_if.W_VALID  = 1'b0;
        axi_if.B_READY  = 1'b1;
    #20 axi_if.B_READY  = 1'b0;
    // check if value was wrote into memory
    #20 axi_if.AR_VALID = 1'b1;
        axi_if.AR_ADDR  = 'b1;
      //axi_if.AR_PROT  = 3'b0;
    #20 axi_if.R_READY  = 1'b1;
        axi_if.AR_VALID = 1'b0;
    #20 axi_if.R_READY  = 1'b0;
    #50 $finish();

  end

endmodule