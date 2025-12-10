module axi4lite_slave (
  axi4lite_if axi_if
);

  // declaring internal signals
  typedef enum logic [2:0] {IDLE, WRITE, W_RESP, READ_ADDR, READ_DATA} state_t;
  state_t curr_state;
  state_t next_state;

  logic w_addr_flag;
  logic w_data_flag;

  // Setting proper flags based on current state
  // AW
  assign axi_if.AW_READY    = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  // W
  assign axi_if.W_READY     = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  assign w_addr_flag = axi_if.AW_VALID && axi_if.AW_READY;
  assign w_data_flag = axi_if.W_VALID && axi_if.W_READY  ;
  // B
  assign axi_if.B_VALID     = (curr_state == W_RESP)    ? 1'b1 : 1'b0;
  assign axi_if.B_RESP      = (curr_state == W_RESP)    ? 2'b0 : 2'b0; // TODO response is always OKAY
  // AR
  assign axi_if.AR_READY    = (curr_state == READ_ADDR) ? 1'b1 : 1'b0;
  // R
  assign axi_if.R_VALID     = (curr_state == READ_DATA) ? 1'b1 : 1'b0;
  assign axi_if.R_DATA      = (curr_state == READ_DATA) ? {AXI_DATA_WIDTH{1'b1}} : 1'b0; // TODO add real data
  assign axi_if.R_RESP      = (curr_state == READ_DATA) ? 2'b0 : 2'b0; // TODO response is always OKAY

  // TODO for now, writtig transaction does nothing

  // moving forward with the transaction
  always_ff @(posedge axi_if.A_CLK) begin
    if (!axi_if.A_RSTn) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end

  // setting ordinary of the transaction
  always_comb begin
    case (curr_state)
      IDLE      : begin // TODO what if ar and ar valid are both high?
                    if (axi_if.AW_VALID) begin
                      next_state = WRITE;
                    end else if (axi_if.AR_VALID) begin
                      next_state = READ_ADDR;
                    end
                  end
      WRITE     : next_state = W_RESP;
      W_RESP    : next_state = IDLE;
      READ_ADDR : next_state = READ_DATA;
      READ_DATA : next_state = IDLE;
      default   : next_state = IDLE;
    endcase
  end

endmodule