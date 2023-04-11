function G_r = GFunction3D(data,box,r,dr)
    [DIST,rbox,lambda] = boxboundary(data,box);
    Nr  = meanpoints_g(r,DIST,rbox,dr);
    G_r = Nr./(lambda*4*pi*dr.*(r.^2));
end