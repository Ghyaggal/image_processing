module Matrix_Generate_5x5_8Bit 
#(
    parameter IMG_H_DISP = 640,
    parameter IMG_V_DISP = 480,
    parameter DELAY_NUM  = 10
)(
    clk,
    rst_n,
    per_img_vsync,
    per_img_href,
    per_img_gray,
    matrix_img_vsync,
    matrix_img_href,
    matrix_top_edge_flag,
    matrix_bottom_edge_flag,
    matrix_left_edge_flag,
    matrix_right_edge_flag,
    matrix_p11,
    matrix_p12,
    matrix_p13,
    matrix_p14,
    matrix_p15,
    matrix_p21,
    matrix_p22,
    matrix_p23,
    matrix_p24,
    matrix_p25,
    matrix_p31,
    matrix_p32,
    matrix_p33,
    matrix_p34,
    matrix_p35,
    matrix_p41,
    matrix_p42,
    matrix_p43,
    matrix_p44,
    matrix_p45,
    matrix_p51,
    matrix_p52,
    matrix_p53,
    matrix_p54,
    matrix_p55
    );

    
    input               clk;
    input               rst_n;
    input               per_img_vsync;
    input               per_img_href;
    input [7:0]         per_img_gray;
    output              matrix_img_vsync;
    output              matrix_img_href;
    output              matrix_top_edge_flag;
    output              matrix_bottom_edge_flag;
    output              matrix_left_edge_flag;
    output              matrix_right_edge_flag;
    output reg [7:0]    matrix_p11;
    output reg [7:0]    matrix_p12;
    output reg [7:0]    matrix_p13;
    output reg [7:0]    matrix_p14;
    output reg [7:0]    matrix_p15;
    output reg [7:0]    matrix_p21;
    output reg [7:0]    matrix_p22;
    output reg [7:0]    matrix_p23;
    output reg [7:0]    matrix_p24;
    output reg [7:0]    matrix_p25;
    output reg [7:0]    matrix_p31;
    output reg [7:0]    matrix_p32;
    output reg [7:0]    matrix_p33;
    output reg [7:0]    matrix_p34;
    output reg [7:0]    matrix_p35;
    output reg [7:0]    matrix_p41;
    output reg [7:0]    matrix_p42;
    output reg [7:0]    matrix_p43;
    output reg [7:0]    matrix_p44;
    output reg [7:0]    matrix_p45;
    output reg [7:0]    matrix_p51;
    output reg [7:0]    matrix_p52;
    output reg [7:0]    matrix_p53;
    output reg [7:0]    matrix_p54;
    output reg [7:0]    matrix_p55;


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

    reg  per_img_href_dly;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_img_href_dly <= 1'b0;
        end else begin
            per_img_href_dly <= per_img_href;
        end
    end

    wire img_href_neg = per_img_href_dly & ~per_img_href;

    reg [10:0] vcnt;
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
            end else if ((extend_cnt>12'd0)&&(extend_cnt<{DELAY_NUM, 1'b0}+{IMG_H_DISP, 1'b0})) begin
                extend_cnt <= extend_cnt + 1'b1;
            end else begin
                extend_cnt <= 12'd0;
            end
        end
    end

    wire extend_2nd_last_row_en = {extend_cnt>DELAY_NUM}&(extend_cnt<=DELAY_NUM+IMG_H_DISP)?1'b1:1'b0;
    wire extend_1st_last_row_en = (extend_cnt>{DELAY_NUM, 1'b0}+IMG_H_DISP)?1'b1:1'b0;

    wire        fifo1_wr_en;
    wire        fifo1_rd_en;
    wire [7:0]  fifo1_dout;
    wire        fifo2_wr_en;
    wire        fifo2_rd_en;
    wire [7:0]  fifo2_dout;
    wire        fifo3_wr_en;
    wire        fifo3_rd_en;
    wire [7:0]  fifo3_dout;
    wire        fifo4_wr_en;
    wire        fifo4_rd_en;
    wire [7:0]  fifo4_dout;


    assign fifo1_wr_en = per_img_href;
    assign fifo1_rd_en = per_img_href & (vcnt > 11'd0) | extend_2nd_last_row_en;
    assign fifo2_wr_en = per_img_href & (vcnt > 11'd0) | extend_2nd_last_row_en;
    assign fifo2_rd_en = per_img_href & (vcnt > 11'd1) | extend_2nd_last_row_en | extend_1st_last_row_en;
    assign fifo3_wr_en = per_img_href & (vcnt > 11'd1) | extend_2nd_last_row_en;
    assign fifo3_rd_en = per_img_href & (vcnt > 11'd2) | extend_2nd_last_row_en | extend_1st_last_row_en;
    assign fifo4_wr_en = per_img_href & (vcnt > 11'd2) | extend_2nd_last_row_en;
    assign fifo4_rd_en = per_img_href & (vcnt > 11'd3) | extend_2nd_last_row_en | extend_1st_last_row_en;

    sync_fifo 
    #(
        .C_FIFO_WIDTH(8),
        .C_FIFO_DEPTH(1024)
    )
    sync_fifo_inst1
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en          (fifo1_wr_en),
        .rd_en          (fifo1_rd_en),
        .din            (per_img_gray),
        .full           (),
        .empty          (),
        .dout           (fifo1_dout),
        .data_count     ()
    );


    sync_fifo 
    #(
        .C_FIFO_WIDTH(8),
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


    sync_fifo 
    #(
        .C_FIFO_WIDTH(8),
        .C_FIFO_DEPTH(1024)
    )
    sync_fifo_inst3
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en          (fifo3_wr_en),
        .rd_en          (fifo3_rd_en),
        .din            (fifo2_dout),
        .full           (),
        .empty          (),
        .dout           (fifo3_dout),
        .data_count     ()
    );

    sync_fifo 
    #(
        .C_FIFO_WIDTH(8),
        .C_FIFO_DEPTH(1024)
    )
    sync_fifo_inst4
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en          (fifo4_wr_en),
        .rd_en          (fifo4_rd_en),
        .din            (fifo3_dout),
        .full           (),
        .empty          (),
        .dout           (fifo4_dout),
        .data_count     ()
    );

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15} <= 40'h0;
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25} <= 40'h0;
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35} <= 40'h0;
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45} <= 40'h0;
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55} <= 40'h0;
    end
    else
    begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15} <= {matrix_p12, matrix_p13, matrix_p14, matrix_p15, fifo4_dout};      //  1st row input
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25} <= {matrix_p22, matrix_p23, matrix_p24, matrix_p25, fifo3_dout};      //  2nd row input
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35} <= {matrix_p32, matrix_p33, matrix_p34, matrix_p35, fifo2_dout};      //  3rd row input
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45} <= {matrix_p42, matrix_p43, matrix_p44, matrix_p45, fifo1_dout};      //  4rd row input
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55} <= {matrix_p52, matrix_p53, matrix_p54, matrix_p55, per_img_gray};     //  5rd row input
    end
