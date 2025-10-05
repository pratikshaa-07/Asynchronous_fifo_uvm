class write_sequencer extends uvm_sequencer#(wrt_seq_item);

  `uvm_component_utils(write_sequencer)

  function new(string name="", uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
