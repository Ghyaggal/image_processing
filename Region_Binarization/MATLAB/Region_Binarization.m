clear all; close all; clc;


IMG1 = imread('shade_text.jpg');  
IMG1 = rgb2gray(IMG1);

h = size(IMG1,1);       
w = size(IMG1,2);      

subplot(131);imshow(IMG1);title(' 1 ');

IMG2 = region_bin_auto(IMG1,5,1);
subplot(132);imshow(IMG2);title(' 2 Region 1');

IMG3 = region_bin_auto(IMG1,5,0.9);
subplot(133);imshow(IMG3);title(' 3 Region 0.9');

Gray2Gray_Data_Gen(IMG1,IMG3);


