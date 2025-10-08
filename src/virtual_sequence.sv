class virtual_sequence extends uvm_sequence#(uvm_sequence_item);
  
  // write sequence handles
  wrt_base_seq wseq;
  full_write   full_wrt_seq;
  no_write     no_wrt_seq;
  wrt_dist     wdist_seq;
  
  // read sequence handles 
  rd_base_seq  rseq;
  no_read      no_rd_seq;
  full_read    full_rd_seq;
  rd_dist      rdist_seq;
  
  // declare parent sequencer handle (auto-assigned)
  `uvm_object_utils(virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  function new(string name = "");
    super.new(name);
  endfunction 
  
  virtual task body();

    // creating write sequence handles
    wseq         = wrt_base_seq::type_id::create("wseq");
    full_wrt_seq = full_write::type_id::create("full_wrt_seq"); 
    no_wrt_seq   = no_write::type_id::create("no_wrt_seq"); 
    wdist_seq    = wrt_dist::type_id::create("wdist_seq"); 
    
    // creating read sequence handles
    rseq         = rd_base_seq::type_id::create("rseq");
    no_rd_seq    = no_read::type_id::create("no_rd_seq"); 
    full_rd_seq  = full_read::type_id::create("full_rd_seq"); 
    rdist_seq    = rd_dist::type_id::create("rdist_seq"); 
    

    // ---- random test ----
    fork
      begin
        wseq.start(p_sequencer.wrt_seqr);
      end
      begin
        #10;
        rseq.start(p_sequencer.rd_seqr);
      end
    join 
    

    // ------ no read only write ------
    fork
      begin
        full_wrt_seq.start(p_sequencer.wrt_seqr);
      end
      begin
        no_rd_seq.start(p_sequencer.rd_seqr);
        #100;
      end
    join
    

    // ------ no write only read ------
    fork
      begin
        no_wrt_seq.start(p_sequencer.wrt_seqr);
        #100;
      end
      begin
        full_rd_seq.start(p_sequencer.rd_seqr);
      end
    join
    

    // --------- distribution ---------
    fork
      begin
        rdist_seq.start(p_sequencer.rd_seqr);
      end
      begin
        wdist_seq.start(p_sequencer.wrt_seqr);
        #100;
      end
    join

  endtask
  
endclass
