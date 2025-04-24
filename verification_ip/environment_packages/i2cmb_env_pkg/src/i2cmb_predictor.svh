class predictor extends ncsu_component#(.T(wb_transaction_base));

  ncsu_component#(i2c_transaction_base) scoreboard;
  i2c_transaction_base pred_trans_in, pred_trans_out;
  env_configuration configuration;
  local i2c_transaction_base i2c_trans;

    local byte_fsm_state_t current_bus_state;
    local byte_fsm_state_t next_bus_state;

    local bit addr_complete;
    local bit [7:0] dpr;
    local i2c_op_t i2c_op;
    local bit [6:0] i2c_addr;
    local bit [7:0] i2c_data[$];

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
    this.i2c_trans = new("expected_trans");
    this.current_bus_state = S_IDLE;
  endfunction

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component#(i2c_transaction_base) scoreboard);
    this.scoreboard = scoreboard;
  endfunction

    virtual function void nb_put (input T trans);

        bit transfer_complete = this.run_golden_model(trans);
        if (transfer_complete) begin
            this.addr_complete = 1'b0;
            this.i2c_trans.i2c_op = this.i2c_op;
            this.i2c_trans.i2c_addr = this.i2c_addr;
            {>> 8 {this.i2c_trans.i2c_data}} = this.i2c_data;;
            this.i2c_data.delete();
            this.scoreboard.nb_transport (this.i2c_trans, this.i2c_trans);
            this.i2c_trans = new ("expected_trans");
        end
    endfunction

  local function bit run_golden_model(input T trans);
      addr_t addr = addr_t'(trans.wb_addr);
      cmdr_u data = trans.wb_data;
      bit    we   = trans.wb_we;
      cmdr_t cmdr = data.fields;
      bit transfer_complete = 1'b0;

      case (current_bus_state)
      S_IDLE: begin
          if(addr == CMDR_ADDR && cmdr.cmd == CMD_START) begin
              next_bus_state = S_START;
          end 
          else if(addr == CMDR_ADDR && cmdr.cmd == CMD_SET_BUS) begin
              next_bus_state = S_IDLE; 
          end 
          else begin
              next_bus_state = S_IDLE;
          end
      end

      S_START: begin
          if(cmdr.don) begin
              next_bus_state = S_BUS_TAKEN;
          end
          else if (cmdr.err || cmdr.al) begin
              next_bus_state = S_IDLE;
              $error ("error / arbitration lost");
          end
      end

      S_BUS_TAKEN: begin
          if (addr == DPR_ADDR) begin
              this.dpr = data.value;
              // Read data from the BFM is stored in the DPR
              if (!we) 
                  this.i2c_data.push_back(this.dpr);
          end
          else if (addr == CMDR_ADDR && cmdr.cmd == CMD_WRITE) begin
              next_bus_state = S_WRITE_BYTE;
              if (!this.addr_complete) begin
                  this.addr_complete = 1'b1;
                  this.i2c_op = i2c_op_t'(dpr[0]);
                  this.i2c_addr = this.dpr[7:1];
              end else begin
                  this.i2c_data.push_back(this.dpr);
              end
          end
          else if (addr == CMDR_ADDR && (cmdr.cmd == CMD_READ_ACK || cmdr.cmd == CMD_READ_NAK)) begin
              next_bus_state = S_READ_BYTE;
          end 
          else if (addr == CMDR_ADDR && cmdr.cmd == CMD_START) begin
              next_bus_state = S_START;
              if (this.addr_complete) // Repeated START
                  transfer_complete = 1'b1;
          end
          else if (addr == CMDR_ADDR && cmdr.cmd == CMD_STOP) begin
              next_bus_state = S_STOP;
              transfer_complete = 1'b1;
          end
      end

      S_WRITE_BYTE: begin
          if(cmdr.don || cmdr.nak) begin
              next_bus_state = S_BUS_TAKEN;
          end
          else if (cmdr.err || cmdr.al) begin
              next_bus_state = S_IDLE;
              $error ("error / arbitration lost");
          end
      end

      S_READ_BYTE: begin
          if (cmdr.don) begin
              next_bus_state = S_BUS_TAKEN;
          end
          else if (cmdr.err || cmdr.al) begin
              next_bus_state = S_IDLE;
          end
          else begin
              $error ("Invalid command");
          end
      end

      S_STOP: begin
          if (cmdr.don) begin
              next_bus_state = S_IDLE;
          end
          else begin
              $error ("Invalid command");
          end
      end

      default: $error ("Invalid state");
      endcase

      current_bus_state = next_bus_state;
      return transfer_complete;
  endfunction
endclass
