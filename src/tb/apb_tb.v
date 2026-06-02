`timescale 1ns/1ps

module tb;

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;

reg                     PCLK;
reg                     PRESETn;

reg                     transfer;
reg                     read_write;

reg  [ADDR_WIDTH-1:0]   write_addr;
reg  [DATA_WIDTH-1:0]   write_data;
reg  [ADDR_WIDTH-1:0]   read_addr;

wire [DATA_WIDTH-1:0]   read_data_out;

wire [ADDR_WIDTH-1:0]   PADDR;
wire [DATA_WIDTH-1:0]   PWDATA;
wire [DATA_WIDTH-1:0]   PRDATA;

wire                    PWRITE;
wire                    PSEL;
wire                    PENABLE;
wire                    PREADY;
wire                    PSLVERR;
  
  reg [DATA_WIDTH-1:0]   exp_PWDATA;


integer pass_cnt;
integer fail_cnt;

// DUTs

apb_master m_dut
(
    .PCLK          (PCLK),
    .PRESETn       (PRESETn),

    .transfer      (transfer),
    .read_write    (read_write),

    .write_addr    (write_addr),
    .write_data    (write_data),

    .read_addr     (read_addr),

    .read_data_out (read_data_out),

    .PADDR         (PADDR),
    .PWDATA        (PWDATA),
    .PRDATA        (PRDATA),

    .PWRITE        (PWRITE),
    .PENABLE       (PENABLE),
    .PSEL          (PSEL),

    .PREADY        (PREADY),
    .PSLVERR       (PSLVERR)
);

apb_slave s_dut
(
    .PCLK     (PCLK),
    .PRESETn  (PRESETn),

    .PADDR    (PADDR),
    .PWDATA   (PWDATA),

    .PRDATA   (PRDATA),

    .PWRITE   (PWRITE),
    .PENABLE  (PENABLE),
    .PSEL     (PSEL),

    .PREADY   (PREADY),
    .PSLVERR  (PSLVERR)
);

//////////////////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////////////////

initial
begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
end

// Reset

task reset;
begin
    PRESETn   = 0;
    transfer  = 0;
    read_write= 0;

    repeat(5) @(posedge PCLK);

    PRESETn = 1;

    repeat(2) @(posedge PCLK);
end
endtask

// APB Write

task apb_write(
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data
);
begin

    @(posedge PCLK);

    write_addr = addr;
    write_data = data;

    read_write = 1'b1;

    transfer = 1'b1;

    @(posedge PCLK);

    transfer = 1'b0;

    wait(PREADY);

    @(posedge PCLK);

    $display("[%0t] WRITE ADDR=%0h DATA=%0h",
              $time, addr, data);

end
endtask

// APB Read

task apb_read(
    input  [ADDR_WIDTH-1:0] addr,
    output [DATA_WIDTH-1:0] data
);
begin

    @(posedge PCLK);

    read_addr = addr;

    read_write = 1'b0;

    transfer = 1'b1;

    @(posedge PCLK);

    transfer = 1'b0;

    wait(PREADY);
  
      data = read_data_out;


    @(posedge PCLK);


    $display("[%0t] READ ADDR=%0h DATA=%0h",
              $time, addr, data);

end
endtask



task sanity_test;

reg [7:0] addr;
reg [7:0] wr_data;
reg [7:0] rd_data;

begin

    addr    = $urandom_range(0,200);
    wr_data = $urandom_range(0,255);
//     exp_PWDATA = wr_data;

    apb_write(addr, wr_data);
    apb_read(addr, rd_data);

//   repeat(2) @(posedge PCLK); 
   @(posedge PCLK);
  
  if(read_data_out == wr_data)
    begin
        pass_cnt++;

        $display("--------------------------------");
        $display("PASS");
        $display("ADDR=%0h",addr);
        $display("WRITE=%0h READ=%0h",
                  wr_data,read_data_out);
        $display("--------------------------------");
    end
    else
    begin
        fail_cnt++;

        $display("--------------------------------");
        $display("FAIL");
        $display("ADDR=%0h",addr);
        $display("WRITE=%0h READ=%0h",
                  wr_data,read_data_out);
        $display("--------------------------------");
    end

end
endtask


initial
begin

    pass_cnt = 0;
    fail_cnt = 0;

    reset();

    repeat(20)
    begin
        sanity_test();
    end

    $display("\n");
    $display("==============================");
    $display("PASS COUNT = %0d",pass_cnt);
    $display("FAIL COUNT = %0d",fail_cnt);
    $display("==============================");

    #50;
    $finish;

end



initial
begin
    $dumpfile("apb.vcd");
    $dumpvars(0,tb);
end

endmodule
