class test_base extends ncsu_component;

  env_configuration cfg;
  environment env;
  generator gen;
  string gen_trans_type;
  i2cmb_generator_compulsory_test gen_compulsory_test;
  i2cmb_register_test gen_register_test;
  i2cmb_dut_functionality_test gen_dut_func_test;
  
  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);

    if($value$plusargs("GEN_TRANS_TYPE=%s", gen_trans_type))
      $display("RUNNING TESTCASE: %s", gen_trans_type);

    env = new("env", this);
    env.set_configuration(cfg);
    env.build();

    if(gen_trans_type == "i2cmb_generator_compulsory_test") begin
      gen_compulsory_test = new("gen_compulsory_test", this);
      gen_compulsory_test.set_wb_agent(env.get_p0_agent());
      gen_compulsory_test.set_i2c_agent(env.get_p1_agent());
    end
    else if(gen_trans_type == "i2cmb_register_test") begin
      gen_register_test = new("gen_register_test", this);
      gen_register_test.set_wb_agent(env.get_p0_agent());
      gen_register_test.set_i2c_agent(env.get_p1_agent());    
    end
    else if(gen_trans_type == "i2cmb_dut_functionality_test") begin
      gen_dut_func_test = new("gen_dut_func_test", this);
      gen_dut_func_test.set_wb_agent(env.get_p0_agent());
      gen_dut_func_test.set_i2c_agent(env.get_p1_agent());    
    end
    else begin
      gen = new("gen", this);
      gen.set_wb_agent(env.get_p0_agent());
      gen.set_i2c_agent(env.get_p1_agent());
    end
    
  endfunction

  virtual task run();
    env.run();

    if(gen_trans_type == "i2cmb_generator_compulsory_test")
      gen_compulsory_test.run();
    else if(gen_trans_type == "i2cmb_register_test")
      gen_register_test.run();
    else if(gen_trans_type == "i2cmb_dut_functionality_test")
      gen_dut_func_test.run();
    else
      gen.run();
  endtask

endclass
