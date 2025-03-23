class coverage_class extends ncsu_component#(.T(wb_transaction_base));

  ncsu_component#(T) scoreboard;
  wb_transaction_base transport_trans;
  env_configuration configuration;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    ncsu_info("coverage::nb_put()", $sformatf({get_full_name(), " ", trans.convert2string()}),
              NCSU_MEDIUM);
  endfunction

endclass
