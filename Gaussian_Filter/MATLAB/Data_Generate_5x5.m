clear all; close all; clc;

sigma = 3;
G1 = zeros(5, 5);
for i = -2 : 2
    for j = -2 : 2
        G1(i+3, j+3) = exp(-(i^2+j^2)/(2*sigma^2));
    end
end

temp = sum(sum(G1));
G2 = G1/temp;
G3 = floor(G2*1024);

