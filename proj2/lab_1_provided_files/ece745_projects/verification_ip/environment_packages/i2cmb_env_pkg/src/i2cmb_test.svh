class test_base extends ncsu_component;

  env_configuration cfg;
  environment env;
  generator gen;

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name, parent);

    env = new("env", this);
    env.set_configuration(cfg);
    env.build();

    gen = new("gen", this);
    gen.set_wb_agent(env.get_p0_agent());
    gen.set_i2c_agent(env.get_p1_agent());
    
  endfunction

  virtual task run();
    env.run();
    gen.run();
  endtask

endclass
