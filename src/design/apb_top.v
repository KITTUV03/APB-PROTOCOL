
module apb_top #
(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 256
)
(
    input                       PCLK,
    input                       PRESETn,

    input                       transfer,
    input                       read_write,

    input  [ADDR_WIDTH-1:0]     write_addr,
    input  [DATA_WIDTH-1:0]     write_data,

    input  [ADDR_WIDTH-1:0]     read_addr,

    output [DATA_WIDTH-1:0]     read_data_out
);

    wire [ADDR_WIDTH-1:0] PADDR;
    wire [DATA_WIDTH-1:0] PWDATA;

    wire [DATA_WIDTH-1:0] PRDATA;
    wire [DATA_WIDTH-1:0] PRDATA1;
    wire [DATA_WIDTH-1:0] PRDATA2;

    wire PWRITE;
    wire PENABLE;
    wire PSEL;

    wire PSEL1;
    wire PSEL2;

    wire PREADY;
    wire PREADY1;
    wire PREADY2;

    wire PSLVERR;
    wire PSLVERR1;
    wire PSLVERR2;


    apb_master #
    (
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    )
    u_master
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

   
    apb_decoder #
    (
        .ADDR_WIDTH (ADDR_WIDTH)
    )
    u_decoder
    (
        .PADDR (PADDR),
        .PSEL  (PSEL),

        .PSEL1 (PSEL1),
        .PSEL2 (PSEL2)
    );

    apb_slave #
    (
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
    )
    u_slave1
    (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),

        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA1),

        .PWRITE   (PWRITE),
        .PENABLE  (PENABLE),
        .PSEL     (PSEL1),

        .PREADY   (PREADY1),
        .PSLVERR  (PSLVERR1)
    );

    apb_slave #
    (
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
    )
    u_slave2
    (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),

        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA2),

        .PWRITE   (PWRITE),
        .PENABLE  (PENABLE),
        .PSEL     (PSEL2),

        .PREADY   (PREADY2),
        .PSLVERR  (PSLVERR2)
    );


    assign PRDATA  = (PSEL1) ? PRDATA1 :
                     (PSEL2) ? PRDATA2 : 0;

    assign PREADY  = (PSEL1) ? PREADY1 :
                     (PSEL2) ? PREADY2 : 0;

    assign PSLVERR = (PSEL1) ? PSLVERR1 :
                     (PSEL2) ? PSLVERR2 : 0;
  
    assign PWDATA = write_data;
    assign PWRITE = read_write;
    assign PADDR  = PWRITE ? write_addr : read_addr;

endmodule
