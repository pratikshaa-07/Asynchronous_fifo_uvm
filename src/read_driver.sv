class read_driver extends uvm_driver#(rd_seq_item);
  
  virtual inf.RD_DRV vif;
  `uvm_component_utils(read_driver)

  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual inf)::get(this, "", "vif", vif))
         `uvm_fatal("VIF not set",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction
       
  
 task drive();
   static int i=0;
   vif.rd_drv_cb.rinc<=req.rinc;
   i++;
   `uvm_info("DRIVER", $sformatf("[READ-DRIVER-%0d] SENT: rinc = %0d",i,req.rinc), UVM_LOW)
    repeat(2)
      begin
        @(vif.rd_drv_cb);
      end
 endtask

 task run_phase(uvm_phase phase);
   super.run_phase(phase);
   repeat(3) 
      begin
        @(vif.rd_drv_cb);
     end
       forever
         begin
           seq_item_port.get_next_item(req);
           drive();
           seq_item_port.item_done();
         end
 endtask        
endclass
