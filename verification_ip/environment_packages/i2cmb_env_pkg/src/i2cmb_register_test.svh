class i2cmb_register_test extends generator;
    `ncsu_register_object(i2cmb_register_test)

    wb_transaction_base wb_trans_write[addr_t], wb_trans_read[addr_t];
    ncsu_component #(wb_transaction_base) p0_agent;
    bit [7:0] access_mode[addr_t];
    bit [7:0] reset_value[addr_t];
    bit [WB_DATA_WIDTH-1:0] wb_recv_data;

    function new (string name = "", ncsu_component_base parent = null);
        super.new (name, parent);

        reset_value[CSR_ADDR] = 8'h00;
        reset_value[DPR_ADDR] = 8'h00;
        reset_value[CMDR_ADDR] = 8'h00;
        reset_value[FSMR_ADDR] = 8'h00;

        access_mode[CSR_ADDR] = 8'hc0;
        access_mode[DPR_ADDR] = 8'h00;
        access_mode[CMDR_ADDR] = 8'h17;
        access_mode[FSMR_ADDR] = 8'h00;

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

    // New instances of wb_trans_write and wb_trans_read
    for(int i =0; i <= 3; ++i) begin
        wb_trans_write[i] = new($sformatf("wb_trans_write_%0d", i));
        wb_trans_read[i] = new($sformatf("wb_trans_read_%0d", i));
    end

    /* Test Plan - 1.1: Register Address Valid
     * Check if address of all registers are valid
    */
    $display("************TESTPLAN 1.1: Register Address Valid Start *************");
    // Refer to the test cases below, as they will automatically access all the address and fail if invalid.
    $display("************TESTPLAN 1.1: Register Address Valid Done *************");

    /* Test Plan - 1.2: Register or Field Aliasing
     * Check if write operation doesn't affect other registers
    */
    // Enable core
    this.wb_enable_core(wb_trans_write[CSR_ADDR]);

    $display("************TESTPLAN 1.2: Register or Field Aliasing Start *************");

    for(int i =0; i <= 3; ++i) begin
        wb_trans_write[i].wb_addr = i; // CSR -> DPR -> CMDR -> FSMR
        wb_trans_write[i].op_sel = 1 ; // write operation
        wb_trans_write[i].wb_data = 8'hff;
        p0_agent.bl_put(wb_trans_write[i]);

        for(int j = 0; j <=3; j++) begin
            if(i == j) continue;
            else begin
                // $display("read data %d",wb_trans_read[j].wb_data);
                assert(wb_trans_read[j].wb_data == reset_value[j])  $display("TEST 1.2: REGISTER OR FIELD ALIASING --> PASSED");
                else $error("TEST 1.2: REGISTER OR FIELD ALIASING --> FAILED");
            end
        end     
    end

    $display("************TESTPLAN 1.2: Register or Field Aliasing Done *************");


    // Reset Core
    this.wb_reset_core(wb_trans_write[CSR_ADDR]);

    /* Test Plan - 1.3: Register and Field Default Values
    * Check if registers have default values after reset
    */
    $display("************TESTPLAN 1.3: Register and Field Default Values At Start *************");

    for(int i =0; i <= 3; ++i) begin
        p0_agent.bl_put(wb_trans_read[i]);
        assert(wb_trans_read[i].wb_data == reset_value[i]) $display("TEST 1.3: REGISTER DEFAULT VALUES AFTER RESET --> PASSED");
        else $error("TEST 1.3: REGISTER DEFAULT VALUES AFTER RESET --> FAILED");
    end

    $display("************TESTPLAN 1.3: Register and Field Default Values Done *************");


    /* Test Plan - 1.4: Register Access Permissions Enforced
     * Check permission for register before and after core reset.
    */
    $display("************TESTPLAN 1.4: Check Access permission/Mode for register before and after core enable. *************");

    $display("************TESTPLAN 1.4: Check permission for register before enable. *************");
    for(int i =0; i <= 3; ++i) begin
        wb_trans_write[i].wb_addr = i; // CSR -> DPR -> CMDR -> FSMR
        wb_trans_write[i].op_sel = 1 ; // write operation
        wb_trans_write[i].wb_data = 8'hff;
        p0_agent.bl_put(wb_trans_write[i]);
        
        p0_agent.bl_put(wb_trans_read[i]);
        if(i == CSR_ADDR) begin
            assert(wb_trans_read[i].wb_data == access_mode[i] )  $display("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> PASSED");
            else $error("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> FAILED");
        end
    end

    // Enable core
    this.wb_enable_core(wb_trans_write[CSR_ADDR]);
    for(int i =0; i <= 3; ++i) begin
        wb_trans_write[i].wb_addr = i; // CSR -> DPR -> CMDR -> FSMR
        wb_trans_write[i].op_sel = 1 ; // write operation
        wb_trans_write[i].wb_data = 8'hff;
        p0_agent.bl_put(wb_trans_write[i]);
        
        p0_agent.bl_put(wb_trans_read[i]);
        // $display("read data %d",wb_trans_read[i].wb_data);
        assert(wb_trans_read[i].wb_data == access_mode[CSR_ADDR] )  $display("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> PASSED");
        else $error("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> FAILED");
    end

    $display("************TESTPLAN 1.4: Register and Field Default Values Done *************");

    /* Test Plan - 1.5: Register Loopback
     * Write to a register and read back the same value.
    */
    $display("************TESTPLAN 1.5: Register Loopback Test Start *************");

    for(int i =0; i <= 3; ++i) begin

        bit [WB_DATA_WIDTH-1:0] loopback_data = 8'h56;

        wb_trans_write[i].wb_addr = i; // CSR -> DPR -> CMDR -> FSMR
        wb_trans_write[i].op_sel = 1 ; // write operation
        wb_trans_write[i].wb_data = loopback_data;
        p0_agent.bl_put(wb_trans_write[i]);

        wb_trans_read[i].wb_addr = i; // CSR -> DPR -> CMDR -> FSMR
        wb_trans_read[i].op_sel = 0; // read operation
        wb_trans_read[i].wb_data = loopback_data;
        p0_agent.bl_put(wb_trans_read[i]);        

        // $display("read data %d",wb_trans_read[i].wb_data);
        assert(wb_trans_read[i].wb_data == wb_trans_read[i].wb_data)  $display("TEST 1.5: REGISTER LOOPBACK--> PASSED");
        else $error("TEST 1.5: REGISTER LOOPBACK --> FAILED");     
    end

    $display("************TESTPLAN 1.5: Register Loopback Test Done *************");

    
    $finish;

    endtask

endclass
