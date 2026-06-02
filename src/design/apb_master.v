


module apb_master #
(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)
(
    input                       PCLK,
    input                       PRESETn,

    input                       transfer,
    input                       read_write,

    input  [ADDR_WIDTH-1:0]     write_addr,
    input  [DATA_WIDTH-1:0]     write_data,

    input  [ADDR_WIDTH-1:0]     read_addr,

    output reg [DATA_WIDTH-1:0] read_data_out,

    // APB Signals
    output reg [ADDR_WIDTH-1:0] PADDR,
    output reg [DATA_WIDTH-1:0] PWDATA,
    input      [DATA_WIDTH-1:0] PRDATA,

    output reg                  PWRITE,
    output reg                  PENABLE,
    output reg                  PSEL,

    input                       PREADY,
    input                       PSLVERR
);

  

    parameter IDLE   = 2'b00;
    parameter SETUP  = 2'b01;
    parameter ACCESS = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;

    always @(posedge PCLK or negedge PRESETn)
    begin
        if(!PRESETn)
            current_state <= IDLE;
            PADDR         <= 0;
            PWDATA        <= 0;
            PWRITE        <= 0;
            PENABLE       <= 0;
            PSEL          <= 0;
            read_data_out <= 0;
        else
            current_state <= next_state;
    end

    always @(*)
    begin
        next_state = current_state;

        case(current_state)

            IDLE:
            begin
                if(transfer)
                    next_state = SETUP;
            end

            SETUP:
            begin
                next_state = ACCESS;
            end

            ACCESS:
            begin
              if(PREADY)
                    next_state = transfer?SETUP:IDLE;
                else
                    next_state = ACCESS;
            end

            default:
                next_state = IDLE;

        endcase
    end

  always @(*)
    begin
        if(!PRESETn)
        begin
            PADDR         <= 0;
            PWDATA        <= 0;
            PWRITE        <= 0;
            PENABLE       <= 0;
            PSEL          <= 0;
            read_data_out <= 0;
        end
        else
        begin

            case(current_state)

                IDLE:
                begin
                    PSEL    <= 0;
                    PENABLE <= 0;
                end

                SETUP:
                begin
                    PSEL    <= 1'b1;
                    PENABLE <= 1'b0;

                    PWRITE  <= read_write;

                    if(read_write)
                    begin
                        PADDR  <= write_addr;
                        PWDATA <= write_data;
                    end
                    else
                    begin
                        PADDR <= read_addr;
                    end
                end

                ACCESS:
                begin
                    PENABLE <= 1'b1;

                    if(PREADY)
                    begin
                      if(!transfer) begin
                        PSEL    <= 1'b0;
                        PENABLE <= 1'b0;
                      end
                      
                      else begin
                        PSEL    <= 1'b1;
                        PENABLE <= 1'b0;
                      end

                        if(!PWRITE)
                            read_data_out <= PRDATA;
                    end
                end

            endcase
        end
    end

endmodule
