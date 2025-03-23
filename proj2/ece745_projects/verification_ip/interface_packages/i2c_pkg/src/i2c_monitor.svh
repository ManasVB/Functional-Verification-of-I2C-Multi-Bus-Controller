class i2c_monitor extends ncsu_component#(.T(i2c_transaction_base));

  i2c_configuration configuration;
  virtual i2c_if bus;
  ncsu_component#(T) agent;

  T monitored_trans;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task run();
    forever begin
      monitored_trans = new("monitored trans");
      bus.monitor(monitored_trans.i2c_addr,
                      monitored_trans.i2c_op,
                      monitored_trans.i2c_data);

      ncsu_info("i2c_monitor::run()", $sformatf("%s: Address: 0x%0h, Operation: %d, Data: %p",
                get_full_name(), 
                monitored_trans.i2c_addr,
                monitored_trans.i2c_op,
                monitored_trans.i2c_data),
                NCSU_MEDIUM);
      agent.nb_put(monitored_trans);
    end
  endtask

endclass
