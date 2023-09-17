module histEQ_proc (
    clk,
    rst_n,
    pixel_level,
    pixel_level_acc_num,
    pixel_level_valid,
    histEQ_start_flag,
    per_img_vsync,
    per_img_href,
    per_img_gray,
    post_img_vsync,
    post_img_href,
    post_img_gray
    );

    input               clk;
    input               rst_n;
    input [7:0]         pixel_level;
    input [19:0]        pixel_level_acc_num;
    input               pixel_level_valid;
    output reg          histEQ_start_flag;
    input               per_img_vsync;
    input               per_img_href;
    input [7:0]         per_img_gray;
    output              post_img_vsync;
    output              post_img_href;
    output [7:0]        post_img_gray;
    //----------------------------------------------------------------
    wire                ram_a_wren;
    wire [7:0]          ram_a_addr;
    wire [19:0]         ram_a_wdata;
    wire [7:0]          ram_b_addr;
    wire [19:0]         ram_b_rdata;
    
    assign ram_a_wren   = pixel_level_valid;
    assign ram_a_addr   = pixel_level;
    assign ram_a_wdata  = pixel_level_acc_num;
    assign ram_b_addr   = per_img_gray;

    ram_dual_port
    #(
        .C_ADDR_WIDTH(8),
        .C_DATA_WIDTH(20)
    )
    ram_dual_port_inst
    (
        .clk_a      (clk),
        .wren_a     (ram_a_wren),
        .addr_a     (ram_a_addr),
        .din_a      (ram_a_wdata),
        .dout_a     (),
        .clk_b      (clk),
        .wren_b     (1'b0),
        .addr_b     (ram_b_addr),
        .din_b      (20'd0),
        .dout_b     (ram_b_rdata)
    );    

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            histEQ_start_flag <= 1'b0;
        end else begin
            if ((pixel_level_valid == 1'b1)&&(pixel_level == 8'd255)) begin
                histEQ_start_flag <= 1'b1;
            end else begin
                histEQ_start_flag <= 1'b0;
            end
        end
    end
    //----------------------------------------------------------------
    reg [34:0]      mult_result;
    always @(posedge clk) begin
        mult_result <= ram_b_rdata * 18'd136957;
    end

    reg [7:0]       pixel_data;
    always @(posedge clk) begin
        pixel_data <= mult_result[34:27] + mult_result[26];
    end
    //----------------------------------------------------------------
    reg [2:0]       per_img_vsync_r;
    reg [2:0]       per_img_href_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_img_vsync_r <= 3'd0;
            per_img_href_r  <= 3'd0;
        end else begin
            per_img_vsync_r <= {per_img_vsync_r[2:0], per_img_vsync};
            per_img_href_r  <= {per_img_href_r[2:0], per_img_href};
        end
    end
    //----------------------------------------------------------------
    assign post_img_vsync = per_img_vsync_r[2];
    assign post_img_href  = per_img_href_r[2];
    assign post_img_gray  = pixel_data;

endmodule