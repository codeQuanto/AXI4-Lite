parameter AXI_DATA_WIDTH = 32;
parameter AXI_ADDR_WIDTH = 32;
parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH+7)/8;

// Opcode enum for ALU and memory operations
typedef enum logic [2:0] {
  ADD     = 3'b000,
  AND     = 3'b001,
  XOR     = 3'b010,
  LOAD_A  = 3'b011,
  M_PLUS  = 3'b100,
  M_MINUS = 3'b101,
  MR      = 3'b110,
  MC      = 3'b111
} opcode_t;