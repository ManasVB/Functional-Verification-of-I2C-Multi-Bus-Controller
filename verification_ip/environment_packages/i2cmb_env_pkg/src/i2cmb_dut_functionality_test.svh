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
    

    virtual task run();
        /* Test Plan - 2.5: CSR Bus ID Test
        * Check if BUS ID field in CSR matches selected BUS ID 
        */
        $display("************TESTPLAN 2.5: CSR Bus ID Test Start *************");


        $display("************TESTPLAN 2.5: CSR Bus ID Test Done *************");

        
        /* Test Plan - 2.8: Acknowledge detection
        * Check if DUT is detecting ack during write operation 
        */
        $display("************TESTPLAN 2.8: Acknowledge Detection Start *************");


        $display("************TESTPLAN 2.8: Acknowledge Detection Done *************");

    endtask

endclass
