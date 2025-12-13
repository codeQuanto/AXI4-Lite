
module axi4lite_slave (
  axi4lite_if axi_if
);

  // declaring internal signals
  typedef enum logic [2:0] {IDLE, WRITE, W_RESP, READ_ADDR, READ_DATA} state_t;
  state_t curr_state;
  state_t next_state;

  logic aw_handshake;
  logic w_handshake;

  // Setting proper flags based on current state
  // AW
  assign axi_if.AW_READY    = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  // W
  assign axi_if.W_READY     = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  assign aw_handshake       = axi_if.AW_VALID && axi_if.AW_READY;
  assign w_handshake        = axi_if.W_VALID && axi_if.W_READY  ;
  // B
  assign axi_if.B_VALID     = (curr_state == W_RESP)    ? 1'b1 : 1'b0;
  assign axi_if.B_RESP      = (curr_state == W_RESP)    ? 2'b1 : 2'b0; // TODO response is always 1'b1 - just to observe the reaction (should be 0)
  // AR
  assign axi_if.AR_READY    = (curr_state == READ_ADDR) ? 1'b1 : 1'b0;
  // R
  assign axi_if.R_VALID     = (curr_state == READ_DATA) ? 1'b1 : 1'b0;
  assign axi_if.R_DATA      = (curr_state == READ_DATA) ? {AXI_DATA_WIDTH{1'b1}} : {AXI_DATA_WIDTH{1'b0}}; // TODO add real data
  assign axi_if.R_RESP      = (curr_state == READ_DATA) ? 2'b1 : 2'b0; // TODO response is always 1'b1 - just to observe the reaction (should be 0)

  // moving forward with the transaction
  always_ff @(posedge axi_if.A_CLK) begin
    if (!axi_if.A_RSTn) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end

  // state machine for the transaction flow
  always_comb begin
    case (curr_state)
      IDLE      : begin
                    if (axi_if.AR_VALID) begin
                      next_state = READ_ADDR;
                    end else if (axi_if.AW_VALID || axi_if.W_VALID) begin
                      next_state = WRITE;
                    end else begin
                      next_state = IDLE;
                    end
                  end
      WRITE     : if (aw_handshake    && w_handshake)     next_state = W_RESP;
      W_RESP    : if (axi_if.B_VALID  && axi_if.B_READY)  next_state = IDLE;
      READ_ADDR : if (axi_if.AR_VALID && axi_if.AR_READY) next_state = READ_DATA;
      READ_DATA : if (axi_if.R_VALID  && axi_if.R_READY)  next_state = IDLE;
      default   : next_state = IDLE;
    endcase
  end

endmodule