`include "vivado_interfaces.svh"

module top(
  input logic aclk,
  input logic aresetn
);

  vivado_axi4_lite_v1_0 M_AXI();
  
  axi_vip_0_sv axi_vip_i (
    .M_AXI(M_AXI.master), // vivado_axi4_lite_v1_0.master M_AXI
    .aclk(aclk),          // input wire aclk
    .aresetn(aresetn)     // input wire aresetn
  );

  axi4lite_if axi_if (
    .A_CLK (aclk),
    .A_RSTn (aresetn)
  );

  axi4lite_slave dut (.axi_if (axi_if.slave));

// s_input = m_output
assign dut.axi_if.AW_ADDR  = axi_vip_i.M_AXI.m_axi_awaddr;
assign dut.axi_if.AW_VALID = axi_vip_i.M_AXI.m_axi_awvalid;
assign dut.axi_if.W_DATA   = axi_vip_i.M_AXI.m_axi_wdata;
assign dut.axi_if.W_VALID  = axi_vip_i.M_AXI.m_axi_wvalid;
assign dut.axi_if.B_READY  = axi_vip_i.M_AXI.m_axi_bready;
assign dut.axi_if.AR_ADDR  = axi_vip_i.M_AXI.m_axi_araddr;
assign dut.axi_if.AR_VALID = axi_vip_i.M_AXI.m_axi_arvalid;
assign dut.axi_if.R_READY  = axi_vip_i.M_AXI.m_axi_rready;

// m_input = s_output
assign axi_vip_i.M_AXI.m_axi_awready = dut.axi_if.AW_READY;
assign axi_vip_i.M_AXI.m_axi_wready  = dut.axi_if.W_READY;
assign axi_vip_i.M_AXI.m_axi_bresp   = dut.axi_if.B_RESP;
assign axi_vip_i.M_AXI.m_axi_bvalid  = dut.axi_if.B_VALID;
assign axi_vip_i.M_AXI.m_axi_arready = dut.axi_if.AR_READY;
assign axi_vip_i.M_AXI.m_axi_rdata   = dut.axi_if.R_DATA;
assign axi_vip_i.M_AXI.m_axi_rresp   = dut.axi_if.R_RESP;
assign axi_vip_i.M_AXI.m_axi_rvalid  = dut.axi_if.R_VALID;

endmodule