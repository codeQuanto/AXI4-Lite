`include "vivado_interfaces.svh"
import axi_vip_pkg::*;
import axi_vip_0_pkg::*;

module top_tb(
);

  logic aclk;
  logic aresetn;
  logic [31:0] data;

  axi_vip_0_mst_t axi_master;

  vivado_axi4_lite_v1_0 M_AXI();
  axi4lite_if axi_if(aclk, aresetn);
  
  axi_vip_0_sv axi_vip_i (
    .M_AXI(M_AXI.master), // vivado_axi4_lite_v1_0.master M_AXI
    .aclk(aclk),          // input wire aclk
    .aresetn(aresetn)     // input wire aresetn
  );



  axi4lite_slave dut (
    //.A_CLK    (aclk),
    //.A_RSTn   (aresetn),
    .axi_if   (axi_if.slave)

    /*
    .AW_VALID (M_AXI.m_axi_awvalid),
    .AW_READY (M_AXI.m_axi_awready),
    .AW_ADDR  (M_AXI.m_axi_awaddr),
    .W_VALID  (M_AXI.m_axi_wvalid),
    .W_READY  (M_AXI.m_axi_wready),
    .W_DATA   (M_AXI.m_axi_wdata),
    .B_VALID  (M_AXI.m_axi_bvalid),
    .B_READY  (M_AXI.m_axi_bready),
    .B_RESP   (M_AXI.m_axi_bresp),
    .AR_VALID (M_AXI.m_axi_arvalid),
    .AR_READY (M_AXI.m_axi_arready),
    .AR_ADDR  (M_AXI.m_axi_araddr),
    .R_VALID  (M_AXI.m_axi_rvalid),
    .R_READY  (M_AXI.m_axi_rready),
    .R_DATA   (M_AXI.m_axi_rdata),
    .R_RESP   (M_AXI.m_axi_rresp) */
  );

assign axi_if.AW_VALID = M_AXI.AWVALID;
assign axi_if.AW_ADDR  = M_AXI.AWADDR;
assign axi_if.W_VALID  = M_AXI.WVALID;
assign axi_if.W_DATA   = M_AXI.WDATA;
assign axi_if.B_READY  = M_AXI.BREADY;
assign axi_if.AR_VALID = M_AXI.ARVALID;
assign axi_if.AR_ADDR  = M_AXI.ARADDR;
assign axi_if.R_READY  = M_AXI.RREADY;

assign M_AXI.AWREADY = axi_if.AW_READY;
assign M_AXI.WREADY  = axi_if.W_READY;
assign M_AXI.BVALID  = axi_if.B_VALID;
assign M_AXI.BRESP   = axi_if.B_RESP;
assign M_AXI.ARREADY = axi_if.AR_READY;
assign M_AXI.RVALID  = axi_if.R_VALID;
assign M_AXI.RDATA   = axi_if.R_DATA;
assign M_AXI.RRESP   = axi_if.R_RESP;

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

  axi_master = new("axi_master", top_tb.axi_vip_i.inst.inst.IF);
  axi_master.start_master();

  // tutaj trzeba poczytac w poradniku VIPa jak to zrobic. Widzialem inne komendy, inny 'workflow'
  //axi_master.write(32'h0000_0004, 32'h1234_5678);
  //axi_master.read (32'h0000_0004, data);
end

endmodule