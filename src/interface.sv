`include"define.sv"
`include"uvm_macros.svh"
interface inf(input wclk,rclk,wrst_n,rrst_n);
 
  //inputs
  bit   [`DSIZE-1:0]  wdata;
  bit   winc;
  bit   rinc;
  
  //outputs
  logic   wfull;
  logic   rempty;
  logic [`DSIZE-1:0]  rdata;
  
  //write-driver
  clocking wr_drv_cb @(posedge wclk);
    default input #0 output #0;
    input wfull;
    output wdata,winc;
  endclocking
  
  //read-driver
  clocking rd_drv_cb @(posedge rclk);
    default input #0 output #0;
    input rdata,rempty;
    output rinc;
  endclocking
  
  //write-monitor
  clocking wr_mon_cb @(posedge rclk);
    default input #0 output #0;
    input wdata,winc,wfull;
  endclocking
  
  //read-monitor
  clocking rd_mon_cb @(posedge rclk);
    default input #0 output #0;
    input rinc,rdata,rempty;
  endclocking
  
  modport WR_DRV(clocking wr_drv_cb);
  modport WR_MON(clocking wr_mon_cb);
  modport RD_DRV(clocking rd_drv_cb);
  modport RD_MON(clocking rd_mon_cb);
   
endinterface
  
