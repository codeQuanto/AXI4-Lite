`include "vivado_interfaces.svh"
//`include "params.vh"
import axi_vip_pkg::*;
import axi_vip_0_pkg::*;

module top_tb(
);

  logic aclk;
  logic aresetn;

  axi_vip_0_mst_t axi_master; // master agent

  vivado_axi4_lite_v1_0 M_AXI();     // VIP master interface
  axi4lite_if axi_if(aclk, aresetn); // custom interface

  // VIP instation
  axi_vip_0_sv axi_vip_i (
    .M_AXI(M_AXI.master), // vivado_axi4_lite_v1_0.master M_AXI
    .aclk(aclk),          // input wire aclk
    .aresetn(aresetn)     // input wire aresetn
  );

  // DUT instation
  axi4lite_slave dut (
    .axi_if   (axi_if.slave)
  );

// DUT-VIP connection
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

// clk creation
initial aclk = 0;
always #10 aclk = ~aclk;

// initial reset
initial begin
  aresetn = 0;
  #400;
  aresetn = 1;
end

// main test block
initial begin : main_test_b

  xil_axi_resp_t resp;      
  logic [31:0]   rdata;     
  logic [31:0]   expected;  
  logic [31:0]   test_val;
  
  wait(aresetn == 1);
  @(posedge aclk);

  axi_master = new("axi_master", top_tb.axi_vip_i.inst.inst.IF);
  axi_master.start_master();

  $display("[TEST 1] Konfiguracja: 50 + 10 (ADD)");

  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, 32'd50, resp);
 
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'd10, resp);
  
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd0, resp);

  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);

  if (rdata == 32'd60) 
      $display("[PASS] Odczytano poprawny wynik: %0d", rdata);
  else 
      $error("[FAIL] Oczekiwano 60, otrzymano: %0d", rdata);

  #50;


  $display("[TEST 2] Zmiana operacji na AND");

  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd1, resp);
  
  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);

  if (rdata == 32'd2) 
      $display("[PASS] Odczytano poprawny wynik: %0d", rdata);
  else 
      $error("[FAIL] Oczekiwano 2, otrzymano: %0d", rdata);

  #50;

  $display("[TEST 3] Przeplatane zmiany operacji");

  // A=100 B=50 ADD=150
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, 32'd100, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'd50, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd0, resp); 
  
  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);
  if (rdata != 150) $error("Blad! Otrzymano: %d", rdata);
  else $display("[PASS] 100 + 50 = %0d", rdata);

  // A=255(0xFF) B=0  AND=0
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, 32'hFF, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'h00, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd1, resp); 

  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);
  if (rdata != 0) $error("Blad! Otrzymano: %d", rdata);
  else $display("[PASS] 0xFF & 0x00 = %0d", rdata);

  #50; 
  
  $display("[TEST 4] R/W Check");

  test_val = 32'hAABB_CCDD; 
  $display("   -> Zapis do OperandA: %h", test_val);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, test_val, resp); 
  
  #50;
  
  axi_master.AXI4LITE_READ_BURST(32'h0000_0000, 0, rdata, resp);     
  if (rdata == test_val) $display("[PASS] Odczyt zgodny!");
  else $error("[FAIL] Oczekiwano %h, odczytano %h", test_val, rdata);

  #50;

  $display("[TEST 5] Sekwencja do wizualizacji AXI (20 + 30)");

  // ZapisA=20 
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, 32'd20, resp);
  #200; 
  // ZapisB=30
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'd30, resp);
  #200;

  // Zapis OpCode=ADD
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd0, resp);
  #200;

  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);
  if (rdata == 50) $display("      [PASS] Wynik koncowy OK: %0d", rdata);

  #200;

  // ===== TESTY OPERACJI PAMIECIOWYCH =====
  $display("\n[TEST 6] Memory Operations (M+, M-, MR, MC)");
  
  // Setup ALU: ADD 15 + 0 = 15
  $display("   Setting up ALU: 15 + 0 = 15");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, 32'd15, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'd0, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd0, resp);  // ADD
  #200;

  // M+ test: reg[5] += 15 (result: 15)
  $display("   -> M+ (add 15 to reg[5])");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0010, 0, 32'd5, resp);  // mem_sel = 5
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd4, resp);  // opcode = M+ (0x4)
  #200;
  axi_master.AXI4LITE_READ_BURST(32'h0000_0014, 0, rdata, resp);
  if (rdata == 15) $display("      [PASS] reg[5] = %0d (expected 15)", rdata);
  else $error("      [FAIL] reg[5] = %0d (expected 15)", rdata);
  #200;

  // M+ again: reg[5] += 15 (result: 30)
  $display("   -> M+ again (accumulate 15, total = 30)");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd4, resp);  // opcode = M+
  #200;
  axi_master.AXI4LITE_READ_BURST(32'h0000_0014, 0, rdata, resp);
  if (rdata == 30) $display("      [PASS] reg[5] = %0d (expected 30)", rdata);
  else $error("      [FAIL] reg[5] = %0d (expected 30)", rdata);
  #200;

  // Setup ALU: ADD 8 + 0 = 8
  $display("   Setting up ALU: 8 + 0 = 8");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0000, 0, 32'd8, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'd0, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd0, resp);  // ADD
  #200;

  // M- test: reg[5] -= 8 (result: 22)
  $display("   -> M- (subtract 8 from reg[5], 30 - 8 = 22)");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd5, resp);  // opcode = M- (0x5)
  #200;
  axi_master.AXI4LITE_READ_BURST(32'h0000_0014, 0, rdata, resp);
  if (rdata == 22) $display("      [PASS] reg[5] = %0d (expected 22)", rdata);
  else $error("      [FAIL] reg[5] = %0d (expected 22)", rdata);
  #200;

  // MR test: read reg[5] to reg[3]
  $display("   -> MR (recall reg[5] to reg[3])");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0010, 0, 32'd5, resp);  // mem_sel = 5
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd6, resp);  // opcode = MR (0x6)
  #200;
  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);
  if (rdata == 22) $display("      [PASS] reg[3] = %0d (expected 22)", rdata);
  else $error("      [FAIL] reg[3] = %0d (expected 22)", rdata);
  #200;

  // MC test: clear reg[5]
  $display("   -> MC (clear reg[5])");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd7, resp);  // opcode = MC (0x7)
  #200;
  axi_master.AXI4LITE_READ_BURST(32'h0000_0014, 0, rdata, resp);
  if (rdata == 0) $display("      [PASS] reg[5] = %0d (expected 0)", rdata);
  else $error("      [FAIL] reg[5] = %0d (expected 0)", rdata);
  #200;

  // ===== TEST LOAD A =====
  $display("\n[TEST 7] Load A Operation");
  
  // Put value 42 in reg[6]
  $display("   Storing 42 in reg[6]");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0018, 0, 32'd42, resp);
  #200;

  // Load A: reg[0] <= reg[6]
  $display("   -> Load A (load reg[6]=42 to operandA)");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0010, 0, 32'd6, resp);  // mem_sel = 6
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd3, resp);  // opcode = Load A (0x3)
  #200;

  // Do ALU: 42 + 18 = 60
  $display("   Setting up ALU: 42 (loaded) + 18 = 60");
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0004, 0, 32'd18, resp);
  axi_master.AXI4LITE_WRITE_BURST(32'h0000_0008, 0, 32'd0, resp);  // opcode = ADD
  #200;
  axi_master.AXI4LITE_READ_BURST(32'h0000_000C, 0, rdata, resp);
  if (rdata == 60) $display("      [PASS] reg[3] = %0d (expected 60)", rdata);
  else $error("      [FAIL] reg[3] = %0d (expected 60)", rdata);

  $finish;
end : main_test_b

endmodule