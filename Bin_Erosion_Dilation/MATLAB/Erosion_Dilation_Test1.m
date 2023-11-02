clear all; close all; clc;

% -------------------------------------------------------------------------
% Read PC image to Matlab
IMG1 = imread('shade_text2_bin.tif');

h = size(IMG1,1);        
w = size(IMG1,2);        

IMG1 = ~im2bw(IMG1,0.5);
subplot(131);imshow(IMG1);title('1');

% -------------------------------------------------------------------------
IMG2 = bin_erosion(IMG1);
subplot(132);imshow(IMG2);title('2');

% -------------------------------------------------------------------------
IMG3 = bin_dilation(IMG2);
subplot(133);imshow(IMG3);title('3');

