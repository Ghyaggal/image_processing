clear all; close all; clc;

IMG1 = imread("gsls_test1.tif");
h = size(IMG1, 1);
w = size(IMG1, 2);

subplot(221), imshow(IMG1), title("Original Image");
subplot(223), imhist(IMG1), title("Original Hist");

IMG2 = zeros(h, w);
IMG2 = histeq(IMG1);

subplot(222), imshow(IMG2), title("Original Image");
subplot(224), imhist(IMG2), title("Original Hist");