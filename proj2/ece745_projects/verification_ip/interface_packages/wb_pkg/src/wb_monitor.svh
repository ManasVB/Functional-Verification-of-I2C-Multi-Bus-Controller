class wb_monitor extends ncsu_component#(.T(wb_transaction_base));

  wb_configuration configuration;
  virtual wb_if bus;
  ncsu_component#(T) parent;

  T monitored_trans;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_parent(ncsu_component#(T) parent);
      this.parent = parent;
  endfunction

  virtual task run();
    bus.wait_for_reset();
    forever begin
      monitored_trans = new("monitored trans");
      bus.master_monitor(monitored_trans.wb_addr,
                      monitored_trans.wb_data,
                      monitored_trans.wb_we);

      ncsu_info("wb_monitor::run()", $sformatf("%s: Address: 0x%0h, Data: %x, Write Enable: %d",
                get_full_name(), 
                monitored_trans.wb_addr,
                monitored_trans.wb_data,
                monitored_trans.wb_we),
                NCSU_MEDIUM);
      parent.nb_put(monitored_trans);
    end
  endtask

endclass
