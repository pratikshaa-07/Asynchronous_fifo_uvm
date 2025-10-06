class rd_base_seq extends uvm_sequence #(rd_seq_item);
  rd_seq_item req;
  `uvm_object_utils(rd_base_seq)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(20)
      begin
        req = rd_seq_item::type_id::create("req");
        wait_for_grant();
        req.randomize();
        send_request(req);
        wait_for_item_done();
      end
  endtask
endclass

//no read
class no_read extends uvm_sequence #(rd_seq_item);
  rd_seq_item req;
  `uvm_object_utils(no_read)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req,{req.rinc==1'b0;})
      end
  endtask
endclass

//continuous read
class full_read extends uvm_sequence #(rd_seq_item);
  rd_seq_item req;
  `uvm_object_utils(full_read)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req,{req.rinc==1'b1;})
      end
  endtask
endclass
  

//weighted
class rd_dist extends uvm_sequence #(rd_seq_item);
  rd_seq_item req;
  `uvm_object_utils(rd_dist)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req, { req.rinc dist { 1 := 40, 0 := 60 }; })
      end
  endtask
endclass
