class virtual_sequence extends uvm_sequence#(uvm_sequence_item);
  
  // write sequence handles
  wrt_base_seq wseq;
  full_write   full_wrt_seq;
  no_write     no_wrt_seq;
  wrt_dist     wdist_seq;
  normal_wrt   n_wrt_seq;
  
  // read sequence handles 
  rd_base_seq  rseq;
  no_read      no_rd_seq;
  full_read    full_rd_seq;
  rd_dist      rdist_seq;
  normal_rd    n_rd_seq;

  // sequencer handles 
  write_sequencer wseqr;
  read_sequencer  rseqr;
  virtual_sequencer v_seqr;
  
  `uvm_object_utils(virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer) 

  function new(string name = "");
    super.new(name);
  endfunction 
  

  virtual task body();
    super.body();
    
    // creating write handles
    wseq        = wrt_base_seq::type_id::create("wseq");
    full_wrt_seq= full_write::type_id::create("full_wrt_seq"); 
    no_wrt_seq  = no_write::type_id::create("no_wrt_seq"); 
    wdist_seq   = wrt_dist::type_id::create("wdist_seq"); 
    n_wrt_seq   = normal_wrt::type_id::create("n_wrt_seq");
      
    // creating read handles
    rseq        = rd_base_seq::type_id::create("rseq");
    no_rd_seq   = no_read::type_id::create("no_rd_seq"); 
    full_rd_seq = full_read::type_id::create("full_rd_seq"); 
    rdist_seq   = rd_dist::type_id::create("rdist_seq"); 
    n_rd_seq    = normal_rd::type_id::create("n_rd_seq");
      

// ---- random test ----
      fork
        begin
          wseq.start(p_sequencer.wrt_seqr);
        end
        begin
          //#300;
          rseq.start(p_sequencer.rd_seqr);
        end
      join 

// ------no read only write-----
      fork
        begin
          full_wrt_seq.start(p_sequencer.wrt_seqr);
        end
        begin
          no_rd_seq.start(p_sequencer.rd_seqr);
          #100;
        end
      join

// ------no write only read------
      fork
        begin
          no_wrt_seq.start(p_sequencer.wrt_seqr);
          #100;
        end
        begin
          full_rd_seq.start(p_sequencer.rd_seqr);
        end
      join


//  ---------distribution---------
      fork
        begin
          rdist_seq.start(p_sequencer.rd_seqr);
        end
        begin
          wdist_seq.start(p_sequencer.wrt_seqr);
          #100;
        end
      join


// ---------write followed by read---------

    fork
      begin
        n_wrt_seq.start(p_sequencer.wrt_seqr);
      end
      begin
        n_rd_seq.start(p_sequencer.rd_seqr);
      end
    join
  endtask
  
endclass
