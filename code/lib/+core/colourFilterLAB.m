function [BW,param] = colourFilterLAB(i,init,rate,postprocessing,percentage)
    mask_pre = zeros(size(i,1),size(i,2));
    mask_cur = zeros(size(i,1),size(i,2));
    LMean = init(1);
    aMean = init(2);
    bMean = init(3);
    thres = init(4);

    lab_Image = applycform(im2double(i), makecform('srgb2lab'));
    count = 1;
    while (sum(mask_cur,'all') < percentage*numel(lab_Image(:,:,1))) && (count < 20)
        deltaL = lab_Image(:,:,1) - LMean;
        deltaa = lab_Image(:,:,2) - aMean;
        deltab = lab_Image(:,:,3) - bMean;
        deltaE = sqrt(deltaL.^2 + deltaa.^2 + deltab.^2);
        mask_pre = mask_cur;
        mask_cur = deltaE <= thres;
        [LMean, aMean, bMean] = GetMeanLABValues(lab_Image(:,:,1), lab_Image(:,:,2), lab_Image(:,:,3), mask_cur);
        LMean = LMean*rate(1);
        aMean = aMean*rate(1);
        bMean = bMean*rate(1);
        meanMaskedDeltaE  = mean(deltaE(mask_cur));
        stDevMaskedDeltaE = std(deltaE(mask_cur));
        thres = meanMaskedDeltaE + rate(2)*stDevMaskedDeltaE; 
        
        if postprocessing
            mask_cur = imclose(mask_cur,strel('disk',3));
            mask_cur = imfill(mask_cur,'holes');
            mask_cur = imopen(mask_cur,strel('disk',2));
            mask_cur = bwareaopen(mask_cur,40);
        end

        count = count + 1;
%         f = figure;
%         imshow(i);
%         visual.plotBinaryMask(f,mask_cur,[0.8500 0.3250 0.0980]);
    end
    BW = mask_pre;
    param = [LMean, aMean, bMean , thres] ; 
end

function [LMean, aMean, bMean] = GetMeanLABValues(LChannel, aChannel, bChannel, mask)
    LVector = LChannel(mask); % 1D vector of only the pixels within the masked area.
    LMean = mean(LVector);
    aVector = aChannel(mask); % 1D vector of only the pixels within the masked area.
    aMean = mean(aVector);
    bVector = bChannel(mask); % 1D vector of only the pixels within the masked area.
    bMean = mean(bVector);
end