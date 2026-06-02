
module apb_decoder #
(
    parameter ADDR_WIDTH = 8
)
(
    input  [ADDR_WIDTH-1:0] PADDR,
    input                   PSEL,

    output reg              PSEL1,
    output reg              PSEL2
);

    always @(*)
    begin

        PSEL1 = 0;
        PSEL2 = 0;

        if(PSEL)
        begin
          if(PADDR[ADDR_WIDTH-1] == 1'b0) //We are checking MSB of address if MSB=0 Slave 1 and if MSB=1 slave 2
                PSEL1 = 1'b1;
            else
                PSEL2 = 1'b1;
        end

    end

endmodule
