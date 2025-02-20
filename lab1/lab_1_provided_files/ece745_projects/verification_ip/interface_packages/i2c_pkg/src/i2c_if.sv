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
bit rdata;

bit [I2C_ADDR_WIDTH-1 :0] saddr; // To store slave address
i2c_op_t observed_op;

bit write_en = 1'b0, ack_enable = 1'b0;

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

assign sda = write_en ? (rdata) : 1'bz; //(ack_enable ? ack : 1'bz);

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
	bit ack; // Acknowlege bit

	wait(start);
	start = 1'b0;
	stop = 1'b0;

	// Capture the 7-bit address
	for(int i = I2C_ADDR_WIDTH - 1; i >= 0; i--) begin
		// Capture the SDA bit on the rising edge of SCL
		@(posedge scl);		
		saddr[i] = sda;
	end

	// Get the R/W bit
	@(posedge scl);
	observed_op = sda;
	op = observed_op;
	
	// Ack/Nack
	//write_en = 1'b1;
	//ack = 1'b1;
	@(posedge scl);
	//@(negedge scl);
	//write_en = 1'b0;
	//ack = 1'b0;

	if(op == READ) return;

	write_en = 1'b0;

	fork begin
		while(1) begin

		for(int i = I2C_DATA_WIDTH - 1; i >=0 ; i--) begin
			@(posedge scl);
			wdata[i] = sda; 			
		end
		wdata_buffer.push_back(wdata);

		
		//write_en = 1'b1;
		//ack = 1'b1;
		@(posedge scl);
		//@(negedge scl);
		//write_en = 1'b0;
		//ack = 1'b0;
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
	
	int i;
	rdata_buffer = read_data;	
	fork
	begin

		foreach(read_data[i]) begin
			for(int j = I2C_DATA_WIDTH - 1; j >=0; j--) begin
				@(negedge scl)
				rdata = read_data[i][j];
			end
				@(negedge scl);
		end

	end

	begin

		foreach(read_data[i]) begin
			repeat(I2C_DATA_WIDTH) begin
				write_en = 1'b1;
				@(posedge scl);
				@(negedge scl);
				write_en = 1'b0;
			end
			
			//write_en = 1'b1;
			ack = 1'b1;
			@(posedge scl);
			//@(negedge scl);
			//write_en = 1'b0;
			//@(negedge scl);
			//ack_enable = 1'b0;
			
		end
	end

	wait(stop || rep_start);
	join;

	disable fork;

	transfer_complete = 1'b1;

endtask

task monitor (output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data [$]);

	wait(start);

	wait(!start);

	wait(start || stop);

	addr = saddr;
	op = observed_op;

	if(op == WRITE)
		data = wdata_buffer;
	else
		data = rdata_buffer;

endtask

endinterface

