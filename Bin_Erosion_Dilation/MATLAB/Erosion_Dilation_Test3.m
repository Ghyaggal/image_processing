clear all; close all; clc;

% -------------------------------------------------------------------------
% Read PC image to Matlab
IMG1 = imread('shade_text2_bin.tif');
h = size(IMG1,1);         % 读取图像高度
w = size(IMG1,2);         % 读取图像宽度

IMG1 = ~im2bw(IMG1,0.5);
subplot(131);imshow(IMG1);title('【1】原图');

% -------------------------------------------------------------------------
IMG2 = bin_compare(IMG1,6);
subplot(132);imshow(IMG2);title('【2】阈值6比较');

% -------------------------------------------------------------------------
IMG3 = bin_compare(IMG2,3);
subplot(133);imshow(IMG3);title('【3】阈值3比较');

% -------------------------------------------------------------------------
% Generate image Source Data and Target Data
Bin2Bin_Data_Gen(IMG1,IMG3);

