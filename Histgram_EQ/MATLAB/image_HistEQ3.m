clear all; close all; clc;

IMG1 = imread("Scart.jpg");
IMG1 = rgb2gray(IMG1);
h = size(IMG1, 1);
w = size(IMG1, 2);

NumPixel = zeros(1, 256);

for i = 1 : h
    for j = 1 : w
        NumPixel(IMG1(i, j) + 1) = NumPixel(IMG1(i, j) + 1) + 1;
    end
end

CumPixel = zeros(1, 256);

for i = 1:256
    if i == 1
        CumPixel(i) = NumPixel(i);
    else
        CumPixel(i) = CumPixel(i-1) + NumPixel(i);
    end
end

IMG2 = zeros(h, w);

for i = 1:h
    for j = 1 : w 
        IMG2(i, j) = CumPixel(IMG1(i, j) + 1) / 980;
    end
end
IMG2 = uint8(IMG2);

subplot(231), imshow(IMG1); title('Original Image');
subplot(232), imhist(IMG1); title('Original Hist');

NumPixel2 = zeros(1, 256);

for i = 1 : h
    for j = 1 : w
        NumPixel2(IMG2(i, j) + 1) = NumPixel2(IMG2(i, j) + 1) + 1;
    end
end

CumPixel2 = zeros(1, 256);

for i = 1:256
    if i == 1
        CumPixel2(i) = NumPixel2(i);
    else
        CumPixel2(i) = CumPixel2(i-1) + NumPixel2(i);
    end
end

subplot(234), imshow(IMG2); title('Manual HistEQ Image');
subplot(235), imhist(IMG2); title('Manual HistEQ Hist');


subplot(233), bar(CumPixel); title('Original');
subplot(236), bar(CumPixel2); title('HistEQ');
