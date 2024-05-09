function largeM = largeFeatureKernel(img,thres)
% find large features in an image
% input  : img, original image
%          thres, threshold for determining features, determined by otsu's threshold
% output : largeM, binary mask for the large feature
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk

    img1   = imgaussfilt3(img,2) - imgaussfilt3(img,60); 
    largeM = false(size(img));
    largeM(img1>thres) = 1; %450 is determined from 2-level otsu and given LBs are all having similar values (saturated)
end