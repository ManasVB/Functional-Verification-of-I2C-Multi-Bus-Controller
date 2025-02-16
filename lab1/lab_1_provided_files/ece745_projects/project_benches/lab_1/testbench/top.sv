`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;

parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;

parameter CLK_PHASE = 5;
parameter RESET = 113;
parameter CSR_Reg = 8'h00;
parameter DPR_Reg = 8'h01;
parameter CMDR_Reg = 8'h02;
parameter FSMR_Reg = 8'h03;

// ****************************************************************************
// Clock generator
initial  
  begin : clk_gen
	clk = 1'b0;	// init the clock to zero
     	forever #CLK_PHASE clk <= ~clk;
  end	

// ****************************************************************************
// Reset generator
initial 
  begin : rst_gen
  	rst = 1'b1;
 	#RESET;
  	rst = 1'b0;
  end
// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
initial
  begin : wb_monitoring
	bit [WB_ADDR_WIDTH-1:0] monitor_addr;
	bit [WB_DATA_WIDTH-1:0] monitor_data;
	bit monitor_we;
	
        forever begin
        @(posedge clk)
		wb_bus.master_monitor(monitor_addr, monitor_data, monitor_we);
		$display(" Address: 0x%0h, Data: %x, Direction: %d", monitor_addr, monitor_data, monitor_we);
	end 
	
  end

// ****************************************************************************
// Define the flow of the simulation

initial
  begin : test_flow
	bit [WB_DATA_WIDTH-1:0] recv_data;
	#RESET; // Wait for reset

	wb_bus.master_write(CSR_Reg, 8'b11xx_xxxx);	// Enable the IICMB core after power-up
	
	//Write a byte 0x78 to a slave with address 0x22, residing on I2C bus #5.
	
	wb_bus.master_write(DPR_Reg, 8'h05);	// ID of Desired I2C Bus
	
	wb_bus.master_write(CMDR_Reg, 8'bxxxx_x110);	// Set Bus Command
	
	wait(irq == 1);
	wb_bus.master_read(CMDR_Reg, recv_data);
	
	wb_bus.master_write(CMDR_Reg, 8'bxxxx_x100);	// Start Command
	
	wait(irq == 1);
	wb_bus.master_read(CMDR_Reg, recv_data);

	wb_bus.master_write(DPR_Reg, 8'h44);
	
	wb_bus.master_write(CMDR_Reg, 8'bxxxx_x001);	// Write Command

	wait(irq == 1);
	wb_bus.master_read(CMDR_Reg, recv_data);
	
	wb_bus.master_write(DPR_Reg, 8'h78);	// Byte is written

	wb_bus.master_write(CMDR_Reg, 8'bxxxx_x001);	// Write Command

	wait(irq == 1);
	wb_bus.master_read(CMDR_Reg, recv_data);

	wb_bus.master_write(CMDR_Reg, 8'bxxxx_x101);	// Stop Command

	wait(irq == 1);
	wb_bus.master_read(CMDR_Reg, recv_data);
	
 	$finish;
end

// ****************************************************************************
// Instantiate the I2C Interface
i2c_if       #(
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH),
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH)
      )
i2c_bus (
  // System sigals
  .scl(scl),
  .sda(sda),
  );

// ****************************************************************************

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule
