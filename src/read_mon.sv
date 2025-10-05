class read_monitor extends uvm_monitor;
  
  virtual inf.RD_MON vif;
  rd_seq_item req;
  int i;
  uvm_analysis_port #(rd_seq_item) read_port;
  
  `uvm_component_utils(read_monitor)
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual inf)::get(this, "", "vif", vif))
         `uvm_fatal("VIF not set",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  task run_phase(uvm_phase phase);
    i=0;
    super.run_phase(phase);
    repeat(2)
      @(posedge vif.rd_mon_cb);
    forever
      begin
        req=rd_seq_item::type_id::create(req);
        req.rdata  = vif.rd_mon_cb.rdata;
        req.rempty = vif.rd_mon_cb.rempty;
        req.rinc   = vif.rd_mon_cb.rinc;
        read_port.write(req);
        `uvm_info("READ MONITOR", $sformatf("[READ-MONITOR-%0d] CAPTURED: rdata = %0d rempty = %0d rinc = %0d",i,req.rdata,req.rempty,req.rinc), UVM_LOW);
        i++;
        repeat(2) @(posedge vif.rd_mon_cb);
      end
  endtask
endclass
  
  
