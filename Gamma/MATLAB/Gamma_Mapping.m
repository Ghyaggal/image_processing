clear all; close all; clc;

IMG1 = imread('Scart.jpg');
IMG1 = rgb2gray(IMG1);

h = size(IMG1, 1);
w = size(IMG1, 2);

subplot(221); imshow(IMG1); title('ԭͼ');

IMG2 = zeros(h, w);
for i = 1 : h
    for j = 1 : w
        IMG2(i, j) = (255/255.^2.2)*double(IMG1(i, j)).^2.2;
    end
end

IMG2 = uint8(IMG2);
subplot(222); imshow(IMG2); title('Gamma=2.2');

IMG3 = zeros(h, w);
for i = 1 : h
    for j = 1 : w
        IMG3(i, j) = (255/255.^(1/2.2))*double(IMG1(i, j)).^(1/2.2);
    end
end

IMG3 = uint8(IMG3);
subplot(223); imshow(IMG3); title('Gamma=1/2.2');


THRESHOLD = 127;
E = 4;
IMG4 = zeros(h, w);
for i = 1 : h
    for j = 1 : w
        IMG4(i, j) = (1./(1+(THRESHOLD./double(IMG1(i, j))).^E))*255;
    end
end

IMG4 = uint8(IMG4);
subplot(224); imshow(IMG4); title('enhanced');

Gray2Gray_Data_Gen(IMG1, IMG2)
