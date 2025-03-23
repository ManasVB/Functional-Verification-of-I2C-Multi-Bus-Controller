class wb_agent extends ncsu_component#(.T(wb_transaction_base));

  wb_configuration configuration;
  wb_driver driver;
  wb_monitor monitor;
  // wb_coverage cvg;
  ncsu_component #(T) subscribers[$];
  virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) bus;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
    if(!(ncsu_config_db#(virtual wb_if #(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)))::get(get_full_name(),this.bus)))
      ncsu_fatal("wb_agent::new()", $sformatf("ncsu_config_db::get() call fail %s", get_full_name()));
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    driver = new("driver", this);
    driver.set_configuration(configuration);
    driver.build();
    driver.bus = this.bus;
    
    // if(configuration.collect_coverage) begin
    //   cvg = new("coverage", this);
    //   cvg = set_configuration(configuration);
    //   cvg.build();
    //   connect_subscriber(cvg);
    // end

    monitor = new("monitor", this);
    monitor.set_configuration(configuration);
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
