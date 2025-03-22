class env_configuration extends ncsu_configuration;

  wb_configuration p0_agent_config;
  i2c_configuration p1_agent_config;

  function new(string name="");
    super.new(name);

    p0_agent_config = new("wb_agent_config");
    p1_agent_config = new("i2c_agent_config");
  endfunction

endclass
