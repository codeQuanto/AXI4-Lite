`include "params.vh"

module alu (
  input  logic [7:0] operandA,
  input  logic [7:0] operandB,
  input  logic [2:0] opp_code,  // Changed from opcode_t to logic [2:0]
  output logic [7:0] result
);
  always_comb begin
    case (opp_code)
      3'b000  : result = operandA + operandB; // ADD
      3'b001  : result = operandA & operandB; // AND
      3'b010  : result = operandA ^ operandB; // XOR
      3'b011  : result = 8'h00; // LOAD_A - operacja wykonywana w reg_bank
      3'b100  : result = 8'h00; // M_PLUS - operacja wykonywana w reg_bank
      3'b101  : result = 8'h00; // M_MINUS - operacja wykonywana w reg_bank
      3'b110  : result = 8'h00; // MR - operacja wykonywana w reg_bank
      3'b111  : result = 8'h00; // MC - operacja wykonywana w reg_bank
      default : result = 8'h00;
    endcase
  end
endmodule