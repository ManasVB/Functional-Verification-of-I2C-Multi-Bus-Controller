class scoreboard extends ncsu_component#(.T(i2c_transaction_base));

  env_configuration configuration;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  T expected_trans;

  virtual function void nb_transport(input T input_trans, output T output_trans);
    ncsu_info("scoreboard::nb_transport()", {"expected transaction ", input_trans.convert2string()}, NCSU_NONE);
    this.expected_trans = input_trans;
  endfunction

  virtual function void nb_put(T trans);
    ncsu_info("scoreboard::nb_put()", {"expected transaction ", expected_trans.convert2string()}, NCSU_NONE);
    ncsu_info("scoreboard::nb_put()", {"actual transaction ", trans.convert2string()}, NCSU_NONE);
    if(this.expected_trans.compare(trans))
      ncsu_info("scoreboard::nb_put()", $sformatf({get_full_name(), " ", trans.convert2string()}), NCSU_MEDIUM);
    else
      ncsu_info("scoreboard::nb_put()", $sformatf({get_full_name(), " ", trans.convert2string()}), NCSU_MEDIUM);  
  endfunction

endclass
