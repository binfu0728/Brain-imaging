function [row,col] = ind2sub2d(imsz,ind)
    row = mod(ind,imsz(1));
    col = (ind-row)/imsz(1) + 1;
end