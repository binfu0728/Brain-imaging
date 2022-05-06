function G_r = GFunction2D(data,box,r,dr)
    [DIST,rbox,lambda] = boxboundary(data,box);
    Nr  = meanpoints_g(r,DIST,rbox,dr);
    G_r = Nr./(lambda*2*pi*dr.*r);
end