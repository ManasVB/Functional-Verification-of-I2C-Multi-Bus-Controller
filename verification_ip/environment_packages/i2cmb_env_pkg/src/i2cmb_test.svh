class test_base extends ncsu_component;

  env_configuration cfg;
  environment env;
  generator gen;
  string gen_type;
  
  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);

    // if($value$plusargs("GEN_TRANS_TYPE=%s", gen_type))
    //   $display("RUNNING TESTCASE: %s", gen_type);

    env = new("env", this);
    env.set_configuration(cfg);
    env.build();

    gen = new("gen", this);
    // $cast(gen, ncsu_object_factory::create(gen_type));
    gen.set_wb_agent(env.get_p0_agent());
    gen.set_i2c_agent(env.get_p1_agent());
    
  endfunction

  virtual task run();
    env.run();
    gen.run();
  endtask

endclass
