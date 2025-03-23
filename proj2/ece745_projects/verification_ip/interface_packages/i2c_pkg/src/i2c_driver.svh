class i2c_driver extends ncsu_component#(.T(i2c_transaction_base));

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
  endfunction

  virtual i2c_if bus;

  i2c_configuration configuration;
  i2c_transaction_base i2c_trans;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    ncsu_info("i2c_driver::run()", {get_full_name(), "-", trans.convert2string()}, NCSU_NONE);
   
    if(trans.op_sel == 1)
      bus.wait_for_i2c_transfer(trans.i2c_op, trans.i2c_data);
    else
      bus.provide_read_data(trans.i2c_data, trans.complete);
  endtask

endclass