end

reg          extend_1st_last_row_en_dly;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            extend_1st_last_row_en_dly <= 1'b0;
        end else begin
            extend_1st_last_row_en_dly <= extend_1st_last_row_en;
        end
    end

    reg [2:0]   img_vsync;
    reg [2:0]   img_href;
    reg [2:0]   top_edge_flag;
    reg [2:0]   bottom_edge_flag;
    reg [2:0]   left_edge_flag;
    reg [2:0]   right_edge_flag;
   
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            img_vsync <= 3'd0;
        end else begin
            if ((per_img_href)&&(vcnt == 11'd2)&&(hcnt == 11'd0)) begin
                img_vsync[0] <= 1'b1;
            end else if ((extend_1st_last_row_en_dly==1'b1)&&(extend_1st_last_row_en==1'b0)) begin
                img_vsync[0] <= 1'b0;
            end else begin
                img_vsync[0] <= img_vsync[0];
            end
            img_vsync[2:1] <= img_vsync[1:0];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            img_href            <= 3'd0;
            top_edge_flag       <= 3'd0;
            bottom_edge_flag    <= 3'd0;
            left_edge_flag      <= 3'd0;
            right_edge_flag     <= 3'd0;
        end else begin
            img_href[0]             <= per_img_href & (vcnt > 11'd1) | extend_1st_last_row_en | extend_2nd_last_row_en;
            img_href[2:1]           <= img_href[1:0];
            top_edge_flag[0]        <= per_img_href & (vcnt==11'd2) | (vcnt==11'd3);
            top_edge_flag[2:1]      <= top_edge_flag[1:0];
            bottom_edge_flag[0]     <= extend_1st_last_row_en | extend_2nd_last_row_en;
            bottom_edge_flag[2:1]   <= bottom_edge_flag[1:0];
            left_edge_flag[0]       <= per_img_href & (vcnt > 11'd1) & (hcnt<=11'd1) | (extend_cnt == DELAY_NUM+1'b1) | (extend_cnt == DELAY_NUM + 2'd2)
                                        | (extend_cnt == {DELAY_NUM, 1'b0} + IMG_H_DISP + 1'b1) | (extend_cnt == {DELAY_NUM, 1'b0} + IMG_H_DISP + 2'd2);
            left_edge_flag[2:1]     <= left_edge_flag[1:0];
            right_edge_flag[0]      <= per_img_href & (vcnt > 11'd1) & (hcnt>=IMG_H_DISP-2'd2) | (extend_cnt==DELAY_NUM+IMG_H_DISP-1'b1) | (extend_cnt == DELAY_NUM + IMG_H_DISP)
                                        | (extend_cnt == {DELAY_NUM, 1'b0} + {IMG_H_DISP, 1'b0} - 1'b1) | (extend_cnt == {DELAY_NUM, 1'b0} + {IMG_H_DISP, 1'b0});
            right_edge_flag[2:1]    <= right_edge_flag[1:0];
        end
    end

    assign  matrix_img_vsync        = img_vsync[2];
    assign  matrix_img_href         = img_href[2];
    assign  matrix_top_edge_flag    = top_edge_flag[2];
    assign  matrix_bottom_edge_flag = bottom_edge_flag[2];
    assign  matrix_left_edge_flag   = left_edge_flag[2];
    assign  matrix_right_edge_flag  = right_edge_flag[2];

endmodule