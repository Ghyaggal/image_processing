module Matrix_Generate_3x3_8Bit 
#(
    parameter IMG_H_DISP = 640,
    parameter IMG_V_DISP = 480,
    parameter DELAY_NUM  = 10
)(
    clk,
    rst_n,
    per_img_vsync,
    per_img_href,
    per_img_bit,
    matrix_img_vsync,
    matrix_img_href,
    matrix_top_edge_flag,
    matrix_bottom_edge_flag,
    matrix_left_edge_flag,
    matrix_right_edge_flag,
    matrix_p11,
    matrix_p12,
    matrix_p13,
    matrix_p21,
    matrix_p22,
    matrix_p23,
    matrix_p31,
    matrix_p32,
    matrix_p33
    );
    
    input               clk;
    input               rst_n;
    input               per_img_vsync;
    input               per_img_href;
    input               per_img_bit;
    output              matrix_img_vsync;
    output              matrix_img_href;
    output              matrix_top_edge_flag;
    output              matrix_bottom_edge_flag;
    output              matrix_left_edge_flag;
    output              matrix_right_edge_flag;
    output reg          matrix_p11;
    output reg          matrix_p12;
    output reg          matrix_p13;
    output reg          matrix_p21;
    output reg          matrix_p22;
    output reg          matrix_p23;
    output reg          matrix_p31;
    output reg          matrix_p32;
    output reg          matrix_p33;


    reg [10:0]  hcnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcnt <= 11'd0;
        end else begin
            if (per_img_href) begin
                hcnt <= hcnt + 1'b1;
            end else begin
                hcnt <= 11'd0;
            end
        end
    end

    reg         per_img_href_dly;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_img_href_dly <= 1'b0;
        end else begin
            per_img_href_dly <= per_img_href;
        end
    end

    wire img_href_neg  = per_img_href_dly & ~per_img_href;

    reg [10:0]  vcnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vcnt <= 11'd0;
        end else begin
            if (per_img_vsync == 1'b0) begin
                vcnt <= 11'd0;
            end else if (img_href_neg) begin
                vcnt <= vcnt + 1'b1;
            end else begin
                vcnt <= vcnt;
            end
        end
    end

    reg [11:0] extend_cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            extend_cnt <= 12'd0;
        end else begin
            if ((per_img_href)&&(hcnt==IMG_H_DISP-1'b1)&&(vcnt==IMG_V_DISP-1'b1)) begin
                extend_cnt <= 12'd1;
            end else if ((extend_cnt>12'd0)&&(extend_cnt<DELAY_NUM+IMG_H_DISP)) begin
                extend_cnt <= extend_cnt + 1'b1;
            end else begin
                extend_cnt <= 12'd0;
            end
        end
    end

    wire extend_en = (extend_cnt > DELAY_NUM) ? 1'b1 : 1'b0;

    wire        fifo1_wr_en;
    wire        fifo1_rd_en;
    wire        fifo1_dout;
    wire        fifo2_wr_en;
    wire        fifo2_rd_en;
    wire        fifo2_dout;

    assign fifo1_wr_en = per_img_href;
    assign fifo1_rd_en = per_img_href & (vcnt > 11'd0) | extend_en;
    assign fifo2_wr_en = per_img_href & (vcnt > 11'd0);
    assign fifo2_rd_en = per_img_href & (vcnt > 11'd1) | extend_en;

    sync_fifo 
    #(
        .C_FIFO_WIDTH(1),
        .C_FIFO_DEPTH(1024)
    )
    sync_fifo_inst1
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en          (fifo1_wr_en),
        .rd_en          (fifo1_rd_en),
        .din            (per_img_bit),
        .full           (),
        .empty          (),
        .dout           (fifo1_dout),
        .data_count     ()
    );

    sync_fifo 
    #(
        .C_FIFO_WIDTH(1),
        .C_FIFO_DEPTH(1024)
    )
    sync_fifo_inst2
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en          (fifo2_wr_en),
        .rd_en          (fifo2_rd_en),
        .din            (fifo1_dout),
        .full           (),
        .empty          (),
        .dout           (fifo2_dout),
        .data_count     ()
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {matrix_p11, matrix_p12, matrix_p13} <= 3'd0;
            {matrix_p21, matrix_p22, matrix_p23} <= 3'd0;
            {matrix_p21, matrix_p22, matrix_p23} <= 3'd0;            
        end else begin
            {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, per_img_bit};
            {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, fifo1_dout};
            {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, fifo2_dout};
        end
    end

    reg          extend_en_dly;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            extend_en_dly <= 1'b0;
        end else begin
            extend_en_dly <= extend_en;
        end
    end

    reg [1:0]   img_vsync;
    reg [1:0]   img_href;
    reg [1:0]   top_edge_flag;
    reg [1:0]   bottom_edge_flag;
    reg [1:0]   left_edge_flag;
    reg [1:0]   right_edge_flag;
   
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            img_vsync <= 2'd0;
        end else begin
            if ((per_img_href)&&(vcnt == 11'd1)&&(hcnt == 11'd0)) begin
                img_vsync[0] <= 1'b1;
            end else if ((extend_en_dly==1'b1)&&(extend_en==1'b0)) begin
                img_vsync[0] <= 1'b0;
            end else begin
                img_vsync[0] <= img_vsync[0];
            end
            img_vsync[1] <= img_vsync[0];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            img_href            <= 2'd0;
            top_edge_flag       <= 2'd0;
            bottom_edge_flag    <= 2'd0;
            left_edge_flag      <= 2'd0;
            right_edge_flag     <= 2'd0;
        end else begin
            img_href[0]         <= per_img_href & (vcnt > 11'd0) | extend_en;
            img_href[1]         <= img_href[0];
            top_edge_flag[0]    <= per_img_href & (vcnt==11'd1);
            top_edge_flag[1]    <= top_edge_flag[0];
            bottom_edge_flag[0] <= extend_en;
            bottom_edge_flag[1] <= bottom_edge_flag[0];
            left_edge_flag[0]   <= per_img_href & (vcnt > 11'd0) & (hcnt==11'd0) | (extend_cnt == DELAY_NUM+1'b1);
            left_edge_flag[1]   <= left_edge_flag[0];
            right_edge_flag[0]  <= per_img_href & (vcnt > 11'd0) & (hcnt==IMG_H_DISP-1'd1) | (extend_cnt==DELAY_NUM+IMG_H_DISP);
            right_edge_flag[1]  <= right_edge_flag[0];
        end
    end

    assign  matrix_img_vsync        = img_vsync[1];
    assign  matrix_img_href         = img_href[1];
    assign  matrix_top_edge_flag    = top_edge_flag[1];
    assign  matrix_bottom_edge_flag = bottom_edge_flag[1];
    assign  matrix_left_edge_flag   = left_edge_flag[1];
    assign  matrix_right_edge_flag  = right_edge_flag[1];

endmodule