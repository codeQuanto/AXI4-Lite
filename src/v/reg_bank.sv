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

  logic [7:0] operandA;
  logic [7:0] operandB;
  logic [1:0] opp_code;
  logic [7:0] result;

  // address mapping
  assign write_idx = { 4'b0, write_addr[5:2]};
  assign read_idx  = { 4'b0, read_addr[5:2]};

  // drive output
  assign read_data = reg_bank[read_idx];

  // ALU adresses mapping
  assign operandA = reg_bank[0][7:0];
  assign operandB = reg_bank[1][7:0];
  assign opp_code = reg_bank[2][1:0];
  // reg_bank[3][7:0] <= result - used in sequential logic

  // ALU module instatiation
  alu alu_i (
    .operandA (operandA),
    .operandB (operandB),
    .opp_code (opp_code),
    .result   (result)
  );

  always @(posedge clk) begin
    if (!reset_n) begin
      foreach (reg_bank[index]) begin
        reg_bank[index] <= 32'b0;
      end
    end else begin
      reg_bank[3][7:0] <= result;
      if (write_en && write_idx != 3) begin // reg_bank[3] read only
        reg_bank[write_idx] <= write_data;
      end
    end
  end

endmodule