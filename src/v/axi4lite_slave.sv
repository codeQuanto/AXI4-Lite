
module axi4lite_slave (
  // Global
  input  logic A_CLK, 
  input  logic A_RSTn,
  // AW channel
  input  logic                      AW_VALID,
  output logic                      AW_READY,
  input  logic [AXI_ADDR_WIDTH-1:0] AW_ADDR,
  // input  logic [2:0]                AW_PROT,
  // W channel
  input  logic                      W_VALID,
  output logic                      W_READY,
  input  logic [AXI_DATA_WIDTH-1:0] W_DATA,
  // inout  logic [AXI_STRB_WIDTH-1:0] W_STRB,
  // B channel
  output logic                      B_VALID,
  input  logic                      B_READY,
  output logic [1:0]                B_RESP,
  // AR channel
  input  logic                      AR_VALID,
  output logic                      AR_READY,
  input  logic [AXI_ADDR_WIDTH-1:0] AR_ADDR,
  // input  logic [2:0]                AR_PROT,
  // R channel
  output logic                      R_VALID,
  input  logic                      R_READY,
  output logic [AXI_DATA_WIDTH-1:0] R_DATA,
  output logic [1:0]                R_RESP
);

  // declaring internal signals
  typedef enum logic [2:0] {IDLE, WRITE, W_RESP, READ_ADDR, READ_DATA} state_t;
  state_t curr_state;
  state_t next_state;

  logic aw_handshake;
  logic w_handshake;
  logic aw_handshake_flag;
  logic w_handshake_flag;

  logic write_en;
  logic [AXI_DATA_WIDTH-1:0] read_data;

  // reg_bank instantion
  reg_bank reg_bank_i(
    .clk         (A_CLK),
    .reset_n     (A_RSTn),
    .write_en    (write_en),
    .write_addr  (AW_ADDR),
    .write_data  (W_DATA),
    .read_addr   (AR_ADDR),
    .read_data   (read_data)
  );

  // Setting proper flags based on current state
  // AW
  assign AW_READY    = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  // W
  assign W_READY     = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  assign aw_handshake       = AW_VALID && AW_READY;
  assign w_handshake        = W_VALID && W_READY;
  assign write_en           = aw_handshake_flag && w_handshake_flag;
  // B
  assign B_VALID     = (curr_state == W_RESP)    ? 1'b1 : 1'b0;
  assign B_RESP      = (curr_state == W_RESP)    ? 2'b1 : 2'b0; // TODO response is always 1'b1 - just to observe the reaction (should be 0)
  // AR
  assign AR_READY    = (curr_state == READ_ADDR) ? 1'b1 : 1'b0;
  // R
  assign R_VALID     = (curr_state == READ_DATA) ? 1'b1 : 1'b0;
  assign R_DATA      = (curr_state == READ_DATA) ? read_data : {AXI_DATA_WIDTH{1'b0}};
  assign R_RESP      = (curr_state == READ_DATA) ? 2'b1 : 2'b0; // TODO response is always 1'b1 - just to observe the reaction (should be 0)

  always_comb begin : flag_handling_b
    case (curr_state)
      WRITE : begin 
                if (aw_handshake) aw_handshake_flag = 1'b1;
                if (w_handshake)  w_handshake_flag  = 1'b1;
              end
      W_RESP : begin
                aw_handshake_flag = 1'b0;
                w_handshake_flag  = 1'b0;
              end
    endcase
  end : flag_handling_b

  always_ff @(posedge A_CLK) begin : driving_state_b
    if (!A_RSTn) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end : driving_state_b

  always_comb begin : state_machine_logic_b
    case (curr_state)
      IDLE      : begin
                    if (AR_VALID) begin
                      next_state = READ_ADDR;
                    end else if (AW_VALID || W_VALID) begin
                      next_state = WRITE;
                    end else begin
                      next_state = IDLE;
                    end
                  end
      WRITE     : if (aw_handshake_flag && w_handshake_flag) next_state = W_RESP;
      W_RESP    : if (B_VALID  && B_READY)     next_state = IDLE;
      READ_ADDR : if (AR_VALID && AR_READY)    next_state = READ_DATA;
      READ_DATA : if (R_VALID  && R_READY)     next_state = IDLE;
      default   : next_state = IDLE;
    endcase
  end : state_machine_logic_b

endmodule