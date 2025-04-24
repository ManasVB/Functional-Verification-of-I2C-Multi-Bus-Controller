import i2cmb_env_pkg::*;
import wb_pkg::*;

interface i2cmb_assertions #(
      int ADDR_WIDTH = 32,                                
      int DATA_WIDTH = 16                                
)
(
   // System sigals
   input wire clk_i,
   input wire rst_i,
   input wire irq_i,
   // Master signals
   input wire cyc_o,
   input wire stb_o,
   input wire ack_i,
   input wire [ADDR_WIDTH-1:0] adr_o,
   input wire we_o,
   // Shred signals
   input wire [DATA_WIDTH-1:0] dat_o,
   input wire [DATA_WIDTH-1:0] dat_i
);

  cmdr_u cmdr;
  logic cmdr_read;

  assign cmdr_read = cyc_o && stb_o && !we_o && (adr_o == CMDR_ADDR) && ack_i; // read upon command completion

  assign cmdr.value = cmdr_read ? dat_i : cmdr.value;

  /** Testplan 2.1 CMDR Interrupt clear
  Assertion: Check that IRQ goes LOW after reading CMDR
  */
  property cmdr_irq_clear;
    disable iff (rst_i)
    @(posedge clk_i) cmdr_read |=> !irq_i;
  endproperty

  /** Testplan 2.2 CMDR reserved bit
  Assertion: Ensure that CMDR reserved bit is always '0'
  */  
  property cmdr_res_bit;
    disable iff (rst_i)
    @(posedge clk_i) cmdr_read |-> !cmdr.fields.r;
  endproperty

  /** Testplan 2.7 Valid Register Address
  Assertion: Ensure code address's valid registers only
  */  
  property addr_valid;
    disable iff (rst_i)
    @(posedge clk_i) stb_o |-> (adr_o == 2'h0 || adr_o == 2'h1 || adr_o == 2'h2 || adr_o == 2'h3);
  endproperty


  assert property(cmdr_irq_clear) else $error("Invalid cmdr_irq_clear operation for wb Protocol");
  assert property(cmdr_res_bit) else $error("Invalid cmdr_res_bit operation for wb Protocol");
  assert property(addr_valid) else $error("Invalid addr_valid operation for wb Protocol");

endinterface
