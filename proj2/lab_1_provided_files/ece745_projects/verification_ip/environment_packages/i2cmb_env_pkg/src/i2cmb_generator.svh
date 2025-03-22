class generator extends ncsu_component;

  wb_agent p0_agent;
  i2c_agent p1_agent;

  string trans_name;

  function new(string name="", ncsu_component #(T) parent = null);
    super.new(name, parent);
    if(!$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
      $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      $fatal;
    end
    $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
  endfunction

  function void set_wb_agent(wb_agent agent);
    this.p0_agent = agent;
  endfunction

  function void set_i2c_agent(i2c_agent agent);
    this.p1_agent = agent;
  endfunction

  virtual task run();
    
  endtask

endclass
