module axi4lite_simple_test_tb;

  bit clk, rst;

  // Create a clock
  always #10 clk = ~clk;

  axi4lite_if axi_if (
    .A_CLK (clk),
    .A_RSTn (rst)
  );

  axi4lite_slave dut (.axi_if (axi_if.slave));

  initial begin
    #2  rst = 1'b0;
    #10 rst = 1'b1;
    #18 dut.axi_if.AR_VALID = 1'b1;
        dut.axi_if.AR_ADDR  = 'b1;
        //dut.axi_if.AR_PROT  = 3'b0;
    #20 dut.axi_if.R_READY  = 1'b1;
        dut.axi_if.AR_VALID = 1'b0;
    #20 dut.axi_if.R_READY  = 1'b0;
    #20 dut.axi_if.AW_VALID = 1'b1;
        dut.axi_if.AW_ADDR  = 'b1;
        //dut.axi_if.AW_PROT  = 3'b0;
        dut.axi_if.W_VALID  = 1'b1;
        dut.axi_if.W_DATA   = 'b1;
        //dut.axi_if.W_STRB   = 4'b0;
    #20 dut.axi_if.AW_VALID = 1'b0;
        dut.axi_if.W_VALID  = 1'b0;
        dut.axi_if.B_READY  = 1'b1;
    #20 dut.axi_if.B_READY  = 1'b0;
    // check if value was wrote into memory
    #20 dut.axi_if.AR_VALID = 1'b1;
        dut.axi_if.AR_ADDR  = 'b1;
        //dut.axi_if.AR_PROT  = 3'b0;
    #20 dut.axi_if.R_READY  = 1'b1;
        dut.axi_if.AR_VALID = 1'b0;
    #20 dut.axi_if.R_READY  = 1'b0;
    #50 $finish();

  end

endmodule