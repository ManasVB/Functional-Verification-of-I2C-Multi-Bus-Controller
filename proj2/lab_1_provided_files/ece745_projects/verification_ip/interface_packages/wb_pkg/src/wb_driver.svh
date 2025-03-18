class wb_driver extends ncsu_component#(.T(wb_transaction_base));

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name,parent);
  endfunction

  virtual wb_if bus;

  wb_configuration configuration;
  wb_transaction_base wb_trans;

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    ncsu_info("wb_driver::run()", {get_full_name(), "-", trans.convert2string()}, NCSU_NONE);

    if(trans.wb_we)
      bus.master_write(trans.wb_addr, trans.wb_data);
    else
      bus.master_read(trans.wb_addr, trans.wb_data);

    if(trans.wb_irq)
      bus.wait_for_interrupt();
  endtask

endclass
