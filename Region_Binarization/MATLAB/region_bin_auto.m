function Q=region_bin_auto(IMG, n, p)

[h, w] = size(IMG);
Q = zeros(h, w);
win = zeros(n, n);

bar = waitbar(0, "Speed of auto region binarization process...");

for i = 1 : h
    for j = 1 : w
        if (i<(n-1)/2+1 || i>h-(n-1)/2 || j<(n-1)/2+1 || j>w-(n-1)/2)
            Q(i, j) = 255;
        else
            win = IMG(i-(n-1)/2:i+(n-1)/2, j-(n-1)/2:j+(n-1)/2);
            thresh = floor(sum(sum(win))/(n*n) * p);
            if (win((n-1)/2+1, (n-1)/2+1) < thresh)
                Q(i, j) = 0;
            else
                Q(i, j) = 255;
            end
        end
    end
    waitbar(i/h);
end
close(bar);

Q=uint8(Q);


