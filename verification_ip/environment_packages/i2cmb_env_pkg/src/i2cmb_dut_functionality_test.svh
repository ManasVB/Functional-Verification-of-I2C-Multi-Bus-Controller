class i2cmb_dut_functionality_test extends generator;
    `ncsu_register_object(i2cmb_register_test)

    bit [WB_DATA_WIDTH-1:0] wb_recv_data;

    wb_transaction_base wb_trans;
    ncsu_component #(wb_transaction_base) p0_agent;

    function new (string name = "", ncsu_component_base parent = null);
        super.new (name, parent);
    endfunction

    function void set_wb_agent(ncsu_component #(wb_transaction_base) agent);
        this.p0_agent = agent;
    endfunction

    task wb_enable_core(input wb_transaction_base wb_trans);

        // Enable the IICMB core after power-up
        wb_trans.wb_addr = CSR_Reg;
        wb_trans.wb_data = 8'b11xx_xxxx;
        wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
        p0_agent.bl_put(wb_trans);

    endtask

    task wb_reset_core(input wb_transaction_base wb_trans);

        // Enable the IICMB core after power-up
        wb_trans.wb_addr = CSR_Reg;
        wb_trans.wb_data = (8'b11xx_xxxx & 8'b0);
        wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
        p0_agent.bl_put(wb_trans);

    endtask
    
    virtual task run();

        bit [7:0] csr_value;

        // New instance of wb_trans
        wb_trans = new("wb_trans");

        //Enable core
        this.wb_enable_core(wb_trans);
        
        /* Test Plan - 2.5: CSR Bus ID Test
        * Check if BUS ID field in CSR matches selected BUS ID 
        */
        $display("************TESTPLAN 2.5: CSR Bus ID Test Start *************");

        for (int i = 0; i < 1; i++) begin
            wb_trans.wb_addr = DPR_Reg;
            wb_trans.wb_data = i;
            wb_trans.op_sel = 1; wb_trans.wb_irq = 0;
            p0_agent.bl_put(wb_trans);
                    
            wb_trans.wb_addr = CMDR_Reg; 
            wb_trans.wb_data = 8'bxxxx_x110;
            wb_trans.op_sel = 1; wb_trans.wb_irq = 1;
            p0_agent.bl_put(wb_trans);  // Set Bus Command

            wb_trans.wb_addr = CSR_Reg;
            wb_trans.wb_data = csr_value;
            wb_trans.op_sel = 0; wb_trans.wb_irq = 0;
            p0_agent.bl_put(wb_trans);            
            
            assert (csr_value[3:0] == i) $display("TEST 2.5: CSR Bus ID TEST --> PASSED");
            else $error("TEST 2.5: CSR Bus ID TEST --> FAILED");
                        
        end

        $display("************TESTPLAN 2.5: CSR Bus ID Test Done *************");

        //Reset core
        this.wb_reset_core(wb_trans);
        
        /* Test Plan - 2.8: Acknowledge detection
        * Check if DUT is detecting ack during write operation 
        */
        $display("************TESTPLAN 2.8: Acknowledge Detection Start *************");

        for(int i =0; i < 1; ++i) begin
            p0_agent.bl_put(wb_trans);
            assert(wb_trans.wb_data == 0) $display("TEST 2.8: ACKNOWLEDGE DETECTION --> PASSED");
            else $error("TEST 2.8: ACKNOWLEDGE DETECTION --> FAILED");
        end
        $display("************TESTPLAN 2.8: Acknowledge Detection Done *************");

    endtask

endclass
