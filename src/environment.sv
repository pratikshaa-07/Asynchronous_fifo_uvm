class environment extends uvm_env;
  read_agent  rd_agt;
  write_agent wrt_agt;
//   subscriber  sub;
  scoreboard  scb;
  virtual_sequencer v_seqr; 
  `uvm_component_utils(environment)
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rd_agt  = read_agent::type_id::create("rd_agt",this);
    wrt_agt = write_agent::type_id::create("wrt_agt",this);
//     sub     = subscriber::type_id::create("sub",this);
    scb     = scoreboard::type_id::create("scb",this);
    v_seqr = virtual_sequencer::type_id::create("v_seqr",this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
//     //monitors to subscriber
//     rd_agt.mon.read_port.connect(sub.rd_cov_mon.analysis_export);
//     wrt_agt.mon.write_port.connect(sub.wrt_cov_mon.analysis_export);
    
    //monitors to scoreboard
    rd_agt.mon.read_port.connect(scb.read_fifo.analysis_export);
    wrt_agt.mon.write_port.connect(scb.write_fifo.analysis_export);
    
    v_seqr.wrt_seqr = wrt_agt.seqr;
    v_seqr.rd_seqr = rd_agt.seqr;
  endfunction
endclass
    
