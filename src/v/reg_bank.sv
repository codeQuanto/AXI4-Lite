module reg_bank (
  input  logic        clk,
  input  logic        reset_n,
  input  logic        write_en,
  input  logic [31:0] write_addr,
  input  logic [31:0] write_data,
  input  logic [31:0] read_addr,
  output logic [31:0] read_data
);

  // registers bank - 256 registers
  logic [31:0] reg_bank [255:0];

  logic [7:0]  write_idx;
  logic [7:0]  read_idx;

  // address mapping
  assign write_idx = write_addr[9:2];
  assign read_idx = read_addr[9:2];

  assign read_data = reg_bank[read_idx];

  always @(posedge clk) begin
    if (!reset_n) begin
      foreach (reg_bank[index]) begin
        reg_bank[index] <= 32'b0;
      end
    end else if (write_en)begin
      reg_bank[write_idx] <= write_data;
    end
  end

endmodule