function largeM = LBDetection(img)
    img1   = imgaussfilt3(img,2) - imgaussfilt3(img,30); % why 2 and 30 ? sigma is the width of gaussian kernel
    largeM = false(size(img));
    largeM(img1>450) = 1; %450 is determined from 2-level otsu and given LBs are all having similar values (saturated)
end