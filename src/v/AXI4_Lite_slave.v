module axi4_lite_slave (
  input      [7:0] operandA,
  input      [7:0] operandB,
  input      [1:0] opp_code,
  output     [7:0] result
);

  // Połączenia do ALU
  wire [7:0] reg_result;

  alu alu_i (
    .operandA (operandA),
    .operandB (operandB),
    .opp_code (opp_code),
    .result   (reg_result)
  );

  // Przepisanie wyniku
  assign result = reg_result;

endmodule