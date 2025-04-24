class i2c_transaction_base extends ncsu_transaction;

  `ncsu_register_object(i2c_transaction_base)

  bit [I2C_DATA_WIDTH-1:0] i2c_data [];
  bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
  i2c_op_t i2c_op;
  bit complete;
  bit op_sel;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
      if(i2c_op == READ)
        return {super.convert2string(), $sformatf("Address: 0x%0h, Read Data: %p", i2c_addr, i2c_data)};
      else
        return {super.convert2string(), $sformatf("Address: 0x%0h, Write Data: %p", i2c_addr, i2c_data)};
  endfunction
  
  function bit compare(i2c_transaction_base rhs);
      return ((this.i2c_op == rhs.i2c_op) &&
	            (this.i2c_addr == rhs.i2c_addr) &&
              (this.i2c_data == rhs.i2c_data));
  endfunction

	virtual function bit [I2C_ADDR_WIDTH-1:0] get_addr();
	      return {this.i2c_addr};
	endfunction

	virtual function bit get_op();
	      return this.i2c_op;
	endfunction

endclass
