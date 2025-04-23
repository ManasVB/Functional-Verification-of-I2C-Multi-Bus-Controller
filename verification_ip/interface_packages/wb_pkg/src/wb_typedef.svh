parameter int WB_DATA_WIDTH = 8;
parameter int WB_ADDR_WIDTH = 2;

parameter CSR_Reg = 8'h00;
parameter DPR_Reg = 8'h01;
parameter CMDR_Reg = 8'h02;
parameter FSMR_Reg = 8'h03;

typedef enum bit [2:0] {
    CMD_START       = 3'b100,
    CMD_STOP        = 3'b101,
    CMD_READ_ACK    = 3'b010,
    CMD_READ_NAK    = 3'b011,
    CMD_WRITE       = 3'b001,
    CMD_SET_BUS     = 3'b110,
    CMD_WAIT        = 3'b000,
    NULL_CMD        = 3'b111
} cmd_t;

typedef enum bit [3:0] {
    NULL_RSP        = 4'b0000,
    RSP_DON         = 4'b1000,
    RSP_NAK         = 4'b0100,
    RSP_ARB_LOST    = 4'b0010,
    RSP_ERR         = 4'b0001
} rsp_t;

typedef enum bit [1:0] {
    CSR_ADDR = 2'h0,
    DPR_ADDR = 2'h1,
    CMDR_ADDR = 2'h2,
    FSMR_ADDR = 2'h3
} addr_t;

typedef enum bit {
    WB_READ     =0,
    WB_WRITE    =1
} wb_op_t;

typedef struct packed {
    bit don;
    bit nak;
    bit al;
    bit err;
    bit r;
    cmd_t cmd;
} cmdr_t;

typedef union packed {
    byte value;
    cmdr_t fields;
} cmdr_u;

string  map_reg_ofst_name [ addr_t ] = '{
    CSR_ADDR             :   "CSR" ,
    DPR_ADDR             :   "DPR" ,
    CMDR_ADDR            :   "CMDR",
    FSMR_ADDR            :   "FSMR"
};
