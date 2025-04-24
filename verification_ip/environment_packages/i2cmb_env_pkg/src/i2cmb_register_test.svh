class i2cmb_register_test extends ncsu_component;

  wb_transaction_base trans_w[addr_t], trans_r[addr_t];
  wb_agent wb_agt0;
  bit [7:0] mask_value[addr_t];
  bit [7:0] reset_value[addr_t];

  function new (string name = "", ncsu_component_base parent = null);
      super.new (name, parent);
  endfunction

  virtual task run();

    // Test Plan - 1.2: Register or Field Aliasing
    for(int i=0; i<4 ;i++) begin
        automatic addr_t addr_ofst_1 = addr_t'(i);
        automatic addr_t addr_ofst_2;

        void'(trans_w[addr_ofst_1].set_data( 8'hff ));
        wb_agt0.bl_put(trans_w[addr_ofst_1]);
        // test order: CSR(0) -> DPR(1) -> CMDR(2) -> FSMR(3)
        for(int k=0; k<4 ;k++)begin
            if( k == i ) continue;
            addr_ofst_2 = addr_t'(k);
            assert(trans_r[addr_ofst_2].wb_data == mask_value[addr_ofst_2])  $display("TEST 1.2: REGISTER OR FIELD ALIASING --> PASSED");
            else $error("TEST 1.2: REGISTER OR FIELD ALIASING --> FAILED");
        end
    end

    // Test Plan - 1.3: Register and Field Default Values after reset

    for(int i=3; i>=0 ;i--) begin
        automatic addr_t addr_ofst = addr_t'(i);
        wb_agt0.bl_put(trans_r[addr_ofst]);
        if(trans_r[addr_ofst].wb_data == reset_value[addr_ofst])  $display("TEST 1.3: REGISTER DEFAULT VALUES AFTER RESET --> PASSED");
    	  else $error("TEST 1.3: REGISTER DEFAULT VALUES AFTER RESET --> FAILED");
    end

    // Test Plan - 1.4: Register Access Permissions Enforced

    // reset core
    // void'(trans_w[CSR].set_data( (~CSR_E) & (~CSR_IE) ));
    // wb_agt0.bl_put(trans_w[CSR]);

    for(int i=3; i>=0 ;i--)begin
        automatic addr_t addr_ofst = addr_t'(i);
        void'(trans_w[addr_ofst].set_data( 8'hff ));
        wb_agt0.bl_put(trans_w[addr_ofst]);

        wb_agt0.bl_put(trans_r[addr_ofst]);
        if(addr_ofst == CSR_ADDR)begin
            assert(trans_r[addr_ofst].wb_data == mask_value[CSR_ADDR] )  $display("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> PASSED");
            else $error("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> FAILED");
        end else begin
            assert(trans_r[addr_ofst].wb_data == reset_value[addr_ofst])  $display("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> PASSED");
            else $error("TEST 1.4: REGISTER ACCESS PERMISSION ENFORCED --> FAILED");
        end
    end


  endtask
endclass
