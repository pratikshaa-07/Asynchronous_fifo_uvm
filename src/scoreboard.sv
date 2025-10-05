class scoreboard extends uvm_scoreboard;

  uvm_tlm_analysis_fifo#(rd_seq_item) read_fifo;
  uvm_tlm_analysis_fifo#(wrt_seq_item) write_fifo;

  int depth = 1 << `ASIZE;
  bit [`DSIZE-1:0] fifo_mem[$];
  bit [`DSIZE-1:0] rd_op;

  int pass_count, fail_count;

  `uvm_component_utils(scoreboard)

  function new(string name="", uvm_component parent);
    super.new(name,parent);
    read_fifo  = new("read_fifo", this);
    write_fifo = new("write_fifo", this);
    pass_count = 0;
    fail_count = 0;
  endfunction

  function void write(uvm_object t);
  endfunction

  task run_phase(uvm_phase phase);
    rd_seq_item  read_trans;
    wrt_seq_item write_trans;
    super.run_phase(phase);

    forever 
      begin
      fork
        begin
          write_fifo.get(write_trans);
          compare_write(write_trans);
        end
        begin
          read_fifo.get(read_trans);
          compare_read(read_trans);
        end
      join
    end
  endtask

  // ---------------- WRITE CHECK ----------------
  task compare_write(wrt_seq_item tr);
    if (tr.winc) begin
      if (fifo_mem.size() < depth && tr.wfull==0) begin
        fifo_mem.push_back(tr.wdata);
        pass_count++;
        `uvm_info("SCOREBOARD-WRITE",
                  $sformatf("WRITE %0d COMPLETED, PASS (size=%0d)",
                            tr.wdata, fifo_mem.size()), UVM_LOW)
      end
      else if (fifo_mem.size()==depth && tr.wfull==1) begin
        pass_count++;
        `uvm_info("SCOREBOARD-WRITE",
                  "WRITE ignored (model full), PASS", UVM_LOW)
      end
      else if (fifo_mem.size()==depth && tr.wfull==0) begin
        fail_count++;
        `uvm_error("SCOREBOARD-WRITE",
                   "DUT failed to assert wfull at full depth")
      end
      else begin
        fail_count++;
        `uvm_error("SCOREBOARD-WRITE",
                   "DUT asserted wfull too early")
      end
    end
  endtask

  // ---------------- READ CHECK ----------------
  task compare_read(rd_seq_item tr);

    if (tr.rinc) begin
      if (fifo_mem.size() > 0 && tr.rempty==0) begin
        rd_op = fifo_mem.pop_front();
        if (tr.rdata == rd_op) begin
          pass_count++;
          `uvm_info("SCOREBOARD-READ",
                    $sformatf("READ DATA MATCH: %0d, PASS", tr.rdata), UVM_LOW)
        end
        else begin
          fail_count++;
          `uvm_error("SCOREBOARD-READ",
                     $sformatf("READ MISMATCH: DUT=%0d, EXP=%0d",
                               tr.rdata, rd_op))
        end
      end
      else if (fifo_mem.size()==0 && tr.rempty==1) begin
        pass_count++;
        `uvm_info("SCOREBOARD-READ",
                  "READ ignored (model empty), PASS", UVM_LOW)
      end
      else if (fifo_mem.size()==0 && tr.rempty==0) begin
        fail_count++;
        `uvm_error("SCOREBOARD-READ",
                   "DUT failed to assert rempty when empty")
      end
      else if (fifo_mem.size()!=0 && tr.rempty==1) begin
        fail_count++;
        `uvm_error("SCOREBOARD-READ",
                   "DUT asserted rempty too early")
      end
    end
  endtask

  // report
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCOREBOARD-SUMMARY",$sformatf("FINAL RESULT: PASS COUNT = %0d, FAIL COUNT = %0d",pass_count, fail_count), UVM_NONE)
  endfunction

endclass
