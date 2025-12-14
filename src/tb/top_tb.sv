`include "vivado_interfaces.svh"
import axi_vip_0_pkg::*;

module top_tb(
);

  logic aclk;
  logic aresetn;
  logic [31:0] data;
  
  axi_vip_0_mst_t axi_master;

  vivado_axi4_lite_v1_0 M_AXI();
  
  axi_vip_0_sv axi_vip_i (
    .M_AXI(M_AXI.master), // vivado_axi4_lite_v1_0.master M_AXI
    .aclk(aclk),          // input wire aclk
    .aresetn(aresetn)     // input wire aresetn
  );

  axi4lite_slave dut (
    .A_CLK    (aclk),
    .A_RSTn   (aresetn),
    .AW_VALID (M_AXI.awvalid),
    .AW_READY (M_AXI.awready),
    .AW_ADDR  (M_AXI.awaddr),
    .W_VALID  (M_AXI.wvalid),
    .W_READY  (M_AXI.wready),
    .W_DATA   (M_AXI.wdata),
    .B_VALID  (M_AXI.bvalid),
    .B_READY  (M_AXI.bready),
    .B_RESP   (M_AXI.bresp),
    .AR_VALID (M_AXI.arvalid),
    .AR_READY (M_AXI.arready),
    .AR_ADDR  (M_AXI.araddr),
    .R_VALID  (M_AXI.rvalid),
    .R_READY  (M_AXI.rready),
    .R_DATA   (M_AXI.rdata),
    .R_RESP   (M_AXI.rresp)
  );

initial aclk = 0;
always #10 aclk = ~aclk;

initial begin
  aresetn = 0;
  #50;
  aresetn = 1;
end

initial begin

  wait(aresetn == 1);
  @(posedge aclk);

  axi_master = new("axi_master", axi_vip_i.inst.IF);
  axi_master.start_master();

  axi_master.write(32'h0000_0004, 32'h1234_5678);
  axi_master.read (32'h0000_0004, data);
end

endmodule