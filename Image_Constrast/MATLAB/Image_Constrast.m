clear all; close all; clc;

IMG1 = zeros(256, 256);

for m = 1 : 256
    IMG1(m, m) = m;
    for n = (m+1) : 256
        IMG1(m, n) = n-1;
        IMG1(n, m) = IMG1(m, n)-1;
    end
end

subplot(121); imshow(uint8(IMG1)); title('origin image');

%---------------------------------------------------------------
THRESHOLD = 127;
E = 5;
IMG2 = zeros(256, 256);
for i = 1 : 256
    for j = 1 : 256
        IMG2(i, j) = (1./(1+(THRESHOLD./IMG1(i, j)).^E)) * 255;
    end
end
IMG2 = uint8(IMG2);
subplot(122); imshow(uint8(IMG2)); title('enhanced image');

figure;
subplot(121); imhist(uint8(IMG1)); title('origin');
subplot(122); imhist(uint8(IMG2)); title('enhanced');

