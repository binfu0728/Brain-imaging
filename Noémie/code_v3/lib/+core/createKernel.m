function [k1,k2] = createKernel(k1,k2)
% input:  k1, double, sigma for the background suppression and the radiality check
%         k3, double, sigma for the feature enhancement
% output: k1, double matrix, the kernel for the background suppression and the radiality check
%         k3, double matrix, the kernel for the feature enhancement

    k1 = images.internal.createGaussianKernel([k1,k1], [2*ceil(2*k1) + 1, 2*ceil(2*k1) + 1]);

    %kernel_size = [2*ceil(2*k1) + 1, 2*ceil(2*k1) + 1]; 
    %k1 = fspecial('gaussian', kernel_size, k1);  % more common function

    k2 = core.rickerWavelet([k2,k2]);
end