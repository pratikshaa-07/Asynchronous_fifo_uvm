class write_monitor extends uvm_monitor;
  
  virtual inf.WR_MON vif;
  wrt_seq_item req;
  static int i=0;
  uvm_analysis_port #(wrt_seq_item) write_port;
  
  `uvm_component_utils(write_monitor)
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
    write_port = new("write_port",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual inf)::get(this, "", "vif", vif))
         `uvm_fatal("VIF not set",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    repeat(4)
       begin
         @(vif.wr_mon_cb);
       end
    forever
      begin
        req=wrt_seq_item::type_id::create("req");
        req.winc  = vif.wr_mon_cb.winc;
        req.wfull = vif.wr_mon_cb.wfull;
        req.wdata = vif.wr_mon_cb.wdata;
        i++;
        `uvm_info("WRITE MONITOR", $sformatf("[WRITE-MONITOR-%0d] CAPTURED: winc = %0d wfull = %0d wdata =%0d",i,req.winc,req.wfull,req.wdata), UVM_LOW);
        write_port.write(req);
        repeat (2) 
          begin
          @(vif.wr_mon_cb);
        end
      end
  endtask
endclass
