function largeM = largeFeatureKernel(img)
    img1   = imgaussfilt3(img,2) - imgaussfilt3(img,30); 
    largeM = false(size(img));
    largeM(img1>250) = 1; %450 is determined from 2-level otsu and given LBs are all having similar values (saturated)
end