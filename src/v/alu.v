module alu (
  input      [7:0] operandA,
  input      [7:0] operandB,
  input      [1:0] opp_code,
  output reg [7:0] result
);
  always @(*) begin
      case (opp_code)
      2'b00 : result = operandA + operandB;
      2'b01 : result = operandA & operandB;
      2'b10 : result = operandA ^ operandB;
      2'b11 : result = operandA ^ operandB;
    endcase
  end
endmodule