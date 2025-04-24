class generator extends ncsu_component;
  `ncsu_register_object(generator)
  
  wb_transaction_base wb_trans;
  i2c_transaction_base i2c_trans;

  ncsu_component #(wb_transaction_base) p0_agent;
  ncsu_component #(i2c_transaction_base) p1_agent;

  string trans_name;
  bit todo_type;
  int rwdata = 64, inc_data, dec_data;
  bit [WB_DATA_WIDTH-1:0] wb_recv_data;
	bit [I2C_DATA_WIDTH-1:0] i2c_recv_data;

  parameter bit WB_WRITE = 1'b0;
  parameter bit WB_READ = 1'b1;

  function new(string name="", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_wb_agent(ncsu_component #(wb_transaction_base) agent);
    this.p0_agent = agent;
  endfunction

  function void set_i2c_agent(ncsu_component #(i2c_transaction_base) agent);
    this.p1_agent = agent;
  endfunction

  virtual task run();
  
  fork
    run_wishbone();

    run_i2c();
  join_any

  $finish;
    
  endtask

  virtual task run_wishbone();

    wb_trans = new("wb_trans");

    this.wb_init();

    // Write 32 incrementing values, from 0 to 31, to the i2c_bus
    this.wb_start();
    this.wb_set_slave_params(8'h22, WB_WRITE);
    for(int i = 0;i <= 31; ++i) begin
      this.perform_write(i);
    end
    this.wb_stop();

    // Read 32 values from the i2c_bus -> Return incrementing data from 100 to 131
    todo_type = 0;
    this.wb_start();
    this.wb_set_slave_params(8'h22, WB_READ);
    repeat(32) begin
      this.perform_read_ack();
    end
    this.perform_read_nack();
    this.wb_stop();

    // Alternate writes and reads for 64 transfers
    todo_type = 1;
    inc_data = rwdata;
    dec_data = rwdata-1;
    repeat(rwdata) begin
      this.wb_start();
      this.wb_set_slave_params(8'h22, WB_WRITE);
      this.perform_write(inc_data++);
      this.wb_stop();

      this.wb_start();
      this.wb_set_slave_params(8'h22, WB_READ);
      this.perform_read_nack();
      this.wb_stop();
    end
    
    endtask
  
  virtual task run_i2c();
  
    bit transfer_complete = 1'b0;
    int i = 0;
    bit [I2C_DATA_WIDTH - 1 : 0] read_data [];

    i2c_trans = new("i2c_trans");

    i2c_trans.complete = transfer_complete;

    forever begin
      i2c_trans.op_sel = 1;
      p1_agent.bl_put(i2c_trans);

      if(i2c_trans.i2c_op == 1) begin
          if(todo_type == 0) begin // For Q2. Incrementing reads
            read_data = new[32];
            foreach (read_data[i])
              read_data[i] = 100 + i;
            
            i2c_trans.i2c_data = read_data;
            i2c_trans.op_sel = 0;
            p1_agent.bl_put(i2c_trans);

          end else begin // For Q3. decrementing reads
            i2c_trans.i2c_data = '{dec_data--};
            i2c_trans.op_sel = 0;
            p1_agent.bl_put(i2c_trans);            
          end
      end
    end
  endtask

  task wb_init();

    // Enable the IICMB core after power-up
    wb_trans.wb_addr = CSR_Reg;
    wb_trans.wb_data = 8'b11xx_xxxx;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    //Write a byte 0x78 to a slave with address 0x22, residing on I2C bus #5.
    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = 8'h05;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x110;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);  // Set Bus Command

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

  endtask

  task wb_start();
    // Start Command
    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x100;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);
  endtask

  task wb_set_slave_params(input int slave_addr, input bit op);
    // Set Slave address and (slave_addr << 1 | (R/W))
    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = ((slave_addr << 1) | op);
    wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x001;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);
  endtask

  task wb_stop();
    // Stop Command
    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x101;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);
  endtask

  task perform_write(input int data);
    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = data;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x001;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);
  endtask

  task perform_read_ack();
    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x010;  // Read with ACK Command
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = i2c_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);  
  endtask;

  task perform_read_nack();
    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x011;  // Read with NACK Command
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = wb_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = i2c_recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans); 
  endtask
endclass
