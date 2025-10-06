class subscriber extends uvm_component;

  uvm_tlm_analysis_fifo#(rd_seq_item) rd_cov_mon;
  uvm_tlm_analysis_fifo#(wrt_seq_item) wrt_cov_mon;

  rd_seq_item  read_mon;
  wrt_seq_item write_mon;

  real rd_cov_report, wrt_cov_report, combined_cov_report;

  `uvm_component_utils(subscriber)

  covergroup wrt_cg;
    WINC:  coverpoint write_mon.winc   { bins winc[]  = {0,1}; }
    WFULL: coverpoint write_mon.wfull  { bins wfull[] = {0,1}; }
    WDATA: coverpoint write_mon.wdata  { 
      bins wdata1 = {[0:129]};
      bins wdata2 = {[130:255]};
    }
  endgroup

  covergroup rd_cg;
    RINC:    coverpoint read_mon.rinc   { bins rinc[]   = {0,1}; }
    REMPTY:  coverpoint read_mon.rempty { bins rempty[] = {0,1}; }
    RDATA:   coverpoint read_mon.rdata  {
      bins rdata1 = {[0:129]};
      bins rdata2 = {[130:255]};
    }
  endgroup

  covergroup wr_rd_cg;
    WINC:   coverpoint write_mon.winc   { bins winc[]  = {0,1}; }
    WFULL:  coverpoint write_mon.wfull  { bins wfull[] = {0,1}; }
    RINC:   coverpoint read_mon.rinc    { bins rinc[]  = {0,1}; }
    REMPTY: coverpoint read_mon.rempty  { bins rempty[] = {0,1}; }

    cross WINC, RINC;
    cross WFULL, REMPTY;
  endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    rd_cov_mon  = new("rd_cov_mon", this);
    wrt_cov_mon = new("wrt_cov_mon", this);
    wrt_cg    = new();
    rd_cg     = new();
    wr_rd_cg  = new();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      wrt_cov_mon.get(write_mon);
      wrt_cg.sample();

      rd_cov_mon.get(read_mon);
      rd_cg.sample();

      wr_rd_cg.sample();
    end
  endtask


  virtual function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    rd_cov_report       = rd_cg.get_coverage();
    wrt_cov_report      = wrt_cg.get_coverage();
    combined_cov_report = wr_rd_cg.get_coverage();
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("READ COVERAGE",  $sformatf("Coverage sampled for READ  = %0.2f%%", rd_cov_report),  UVM_LOW)
    `uvm_info("WRITE COVERAGE", $sformatf("Coverage sampled for WRITE = %0.2f%%", wrt_cov_report), UVM_LOW)
    `uvm_info("COMBINED COVERAGE", $sformatf("Combined READ/WRITE coverage = %0.2f%%", combined_cov_report), UVM_LOW)
  endfunction

endclass

