// INCLUDE_TAG     ------ Begin cut for INTERFACE INSTANTIATION Include ------
`include "vivado_interfaces.svh"
// INCLUDE_TAG_END ------  End cut for INTERFACE INSTANTIATION Include  ------

// INTF_TAG     ------ Begin cut for INTERFACE INSTANTIATION Template ------
vivado_axi4_lite_v1_0 M_AXI();
// INTF_TAG_END ------  End cut for INTERFACE INSTANTIATION Template  ------

// INST_TAG     ------ Begin cut for WRAPPER INSTANTIATION Template ------
axi_vip_0_sv axi_vip_i (
  .M_AXI(M_AXI.master), // vivado_axi4_lite_v1_0.master M_AXI
  .aclk(aclk), // input wire aclk
  .aresetn(aresetn) // input wire aresetn
);
// INST_TAG_END ------  End cut for WRAPPER INSTANTIATION Template  ------

// You must compile the wrapper file axi_vip_0_sv.sv when simulating
// the module, axi_vip_0_sv. When compiling the wrapper file, be sure to
// reference the System Verilog simulation library.
