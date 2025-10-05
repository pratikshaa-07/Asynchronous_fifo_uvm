class virtual_sequence extends uvm_sequence#(uvm_sequence_item);
  
  //sequence handles
  wrt_base_seq wseq;
  rd_base_seq  rseq;
  
  //sequencer handles
  write_sequencer wseqr;
  read_sequencer  rseqr;
  
  virtual_sequencer v_seqr;
  `uvm_object_utils(virtual_sequence)
//   `uvm_declare_p_sequencer(virtual_sequencer)
  
  function new(string name = "");
    super.new(name);
  endfunction 
  
  virtual task body();
     if(!$cast(v_seqr,m_sequencer))
      begin
        `uvm_error(get_full_name(),"Cast failed")
      end
    else
      begin   
        wseq = wrt_base_seq::type_id::create("wseq"); 
        rseq = rd_base_seq::type_id::create("rseq");
        fork
          begin
            wseq.start(v_seqr.wrt_seqr);
          end
          begin
            rseq.start(v_seqr.rd_seqr);
          end
        join 
      end
  endtask
  
endclass
