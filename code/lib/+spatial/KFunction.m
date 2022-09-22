function K_r = KFunction(data,box,r)
    [DIST,rbox,lambda] = boxboundary(data,box);
    Nr = meanpoints_k(r,DIST,rbox);
    K_r = Nr/lambda;
end





