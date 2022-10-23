function [BW,rate] = findCoincidence(BW1,BW2,ref)
% input  : BW1, the binary mask for the first channel
%          BW2, the binary mask for the second channel
%          ref, reference channel, the one on the denominator
% 
% output : BW, the colocalized binary mask
%          rate, coincidence rate

    m1 = cat(3,BW1,BW2);
    BW = m1(:,:,ref);

    if sum(BW1,'all') ~= 0 && sum(BW2,'all') ~= 0 %if there is at least one object in each channel
        [rate,test] = analyze.coincidence(m1,ref);
        regions     = bwconncomp(BW).PixelIdxList;
        if ~isempty(regions)
            idx = find(test<=0.1);
            BW  = image.fillRegions(BW,idx);
        end
    else
        rate = 0;
        BW   = false(size(BW1));
    end
end