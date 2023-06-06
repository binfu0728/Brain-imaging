function [row,col] = ind2sub2d(imsz,ind)
    row = mod(ind,imsz(2));
    col = (ind-row)/imsz(2) + 1;
end