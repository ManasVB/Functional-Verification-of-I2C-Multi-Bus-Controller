class wb_transaction_base extends ncsu_transaction;

  `ncsu_register_object(wb_transaction_base)

  bit [WB_DATA_WIDTH-1:0] wb_data;
  bit [WB_ADDR_WIDTH-1:0] wb_addr;
  bit wb_we;
  bit wb_irq;
  bit op_sel;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
      if(!op_sel)
        return {super.convert2string(), $sformatf("Read Data: %p", wb_data)};
      else
        return {super.convert2string(), $sformatf("Write Data: %p", wb_data)};
  endfunction    

  function bit compare(wb_transaction_base rhs);
      return ((this.wb_we == rhs.wb_we) &&
	            (this.wb_addr == rhs.wb_addr) &&
              (this.wb_data == rhs.wb_data));
  endfunction

endclass
