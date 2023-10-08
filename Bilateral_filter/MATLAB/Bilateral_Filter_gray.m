function B=Bilateral_Filter_gray(I, n, sigma_d, sigma_r)

dim = size(I);
w = floor(n/2);

G1 = zeros(n, n);
for i = -w : w
    for j = -w : w
        G1(i+w+1, j+w+1) = exp(-(i^2 + j^2)/(2*sigma_d^2));
    end
end

temp = sum(G1(:));
G2 = G1/temp;
       
G3 = floor(G2*1024);

I = double(I);

h = waitbar(0, 'Speed of bilateral filter process...');
B = zeros(dim);
for i = 1 : dim(1)
    for j = 1 : dim(2)
        if (i<w+1 || i>dim(1)-w || j<w+1 || j>dim(2)-w)
            B(i, j) = I(i, j);
        else
            A = I(i-w:i+w, j-w:j+w);
            H = exp(-((A-I(i, j))/255).^2/(2*sigma_r^2));
            F = G3.*H;
            F2 = F/sum(F(:));
            B(i,j) = sum(F2(:).*A(:));
        end
    end
    waitbar(i/dim(1));
end
close(h);

I = uint8(I);
B = uint8(B);

       



        