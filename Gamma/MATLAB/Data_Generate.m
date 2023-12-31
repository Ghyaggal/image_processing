clear all; close all; clc;

% ----------------------------------------------------------------------
fp_gray = fopen('.\Curve_Gamma_2P2.v','w');
fprintf(fp_gray,'//Curve of Gamma = 2.2\n');
fprintf(fp_gray,'module Curve_Gamma_2P2\n');
fprintf(fp_gray,'(\n');
fprintf(fp_gray,'   input\t\t[7:0]\tPre_Data,\n');
fprintf(fp_gray,'   output\treg\t[7:0]\tPost_Data\n');
fprintf(fp_gray,');\n\n');
fprintf(fp_gray,'always@(*)\n');
fprintf(fp_gray,'begin\n');
fprintf(fp_gray,'\tcase(Pre_Data)\n');
Gray_ARRAY = zeros(1,256);
for i = 1 : 256
    Gray_ARRAY(1,i) = (255/255.^2.2)*(i-1).^2.2;
    Gray_ARRAY(1,i) = uint8(Gray_ARRAY(1,i));
    fprintf(fp_gray,'\t8''h%s : Post_Data = 8''h%s; \n',dec2hex(i-1,2), dec2hex(Gray_ARRAY(1,i),2));
end
fprintf(fp_gray,'\tendcase\n');
fprintf(fp_gray,'end\n');
fprintf(fp_gray,'\nendmodule\n');   
fclose(fp_gray);

reshape(Gray_ARRAY,16,16)