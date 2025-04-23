class i2cmb_i2c_coverage extends ncsu_component #(.T(i2c_transaction_base));

  i2c_op_t i2c_op;
  bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
  bit [I2C_DATA_WIDTH-1:0] i2c_data[];
  event i2c_covr;

  env_configuration configuration;

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  covergroup i2c_coverage @(i2c_covr);
  	option.per_instance = 1;
    option.name = get_full_name();
    i2c_addr: coverpoint i2c_addr { option.auto_bin_max = 1; }
    i2c_op: coverpoint i2c_op { option.auto_bin_max = 1; }
    i2c_addr_x_op: cross i2c_addr, i2c_op;
  endgroup

  function new(string name= "", ncsu_component_base parent = null);
    super.new(name, parent);
    i2c_coverage = new;
  endfunction

  virtual function void nb_put(T trans);

    // $cast(i2c_op ,trans.get_op());
    // i2c_addr = trans.get_addr();

    ->>i2c_covr;

  endfunction  

endclass
