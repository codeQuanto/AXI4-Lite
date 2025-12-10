/* output dla slave
 * output AW_READY, W_READY, B_VALID, B_RESP,
 * AR_READY, R_VALID, R_DATA, R_RESP
*/

module axi4lite_slave (
  axi4lite_if axi_if
);

  // write addr logic
  always @(posedge A_CLK) begin
    if (aw_ready) begin
      AW_READY <= 1'b1;
    end
    // hold ready high until handshake
    if (AW_VALID && AW_READY) begin
      AW_READY <= 1'b0;
    end
  end

  // write data logic
  always @(posedge A_CLK) begin
    if (w_ready) begin
      W_READY <= 1'b1;
    end
    // hold ready high until handshake
    if (W_VALID && W_READY) begin
      W_READY <= 1'b0;
    end
  end

  // write resp logic
  always @(posedge A_CLK) begin
    if (!A_RSTn) begin
      B_VALID <= 1'b0;
    end else begin
      // TODO setting B ready and B resp
      // hold ready high until handshake
      if (B_VALID && B_READY) begin
        B_READY <= 1'b0;
      end
    end
  end

  // read addr logic
  always @(posedge A_CLK) begin
    if (ar_ready) begin
      AR_READY <= 1'b1;
    end
    // hold valid high until handshake
    if (AR_VALID && AR_READY) begin
      AR_READY <= 1'b0;
    end
  end

  // read data logic
  always @(posedge A_CLK) begin
    if (!A_RSTn) begin
      R_VALID <= 1'b0;
    end else begin
      if (r_valid) begin
        R_VALID <= 1'b1;
      end
      // hold valid high until handshake
      if (R_VALID && R_READY) begin
        R_VALID <= 1'b0;
      end
    end
  end

  // TODO add RRESP service

endmodule