function RGB2YCbCr_Data_Gen(img_RGB, img_YCbCr)

    h1 = size(img_RGB,1);        
    w1 = size(img_RGB,2);         
    h2 = size(img_YCbCr,1);      
    w2 = size(img_YCbCr,2);       


bar = waitbar(0, 'Speed of source data generating ...');
fid = fopen('./img_RGB.dat', 'wt');

for row = 1 : h1
    r = lower(dec2hex(img_RGB(row, :, 1), 2))';
    g = lower(dec2hex(img_RGB(row, :, 2), 2))';
    b = lower(dec2hex(img_RGB(row, :, 3), 2))';
    str_data_temp = [];
    for col = 1 : w1
        str_data_temp = [str_data_temp, r(col*2-1:col*2), '', g(col*2-1:col*2), '', b(col*2-1:col*2), ''];
    end
    str_data_temp = [str_data_temp, 10];
    fprintf(fid, '%s', str_data_temp);
    waitbar(row/h1);
end

fclose(fid);
close(bar);


bar = waitbar(0, 'Speed of target data generating ...');
fid = fopen('./img_YCbCr.dat', 'wt');

for row = 1 : h2
    r = lower(dec2hex(img_YCbCr(row, :, 1), 2))';
    g = lower(dec2hex(img_YCbCr(row, :, 2), 2))';
    b = lower(dec2hex(img_YCbCr(row, :, 3), 2))';
    str_data_temp = [];
    for col = 1 : w2
        str_data_temp = [str_data_temp, r(col*2-1:col*2), ' ', g(col*2-1:col*2), ' ', b(col*2-1:col*2), ' '];
    end
    str_data_temp = [str_data_temp, 10];
    fprintf(fid, '%s', str_data_temp);
    waitbar(row/h2);
end

fclose(fid);
close(bar);