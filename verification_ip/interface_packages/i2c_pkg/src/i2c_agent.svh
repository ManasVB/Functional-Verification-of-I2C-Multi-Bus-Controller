class i2c_agent extends ncsu_component#(.T(i2c_transaction_base));

  i2c_configuration configuration;
  i2c_driver driver;
  i2c_monitor monitor;

  ncsu_component #(T) subscribers[$];
  virtual i2c_if bus;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
    if(!(ncsu_config_db#(virtual i2c_if #(.I2C_DATA_WIDTH(I2C_DATA_WIDTH), .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH)))::get(get_full_name(),this.bus)))
      ncsu_fatal("i2c_agent::new()", $sformatf("ncsu_config_db::get() call fail %s", get_full_name()));
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    driver = new("driver", this);
    driver.set_configuration(configuration);
    driver.build();
    driver.bus = this.bus;

    monitor = new("monitor", this);
    monitor.set_configuration(configuration);
    monitor.set_parent(this);
    monitor.build();
    monitor.bus = this.bus;

  endfunction

  virtual function void nb_put(T trans);
    foreach(subscribers[i]) subscribers[i].nb_put(trans);
  endfunction

  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction

  virtual task run();
    fork 
      monitor.run(); 
    join_none
  endtask

endclass
