module sync_fifo 
#(
    parameter C_FIFO_WIDTH = 8,
    parameter C_FIFO_DEPTH = 1024
)(
    clk,
    rst_n,
    wr_en,
    rd_en,
    din,
    full,
    empty,
    dout,
    data_count
    );

    input                                   clk;
    input                                   rst_n;
    input                                   wr_en;
    input                                   rd_en;
    input [C_FIFO_WIDTH-1:0]                din;
    output reg                              full;
    output reg                              empty;
    output [C_FIFO_WIDTH-1:0]               dout;
    output reg [Clogb2(C_FIFO_DEPTH-1):0]   data_count;


    reg [C_FIFO_WIDTH-1:0]                  mem [C_FIFO_DEPTH-1:0];
    reg [Clogb2(C_FIFO_DEPTH-1):0]          write_pointer;
    reg [Clogb2(C_FIFO_DEPTH-1):0]          read_pointer;

    always @(posedge clk) begin
        if (!rst_n) begin
            write_pointer <= 0;
        end else begin
            if ((wr_en)&&(full == 1'b0)) begin
                if (write_pointer < C_FIFO_DEPTH-1) begin
                    write_pointer <= write_pointer + 1'b1;
                end else begin
                    write_pointer <= 0;
                end
            end else begin
                write_pointer <= write_pointer;
            end
        end
    end

    always @(posedge clk) begin
        if ((wr_en)&&(full == 1'b0)) begin
            mem[write_pointer] <= din;
        end else begin
            mem[write_pointer] <= mem[write_pointer];
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            full <= 1'b0;
        end else begin
            if ((read_pointer==0)&&(write_pointer==C_FIFO_DEPTH-1'b1)||(write_pointer==read_pointer-1'b1)) begin
                full <= 1'b1;
            end else if ((full)&&(rd_en)) begin
                full <= 1'b0;
            end else begin
                full <= full;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            read_pointer <= 0;
        end else begin
            if ((rd_en)&&(empty == 1'b0)) begin
                if (read_pointer < C_FIFO_DEPTH-1) begin
                    read_pointer <= read_pointer + 1'b1;
                end else begin
                    read_pointer <= 0;
                end
            end else begin
                read_pointer <= read_pointer;
            end
        end
    end

    assign dout = mem[read_pointer];

    always @(posedge clk) begin
        if (!rst_n) begin
            empty <= 1'b0;
        end else begin
            if ((read_pointer==C_FIFO_DEPTH-1'b1)&&(write_pointer==0)||(read_pointer==write_pointer-1'b1)) begin
                empty <= 1'b1;
            end else if ((empty)&&(wr_en)) begin
                empty <= 1'b0;
            end else begin
                empty <= empty;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            data_count <= 0;
        end else begin
            if ((full==1'b0)&&(wr_en)) begin
                data_count <= data_count + 1'b1;
            end else if ((empty==1'b0)&&(rd_en)) begin
                data_count <= data_count - 1'b1;
            end else begin
                data_count <= data_count;
            end
        end
    end


    function integer Clogb2;
        input integer DEPTH;
        for (Clogb2=0; DEPTH > 0; Clogb2=Clogb2+1)
            DEPTH = DEPTH >> 1;
    endfunction

endmodule