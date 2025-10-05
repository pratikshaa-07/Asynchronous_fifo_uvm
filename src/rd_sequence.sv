class rd_base_seq extends uvm_sequence #(rd_seq_item);
  rd_seq_item req;
  `uvm_object_utils(rd_base_seq)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(2)
      begin
        req = rd_seq_item::type_id::create("req");
        wait_for_grant();
        req.randomize();
        send_request(req);
        wait_for_item_done();
      end
  endtask
endclass
        
    
