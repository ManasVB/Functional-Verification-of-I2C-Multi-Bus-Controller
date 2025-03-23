class predictor extends ncsu_component#(.T(wb_transaction_base));

  ncsu_component#(T) scoreboard;
  wb_transaction_base transport_trans;
  env_configuration configuration;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  // virtual function void set_scoreboard(ncsu_component#(i2c_transaction_base) scoreboard);
  //   this.scoreboard = scoreboard;
  // endfunction

  virtual function void nb_put(T trans);
    ncsu_info("predictor::nb_put()", $sformatf({get_full_name(), " ", trans.convert2string()}),
              NCSU_MEDIUM);
    scoreboard.nb_transport(trans, transport_trans);
  endfunction

endclass
