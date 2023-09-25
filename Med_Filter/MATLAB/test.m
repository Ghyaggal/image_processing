clear all; close all; clc;

IMG1 = imread('Scart.jpg');
IMG1 = rgb2gray(IMG1);
[h, w] = size(IMG1);

subplot(221); imshow(IMG1); title('1');

IMG2 = imnoise(IMG1, 'salt & pepper', 0.01);
subplot(222); imshow(IMG2); title('2');

IMG3 = medfilt2(IMG2, [3, 3]);
subplot(223); imshow(IMG3); title('3');

IMG4 = Med_Filter(IMG2, 3);
subplot(224); imshow(IMG4); title('4');

Gray2Gray_Data_Gen(IMG2, IMG4);