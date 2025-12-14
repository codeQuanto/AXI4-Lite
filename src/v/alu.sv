module alu (
  input  logic [7:0] operandA,
  input  logic [7:0] operandB,
  input  logic [1:0] opp_code,
  output logic [7:0] result
);
  always_comb begin
    case (opp_code)
      2'b00 : result = operandA + operandB;
      2'b01 : result = operandA & operandB;
      2'b10 : result = operandA ^ operandB;
      2'b11 : result = operandA;
    endcase
  end
endmodule