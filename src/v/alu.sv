`include "params.vh"

module alu (
  input  logic [7:0] operandA,
  input  logic [7:0] operandB,
  input  opcode_t    opp_code,
  output logic [7:0] result
);
  always_comb begin
    case (opp_code)
      ADD     : result = operandA + operandB;
      AND     : result = operandA & operandB;
      XOR     : result = operandA ^ operandB;
      default : result = 8'h00;
    endcase
  end
endmodule