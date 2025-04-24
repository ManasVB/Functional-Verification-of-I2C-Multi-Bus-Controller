class i2cmb_dut_functionality_test extends generator;

  function new (string name = "", ncsu_component_base parent = null);
      super.new (name, parent);
  endfunction

  local wb_agent agent_wb;

  protected task generate_wb_transaction_write (bit [1:0] wb_addr, bit [7:0] wb_data); 
      wb_transaction_base wb_trans = new ("wb_transaction");
      wb_trans.wb_addr = wb_addr;
      wb_trans.wb_data = wb_data;
      agent_wb.bl_put (wb_trans);
  endtask

  protected task generate_wb_transaction_read (bit [1:0] wb_addr, ref bit [7:0] wb_data);
      wb_transaction_base wb_trans = new ("wb_transaction");
      wb_trans.wb_addr = wb_addr;
      // agent_wb.bl_get_ref (wb_trans);
      wb_data = wb_trans.wb_data;
  endtask
  
  // Testplan 2.1: Ensure that the `BUS ID` field in the CSR matches the selected bus ID
  local task test_bus_id ();
      bit [7:0] csr_value;

      for (byte i = 4'd0; i < 4'd16; i++) begin 
          generate_wb_transaction_write (DPR_ADDR, i);
          generate_wb_transaction_write (CMDR_ADDR, CMD_SET_BUS);
          // generate_wb_transaction_read (CSR_ADDR, csr_value);
          // assert (csr_value[3:0] == i);
      end
  endtask

endclass
