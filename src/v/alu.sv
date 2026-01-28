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
      default : result = 8'h00;
    endcase
  end
endmodule