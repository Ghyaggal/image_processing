module med_filter_proc 
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


    reg [7:0] data_max1, data_max2, data_max3;
    reg [7:0] data_mid1, data_mid2, data_mid3;
    reg [7:0] data_min1, data_min2, data_min3;

    always @(posedge clk)
    begin
        if((matrix_p11 <= matrix_p12)&&(matrix_p11 <= matrix_p13))
            data_min1 <= matrix_p11;
        else if((matrix_p12 <= matrix_p11)&&(matrix_p12 <= matrix_p13))
            data_min1 <= matrix_p12;
        else
            data_min1 <= matrix_p13;
    end

    always @(posedge clk)
    begin
        if((matrix_p11 <= matrix_p12)&&(matrix_p11 >= matrix_p13)||(matrix_p11 >= matrix_p12)&&(matrix_p11 <= matrix_p13))
            data_mid1 <= matrix_p11;
        else if((matrix_p12 <= matrix_p11)&&(matrix_p12 >= matrix_p13)||(matrix_p12 >= matrix_p11)&&(matrix_p12 <= matrix_p13))
            data_mid1 <= matrix_p12;
        else
            data_mid1 <= matrix_p13;
    end

    always @(posedge clk)
    begin
        if((matrix_p11 >= matrix_p12)&&(matrix_p11 >= matrix_p13))
            data_max1 <= matrix_p11;
        else if((matrix_p12 >= matrix_p11)&&(matrix_p12 >= matrix_p13))
            data_max1 <= matrix_p12;
        else
            data_max1 <= matrix_p13;
    end


    always @(posedge clk)
    begin
        if((matrix_p21 <= matrix_p22)&&(matrix_p21 <= matrix_p23))
            data_min2 <= matrix_p21;
        else if((matrix_p22 <= matrix_p21)&&(matrix_p22 <= matrix_p23))
            data_min2 <= matrix_p22;
        else
            data_min2 <= matrix_p23;
    end

    always @(posedge clk)
    begin
        if((matrix_p21 <= matrix_p22)&&(matrix_p21 >= matrix_p23)||(matrix_p21 >= matrix_p22)&&(matrix_p21 <= matrix_p23))
            data_mid2 <= matrix_p21;
        else if((matrix_p22 <= matrix_p21)&&(matrix_p22 >= matrix_p23)||(matrix_p22 >= matrix_p21)&&(matrix_p22 <= matrix_p23))
            data_mid2 <= matrix_p22;
        else
            data_mid2 <= matrix_p23;
    end

    always @(posedge clk)
    begin
        if((matrix_p21 >= matrix_p22)&&(matrix_p21 >= matrix_p23))
            data_max2 <= matrix_p21;
        else if((matrix_p22 >= matrix_p21)&&(matrix_p22 >= matrix_p23))
            data_max2 <= matrix_p22;
        else
            data_max2 <= matrix_p23;
    end

    always @(posedge clk)
    begin
        if((matrix_p31 <= matrix_p32)&&(matrix_p31 <= matrix_p33))
            data_min3 <= matrix_p31;
        else if((matrix_p32 <= matrix_p31)&&(matrix_p32 <= matrix_p33))
            data_min3 <= matrix_p32;
        else
            data_min3 <= matrix_p33;
    end

    always @(posedge clk)
    begin
        if((matrix_p31 <= matrix_p32)&&(matrix_p31 >= matrix_p33)||(matrix_p31 >= matrix_p32)&&(matrix_p31 <= matrix_p33))
            data_mid3 <= matrix_p31;
        else if((matrix_p32 <= matrix_p31)&&(matrix_p32 >= matrix_p33)||(matrix_p32 >= matrix_p31)&&(matrix_p32 <= matrix_p33))
            data_mid3 <= matrix_p32;
        else
            data_mid3 <= matrix_p33;
    end

    always @(posedge clk)
    begin
        if((matrix_p31 >= matrix_p32)&&(matrix_p31 >= matrix_p33))
            data_max3 <= matrix_p31;
        else if((matrix_p32 >= matrix_p31)&&(matrix_p32 >= matrix_p33))
            data_max3 <= matrix_p32;
        else
            data_max3 <= matrix_p33;
    end

    reg [7:0] max_min, mid_mid, min_max;
    always @(posedge clk)
    begin
        if((data_min1 >= data_min2)&&(data_min1 >= data_min3))
            max_min <= data_min1;
        else if((data_min2 >= data_min1)&&(data_min2 >= data_min3))
            max_min <= data_min2;
        else
            max_min <= data_min3;
    end

    always @(posedge clk)
    begin
        if((data_mid1 >= data_mid2)&&(data_mid1 <= data_mid3)||(data_mid1 <= data_mid2)&&(data_mid1 >= data_mid3))
            mid_mid <= data_mid1;
        else if((data_mid2 >= data_mid1)&&(data_mid2 <= data_mid3)||(data_mid2 <= data_mid1)&&(data_mid2 >= data_mid3))
            mid_mid <= data_mid2;
        else
            mid_mid <= data_mid3;
    end

    always @(posedge clk)
    begin
        if((data_max1 <= data_max2)&&(data_max1 <= data_max3))
            min_max <= data_max1;
        else if((data_max2 <= data_max1)&&(data_max2 <= data_max3))
            min_max <= data_max2;
        else
            min_max <= data_max3;
    end

    reg [7:0] pixel_Data;
    always @(posedge clk)
    begin
        if((max_min >= mid_mid)&&(max_min <= min_max)||(max_min <= mid_mid)&&(max_min >= min_max))
            pixel_Data <= max_min;
        else if((mid_mid >= max_min)&&(mid_mid <= min_max)||(mid_mid <= max_min)&&(mid_mid >= min_max))
            pixel_Data <= mid_mid;
        else
            pixel_Data <= min_max;
    end

    reg [2:0] edge_flag;
    reg [2:0] img_href, img_vsync;
    always @(posedge clk) begin
        img_href  <= {img_href[1:0], matrix_img_href};
        img_vsync <= {img_vsync[1:0], matrix_img_vsync};
        edge_flag <= {edge_flag[1:0], matrix_top_edge_flag|matrix_bottom_edge_flag|matrix_left_edge_flag|matrix_right_edge_flag};
    end

    reg [7:0] matrix_p22_r [2:0];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_p22_r[0] <= 8'd0;
            matrix_p22_r[1] <= 8'd0;
            matrix_p22_r[2] <= 8'd0;
        end else begin
            matrix_p22_r[0] <= matrix_p22;
            matrix_p22_r[1] <= matrix_p22_r[0];
            matrix_p22_r[2] <= matrix_p22_r[1];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_gray <= 8'd0;
        end else begin
            if (edge_flag[2]) begin
                post_img_gray <= matrix_p22_r[2];
            end else begin
                post_img_gray <= pixel_Data;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync <= 1'b0;
            post_img_href  <= 1'b0;
        end else begin
            post_img_vsync <= img_vsync[2];
            post_img_href  <= img_href[2];
        end
    end

endmodule