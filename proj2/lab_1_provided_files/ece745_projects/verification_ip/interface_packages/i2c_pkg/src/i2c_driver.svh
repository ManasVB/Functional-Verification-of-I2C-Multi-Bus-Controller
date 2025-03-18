class i2c_driver extends ncsu_component#(.T(i2c_transaction_base));

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name,parent);
  endfunction

  virtual i2c_if i2c_bus;

  i2c_configuration configuration;
  i2c_transaction_base i2c_trans;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    i2c_bus.wait_for_i2c_transfer(trans.i2c_op, trans.i2c_data);

    if(trans.i2c_op == READ)
      i2c_bus.provide_read_data(trans.i2c_data, trans.complete);
  endtask

endclass
