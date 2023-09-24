module mean_filter_proc 
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
    output reg          post_img_vsync;
    output reg          post_img_href;
    output reg [7:0]    post_img_gray;


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

    reg [9:0]   Data_sum1;
    reg [9:0]   Data_sum2;
    reg [9:0]   Data_sum3;
    reg [11:0]   Data_sum;

    always @(posedge clk) begin
        Data_sum1 <= matrix_p11 + matrix_p12 + matrix_p13;
        Data_sum2 <= matrix_p21 + matrix_p22 + matrix_p23;
        Data_sum3 <= matrix_p31 + matrix_p32 + matrix_p33;
        Data_sum  <= Data_sum1  + Data_sum2  + Data_sum3;
    end

    reg [22:0]  Data_mult;
    reg [7:0]   avg_data;
    always @(posedge clk) begin
        Data_mult <= Data_sum * 3641;
        avg_data  <= Data_mult[22:15] + Data_mult[14];
    end

    reg [3:0] edge_flag;
    reg [3:0] img_vsync;
    reg [3:0] img_href;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            edge_flag <= 4'd0;
            img_vsync <= 4'd0;
            img_href  <= 4'd0;
        end else begin
            edge_flag <= {edge_flag[2:0], matrix_top_edge_flag|matrix_bottom_edge_flag|matrix_left_edge_flag|matrix_right_edge_flag};
            img_vsync <= {img_vsync[2:0], matrix_img_vsync};
            img_href  <= {img_href[2:0], matrix_img_href};
        end
    end

    reg [7:0]   matrix_p22_r [3:0];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_p22_r[0] <= 0;
            matrix_p22_r[1] <= 0;
            matrix_p22_r[2] <= 0;
            matrix_p22_r[3] <= 0; 
        end else begin
            matrix_p22_r[0] <= matrix_p22;
            matrix_p22_r[1] <= matrix_p22_r[0];
            matrix_p22_r[2] <= matrix_p22_r[1];
            matrix_p22_r[3] <= matrix_p22_r[2]; 
        end
        
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_gray <= 8'd0;
        end else begin
            if (edge_flag[3]) begin
                post_img_gray <= matrix_p22_r[3];
            end else begin
                post_img_gray <= avg_data;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync <= 1'b0;
            post_img_href  <= 1'b0;         
        end else begin
            post_img_vsync <= img_vsync[3];
            post_img_href  <= img_href[3];
        end
    end

endmodule