interface i2c_if #(
	int I2C_DATA_WIDTH=8,
	int I2C_ADDR_WIDTH=7
	)
(
inout scl, inout triand sda
);

typedef enum bit {WRITE = 1'b0, READ = 1'b1} i2c_op_t;

bit start = 1'b0, stop = 1'b0, rep_start = 1'b0;
bit ack = 1'b0, nack = 1'b0;

bit [I2C_DATA_WIDTH-1 :0] rdata_buffer [$]; // Unbounded buffer to hold all the read_data
bit [I2C_DATA_WIDTH-1 :0] wdata_buffer [$]; // Unbounded buffer to hold all the write_data

bit [I2C_ADDR_WIDTH-1 :0] saddr; // To store slave address
i2c_op_t observed_op;

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

// When SCL is low and SDA goes from low-high: repeated_start
always@(negedge sda) begin
	if(!scl)
		rep_start = 1'b1;
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
	bit [I2C_DATA_WIDTH-1:0] wdata; // 8-bit write data, temp variable	
	int i;
	bit ack; // Acknowlege bit

	wait(start);
	start = 1'b0;
	stop = 1'b0;

	// Capture the 7-bit address
	for(i = I2C_ADDR_WIDTH - 1; i >= 0; i--) begin
		// Capture the SDA bit on the rising edge of SCL
		@(posedge scl)		
		saddr[i] = sda;
	end

	// Get the R/W bit
	@(posedge scl)
	observed_op = sda;
	op = observed_op;
	
	// Ack/Nack
	@(posedge scl)
	ack = 1'b1;

	if(op == READ) return;

	fork begin
		while(1) begin

		for(i = I2C_DATA_WIDTH - 1; i >=0 ; i--) begin
			@(posedge scl)
			wdata[i] = sda; 			
		end
		wdata_buffer.push_back(wdata);

		@(posedge scl)
		ack = 0;

		end
	end

	wait(stop);
	
	join_any;
	disable fork;

	// Copy the data from the buffer to ouput parameter write_data
	write_data = wdata_buffer;
		
endtask

/* Input is read_data and the output bit transfer_complete is set when stop bit or
 * repeated start is detected. 
 */
task provide_read_data (input bit [I2C_DATA_WIDTH-1:0] read_data [], output bit transfer_complete);
	bit [I2C_DATA_WIDTH-1 :0] rdata;	
	int i,j;

		// Capture the read data and push into the queue
	for(i = 0; i < read_data.size(); i++) begin
		for(j = I2C_DATA_WIDTH; j >= 0; j--) begin
			@(posedge scl)
			rdata = read_data[i][j];	
		end
	
		rdata_buffer.push_back(rdata);
		
		@(posedge scl)
		ack = 1'b1;

		if(stop || rep_start)
			break;
	end

	transfer_complete = 1'b1;
endtask

task monitor (output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);

        bit [I2C_ADDR_WIDTH-1:0] observed_addr;  // To store captured address
        bit [I2C_DATA_WIDTH-1:0] observed_data [$];  // To store captured data
        bit ack;  // To store acknowledgment bit
	int i;
        bit [I2C_DATA_WIDTH-1:0] m_data;

	wait(start);

	wait(!start);

	wait(stop);

	addr = saddr;
	op = observed_op;

	if(op == WRITE)
		data = wdata_buffer;
	else
		data = rdata_buffer;

	
	// Delete the buffers once done
	wdata_buffer.delete();
	rdata_buffer.delete();
	
endtask

endinterface

