module RGB_to_YCbCr (
    clk,
    rst_n,
    per_img_vsync,
    per_img_href,
    per_img_red,
    per_img_green,
    per_img_blue,
    post_img_vsync,
    post_img_href,
    post_img_Y,
    post_img_Cb,
    post_img_Cr
    );

    input clk;
    input rst_n;
    input per_img_vsync;
    input per_img_href;
    input [7:0] per_img_red;
    input [7:0] per_img_green;
    input [7:0] per_img_blue;

    output post_img_vsync;
    output post_img_href;
    output [7:0] post_img_Y;
    output [7:0] post_img_Cb;
    output [7:0] post_img_Cr;

    reg [15:0] mult_red_1,  mult_red_2, mult_red_3;
    reg [15:0] mult_green_1,  mult_green_2, mult_green_3;
    reg [15:0] mult_blue_1,  mult_blue_2, mult_blue_3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_red_1   <= 16'd0;
            mult_red_2   <= 16'd0;
            mult_red_3   <= 16'd0;
            mult_green_1 <= 16'd0;
            mult_green_2 <= 16'd0;
            mult_green_3 <= 16'd0;
            mult_blue_1  <= 16'd0;
            mult_blue_2  <= 16'd0;
            mult_blue_3  <= 16'd0;
        end else begin
            mult_red_1   <= per_img_red*76;
            mult_red_2   <= per_img_red*43;
            mult_red_3   <= per_img_red*128;
            mult_green_1 <= per_img_green*150;
            mult_green_2 <= per_img_green*84;
            mult_green_3 <= per_img_green*107;
            mult_blue_1  <= per_img_blue*29;
            mult_blue_2  <= per_img_blue*128;
            mult_blue_3  <= per_img_blue*20;
        end
    end

    reg [15:0] Y_r, Cb_r, Cr_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Y_r     <= 16'd0;
            Cb_r    <= 16'd0;
            Cr_r    <= 16'd0;
        end else begin
            Y_r     <= mult_red_1 + mult_green_1 + mult_blue_1;
            Cb_r    <= 32768 - mult_red_2 - mult_green_2 + mult_blue_2;
            Cr_r    <= 32768 + mult_red_3 - mult_green_3 - mult_blue_3;
        end
    end

    reg [7:0] Y, Cb, Cr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Y       <= 8'd0;
            Cb      <= 8'd0;
            Cr      <= 8'd0;
        end else begin
            Y       <= Y_r[15:8];
            Cb      <= Cb_r[15:8];
            Cr      <= Cr_r[15:8];
        end
    end    

    reg [2:0] per_img_vsync_r, per_img_href_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_img_vsync_r <= 3'd0;
            per_img_href_r  <= 3'd0;
        end else begin
            per_img_vsync_r <= {per_img_vsync_r[1:0], per_img_vsync};
            per_img_href_r  <= {per_img_href_r[1:0], per_img_href};
        end
    end

    assign post_img_vsync = per_img_vsync_r[2];
    assign post_img_href  = per_img_href_r[2];
    assign post_img_Y     = post_img_href ? Y  : 8'd0;
    assign post_img_Cb    = post_img_href ? Cb : 8'd0;
    assign post_img_Cr    = post_img_href ? Cr : 8'd0;

endmodule