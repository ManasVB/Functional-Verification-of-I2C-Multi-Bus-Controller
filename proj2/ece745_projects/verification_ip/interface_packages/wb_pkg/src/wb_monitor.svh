class wb_monitor extends ncsu_component#(.T(wb_transaction_base));

  wb_configuration configuration;
  virtual wb_if bus;

  T monitored_trans;

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task run();
    bus.wait_for_reset();
    forever begin
      monitored_trans = new("monitored trans");
      bus.master_monitor(monitored_trans.wb_addr,
                      monitored_trans.wb_data,
                      monitored_trans.wb_en);

      ncsu_info("wb_monitor::run()", $sformatf("%s: Address: 0x%0h, Data: %x, Write Enable: %d",
                get_full_name(), 
                monitored_trans.wb_addr,
                monitored_trans.wb_data,
                monitored_trans.wb_en),
                NCSU_MEDIUM);
      parent.nb_put(monitored_trans);
    end
  endtask

endclass
