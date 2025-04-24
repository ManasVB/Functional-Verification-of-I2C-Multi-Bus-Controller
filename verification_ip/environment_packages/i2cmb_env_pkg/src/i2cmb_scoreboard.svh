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
    ncsu_info("scoreboard::nb_transport()", {"Expected transaction ", input_trans.convert2string()}, NCSU_NONE);
    this.expected_trans = input_trans;
  endfunction

  virtual function void nb_put (input T trans);
      $display({get_full_name(),"::nb_put: actual i2c_transaction ", trans.convert2string()});
      // The expected transaction comes from the predictor. We don't get an expected transaction
      // if the predictor is disabled
      if (expected_trans.i2c_addr == trans.i2c_addr) begin
          $display({get_full_name(),": i2c_transaction MATCH!"});
      end else begin
          $display({get_full_name(),": i2c_transaction MISMATCH!"});
      end
  endfunction

endclass
