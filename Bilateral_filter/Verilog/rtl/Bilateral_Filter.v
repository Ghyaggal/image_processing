module Bilateral_Filter 
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
    output reg[7:0]     post_img_gray;

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

    reg [7:0]  num_sub11;
    reg [7:0]  num_sub12;
    reg [7:0]  num_sub13;
    reg [7:0]  num_sub21;
    reg [7:0]  num_sub23;
    reg [7:0]  num_sub31;
    reg [7:0]  num_sub32;
    reg [7:0]  num_sub33;

    always @(posedge clk) begin
        if (matrix_p11 > matrix_p22) begin
            num_sub11 <= matrix_p11 - matrix_p22;
        end else begin
            num_sub11 <= matrix_p22 - matrix_p11;
        end
    end

    always @(posedge clk) begin
        if (matrix_p12 > matrix_p22) begin
            num_sub12 <= matrix_p12 - matrix_p22;
        end else begin
            num_sub12 <= matrix_p22 - matrix_p12;
        end
    end

    always @(posedge clk) begin
        if (matrix_p13 > matrix_p22) begin
            num_sub13 <= matrix_p13 - matrix_p22;
        end else begin
            num_sub13 <= matrix_p22 - matrix_p13;
        end
    end

    always @(posedge clk) begin
        if (matrix_p21 > matrix_p22) begin
            num_sub21 <= matrix_p21 - matrix_p22;
        end else begin
            num_sub21 <= matrix_p22 - matrix_p21;
        end
    end

    always @(posedge clk) begin
        if (matrix_p23 > matrix_p22) begin
            num_sub23 <= matrix_p23 - matrix_p22;
        end else begin
            num_sub23 <= matrix_p22 - matrix_p23;
        end
    end

    always @(posedge clk) begin
        if (matrix_p31 > matrix_p22) begin
            num_sub31 <= matrix_p31 - matrix_p22;
        end else begin
            num_sub31 <= matrix_p22 - matrix_p31;
        end
    end

    always @(posedge clk) begin
        if (matrix_p32 > matrix_p22) begin
            num_sub32 <= matrix_p32 - matrix_p22;
        end else begin
            num_sub32 <= matrix_p22 - matrix_p32;
        end
    end

    always @(posedge clk) begin
        if (matrix_p33 > matrix_p22) begin
            num_sub33 <= matrix_p33 - matrix_p22;
        end else begin
            num_sub33 <= matrix_p22 - matrix_p33;
        end
    end

    wire [9:0]      Similary_p11;
    wire [9:0]      Similary_p12;
    wire [9:0]      Similary_p13;
    wire [9:0]      Similary_p21;
    wire [9:0]      Similary_p22;
    wire [9:0]      Similary_p23;
    wire [9:0]      Similary_p31;
    wire [9:0]      Similary_p32;
    wire [9:0]      Similary_p33;

    Similary_LUT Similary_LUT_inst1
    (
        .Pre_Data    (num_sub11),
        .Post_Data   (Similary_p11)
    );

    Similary_LUT Similary_LUT_inst2
    (
        .Pre_Data    (num_sub12),
        .Post_Data   (Similary_p12)
    );

    Similary_LUT Similary_LUT_inst3
    (
        .Pre_Data    (num_sub13),
        .Post_Data   (Similary_p13)
    );

    Similary_LUT Similary_LUT_inst4
    (
        .Pre_Data    (num_sub21),
        .Post_Data   (Similary_p21)
    );

    Similary_LUT Similary_LUT_inst5
    (
        .Pre_Data    (8'd0),
        .Post_Data   (Similary_p22)
    );

    Similary_LUT Similary_LUT_inst6
    (
        .Pre_Data    (num_sub23),
        .Post_Data   (Similary_p23)
    );

    Similary_LUT Similary_LUT_inst7
    (
        .Pre_Data    (num_sub31),
        .Post_Data   (Similary_p31)
    );

    Similary_LUT Similary_LUT_inst8
    (
        .Pre_Data    (num_sub32),
        .Post_Data   (Similary_p32)
    );

    Similary_LUT Similary_LUT_inst9
    (
        .Pre_Data    (num_sub33),
        .Post_Data   (Similary_p33)
    );


    //      [g11,g12,g13]   [109,115,109]
    //  g = [g21,g22,g23] = [115,122,115]
    //      [g31,g32,g33]   [109,115,109]
    localparam g11 = 7'd109;
    localparam g12 = 7'd115;
    localparam g13 = 7'd109;
    localparam g21 = 7'd115;
    localparam g22 = 7'd122;
    localparam g23 = 7'd115;
    localparam g31 = 7'd109;
    localparam g32 = 7'd115;
    localparam g33 = 7'd109;


    reg [16:0]  s11_mult_g11;
    reg [16:0]  s12_mult_g21;
    reg [16:0]  s13_mult_g31;

    reg [16:0]  s11_mult_g12;
    reg [16:0]  s12_mult_g22;
    reg [16:0]  s13_mult_g32;

    reg [16:0]  s11_mult_g13;
    reg [16:0]  s12_mult_g23;
    reg [16:0]  s13_mult_g33;

    reg [16:0]  s21_mult_g11;
    reg [16:0]  s22_mult_g21;
    reg [16:0]  s23_mult_g31;

    reg [16:0]  s21_mult_g12;
    reg [16:0]  s22_mult_g22;
    reg [16:0]  s23_mult_g32;

    reg [16:0]  s21_mult_g13;
    reg [16:0]  s22_mult_g23;
    reg [16:0]  s23_mult_g33;    

    reg [16:0]  s31_mult_g11;
    reg [16:0]  s32_mult_g21;
    reg [16:0]  s33_mult_g31;

    reg [16:0]  s31_mult_g12;
    reg [16:0]  s32_mult_g22;
    reg [16:0]  s33_mult_g32;

    reg [16:0]  s31_mult_g13;
    reg [16:0]  s32_mult_g23;
    reg [16:0]  s33_mult_g33;

    always @(posedge clk) begin
        s11_mult_g11 <= Similary_p11 * g11;
        s12_mult_g21 <= Similary_p12 * g21;
        s13_mult_g31 <= Similary_p13 * g31;
        s11_mult_g12 <= Similary_p11 * g12;
        s12_mult_g22 <= Similary_p12 * g22;
        s13_mult_g32 <= Similary_p13 * g32;
        s11_mult_g13 <= Similary_p11 * g13;
        s12_mult_g23 <= Similary_p12 * g23;
        s13_mult_g33 <= Similary_p13 * g33;
        s21_mult_g11 <= Similary_p21 * g11;
        s22_mult_g21 <= Similary_p22 * g21;
        s23_mult_g31 <= Similary_p23 * g31;
        s21_mult_g12 <= Similary_p21 * g12;
        s22_mult_g22 <= Similary_p22 * g22;
        s23_mult_g32 <= Similary_p23 * g32;
        s21_mult_g13 <= Similary_p21 * g13;
        s22_mult_g23 <= Similary_p22 * g23;
        s23_mult_g33 <= Similary_p23 * g33;
        s31_mult_g11 <= Similary_p31 * g11;
        s32_mult_g21 <= Similary_p32 * g21;
        s33_mult_g31 <= Similary_p33 * g31;
        s31_mult_g12 <= Similary_p31 * g12;
        s32_mult_g22 <= Similary_p32 * g22;
        s33_mult_g32 <= Similary_p33 * g32;
        s31_mult_g13 <= Similary_p31 * g13;
        s32_mult_g23 <= Similary_p32 * g23;
        s33_mult_g33 <= Similary_p33 * g33;
    end

    reg [20:0]      weight11;
    reg [20:0]      weight12;
    reg [20:0]      weight13;
    reg [20:0]      weight21;
    reg [20:0]      weight22;
    reg [20:0]      weight23;
    reg [20:0]      weight31;
    reg [20:0]      weight32;
    reg [20:0]      weight33;

    always @(posedge clk) begin
        weight11 <= s11_mult_g11 + s12_mult_g21 + s13_mult_g31;
        weight12 <= s11_mult_g12 + s12_mult_g22 + s13_mult_g32;
        weight13 <= s11_mult_g13 + s12_mult_g23 + s13_mult_g33;
        weight21 <= s21_mult_g11 + s22_mult_g21 + s23_mult_g31;
        weight22 <= s21_mult_g12 + s22_mult_g22 + s23_mult_g32;
        weight23 <= s21_mult_g13 + s22_mult_g23 + s23_mult_g33;
        weight31 <= s31_mult_g11 + s32_mult_g21 + s33_mult_g31;
        weight32 <= s31_mult_g12 + s32_mult_g22 + s33_mult_g32;
        weight33 <= s31_mult_g13 + s32_mult_g23 + s33_mult_g33;        
    end


    reg [22:0]      weight_sum_tmp1;
    reg [22:0]      weight_sum_tmp2;
    reg [22:0]      weight_sum_tmp3;

    always @(posedge clk) begin
        weight_sum_tmp1 <= weight11 + weight12 + weight13;
        weight_sum_tmp2 <= weight21 + weight22 + weight23;
        weight_sum_tmp3 <= weight31 + weight32 + weight33;
    end

    reg [24:0]      weight_sum;

    always @(posedge clk) begin
        weight_sum <= weight_sum_tmp1 + weight_sum_tmp2 + weight_sum_tmp3;
    end

    reg [20:0]      weight11_r1;
    reg [20:0]      weight12_r1;
    reg [20:0]      weight13_r1;
    reg [20:0]      weight21_r1;
    reg [20:0]      weight22_r1;
    reg [20:0]      weight23_r1;
    reg [20:0]      weight31_r1;
    reg [20:0]      weight32_r1;
    reg [20:0]      weight33_r1;

    reg [20:0]      weight11_r2;
    reg [20:0]      weight12_r2;
    reg [20:0]      weight13_r2;
    reg [20:0]      weight21_r2;
    reg [20:0]      weight22_r2;
    reg [20:0]      weight23_r2;
    reg [20:0]      weight31_r2;
    reg [20:0]      weight32_r2;
    reg [20:0]      weight33_r2;

    always @(posedge clk) begin
        weight11_r1 <= weight11;
        weight12_r1 <= weight12;
        weight13_r1 <= weight13;
        weight21_r1 <= weight21;
        weight22_r1 <= weight22;
        weight23_r1 <= weight23;
        weight31_r1 <= weight31;
        weight32_r1 <= weight32;
        weight33_r1 <= weight33;

        weight11_r2 <= weight11_r1;
        weight12_r2 <= weight12_r1;
        weight13_r2 <= weight13_r1;
        weight21_r2 <= weight21_r1;
        weight22_r2 <= weight22_r1;
        weight23_r2 <= weight23_r1;
        weight31_r2 <= weight31_r1;
        weight32_r2 <= weight32_r1;
        weight33_r2 <= weight33_r1;        
    end

    reg [9:0]      norm_weight11;
    reg [9:0]      norm_weight12;
    reg [9:0]      norm_weight13;
    reg [9:0]      norm_weight21;
    reg [9:0]      norm_weight22;
    reg [9:0]      norm_weight23;
    reg [9:0]      norm_weight31;
    reg [9:0]      norm_weight32;
    reg [9:0]      norm_weight33;


    always @(posedge clk) begin
        norm_weight11 <= {weight11_r2, 10'b0}/weight_sum;
        norm_weight12 <= {weight12_r2, 10'b0}/weight_sum;
        norm_weight13 <= {weight13_r2, 10'b0}/weight_sum;
        norm_weight21 <= {weight21_r2, 10'b0}/weight_sum;
        norm_weight22 <= {weight22_r2, 10'b0}/weight_sum;
        norm_weight23 <= {weight23_r2, 10'b0}/weight_sum;
        norm_weight31 <= {weight31_r2, 10'b0}/weight_sum;
        norm_weight32 <= {weight32_r2, 10'b0}/weight_sum;
        norm_weight33 <= {weight33_r2, 10'b0}/weight_sum;
    end

    reg [5:0]    matrix_img_vsync_r1;
    reg [5:0]    matrix_img_href_r1;
    reg [5:0]    matrix_edge_flag_r1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_img_vsync_r1 <= 6'b0;
            matrix_img_href_r1  <= 6'b0;
            matrix_edge_flag_r1 <= 6'b0;
        end else begin
            matrix_img_vsync_r1 <= {matrix_img_vsync_r1[4:0], matrix_img_vsync};
            matrix_img_href_r1  <= {matrix_img_href_r1[4:0], matrix_img_href};
            matrix_edge_flag_r1 <= {matrix_edge_flag_r1[4:0], matrix_top_edge_flag | matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag};            
        end
    end

    reg [7:0]    matrix_p11_r [5:0];
    reg [7:0]    matrix_p12_r [5:0];
    reg [7:0]    matrix_p13_r [5:0];
    reg [7:0]    matrix_p21_r [5:0];
    reg [7:0]    matrix_p22_r [5:0];
    reg [7:0]    matrix_p23_r [5:0];
    reg [7:0]    matrix_p31_r [5:0];
    reg [7:0]    matrix_p32_r [5:0];
    reg [7:0]    matrix_p33_r [5:0];

    always @(posedge clk) begin : shift_reg
        integer i;
        for (i=0; i<5; i=i+1) begin
            matrix_p11_r[i+1] <= matrix_p11_r[i];
            matrix_p12_r[i+1] <= matrix_p12_r[i];
            matrix_p13_r[i+1] <= matrix_p13_r[i];
            matrix_p21_r[i+1] <= matrix_p21_r[i];
            matrix_p22_r[i+1] <= matrix_p22_r[i];
            matrix_p23_r[i+1] <= matrix_p23_r[i];
            matrix_p31_r[i+1] <= matrix_p31_r[i];
            matrix_p32_r[i+1] <= matrix_p32_r[i];
            matrix_p33_r[i+1] <= matrix_p33_r[i];        
        end
        matrix_p11_r[0] <= matrix_p11;
        matrix_p12_r[0] <= matrix_p12;
        matrix_p13_r[0] <= matrix_p13;
        matrix_p21_r[0] <= matrix_p21;
        matrix_p22_r[0] <= matrix_p22;
        matrix_p23_r[0] <= matrix_p23;
        matrix_p31_r[0] <= matrix_p31;
        matrix_p32_r[0] <= matrix_p32;
        matrix_p33_r[0] <= matrix_p33;
    end


    reg [17:0]      mult_p11_w11;
    reg [17:0]      mult_p21_w21;
    reg [17:0]      mult_p31_w31;
    reg [17:0]      mult_p12_w12;
    reg [17:0]      mult_p22_w22;
    reg [17:0]      mult_p32_w32;
    reg [17:0]      mult_p13_w13;
    reg [17:0]      mult_p23_w23;
    reg [17:0]      mult_p33_w33;
        

    always @(posedge clk) begin
        mult_p11_w11 <= matrix_p11_r[5] * norm_weight11;
        mult_p21_w21 <= matrix_p21_r[5] * norm_weight21;
        mult_p31_w31 <= matrix_p31_r[5] * norm_weight31;
        mult_p12_w12 <= matrix_p12_r[5] * norm_weight12;
        mult_p22_w22 <= matrix_p22_r[5] * norm_weight22;
        mult_p32_w32 <= matrix_p32_r[5] * norm_weight32;
        mult_p13_w13 <= matrix_p13_r[5] * norm_weight13;
        mult_p23_w23 <= matrix_p23_r[5] * norm_weight23;
        mult_p33_w33 <= matrix_p33_r[5] * norm_weight33;
    end

    reg [17:0]      sum_result_tmp1;
    reg [17:0]      sum_result_tmp2;
    reg [17:0]      sum_result_tmp3;
    reg [17:0]      sum_result;

    always @(posedge clk) begin
        sum_result_tmp1 <= mult_p11_w11 + mult_p21_w21 + mult_p31_w31;
        sum_result_tmp2 <= mult_p12_w12 + mult_p22_w22 + mult_p32_w32;
        sum_result_tmp3 <= mult_p13_w13 + mult_p23_w23 + mult_p33_w33;
        sum_result      <= sum_result_tmp1 + sum_result_tmp2 + sum_result_tmp3;
    end

    reg [2:0]    matrix_img_vsync_r2;
    reg [2:0]    matrix_img_href_r2;
    reg [2:0]    matrix_edge_flag_r2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_img_vsync_r2 <= 3'b0;
            matrix_img_href_r2  <= 3'b0;
            matrix_edge_flag_r2 <= 3'b0;
        end else begin
            matrix_img_vsync_r2 <= {matrix_img_vsync_r2[1:0], matrix_img_vsync_r1[5]};
            matrix_img_href_r2  <= {matrix_img_href_r2[1:0], matrix_img_href_r1[5]};
            matrix_edge_flag_r2 <= {matrix_edge_flag_r2[1:0], matrix_edge_flag_r1[5]};
        end
    end

    reg [7:0]      matrix_p22_r2 [2:0];

    always @(posedge clk) begin
        matrix_p22_r2[0] <= matrix_p22_r[5];
        matrix_p22_r2[1] <= matrix_p22_r2[0];
        matrix_p22_r2[2] <= matrix_p22_r2[1];
    end

    always @(posedge clk) begin
        if (matrix_edge_flag_r2[2] == 1'b1) begin
            post_img_gray <= matrix_p22_r2[2];
        end else begin
            post_img_gray <= sum_result[17:10] + sum_result[9];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync  <= 1'b0;
            post_img_href   <= 1'b0;
        end else begin
            post_img_vsync  <= matrix_img_vsync_r2[2];
            post_img_href   <= matrix_img_href_r2[2];
        end
    end


endmodule