class generator extends ncsu_component;

  wb_transaction_base wb_trans;
  i2c_transaction_base i2c_trans;

  ncsu_component #(wb_transaction_base) p0_agent;
  ncsu_component #(i2c_transaction_base) p1_agent;

  string trans_name;
  bit todo_type;
  int rwdata = 64, inc_data, dec_data;

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

    // run_i2c();
  join
    
  endtask

  virtual task run_wishbone();

    bit [WB_DATA_WIDTH-1:0] recv_data;
    bit [I2C_DATA_WIDTH-1:0] recv_i2c_data;

    wb_trans = new("wb_trans");
  
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
    wb_trans.wb_data = recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    // Start Command
    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x100;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);
    
    // Set Slave address 22 and op = write (0x22 << 1 | 0)
    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = 8'h44;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x001;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);
    
    // Write 32 incrementing values, from 0 to 31, to the i2c_bus
    wb_trans.wb_addr = DPR_Reg;
    wb_trans.wb_data = 31;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg; 
    wb_trans.wb_data = 8'bxxxx_x001;
    wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
    p0_agent.bl_put(wb_trans);

    wb_trans.wb_addr = CMDR_Reg;
    wb_trans.wb_data = recv_data;
    wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
    p0_agent.bl_put(wb_trans);


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

endclass
