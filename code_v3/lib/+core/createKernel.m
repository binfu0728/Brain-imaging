function [k1,k2,k3] = createKernel(k1,k2,k3)
% input:  k1, double, sigma for the background suppression
%         k2, double, sigma for smoothing and the radiality check
%         k3, double, sigma for the feature enhancement
% output: k1, double matrix, the kernel for the background suppression
%         k2, double matrix, the kernel for smoothing and the radiality check
%         k3, double matrix, the kernel for the feature enhancement

    k1 = images.internal.createGaussianKernel([k1,k1], [2*ceil(2*k1) + 1,2*ceil(2*k1) + 1]);
    k2 = images.internal.createGaussianKernel([k2,k2], [2*ceil(2*k2) + 1,2*ceil(2*k2) + 1]);
    k3 = core.rickerWavelet([k3,k3]);
end