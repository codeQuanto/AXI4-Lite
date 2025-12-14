`include "params.vh"

interface axi4lite_if (input A_CLK, input A_RSTn);
  // AW channel
  logic                      AW_VALID;
  logic                      AW_READY;
  logic [AXI_ADDR_WIDTH-1:0] AW_ADDR;
  //logic [2:0]                AW_PROT;
  // W channel
  logic                      W_VALID;
  logic                      W_READY;
  logic [AXI_DATA_WIDTH-1:0] W_DATA;
  //logic [AXI_STRB_WIDTH-1:0] W_STRB;
  // B channel
  logic                      B_VALID;
  logic                      B_READY;
  logic [1:0]                B_RESP;
  // AR channel
  logic                      AR_VALID;
  logic                      AR_READY;
  logic [AXI_ADDR_WIDTH-1:0] AR_ADDR;
  //logic [2:0]                AR_PROT;
  // R channel
  logic                      R_VALID;
  logic                      R_READY;
  logic [AXI_DATA_WIDTH-1:0] R_DATA;
  logic [1:0]                R_RESP;

  // Master perspective
  modport master ( input  A_CLK, A_RSTn,
                          AW_READY, W_READY, B_VALID, B_RESP,
                          AR_READY, R_VALID, R_DATA, R_RESP,
                   output AW_VALID, AW_ADDR, /*AW_PROT,*/ W_VALID, W_DATA, /*W_STRB,*/ B_READY,
                          AR_VALID, AR_ADDR, /*AR_PROT,*/ R_READY
  );
  // Slave perspective
  modport slave ( input  A_CLK, A_RSTn,
                         AW_VALID, AW_ADDR, /*AW_PROT,*/ W_VALID, W_DATA, /*W_STRB,*/ B_READY,
                         AR_VALID, AR_ADDR, /*AR_PROT,*/ R_READY,
                  output AW_READY, W_READY, B_VALID, B_RESP,
                         AR_READY, R_VALID, R_DATA, R_RESP
  );
endinterface
