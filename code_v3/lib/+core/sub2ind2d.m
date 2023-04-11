function ind = sub2ind2d(size,row,col)
    ind = (col-1).*size(2) + row;
end