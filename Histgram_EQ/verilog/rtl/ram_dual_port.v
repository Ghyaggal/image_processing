module ram_dual_port 
#(
    parameter C_ADDR_WIDTH = 8,
    parameter C_DATA_WIDTH = 20
)(
    clk_a,
    wren_a,
    addr_a,
    din_a,
    dout_a,
    clk_b,
    wren_b,
    addr_b,
    din_b,
    dout_b
    );

    input                                clk_a;
    input                                wren_a;
    input [C_ADDR_WIDTH-1:0]             addr_a;
    input [C_DATA_WIDTH-1:0]             din_a;
    output reg   [C_DATA_WIDTH-1:0]      dout_a;
    input                                clk_b;
    input                                wren_b;
    input [C_ADDR_WIDTH-1:0]             addr_b;
    input [C_DATA_WIDTH-1:0]             din_b;
    output reg  [C_DATA_WIDTH-1:0]       dout_b;

    //----------------------------------------------------------------
    localparam C_MEM_DEPTH = {C_ADDR_WIDTH{1'b1}};

    reg [C_DATA_WIDTH-1:0]   mem [C_MEM_DEPTH:0];
    integer  i;
    initial begin
        for (i=0; i<=C_MEM_DEPTH; i=i+1) begin
            mem[i] = 0;
        end
    end

    always @(posedge clk_a) begin
        if (wren_a) begin
            mem[addr_a] <= din_a;
        end else begin
            dout_a <= mem[addr_a];
        end
    end

    always @(posedge clk_b) begin
        if (wren_b) begin
            mem[addr_b] <= din_b;
        end else begin
            dout_b <= mem[addr_b];
        end        
    end
    
endmodule