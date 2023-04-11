function h = rickerWavelet(sigma)
% input:  sigma, double, the sigma of ricker wavelet
% output: h,     double matrix, 2D ricker wavelet
    amplitude   = 2 / (sqrt(3*max(sigma)) * pi^(1/4));
    x           = -ceil(4*sigma(2)) : ceil(4*sigma(2));
    y           = -ceil(4*sigma(2)) : ceil(4*sigma(2));
    [X,Y]       = meshgrid(x,y);
    common_term = (X.^2/(2.*sigma(2).^2)) + (Y.^2/(2.*sigma(1).^2));
    h = amplitude*(1-common_term).*exp(-common_term);
end