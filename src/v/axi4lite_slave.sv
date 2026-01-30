//`include "params.vh"

module axi4lite_slave (
  input  logic                      A_CLK,
  input  logic                      A_RSTn,
  // AW channel
  input  logic                      AW_VALID,
  output logic                      AW_READY,
  input  logic [AXI_ADDR_WIDTH-1:0] AW_ADDR,
  // W channel
  input  logic                      W_VALID,
  output logic                      W_READY,
  input  logic [AXI_DATA_WIDTH-1:0] W_DATA,
  // B channel
  output logic                      B_VALID,
  input  logic                      B_READY,
  output logic [1:0]                B_RESP,
  // AR channel
  input  logic                      AR_VALID,
  output logic                      AR_READY,
  input  logic [AXI_ADDR_WIDTH-1:0] AR_ADDR,
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
  (* MARK_DEBUG="TRUE" *) logic [AXI_ADDR_WIDTH-1:0] aw_addr_latched;  // Fixed: was AXI_DATA_WIDTH
  (* MARK_DEBUG="TRUE" *) logic [AXI_ADDR_WIDTH-1:0] ar_addr_latched;  // Fixed: was AXI_DATA_WIDTH
  (* MARK_DEBUG="TRUE" *) logic write_en;
  logic [AXI_DATA_WIDTH-1:0] read_data;

  // reg_bank instantion
  reg_bank reg_bank_i(
    .clk         (A_CLK),
    .reset_n     (A_RSTn),
    .write_en    (write_en),
    .write_addr  (aw_addr_latched),
    .write_data  (W_DATA),
    .read_addr   (ar_addr_latched),
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
  assign B_RESP      = (curr_state == W_RESP)    ? 2'b00 : 2'b00;
  // AR
  assign AR_READY    = (curr_state == READ_ADDR) ? 1'b1 : 1'b0;
  // R
  assign R_VALID     = (curr_state == READ_DATA) ? 1'b1 : 1'b0;
  assign R_DATA      = (curr_state == READ_DATA) ? read_data : {AXI_DATA_WIDTH{1'b0}};
  assign R_RESP      = (curr_state == READ_DATA) ? 2'b00 : 2'b00;

  always_comb begin : flag_handling_b
    //// Default values to prevent latches
    //aw_handshake_flag = 1'b0;
    //w_handshake_flag  = 1'b0;
    
    case (curr_state)
      WRITE : begin 
                if (aw_handshake) aw_handshake_flag = 1'b1;
                if (w_handshake)  w_handshake_flag  = 1'b1;
              end
      default : begin
                aw_handshake_flag = 1'b0;
                w_handshake_flag  = 1'b0;
              end
    endcase
  end : flag_handling_b

  always_ff @(posedge A_CLK) begin : addr_latch_b
      if (!A_RSTn) begin
          aw_addr_latched <= {AXI_ADDR_WIDTH{1'b0}};  // Fixed: was AXI_DATA_WIDTH
          ar_addr_latched <= {AXI_ADDR_WIDTH{1'b0}};  // Fixed: was AXI_DATA_WIDTH
      end else begin
          if (AW_VALID && AW_READY) begin
              aw_addr_latched <= AW_ADDR;
          end
          if (AR_VALID && AR_READY) begin
              ar_addr_latched <= AR_ADDR;
          end
      end
  end : addr_latch_b

  always_ff @(posedge A_CLK) begin : driving_state_b
    if (!A_RSTn) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end : driving_state_b

  always_comb begin : state_machine_logic_b
    // Default to prevent latches
    next_state = curr_state;
    
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
      WRITE     : begin
                    if (aw_handshake_flag && w_handshake_flag) next_state = W_RESP;
                    else next_state = WRITE;
                  end
      W_RESP    : begin
                    if (B_VALID && B_READY) next_state = IDLE;
                    else next_state = W_RESP;
                  end
      READ_ADDR : begin
                    if (AR_VALID && AR_READY) next_state = READ_DATA;
                    else next_state = READ_ADDR;
                  end
      READ_DATA : begin
                    if (R_VALID && R_READY) next_state = IDLE;
                    else next_state = READ_DATA;
                  end
      default   : next_state = IDLE;
    endcase
  end : state_machine_logic_b

endmodule