class environment extends ncsu_component;

  env_configuration configuration;
  wb_configuration wb_config;
  i2c_configuration i2c_config;

  wb_agent p0_agent;
  i2c_agent p1_agent;

  predictor pred;
  scoreboard scbd;
  // coverage coverage;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(env_configuration cfg);
    configuration = cfg;

    // wb_config = new(cfg.name);
    // i2c_config = new(cfg.name);
  endfunction

  virtual function void build();
    p0_agent = new("p0_agent",this);
    p0_agent.set_configuration(wb_config);
    p0_agent.build();

    p1_agent = new("p1_agent",this);
    p1_agent.set_configuration(i2c_config);
    p1_agent.build();

    // pred = new("pred",this);
    // pred.set_configuration(configuration);
    // pred.build();     

    // scbd = new("scbd",this);
    // scbd.set_configuration(configuration);
    // scbd.build();

    // coverage = new("coverage",this);
    // coverage.set_configuration(configuration.coverage_config);
    // coverage.build();

    // p0_agent.connect_subscriber(coverage);
    // p0_agent.connect_subscriber(pred);
    // pred.set_scoreboard(scbd);
    // p1_agent.connect_subscriber(scbd);

  endfunction

  function ncsu_component#(.T(wb_transaction_base)) get_p0_agent();
    return p0_agent;
  endfunction

  function ncsu_component#(.T(i2c_transaction_base)) get_p1_agent();
    return p1_agent;
    
  endfunction
  
  virtual task run();
    p0_agent.run();
    // p1_agent.run();
  endtask

endclass
