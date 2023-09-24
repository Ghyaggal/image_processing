function Q=avg_filter(IMG, n)

[h, w]  = size(IMG);
win     = zeros(n, n);
Q       = zeros(h, w);

for i= 1 : h
    for j = 1 : w
        if ((i<(n-1)/2+1) || (i>h-(n-1)/2) || (j<(n-1)/2+1) || (j>w-(n-1)/2))
            Q(i, j) = IMG(i, j);
        else
            win = IMG(i-(n-1)/2:i+(n-1)/2, j-(n-1)/2:j+(n-1)/2);
            Q(i, j) = sum(sum(win)) / (n*n);
        end
    end
end
Q = uint8(Q);
