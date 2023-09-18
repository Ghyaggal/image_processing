clear all; close all; clc;

IMG1 = imread('gsls_test1.tif');

h = size(IMG1, 1);
w = size(IMG1, 2);

subplot(121); imshow(IMG1); title('origin');

%------------------------------------------------

THRESHOLD = 127;
E = 7;
IMG2 = zeros(h, w);
for i = 1 : h
    for j = 1 : w
        IMG2(i, j) = (1./(1+(THRESHOLD./double(IMG1(i, j))).^E)) * 255;
    end
end
IMG2 = uint8(IMG2);
subplot(122); imshow(IMG2); title('enhanced');


Gray2Gray_Data_Gen(IMG1,IMG2);