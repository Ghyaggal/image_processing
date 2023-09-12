clear all; close all; clc;

IMG_1 = imread('Scart.jpg');
h     = size(IMG_1, 1); 
w     = size(IMG_1, 2);

subplot(221); imshow(IMG_1); title('RGB Image');

% Y = (R*76 + G*150 + B*29) >> 8
% Cb = (-R*43 - G*84 + B*128 + 32768) >> 8
% Cr = (R*128 - G*107 - B*20 + 32768) >> 8

IMG_1 = double(IMG_1);
IMG_YCbCr = zeros(h, w, 3);

for i = 1 : h
    for j = 1 : w
        IMG_YCbCr(i, j, 1) = bitshift((IMG_1(i, j, 1)*76 + IMG_1(i, j, 2)*150 + IMG_1(i, j, 3)*29), -8);
        IMG_YCbCr(i, j, 2) = bitshift((-IMG_1(i, j, 1)*43 - IMG_1(i, j, 2)*84 + IMG_1(i, j, 3)*128 + 32768), -8);
        IMG_YCbCr(i, j, 3) = bitshift((IMG_1(i, j, 1)*128 - IMG_1(i, j, 2)*107 - IMG_1(i, j, 3)*20 + 32768), -8);
    end
end

IMG_YCbCr = uint8(IMG_YCbCr);

subplot(222); imshow(IMG_YCbCr(:,:,1)); title('Y Channel');
subplot(223); imshow(IMG_YCbCr(:,:,2)); title('Cb Channel');
subplot(224); imshow(IMG_YCbCr(:,:,3)); title('Cr Channel');

RGB2YCbCr_Data_Gen(IMG_1, IMG_YCbCr);