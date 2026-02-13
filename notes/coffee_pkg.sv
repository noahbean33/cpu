package coffee_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // -------------------------------------------------------
  // Enumerations
  // -------------------------------------------------------
  typedef enum logic {
    SMALL = 1'b0,
    LARGE = 1'b1
  } size_e;

  typedef enum logic [1:0] {
    NONE       = 2'd0,
    ESPRESSO   = 2'd1,
    LATTE      = 2'd2,
    CAPPUCCINO = 2'd3
  } coffee_type_e;

      
    // -------------------------------------------------------
  // Transaction
  // -------------------------------------------------------
  class coffee_tr extends uvm_sequence_item;
    rand size_e       size;
    rand bit          with_milk;
    rand bit          with_foam;
         coffee_type_e coffee_type; // Output from DUT

    constraint valid_milk {
      if (with_foam) with_milk == 1;
    }

    `uvm_object_utils(coffee_tr)

    function new(string name = "coffee_tr");
      super.new(name);
    endfunction

    virtual function void do_print(uvm_printer printer);
      printer.print_string("coffee_type", coffee_type.name());
      printer.print_string("size",        size.name());
      printer.print_field_int("with_milk", with_milk, 1);
      printer.print_field_int("with_foam", with_foam, 1);
    endfunction
  endclass



  // -------------------------------------------------------
  // Sequencer
  // -------------------------------------------------------
  class coffee_sequencer extends uvm_sequencer#(coffee_tr);
    `uvm_component_utils(coffee_sequencer)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  // -------------------------------------------------------
  // Driver
  // -------------------------------------------------------
  class coffee_driver extends uvm_driver#(coffee_tr);
    `uvm_component_utils(coffee_driver)
    virtual coffee_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual coffee_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "No virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        coffee_tr tr;
        seq_item_port.get_next_item(tr);
        @(posedge vif.clk);
        vif.size      <= tr.size;
        vif.with_milk <= tr.with_milk;
        vif.with_foam <= tr.with_foam;
        seq_item_port.item_done();
      end
    endtask
  endclass

  // -------------------------------------------------------
  // Monitor
  // -------------------------------------------------------
  class coffee_monitor extends uvm_component;
    `uvm_component_utils(coffee_monitor)

    virtual coffee_if vif;
    uvm_analysis_port#(coffee_tr) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual coffee_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "No virtual interface")
      ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
      coffee_tr tr;
      // Previous input values
      size_e prev_size;
      bit    prev_with_milk;
      bit    prev_with_foam;
      bit    first_cycle = 1;

      tr = coffee_tr::type_id::create("mon_tr", this);

      forever begin
        @(posedge vif.clk);

        // On second and onward cycles, use previous inputs with current output
        if (!first_cycle) begin
          tr.size        = prev_size;
          tr.with_milk   = prev_with_milk;
          tr.with_foam   = prev_with_foam;
          tr.coffee_type = coffee_type_e'(vif.coffee_type);
          tr.print();
          ap.write(tr);
        end

        // Save current inputs for use on next cycle
        prev_size       = size_e'(vif.size);
        prev_with_milk  = vif.with_milk;
        prev_with_foam  = vif.with_foam;
        first_cycle     = 0;
      end
    endtask

  endclass
      
       // -------------------------------------------------------
  // Scoreboard
  // -------------------------------------------------------
  class coffee_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(coffee_scoreboard)

  uvm_analysis_imp#(coffee_tr, coffee_scoreboard) sb_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    sb_ap = new("sb_ap", this);
  endfunction

  function void write(coffee_tr tr);
    coffee_type_e expected;
    case ({tr.size, tr.with_milk, tr.with_foam})
      3'b000:  expected = ESPRESSO;
      3'b110:  expected = LATTE;
      3'b111:  expected = CAPPUCCINO;
      default: expected = NONE;
    endcase

    if (tr.coffee_type !== expected)
      `uvm_error("SCOREBOARD", $sformatf("Mismatch! Expected: %s, Got: %s",
                    expected.name(), tr.coffee_type.name()))
    else
      `uvm_info("SCOREBOARD", $sformatf("Correct coffee: %s", tr.coffee_type.name()), UVM_LOW);
    endfunction
  endclass

      
      
  // -------------------------------------------------------
  // Agent
  // -------------------------------------------------------
  class coffee_agent extends uvm_component;
    `uvm_component_utils(coffee_agent)

    coffee_sequencer sqr;
    coffee_driver    drv;
    coffee_monitor   mon;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      sqr = coffee_sequencer::type_id::create("sqr", this);
      drv = coffee_driver   ::type_id::create("drv", this);
      mon = coffee_monitor  ::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass
      
  // -------------------------------------------------------
  // Environment
  // -------------------------------------------------------
  class coffee_env extends uvm_env;
    `uvm_component_utils(coffee_env)

    coffee_agent      agt;
    coffee_scoreboard scb;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      agt = coffee_agent     ::type_id::create("agt", this);
      scb = coffee_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      agt.mon.ap.connect(scb.sb_ap);
    endfunction
  endclass

  // -------------------------------------------------------
  // Sequence
  // -------------------------------------------------------
  class coffee_sequence extends uvm_sequence#(coffee_tr);
    `uvm_object_utils(coffee_sequence)

    function new(string name = "coffee_sequence");
      super.new(name);
    endfunction

    task body();
      repeat (20) begin
        coffee_tr tr = coffee_tr::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        finish_item(tr);
      end
    endtask
  endclass


  // -------------------------------------------------------
  // Test
  // -------------------------------------------------------
  class coffee_test extends uvm_test;
    `uvm_component_utils(coffee_test)

    coffee_env      env;
    coffee_sequence seq;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      env = coffee_env::type_id::create("env", this);
      seq = coffee_sequence::type_id::create("seq");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      seq.start(env.agt.sqr);
      #20;
      phase.drop_objection(this);
    endtask
  endclass

endpackage : coffee_pkg