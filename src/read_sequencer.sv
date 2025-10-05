class read_sequencer extends uvm_sequencer #(rd_seq_item);
  `uvm_component_utils(read_sequencer)
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
endclass
