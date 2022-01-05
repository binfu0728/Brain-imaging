function RW = RW2DKernel(sigma)
% Inverse Laplacian of Gaussian operator, also called as 2D Ricker wavelet,
% similar to difference of Gaussian kernel, frequently used as a blob detector
    x = (0:8*sigma) - 4*sigma; 
    y = x;
    [X,Y] = meshgrid(x,y);
    amplitude = 1.0 / (pi * sigma * 4);
    rr_ww = (X.^2+Y.^2)/(2.*sigma.^2);
    RW = amplitude*(1-rr_ww).*exp(-rr_ww);
end