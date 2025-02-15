interface i2c_if #(
	int I2C_DATA_WIDTH=8,
	int I2C_ADDR_WIDTH=7
	)
(
inout logic scl, inout logic sda
);

typedef enum bit {WRITE = 1'b0, READ = 1'b1} i2c_op_t;

bit start = 1'b0, stop = 1'b0;
bit ack = 1'b0, nack = 1'b0;

// When SCL is high and SDA goes from high-low: start
always@(negedge sda) begin
	if(scl)
		start = 1'b1;
end

// When SCL is high and SDA goes from low-high: stop
always@(posedge sda) begin
	if(scl)
		stop = 1'b1;
end

/* Wait for the i2c_transfer to complete.
 * First wait for start bit to go high. After that set it to 0.
 * After start bit get the 7-bit address.
 * In the next clock get the R/W bit
 * In the next clock cycle send Ack/Nack.
 * If its a Read condition return.
 * If write, in an infinite loop write the data in write_data[], send Ack/Nack after every byte
 * Once stop bit gets high, break from the loop, and return from the task
 */
task wait_for_i2c_transfer (output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);

	wait(start);
	start = 1'b0;

	bit [6:0] address; // 7-bit address
	bit ack; // Acknowlege bit

	// Capture the 7-bit address
	for(int i = I2C_ADDR_WIDTH - 1; i >= 0; i--) begin
		// Capture the SDA bit on the rising edge of SCL
		@posedge(scl)		
		address[i] = sda;
	end

	// Get the R/W bit
	@posedge(scl)
	op = sda;
	
	bit [I2C_DATA_WIDTH-1:0] wdata; // 8-bit write data, temp variable
	bit [I2C_DATA_WIDTH-1:0] wdata_buffer [$]; // Unbounded buffer to hold all the write_data

	if(op == READ) begin
		ack = 1'b1;
		return;
	end else begin
		ack = 1'b1;
		
		// Capture the 8-bit data till stop bit
		while(1) begin
			for(int i = I2C_DATA_WIDTH - 1; i >=0 ; i--) begin
				@posedge(scl)
				wdata[i] = sda; 			
			end
			wdata_buffer.push_back(wdata);
			
			// Ack/Nack
			@posedge(clk)
			ack = 1'b1;
		
			if(stop)
				break;
		end
	end

	// Copy the data from the buffer to ouput parameter write_data
	write_data = wdata_buffer;

	// Delete the buffer once done
	wdata_buffer.delete();
		
endtask

task provide_read_data (input bit [I2C_DATA_WIDTH-1:0] read_data [], output bit transfer_complete);

endtask

task monitor (output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);

endtask

endinterface

