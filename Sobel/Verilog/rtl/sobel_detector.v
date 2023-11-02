module sobel_detector 
#(
    parameter IMG_H_DISP = 640,
    parameter IMG_V_DISP = 480    
)(
    clk,
    rst_n,
    thresh,
    per_img_href,
    per_img_vsync,
    per_img_gray,
    post_img_href,
    post_img_vsync,
    post_img_bit
);

    input           clk;
    input           rst_n;
    input [7:0]     thresh;
    input           per_img_href;
    input           per_img_vsync;
    input [7:0]     per_img_gray;

    output  reg     post_img_href;
    output  reg     post_img_vsync;
    output  reg     post_img_bit;


    wire          matrix_img_vsync;
    wire          matrix_img_href;
    wire          matrix_top_edge_flag;
    wire          matrix_bottom_edge_flag;
    wire          matrix_left_edge_flag;
    wire          matrix_right_edge_flag;
    wire [7:0]    matrix_p11;
    wire [7:0]    matrix_p12;
    wire [7:0]    matrix_p13;
    wire [7:0]    matrix_p21;
    wire [7:0]    matrix_p22;
    wire [7:0]    matrix_p23;
    wire [7:0]    matrix_p31;
    wire [7:0]    matrix_p32;
    wire [7:0]    matrix_p33;

    Matrix_Generate_3x3_8Bit 
    #(
        .IMG_H_DISP(IMG_H_DISP),
        .IMG_V_DISP(IMG_V_DISP)
    )
    Matrix_Generate_3x3_8Bit
    (
        .clk                     (clk),
        .rst_n                   (rst_n),
        .per_img_vsync           (per_img_vsync),
        .per_img_href            (per_img_href),
        .per_img_gray            (per_img_gray),
        .matrix_img_vsync        (matrix_img_vsync),
        .matrix_img_href         (matrix_img_href),
        .matrix_top_edge_flag    (matrix_top_edge_flag),
        .matrix_bottom_edge_flag (matrix_bottom_edge_flag),
        .matrix_left_edge_flag   (matrix_left_edge_flag),
        .matrix_right_edge_flag  (matrix_right_edge_flag),
        .matrix_p11              (matrix_p11),
        .matrix_p12              (matrix_p12),
        .matrix_p13              (matrix_p13),
        .matrix_p21              (matrix_p21),
        .matrix_p22              (matrix_p22),
        .matrix_p23              (matrix_p23),
        .matrix_p31              (matrix_p31),
        .matrix_p32              (matrix_p32),
        .matrix_p33              (matrix_p33)
        );

    reg [9:0]           Gx_data_temp1;
    reg [9:0]           Gx_data_temp2;
    reg [9:0]           Gy_data_temp1;
    reg [9:0]           Gy_data_temp2;
    reg signed [10:0]   Gx_data;
    reg signed [10:0]   Gy_data;
    reg signed [21:0]   Gx_square_data;
    reg signed [21:0]   Gy_square_data;
    reg [20:0]          G_square_data;
    wire [10:0]         G_data;

    always @(posedge clk) begin
        Gx_data_temp1   <= matrix_p11 + {matrix_p21, 1'b0} + matrix_p31;
        Gx_data_temp2   <= matrix_p13 + {matrix_p23, 1'b0} + matrix_p33;
        Gy_data_temp1   <= matrix_p11 + {matrix_p12, 1'b0} + matrix_p13;
        Gy_data_temp2   <= matrix_p31 + {matrix_p32, 1'b0} + matrix_p33;
        Gx_data         <= Gx_data_temp2 - Gx_data_temp1;
        Gy_data         <= Gy_data_temp2 - Gy_data_temp1;
        Gx_square_data  <= Gx_data * Gx_data;
        Gy_square_data  <= Gy_data * Gy_data;
        G_square_data   <= Gx_square_data[20:0] + Gy_square_data[20:0];
    end

    sqrt sqrt_inst
    (
        .sys_clk     (clk),
        .sys_rst     (~rst_n),
        .din         (G_square_data),
        .din_valid   (1'b1),
        .dout        (G_data),
        .dout_valid  ()
    );


    reg [15:0]      matrix_img_href_r;
    reg [15:0]      matrix_img_vsync_r;
    reg [15:0]      matrix_edge_flag_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_img_href_r   <= 16'd0;
            matrix_img_vsync_r  <= 16'd0;
            matrix_edge_flag_r  <= 16'd0;
        end else begin
            matrix_img_href_r <= {matrix_img_href_r[14:0], matrix_img_href};
            matrix_img_vsync_r <= {matrix_img_vsync_r[14:0], matrix_img_vsync};
            matrix_edge_flag_r <= {matrix_edge_flag_r[14:0], matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag | matrix_top_edge_flag};
        end
    end


    always @(posedge clk) begin
        if (matrix_edge_flag_r[15] == 1'b1) begin
            post_img_bit <= 1'b0;
        end else if (G_data > thresh) begin
            post_img_bit <= 1'b1;
        end else begin
            post_img_bit <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_href <= 1'b0;
            post_img_vsync <= 1'b0;
        end else begin
            post_img_href <= matrix_img_href_r[15];
            post_img_vsync <= matrix_img_vsync_r[15];
        end
    end

endmodule