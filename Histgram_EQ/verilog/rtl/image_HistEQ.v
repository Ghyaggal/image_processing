module image_HistEQ (
    clk,
    rst_n
    );

    input clk;
    input rst_n;


    hist_stat hist_stat_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .img_vsync              (),
    .img_href               (),
    .img_gray               (),
    .pixel_level            (),
    .pixel_level_acc_num    (),
    .pixel_level_valid      ()
    );

    histEQ_proc histEQ_proc_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .pixel_level            (),
    .pixel_level_acc_num    (),
    .pixel_level_valid      (),
    .histEQ_start_flag      (),
    .per_img_vsync          (),
    .per_img_href           (),
    .per_img_gray           (),
    .post_img_vsync         (),
    .post_img_href          (),
    .post_img_gray          ()
    );



endmodule