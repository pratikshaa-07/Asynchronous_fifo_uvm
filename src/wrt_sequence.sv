class wrt_base_seq extends uvm_sequence #(wrt_seq_item);
  wrt_seq_item req;
  `uvm_object_utils(wrt_base_seq)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(20)
      begin
        `uvm_do_with(req,{req.winc==1'b1;})
      end
  endtask
endclass

//continuous write

class full_write extends uvm_sequence #(wrt_seq_item);
  wrt_seq_item req;
  `uvm_object_utils(full_write)
  
  function new(string name="");
    super.new(name);
  endfunction 
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req,{req.winc==1'b1;})
      end
  endtask   
endclass

//no write
class no_write extends uvm_sequence #(wrt_seq_item);
  wrt_seq_item req;
  `uvm_object_utils(no_write)
  
  function new(string name="");
    super.new(name);
  endfunction 
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req,{req.winc==1'b0;})
      end
  endtask   
endclass

//weighted
class wrt_dist extends uvm_sequence #(wrt_seq_item);
  wrt_seq_item req;
  `uvm_object_utils(wrt_dist)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req, { req.winc dist { 1 := 80, 0 := 20 }; })
      end
  endtask
endclass


