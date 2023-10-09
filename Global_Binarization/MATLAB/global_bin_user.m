
function Q=global_bin_user(IMG, threshold)

[h, w] = size(IMG);
Q = zeros(h, w);

for i = 1 : h
    for j = 1 : w
        if (IMG(i, j) < threshold)
            Q(i, j) = 0;
        else
            Q(i, j) = 255;
        end
    end
end

Q = uint8(Q);
