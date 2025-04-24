class i2cmb_wb_coverage extends ncsu_component #(.T(wb_transaction_base));

  addr_t wb_addr;
  cmd_t iicmb_cmd;
  wb_op_t wb_op;
  bit [WB_DATA_WIDTH-1:0] wb_data;
  event wb_covr, sample_DPR, sample_CSR;
  CSR_REG csr_reg;

  env_configuration configuration;

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  covergroup env_coverage @(wb_covr);
    wb_addr_offset: coverpoint 1'b0 { option.auto_bin_max = 1; } 	// c1.auto[CSR],c1.auto[DPR],c1.auto[CMDR],c1.auto[FSMR]
    wb_operation: coverpoint 1'b0 { option.auto_bin_max = 1; } 		// c2.auto[WB_READ],c2.auto[WB_WRITE]
  endgroup  

  covergroup wb_transaction_base_cg with function sample (wb_op_t op, cmd_t cmd, rsp_t rsp);
    option.per_instance = 1;
    option.name = get_full_name();

    command: coverpoint cmd {
        bins valid_cmd[] = {CMD_START, CMD_STOP, CMD_READ_ACK, CMD_READ_NAK, CMD_WRITE, CMD_SET_BUS, CMD_WAIT};
    }

    reponse: coverpoint rsp iff (op == WB_READ) { // Only sample response when we read the CMDR
        bins valid_rsp[] = {RSP_DON, RSP_NAK, RSP_ERR};
    }    

  endgroup

  covergroup DPR_coverage @(sample_DPR);
    // Create 4 automatic bins, each bins cover 256/4= 64 values
    DPR_Data_Value: coverpoint wb_data { option.auto_bin_max = 1; }
  endgroup

  covergroup CSR_coverage @(sample_CSR);
    CSR_Enable_bit: coverpoint csr_reg.e;
    CSR_Interrupt_Enable_bit: coverpoint csr_reg.ie;
    CSR_Bus_Busy_bit: coverpoint csr_reg.bb;
    CSR_Bus_Captured_bit: coverpoint csr_reg.bc;
    CSR_Bus_ID_bits: coverpoint csr_reg.bus_id { option.auto_bin_max = 4; }
  endgroup

  function new(string name= "", ncsu_component_base parent = null);
    super.new(name, parent);
    env_coverage = new;
    wb_transaction_base_cg = new;
    DPR_coverage = new;
    CSR_coverage = new;
  endfunction

  virtual function void nb_put(T trans);

    // $cast( wb_addr, trans.wb_addr);
    cmdr_u cmdr;
    cmd_t cmd;
    rsp_t rsp;
    wb_op_t op;
    cmdr.value = trans.wb_data;
    cmd = cmdr.fields.cmd;
    rsp = rsp_t'({cmdr.fields.don, cmdr.fields.nak, cmdr.fields.al, cmdr.fields.err});
    op = wb_op_t'(trans.wb_we);
    wb_transaction_base_cg.sample(op, cmd, rsp);
    if(wb_addr==DPR_ADDR) ->>sample_DPR;
    if(wb_addr==CSR_ADDR)	->>sample_CSR;

    ->>wb_covr;
  endfunction

endclass
