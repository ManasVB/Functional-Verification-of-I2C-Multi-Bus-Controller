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

	wait(start);
	start = 1'b0;

	bit [6:0] address; // 7-bit address
	bit ack; // Acknowlege bit

	// Capture the 7-bit address
	for(int i = I2C_ADDR_WIDTH - 1; i >= 0; i--) begin
		// Capture the SDA bit on the rising edge of SCL
		@(posedge scl)		
		address[i] = sda;
	end

	// Get the R/W bit
	@(posedge scl)
	op = sda;
	
	bit [I2C_DATA_WIDTH-1:0] wdata; // 8-bit write data, temp variable
	bit [I2C_DATA_WIDTH-1:0] wdata_buffer [$]; // Unbounded buffer to hold all the write_data

	if(op == READ) begin
		ack = 1'b1;
		return;
	end else begin
		ack = 1'b1;
		
		// Capture the 8-bit data till stop bit
		while(!stop) begin
			for(int i = I2C_DATA_WIDTH - 1; i >=0 ; i--) begin
				@(posedge scl)
				wdata[i] = sda; 			
			end
			wdata_buffer.push_back(wdata);
			
			// Ack/Nack
			@(posedge scl)
			ack = 1'b1;
		end
	end

	// Copy the data from the buffer to ouput parameter write_data
	write_data = wdata_buffer;

	// Delete the buffer once done
	wdata_buffer.delete();
		
endtask

/* Input is read_data and the output bit transfer_complete is set when stop bit or
 * repeated start is detected. 
 */
task provide_read_data (input bit [I2C_DATA_WIDTH-1:0] read_data [], output bit transfer_complete);
	bit [I2C_DATA_WIDTH-1 :0] rdata;	
	bit [I2C_DATA_WIDTH-1 :0] rdata_queue [$]; 

		// Capture the read data and push into the queue
		for (int i = 0; i < read_data.size(); i++) begin
			rdata = read_data[i];  // Get each byte from read_data
			rdata_queue.push_back(rdata);  // Store in the queue

			@(posedge scl)  // Wait for next clock cycle
			ack = 1'b1;  // Send ACK for each byte
		end

		if(stop || rep_start)
			break;
	end

	transfer_complete = 1'b1;
endtask

task monitor (output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);

        bit [I2C_ADDR_WIDTH-1:0] observed_addr;  // To store captured address
        bit observed_op;  // To store captured operation (READ/WRITE)
        bit [I2C_DATA_WIDTH-1:0] observed_data;  // To store captured data
        bit ack;  // To store acknowledgment bit

	wait(start);

	
        // Capture the 7-bit address
        observed_addr = 0;
        for (int i = I2C_ADDR_WIDTH - 1; i >= 0; i--) begin
            @(posedge scl); // Wait for rising edge of SCL
            observed_addr[i] = sda; // Capture SDA bit
        end

	
	// Capture the R/W bit (next clock cycle)
        @(posedge scl);
        observed_op = sda; // 1 for READ, 0 for WRITE

        // Output the captured address and operation
        addr = observed_addr;
        op = observed_op;

        // For READ operation, capture the data (if any)
        if (observed_op == READ) begin
            observed_data = 0;

            // Read data byte-by-byte
            for (int i = 0; i < I2C_DATA_WIDTH; i++) begin
                @(posedge scl);  // Wait for next rising edge of SCL
                observed_data[i] = sda;  // Capture SDA bit
            end

            // Return the captured data for a READ operation
            data[0] = observed_data;

        end else begin
            // For WRITE operation, capture the written data bytes
            observed_data = 0;

            // Capture the write data byte-by-byte
            bit [I2C_DATA_WIDTH-1:0] write_data;
            for (int i = 0; i < I2C_DATA_WIDTH; i++) begin
                @(posedge scl);  // Wait for next rising edge of SCL
                write_data[i] = sda;  // Capture SDA bit
            end

            // Return the captured write data
            data[0] = write_data;
	end

            // Send ACK
            @(posedge scl);
            ack = 1'b1;  // Acknowledge the write operation
		
endtask

endinterface

