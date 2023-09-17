module hist_stat (
    clk,
    rst_n,
    img_vsync,
    img_href,
    img_gray,
    pixel_level,
    pixel_level_acc_num,
    pixel_level_valid
    );

    input               clk;
    input               rst_n;
    input               img_vsync;
    input               img_href;
    input  [7:0]        img_gray;
    output reg [7:0]    pixel_level;
    output reg [19:0]   pixel_level_acc_num;
    output reg          pixel_level_valid;
    //----------------------------------------------------------------
    wire [7:0]      ram_a_addr;
    wire [7:0]      ram_b_addr;
    wire [19:0]     ram_b_wdata;
    wire            ram_a_wren;
    wire            ram_b_wren;
    wire [19:0]     ram_a_rdata;
    wire [19:0]     ram_b_rdata;
    //----------------------------------------------------------------
    reg  [7:0]      pixel_data;
    always @(posedge clk) begin
        pixel_data <= img_gray;
    end

    reg             pixel_data_valid;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data_valid <= 1'b0;
        end else begin
            pixel_data_valid <= img_href;
        end
    end

    reg             img_vsync_dly;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            img_vsync_dly <= 1'b0;
        end else begin
            img_vsync_dly <= img_vsync;
        end
    end

    wire            pixel_data_eop;
    assign pixel_data_eop = img_vsync_dly & ~img_vsync;
    //----------------------------------------------------------------
    reg [7:0]   pixel_data_tmp;
    always @(posedge clk) begin
        pixel_data_tmp <= pixel_data;
    end

    reg         pixel_data_valid_tmp;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data_valid_tmp <= 1'b0;
        end else if (pixel_data_valid == 1'b1) begin
            if (pixel_data_valid_tmp == 1'b0) begin
                pixel_data_valid_tmp <= 1'b1;
            end else begin
                if (pixel_data_tmp == pixel_data) begin
                    pixel_data_valid_tmp <= 1'b0;
                end else begin
                    pixel_data_valid_tmp <= 1'b1;
                end
            end
        end else begin
            pixel_data_valid_tmp <= 1'b0;
        end
    end

    reg [1:0]   cnt_num;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_num <= 2'd1;
        end else if ((pixel_data_tmp==pixel_data)&&(pixel_data_valid==1'b1)&&(pixel_data_valid_tmp==1'b1)) begin
            cnt_num <= 2'd2;
        end else begin
            cnt_num <= 2'd1;
        end
    end

    reg         pixel_data_eop_tmp;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data_eop_tmp <= 1'b0;
        end else begin
            pixel_data_eop_tmp <= pixel_data_eop;
        end
    end
    //----------------------------------------------------------------
    reg [7:0]   pixel_data_c1;
    always @(posedge clk) begin
        pixel_data_c1 <= pixel_data;
    end

    reg         pixel_data_valid_c1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data_valid_c1 <= 1'b0;
        end else begin
            pixel_data_valid_c1 <= pixel_data_valid_tmp;
        end
    end

    reg         pixel_data_eop_c1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data_eop_c1 <= 1'b0;
        end else begin
            pixel_data_eop_c1 <= pixel_data_eop_tmp;
        end
    end
    //----------------------------------------------------------------
    reg [7:0]    pixel_data_c2;
    always @(posedge clk) begin
        pixel_data_c2 <= pixel_data_c1;
    end

    reg [3:0]    pixel_data_eop_c2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data_eop_c2 <= 3'd0;
        end else begin
            pixel_data_eop_c2 <= {pixel_data_eop_c2[2:0], pixel_data_eop_c1};
        end
    end
    //----------------------------------------------------------------
    reg         rw_ctrl_flag_c3;
    reg [8:0]   rw_ctrl_addr_c3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rw_ctrl_flag_c3 <= 1'b0;
        end else if (pixel_data_eop_c2[2]) begin
            rw_ctrl_flag_c3 <= 1'b1;
        end else if (rw_ctrl_addr_c3 == 9'h100) begin
            rw_ctrl_flag_c3 <= 1'b0;
        end else begin
            rw_ctrl_flag_c3 <= rw_ctrl_flag_c3;
        end
    end

    reg [8:0]  rw_ctrl_addr_c3_dly;
    always @(posedge clk) begin
        rw_ctrl_addr_c3_dly <= rw_ctrl_addr_c3;
    end

    always @(*) begin
        if (rw_ctrl_flag_c3) begin
            rw_ctrl_addr_c3 = rw_ctrl_addr_c3_dly + 1'b1;
        end else begin
            rw_ctrl_addr_c3 = 9'd0;
        end
    end

    wire [7:0]  ram_addr_c3;
    assign ram_addr_c3 = rw_ctrl_addr_c3 - 1'b1;
    //----------------------------------------------------------------
    reg [7:0]   ram_addr_c4;
    always @(posedge clk) begin
        ram_addr_c4 <= ram_addr_c3;
    end

    reg         rw_ctrl_flag_c4;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rw_ctrl_flag_c4 <= 1'b0;
        end else begin
            rw_ctrl_flag_c4 <= rw_ctrl_flag_c3;
        end
    end
    //----------------------------------------------------------------
    reg [7:0]   ram_addr_c5;
    always @(posedge clk) begin
        ram_addr_c5 <= ram_addr_c4;
    end

    reg [19:0]  pixel_level_num_c5;
    always @(posedge clk) begin
        if (rw_ctrl_flag_c4) begin
            pixel_level_num_c5 <= ram_b_rdata;
        end else begin
            pixel_level_num_c5 <= 20'b0;
        end
    end

    reg         pixel_level_valid_c5;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_level_valid_c5 <= 1'b0;
        end else begin
            pixel_level_valid_c5 <= rw_ctrl_flag_c4;
        end
    end
    //----------------------------------------------------------------
    reg [7:0]   ram_addr_c6;
    always @(posedge clk) begin
        ram_addr_c6 <= ram_addr_c5;
    end

    reg [19:0]  pixel_level_acc_num_c6;
    always @(posedge clk) begin
        if (pixel_level_valid_c5) begin
            if (ram_addr_c5 == 8'b0) begin
                pixel_level_acc_num_c6 <= pixel_level_num_c5;
            end else begin
                pixel_level_acc_num_c6 <= pixel_level_acc_num_c6 + pixel_level_num_c5;
            end
        end else begin
            pixel_level_acc_num_c6 <= pixel_level_acc_num_c6;
        end
    end

    reg         pixel_level_valid_c6;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_level_valid_c6 <= 1'b0;
        end else begin
            pixel_level_valid_c6 <= pixel_level_valid_c5;
        end
    end
    //----------------------------------------------------------------
    always @(posedge clk) begin
        pixel_level         <= ram_addr_c6;
        pixel_level_acc_num <= pixel_level_acc_num_c6;
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            pixel_level_valid <= 1'b0;
        else
            pixel_level_valid <= pixel_level_valid_c6;
    end
    //----------------------------------------------------------------
    assign ram_a_addr   = (rw_ctrl_flag_c4) ? ram_addr_c4 : pixel_data_c1;
    assign ram_b_addr   = (rw_ctrl_flag_c3) ? ram_addr_c3 : pixel_data_c2;
    assign ram_a_wren   = rw_ctrl_flag_c4;
    assign ram_b_wren   = pixel_data_valid_c1;
    assign ram_b_wdata  = ram_a_rdata + cnt_num;

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
        .din_a      (20'd0),
        .dout_a     (ram_a_rdata),
        .clk_b      (clk),
        .wren_b     (ram_b_wren),
        .addr_b     (ram_b_addr),
        .din_b      (ram_b_wdata),
        .dout_b     (ram_b_rdata)
    );


endmodule