/* output dla slave
 * output AW_READY, W_READY, B_VALID, B_RESP,
 * AR_READY, R_VALID, R_DATA, R_RESP
*/

module axi4lite_slave (
  axi4lite_if axi_if
);

  // declaring internal signals
  logic aw_ready;
  logic w_ready;
  logic b_valid;
  logic ar_ready;
  logic r_valid;

  assign AW_READY = aw_ready;
  assign W_READY  = w_ready;
  assign B_VALID  = b_valid;
  assign AR_READY = ar_ready;
  assign R_VALID  = r_valid;


  // Uppercase for input, lowercase for output

  // write addr logic
  always @(posedge A_CLK) begin
    if () begin
      aw_ready <= 1'b1;
    end
    // hold ready high until handshake
    if (AW_VALID && aw_ready) begin
      aw_ready <= 1'b0;
    end
  end

  // write data logic
  always @(posedge A_CLK) begin
    if () begin
      w_ready <= 1'b1;
    end
    // hold ready high until handshake
    if (W_VALID && w_ready) begin
      w_ready <= 1'b0;
    end
  end

  // write resp logic
  always @(posedge A_CLK) begin
    if (!A_RSTn) begin
      b_valid <= 1'b0;
    end else begin
      // TODO setting B ready and B resp
      // hold ready high until handshake
      if (b_valid && B_READY) begin
        b_valid <= 1'b0;
      end
    end
  end

  // read addr logic
  always @(posedge A_CLK) begin
    if () begin
      ar_ready <= 1'b1;
    end
    // hold valid high until handshake
    if (AR_VALID && ar_ready) begin
      ar_ready <= 1'b0;
    end
  end

  // read data logic
  always @(posedge A_CLK) begin
    if (!A_RSTn) begin
      r_valid <= 1'b0;
    end else begin
      if () begin
        r_valid <= 1'b1;
      end
      // hold valid high until handshake
      if (r_valid && R_READY) begin
        r_valid <= 1'b0;
      end
    end
  end

  // TODO add RRESP service

endmodule