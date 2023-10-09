module Region_Binarization 
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

    wire                matrix_img_vsync;
    wire                matrix_img_href;
    wire                matrix_top_edge_flag;
    wire                matrix_bottom_edge_flag;
    wire                matrix_left_edge_flag;
    wire                matrix_right_edge_flag;
    wire [7:0]          matrix_p11;
    wire [7:0]          matrix_p12;
    wire [7:0]          matrix_p13;
    wire [7:0]          matrix_p14;
    wire [7:0]          matrix_p15;
    wire [7:0]          matrix_p21;
    wire [7:0]          matrix_p22;
    wire [7:0]          matrix_p23;
    wire [7:0]          matrix_p24;
    wire [7:0]          matrix_p25;
    wire [7:0]          matrix_p31;
    wire [7:0]          matrix_p32;
    wire [7:0]          matrix_p33;
    wire [7:0]          matrix_p34;
    wire [7:0]          matrix_p35;
    wire [7:0]          matrix_p41;
    wire [7:0]          matrix_p42;
    wire [7:0]          matrix_p43;
    wire [7:0]          matrix_p44;
    wire [7:0]          matrix_p45;
    wire [7:0]          matrix_p51;
    wire [7:0]          matrix_p52;
    wire [7:0]          matrix_p53;
    wire [7:0]          matrix_p54;
    wire [7:0]          matrix_p55;



    Matrix_Generate_5x5_8Bit 
    #(
        .IMG_H_DISP(IMG_H_DISP),
        .IMG_V_DISP(IMG_V_DISP)
    )
    Matrix_Generate_5x5_8Bit_inst
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
        .matrix_p14                 (matrix_p14),
        .matrix_p15                 (matrix_p15),
        .matrix_p21                 (matrix_p21),
        .matrix_p22                 (matrix_p22),
        .matrix_p23                 (matrix_p23),
        .matrix_p24                 (matrix_p24),
        .matrix_p25                 (matrix_p25),
        .matrix_p31                 (matrix_p31),
        .matrix_p32                 (matrix_p32),
        .matrix_p33                 (matrix_p33),
        .matrix_p34                 (matrix_p34),
        .matrix_p35                 (matrix_p35),
        .matrix_p41                 (matrix_p41),
        .matrix_p42                 (matrix_p42),
        .matrix_p43                 (matrix_p43),
        .matrix_p44                 (matrix_p44),
        .matrix_p45                 (matrix_p45),
        .matrix_p51                 (matrix_p51),
        .matrix_p52                 (matrix_p52),
        .matrix_p53                 (matrix_p53),
        .matrix_p54                 (matrix_p54),
        .matrix_p55                 (matrix_p55)
        );


    reg [10:0]      data_sum1;
    reg [10:0]      data_sum2;
    reg [10:0]      data_sum3;
    reg [10:0]      data_sum4;
    reg [10:0]      data_sum5;
    reg [12:0]      data_sum;

    always @(posedge clk) begin
        data_sum1 <= matrix_p11 + matrix_p12 + matrix_p13 + matrix_p14 + matrix_p15;
        data_sum2 <= matrix_p21 + matrix_p22 + matrix_p23 + matrix_p24 + matrix_p25;
        data_sum3 <= matrix_p31 + matrix_p32 + matrix_p33 + matrix_p34 + matrix_p35;
        data_sum4 <= matrix_p41 + matrix_p42 + matrix_p43 + matrix_p44 + matrix_p45;
        data_sum5 <= matrix_p51 + matrix_p52 + matrix_p53 + matrix_p54 + matrix_p55;        
    end

    always @(posedge clk) begin
        data_sum <= data_sum1 + data_sum2 + data_sum3 + data_sum4 + data_sum5;
    end

    reg [31:0]      mult_result;

    always @(posedge clk) begin
        mult_result <= data_sum * 20'd603980;
    end

    wire [7:0]          thresh;
    assign thresh = mult_result[31:24];

    reg [7:0]       matrix_p33_r [2:0];

    always @(posedge clk) begin
        matrix_p33_r[0] <= matrix_p33;
        matrix_p33_r[1] <= matrix_p33_r[0];
        matrix_p33_r[2] <= matrix_p33_r[1];
    end


    reg [2:0]      matrix_img_vsync_r;
    reg [2:0]      matrix_img_href_r;
    reg [2:0]      edge_flag_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_img_vsync_r <= 3'b0;
            matrix_img_href_r  <= 3'b0;
            edge_flag_r        <= 3'b0;
        end else begin
            matrix_img_vsync_r <= {matrix_img_vsync_r[1:0], matrix_img_vsync};
            matrix_img_href_r  <= {matrix_img_href_r[1:0], matrix_img_href};
            edge_flag_r        <= {edge_flag_r[1:0], matrix_top_edge_flag|matrix_bottom_edge_flag|matrix_left_edge_flag|matrix_right_edge_flag};
        end
    end

    always @(posedge clk) begin
        if (edge_flag_r[2]) begin
            post_img_gray <= 8'd255;
        end else begin
            if (thresh > matrix_p33_r[2]) begin
                post_img_gray <= 8'd0;
            end else begin
                post_img_gray <= 8'd255;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_href <= 1'b0;
            post_img_vsync <= 1'b0;
        end else begin
            post_img_href <= matrix_img_href_r[2];
            post_img_vsync <= matrix_img_vsync_r[2];
        end
    end

endmodule

