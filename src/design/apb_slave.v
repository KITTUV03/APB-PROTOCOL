module apb_slave #
(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 256,
    parameter Wait_State = 4
)
(
    input                       PCLK,
    input                       PRESETn,

    input  [ADDR_WIDTH-1:0]     PADDR,
    input  [DATA_WIDTH-1:0]     PWDATA,

    output reg [DATA_WIDTH-1:0] PRDATA,

    input                       PWRITE,
    input                       PENABLE,
    input                       PSEL,

    output reg                  PREADY,
    output reg                  PSLVERR
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

reg [$clog2(Wait_State+1)-1:0] count;

// Memory Read Path

always @(*)
begin
  if(!PWRITE) begin
    PRDATA = mem[PADDR];
  end
end

// PSLVERR 

always @(*)
begin
    PSLVERR = 1'b0;

    if(PSEL && PENABLE)
    begin
      if(PADDR >= DEPTH-4)
            PSLVERR = 1'b1;
    end
end

// Main APB Logic

always @(posedge PCLK or negedge PRESETn)
begin

    if(!PRESETn)
    begin

        PREADY <= 1'b0;
        count  <= '0;

        for(i=0;i<DEPTH;i=i+1)
            mem[i] <= '0;

    end

    else
    begin

        // IDLE

        if(!PSEL)
        begin

            PREADY <= 1'b0;
            count  <= '0;

        end

        // SETUP

        else if(PSEL && !PENABLE)
        begin

            PREADY <= 1'b0;
            count  <= '0;

        end

        // ACCESS

        else if(PSEL && PENABLE)
        begin

            if(count == Wait_State)
            begin

                PREADY <= 1'b1;

                if(PWRITE && !PSLVERR)
                begin
                    mem[PADDR] <= PWDATA;
                end

            end

            else
            begin

                count  <= count + 1'b1;
                PREADY <= 1'b0;

            end

        end

    end

end
endmodule

