clear all; close all; clc;

IMG1 = imread('gsls_test1.tif');
h = size(IMG1,1);      
w = size(IMG1,2);     

subplot(141);imshow(IMG1);title(' 1 ');

IMG2 = global_bin_user(IMG1,128);
subplot(142);imshow(IMG2);title(' 2 Global-128');

mean = floor(sum(sum(IMG1))/(h*w));
IMG3 = global_bin_user(IMG1, mean);
subplot(143);imshow(IMG3);title(' 3 Global');

thresh = floor(graythresh(IMG1)*256);
IMG3 = global_bin_user(IMG1, thresh);
subplot(144);imshow(IMG3);title(' 4 Global-OTSU');
