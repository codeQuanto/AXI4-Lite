module alu_tb;

reg [1:0]  opp_code;
reg [7:0]  operandA;
reg [7:0]  operandB;
wire [7:0] result;

alu dut(operandA,operandB,opp_code,result);

integer i;

initial begin
operandA = 50; operandB = 10; opp_code = 0;

for(i = 1; i < 4; i = i+ 1)begin
    #10
    opp_code = i;
end

#10
$finish();

end

endmodule