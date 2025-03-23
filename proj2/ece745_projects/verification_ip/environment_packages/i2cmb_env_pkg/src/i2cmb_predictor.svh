class predictor extends ncsu_component#(.T(wb_transaction_base));

  ncsu_component#(i2c_transaction_base) scoreboard;
  i2c_transaction_base pred_trans_in, pred_trans_out;
  env_configuration configuration;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component#(i2c_transaction_base) scoreboard);
    this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
    ncsu_info("predictor::nb_put()", $sformatf({get_full_name(), " ", trans.convert2string()}),
              NCSU_MEDIUM);

    /*For the purpose of connecting predictor to scoreboard,
     * the code transports dummy values from predictor to 
     * scoreboard and makes sures that the connection is correct
     * by displaying in scoreboard.nb_transport function.
     */
    
    pred_trans_in = new("pred_trans");
    pred_trans_in.i2c_addr = 8'h22;
    pred_trans_in.i2c_data = '{0};
    pred_trans_in.i2c_op = READ;
    scoreboard.nb_transport(pred_trans_in, pred_trans_out);
  endfunction

endclass
