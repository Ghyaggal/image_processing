module robert 
#(
    parameter IMG_H_DISP = 640,
    parameter IMG_V_DISP = 480
)(
    clk,
    rst_n,
    per_img_vsync,
    per_img_href,
    per_img_gray,
    post_img_vsync,
    post_img_href,
    post_img_gray
);
    
    input               clk;
    input               rst_n;
    input               per_img_vsync;
    input               per_img_href;
    input [7:0]         per_img_gray;

    output              post_img_vsync;
    output              post_img_href;
    output reg [7:0]    post_img_gray;



    wire                matrix_img_vsync;
    wire                matrix_img_href;
    wire                matrix_top_edge_flag;
    wire                matrix_bottom_edge_flag;
    wire                matrix_left_edge_flag;
    wire                matrix_right_edge_flag;
    wire [7:0]          matrix_p11;
    wire [7:0]          matrix_p12;
    wire [7:0]          matrix_p13;
    wire [7:0]          matrix_p21;
    wire [7:0]          matrix_p22;
    wire [7:0]          matrix_p23;
    wire [7:0]          matrix_p31;
    wire [7:0]          matrix_p32;
    wire [7:0]          matrix_p33;


    Matrix_Generate_3x3_8Bit 
    #(
        .IMG_H_DISP(IMG_H_DISP),
        .IMG_V_DISP(IMG_V_DISP)
    )
    Matrix_Generate_3x3_8Bit_inst
    (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .per_img_vsync              (per_img_vsync),
        .per_img_href               (per_img_href),
        .per_img_gray               (per_img_gray),
        .matrix_img_vsync           (matrix_img_vsync),
        .matrix_img_href            (matrix_img_href),
        .matrix_top_edge_flag       (matrix_top_edge_flag),
        .matrix_bottom_edge_flag    (matrix_bottom_edge_flag),
        .matrix_left_edge_flag      (matrix_left_edge_flag),
        .matrix_right_edge_flag     (matrix_right_edge_flag),
        .matrix_p11                 (matrix_p11),
        .matrix_p12                 (matrix_p12),
        .matrix_p13                 (matrix_p13),
        .matrix_p21                 (matrix_p21),
        .matrix_p22                 (matrix_p22),
        .matrix_p23                 (matrix_p23),
        .matrix_p31                 (matrix_p31),
        .matrix_p32                 (matrix_p32),
        .matrix_p33                 (matrix_p33)
        );

    reg signed [8:0]    Gx_data;
    reg signed [8:0]    Gy_data;
    reg signed [17:0]   Gx_square_data;
    reg signed [17:0]   Gy_square_data;
    reg [16:0]          G_square_data;
    wire [8:0]           G_data;

    always @(posedge clk) begin
        Gx_data <= $signed({1'b0, matrix_p23}) - $signed({1'b0, matrix_p12});
        Gy_data <= $signed({1'b0, matrix_p22}) - $signed({1'b0, matrix_p13});
        Gx_square_data <= $signed(Gx_data) * $signed(Gx_data);
        Gy_square_data <= $signed(Gy_data) * $signed(Gy_data);
        G_square_data  <= Gx_square_data[16:0] + Gy_square_data[16:0];
    end

    sqrt    sqrt_inst
    (
        .sys_clk       (clk),
        .sys_rst       (~rst_n),
        .din           (G_square_data),
        .din_valid     (1'b1),
        .dout          (G_data),
        .dout_valid    ()
    );

    reg [7:0]   matrix_p22_r [12:0];
    always @(posedge clk) begin
        matrix_p22_r[0] <= matrix_p22;
        matrix_p22_r[1] <= matrix_p22_r[0];
        matrix_p22_r[2] <= matrix_p22_r[1];
        matrix_p22_r[3] <= matrix_p22_r[2];
        matrix_p22_r[4] <= matrix_p22_r[3];
        matrix_p22_r[5] <= matrix_p22_r[4];
        matrix_p22_r[6] <= matrix_p22_r[5];
        matrix_p22_r[7] <= matrix_p22_r[6];
        matrix_p22_r[8] <= matrix_p22_r[7];
        matrix_p22_r[9] <= matrix_p22_r[8];
        matrix_p22_r[10] <= matrix_p22_r[9];
        matrix_p22_r[11] <= matrix_p22_r[10];
        matrix_p22_r[12] <= matrix_p22_r[11];
    end

    reg [12:0]  matrix_edge_flag_r, matrix_img_href_r, matrix_img_vsync_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_edge_flag_r <= 13'd0;
            matrix_img_href_r  <= 13'd0;
            matrix_img_vsync_r <= 13'd0;
        end else begin
            matrix_edge_flag_r <= {matrix_edge_flag_r[11:0], matrix_right_edge_flag | matrix_bottom_edge_flag};
            matrix_img_href_r  <= {matrix_img_href_r[11:0], matrix_img_href};
            matrix_img_vsync_r <= {matrix_img_vsync_r[11:0], matrix_img_vsync};
        end
    end

    reg [9:0] pixel_Data;
    always @(posedge clk) begin
        if (matrix_edge_flag_r[12] == 1'b1) begin
            pixel_Data <= matrix_p22_r[12];
        end else begin
            pixel_Data <= matrix_p22_r[12] + G_data;
        end
    end

    always @(posedge clk) begin
        if (pixel_Data > 10'd255) begin
            post_img_gray <= 8'd255;
        end else begin
            post_img_gray <= pixel_Data[7:0];
        end
    end

    reg [1:0]   post_img_vsync_r, post_img_href_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync_r <= 2'b0;
            post_img_href_r <= 2'b0;
        end else begin
            post_img_vsync_r <= {post_img_vsync_r[0], matrix_img_vsync_r[12]};
            post_img_href_r  <= {post_img_href_r[0], matrix_img_href_r[12]};
        end
    end

    assign post_img_href = post_img_href_r[1];
    assign post_img_vsync = post_img_vsync_r[1];

endmodule