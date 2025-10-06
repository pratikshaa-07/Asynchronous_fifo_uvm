
class scoreboard extends uvm_scoreboard;

  uvm_tlm_analysis_fifo#(rd_seq_item) read_fifo;
  uvm_tlm_analysis_fifo#(wrt_seq_item) write_fifo;

  int depth = 1 << `ASIZE-1;
  bit [`DSIZE-1:0] fifo_mem[$];
  bit [`DSIZE-1:0] rd_op;

  int read_pass_count, read_fail_count;
  int write_pass_count, write_fail_count;

  `uvm_component_utils(scoreboard)

  function new(string name="", uvm_component parent);
    super.new(name,parent);
    read_fifo  = new("read_fifo", this);
    write_fifo = new("write_fifo", this);
    read_pass_count = 0;
    read_fail_count = 0;
    write_fail_count = 0;
    write_pass_count = 0;

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
      join_any
       // disable fork;
    end
  endtask

  // ---------------- WRITE CHECK ----------------
  task compare_write(wrt_seq_item tr);
    if (tr.winc) begin
      if (fifo_mem.size() < depth && tr.wfull==0) begin
        fifo_mem.push_back(tr.wdata);
        write_pass_count++;
        `uvm_info("SCOREBOARD-WRITE",$sformatf("WRITE %0d COMPLETED, PASS (size=%0d)",
                            tr.wdata, fifo_mem.size()), UVM_LOW)
        $display("----------------------------------------------------------------------------------");
      end
      else if (fifo_mem.size()==depth && tr.wfull==1) begin
        write_pass_count++;
        `uvm_info("SCOREBOARD-WRITE",$sformatf("WRITE ignored model full (size =%0d), PASS ",fifo_mem.size()), UVM_LOW)
        $display("----------------------------------------------------------------------------------");
      end
      else if (fifo_mem.size()>=depth && tr.wfull==0) 
        begin
        write_fail_count++;
          `uvm_error("SCOREBOARD-WRITE",$sformatf("DUT failed to assert wfull at full depth (size = %0d), FAIL",fifo_mem.size()))
        $display("----------------------------------------------------------------------------------");
      end
      else 
        begin
        write_fail_count++;
          `uvm_error("SCOREBOARD-WRITE",$sformatf("DUT asserted wfull too early,FAIL",fifo_mem.size()))
        $display("----------------------------------------------------------------------------------");

      end
    end
  endtask

  // ---------------- READ CHECK ----------------
  task compare_read(rd_seq_item tr);

    if (tr.rinc) begin
      if (fifo_mem.size() > 0 && tr.rempty==0) begin
        rd_op = fifo_mem.pop_front();
        if (tr.rdata == rd_op) begin
          read_pass_count++;
          `uvm_info("[SCOREBOARD-READ]",$sformatf("READ DATA MATCH: %0d, PASS", tr.rdata), UVM_LOW)
        $display("----------------------------------------------------------------------------------");
        end
        else begin
          read_fail_count++;
          `uvm_error("[SCOREBOARD-READ]",$sformatf("READ MISMATCH: DUT=%0d, EXP=%0d",tr.rdata, rd_op))
        $display("----------------------------------------------------------------------------------");
        end
      end
      else if (fifo_mem.size()==0 && tr.rempty==1) 
        begin
        read_pass_count++;
          `uvm_info("[SCOREBOARD-READ]",$sformatf("READ ignored model empty (size=%0d), PASS",fifo_mem.size()), UVM_LOW)
        $display("----------------------------------------------------------------------------------");
      end
      else if (fifo_mem.size()==0 && tr.rempty==0) 
        begin
        read_fail_count++;
          `uvm_error("[SCOREBOARD-READ]","DUT failed to assert rempty when empty")
        $display("----------------------------------------------------------------------------------");
      end
      else if (fifo_mem.size()!=0 && tr.rempty==1) begin
        read_fail_count++;
        rd_op = fifo_mem.pop_front();
        `uvm_error("[SCOREBOARD-READ]",$sformatf("DUT asserted rempty too early (size=%0d), FAIL",fifo_mem.size()))
        $display("-----------------------------------------------------------------------------------");
      end
    end
  endtask

  // report for pass fail count
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCOREBOARD-SUMMARY",$sformatf("FINAL RESULT: READ PASS COUNT = %0d | READ FAIL COUNT = %0d  | WRITE PASS COUNT = %0d | WRITE FAIL COUNT = %0d",read_pass_count, read_fail_count,write_pass_count,write_fail_count), UVM_NONE)
  endfunction

endclass
