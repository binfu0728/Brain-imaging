function [k1,k2] = createKernel(k1,k2)
% create kernel for blob enhancing and backgroudn supression
% input:  k1, double, sigma for the background suppression and the radiality check
%         k2, double, sigma for the feature enhancement
% output: k1, double matrix, the kernel for the background suppression and the radiality check
%         k2, double matrix, the kernel for the feature enhancement
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk

    k1 = images.internal.createGaussianKernel([k1,k1], [2*ceil(2*k1) + 1,2*ceil(2*k1) + 1]);
    k2 = rickerWavelet([k2,k2]);
end

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