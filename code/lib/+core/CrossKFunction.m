function K_r = CrossKFunction(data1,data2,box,r)
%data 1 is ref
    [DIST,rbox,~] = boxboundary(data1,box);
    Nr = meanpoints_k(r,DIST,rbox);
    [DIST,rbox,~] = boxboundary(data2,box);
    Mr = meanpoints_k(r,DIST,rbox);
    K_r = Mr./Nr;
end