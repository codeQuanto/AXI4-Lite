//`include "params.vh"

module reg_bank (
  input  logic        clk,
  input  logic        reset_n,
  input  logic        write_en,
  input  logic [31:0] write_addr,
  input  logic [31:0] write_data,
  input  logic [31:0] read_addr,
  output logic [31:0] read_data
);

  // registers bank - 16 registers
  logic [31:0] reg_bank [15:0];

  // mapped addresses
  logic [7:0]  write_idx;
  logic [7:0]  read_idx;

  logic [3:0]  mem_sel;
  logic [7:0]  operandA;
  logic [7:0]  operandB;
  logic [2:0]  opp_code;  // Changed from opcode_t to logic [2:0]
  logic [31:0] mem_op_result;
  logic        mem_en;
  logic [7:0]  result;

  // address mapping
  assign write_idx = { 4'b0, write_addr[5:2]};
  assign read_idx  = { 4'b0, read_addr[5:2]};

  // drive output
  assign read_data = reg_bank[read_idx];

  // ALU adresses mapping
  assign operandA   = reg_bank[0][7:0];
  assign operandB   = reg_bank[1][7:0];
  assign opp_code   = reg_bank[2][2:0];  // Direct assignment without enum cast
  assign mem_sel    = reg_bank[4][3:0]; // holds index of register for memory operations
  // reg_bank[3][7:0] <= result - used in sequential logic

  // ALU module instantiation
  alu alu_i (
    .operandA (operandA),
    .operandB (operandB),
    .opp_code (opp_code),
    .result   (result)
  );

  always_comb begin
    // Default to prevent latches
    mem_op_result = 32'h00;
    
    // Memory operations - use literal values instead of enum
    if (mem_en) begin
      case (opp_code)
        3'b100  : mem_op_result = reg_bank[mem_sel] + reg_bank[3][7:0]; // M_PLUS
        3'b101  : mem_op_result = reg_bank[mem_sel] - reg_bank[3][7:0]; // M_MINUS
        3'b110  : mem_op_result = reg_bank[mem_sel];                    // MR
        3'b111  : mem_op_result = 32'h00;                               // MC
        default : mem_op_result = 32'h00;
      endcase
    end
  end

  always @(posedge clk) begin
    if (!reset_n) begin
      foreach (reg_bank[index]) begin
        reg_bank[index] <= 32'b0;
      end
    end else begin
      // ALU operations
      reg_bank[3][7:0] <= result;
      // Memory operations
      if (opp_code[2] == 1'b1) begin
        reg_bank[mem_sel] <= mem_op_result;
      end else if (opp_code == 3'b011) begin  // LOAD_A literal value
        // load value from mem as operandA
        reg_bank[0][7:0] <= reg_bank[mem_sel][7:0];
      end

      if (write_en && write_idx != 3) begin // reg_bank[3] read only
        reg_bank[write_idx] <= write_data;
        mem_en <= 1'b1;
      end else begin
        mem_en <= 1'b0; // auto disable memory operations after write
      end
    end
  end

endmodule