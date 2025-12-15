//`include "params.vh"
module axi4lite_slave (
  axi4lite_if  axi_if
);

  // declaring internal signals
  typedef enum logic [2:0] {IDLE, WRITE, W_RESP, READ_ADDR, READ_DATA} state_t;
  state_t curr_state;
  state_t next_state;

  logic aw_handshake;
  logic w_handshake;
  logic aw_handshake_flag;
  logic w_handshake_flag;
  logic [AXI_DATA_WIDTH-1:0] aw_addr_latched;
  logic [AXI_DATA_WIDTH-1:0] ar_addr_latched;
  logic write_en;
  logic [AXI_DATA_WIDTH-1:0] read_data;

  // reg_bank instantion
  reg_bank reg_bank_i(
    .clk         (axi_if.A_CLK),
    .reset_n     (axi_if.A_RSTn),
    .write_en    (write_en),
    .write_addr  ( (axi_if.AW_VALID && axi_if.AW_READY) ? axi_if.AW_ADDR : aw_addr_latched ),
    .write_data  (axi_if.W_DATA),
    .read_addr   ( (axi_if.AR_VALID && axi_if.AR_READY) ? axi_if.AR_ADDR : ar_addr_latched ),
    .read_data   (read_data)
  );

  // Setting proper flags based on current state
  // AW
  assign axi_if.AW_READY    = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  // W
  assign axi_if.W_READY     = (curr_state == WRITE)     ? 1'b1 : 1'b0;
  assign aw_handshake       = axi_if.AW_VALID && axi_if.AW_READY;
  assign w_handshake        = axi_if.W_VALID && axi_if.W_READY;
  assign write_en           = aw_handshake_flag && w_handshake_flag;
  // B
  assign axi_if.B_VALID     = (curr_state == W_RESP)    ? 1'b1 : 1'b0;
  assign axi_if.B_RESP      = (curr_state == W_RESP)    ? 2'b00 : 2'b00;
  // AR
  assign axi_if.AR_READY    = (curr_state == READ_ADDR) ? 1'b1 : 1'b0;
  // R
  assign axi_if.R_VALID     = (curr_state == READ_DATA) ? 1'b1 : 1'b0;
  assign axi_if.R_DATA      = (curr_state == READ_DATA) ? read_data : {AXI_DATA_WIDTH{1'b0}};
  assign axi_if.R_RESP      = (curr_state == READ_DATA) ? 2'b00 : 2'b00;

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

  always_ff @(posedge axi_if.A_CLK) begin : addr_latch_b
      if (!axi_if.A_RSTn) begin
          aw_addr_latched <= {AXI_DATA_WIDTH{1'b0}};
          ar_addr_latched <= {AXI_DATA_WIDTH{1'b0}};
      end else begin
          if (axi_if.AW_VALID && axi_if.AW_READY) begin
              aw_addr_latched <= axi_if.AW_ADDR;
          end
          if (axi_if.AR_VALID && axi_if.AR_READY) begin
              ar_addr_latched <= axi_if.AR_ADDR;
          end
      end
  end : addr_latch_b

  always_ff @(posedge axi_if.A_CLK) begin : driving_state_b
    if (!axi_if.A_RSTn) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end : driving_state_b

  always_comb begin : state_machine_logic_b
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
      WRITE     : if (aw_handshake_flag && w_handshake_flag) next_state = W_RESP;
      W_RESP    : if (axi_if.B_VALID  && axi_if.B_READY)     next_state = IDLE;
      READ_ADDR : if (axi_if.AR_VALID && axi_if.AR_READY)    next_state = READ_DATA;
      READ_DATA : if (axi_if.R_VALID  && axi_if.R_READY)     next_state = IDLE;
      default   : next_state = IDLE;
    endcase
  end : state_machine_logic_b

endmodule