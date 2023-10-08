clear all; close all; clc;

% -------------------------------------------------------------------------
% Read PC image to Matlab
IMG1= imread('girl.jpg');    % ¶ÁÈ¡jpgÍ¼Ïñ

% -------------------------------------------------------------------------
subplot(121);imshow(IMG1);title('¡¾1¡¿Ô­Í¼');

IMG2(:,:,1) = Bilateral_Filter_gray(IMG1(:,:,1), 3, 3, 0.1);  
IMG2(:,:,2) = Bilateral_Filter_gray(IMG1(:,:,2), 3, 3, 0.1);  
IMG2(:,:,3) = Bilateral_Filter_gray(IMG1(:,:,3), 3, 3, 0.1);  
subplot(122);imshow(IMG2);title('¡¾2¡¿Ë«±ßÂË²¨3*3, sigma = [3, 0.1]');