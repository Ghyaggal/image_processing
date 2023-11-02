module bin_compare 
#(
    parameter IMG_H_DISP = 640,
    parameter IMG_V_DISP = 480
)(
    clk,
    rst_n,
    thresh,
    per_img_vsync,
    per_img_href,
    per_img_bit,
    post_img_vsync,
    post_img_href,
    post_img_bit
);
    
    input               clk;
    input               rst_n;
    input [3:0]         thresh;
    input               per_img_vsync;
    input               per_img_href;
    input               per_img_bit;

    output reg          post_img_vsync;
    output reg          post_img_href;
    output reg          post_img_bit;


    wire          matrix_img_vsync;
    wire          matrix_img_href;
    wire          matrix_top_edge_flag;
    wire          matrix_bottom_edge_flag;
    wire          matrix_left_edge_flag;
    wire          matrix_right_edge_flag;
    wire          matrix_p11;
    wire          matrix_p12;
    wire          matrix_p13;
    wire          matrix_p21;
    wire          matrix_p22;
    wire          matrix_p23;
    wire          matrix_p31;
    wire          matrix_p32;
    wire          matrix_p33;

    Matrix_Generate_3x3_8Bit 
    #(
        .IMG_H_DISP(IMG_H_DISP),
        .IMG_V_DISP(IMG_V_DISP)
    )
    Matrix_Generate_3x3_8Bit_inst
    (
        .clk                     (clk),
        .rst_n                   (rst_n),
        .per_img_vsync           (per_img_vsync),
        .per_img_href            (per_img_href),
        .per_img_bit             (per_img_bit),
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

    reg [1:0] data_sum1;
    reg [1:0] data_sum2;
    reg [1:0] data_sum3;
    reg [3:0] data_sum;

    always @(posedge clk) begin
        data_sum1 <= matrix_p11 + matrix_p12 + matrix_p13;
        data_sum2 <= matrix_p21 + matrix_p22 + matrix_p23;
        data_sum3 <= matrix_p31 + matrix_p32 + matrix_p33;
        data_sum  <= data_sum1 + data_sum2 + data_sum3;
    end

    reg [1:0] matrix_img_href_r, matrix_img_vsync_r, matrix_img_edge_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_img_href_r <= 2'd0;
            matrix_img_vsync_r <= 2'd0;
            matrix_img_edge_r <= 2'd0;
        end else begin
            matrix_img_href_r <= {matrix_img_href_r[0], matrix_img_href};
            matrix_img_vsync_r <= {matrix_img_href_r[0], matrix_img_vsync};
            matrix_img_edge_r <= {matrix_img_edge_r[0], matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag | matrix_top_edge_flag};
        end
    end

    always @(posedge clk) begin
        if (matrix_img_edge_r) begin
            post_img_bit <= 1'b0;
        end else if (data_sum >= thresh) begin
            post_img_bit <= 1'b1;
        end else begin
            post_img_bit <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync <= 1'b0;
            post_img_href  <= 1'b0;  
        end else begin
            post_img_vsync <= matrix_img_vsync_r[1];
            post_img_href  <= matrix_img_href_r[1];
        end
    end

endmodule