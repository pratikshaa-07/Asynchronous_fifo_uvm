class write_driver extends uvm_driver#(wrt_seq_item);
  virtual inf.WR_DRV vif;
  `uvm_component_utils(write_driver)

  function new(string name="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual inf)::get(this, "", "vif", vif))
         `uvm_fatal("VIF not set",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
       
  
 task drive();
   static int i=0;
   vif.wr_drv_cb.wdata<=req.wdata;
   vif.wr_drv_cb.wrinc<=req.winc;
   i++;
   `uvm_info("DRIVER", $sformatf("[WRITE- DRIVER-%0d] SENT: wdata = %0d win = %0d",i,req.wdata,req.winc), UVM_LOW);
   @(posedge vif.wr_drv_cb);
 endtask

 task run_phase(uvm_phase phase);
   super.run_phase(phase);
   repeat(3)
     begin
       forever
         begin
         seq_item_port.get_next_item(req);
         drive();
         seq_item_port.item_done();
         end
     end
 endtask
               
endclass
