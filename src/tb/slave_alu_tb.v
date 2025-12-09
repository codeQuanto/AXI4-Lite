module alu_tb;

reg [7:0]  operandA2;
reg [7:0]  operandB;
reg [1:0]  opp_code;
wire [7:0] result;

axi4_lite_slave dut(
  .operandA (operandA2),
  .operandB (operandB),
  .opp_code (opp_code),
  .result   (result)
);

integer i;

initial begin
operandA2 = 50; operandB = 10; opp_code = 0;


for(i = 1; i < 4; i = i+ 1)begin
    #10
    opp_code = i;
end

#10
$finish();

end

endmodule