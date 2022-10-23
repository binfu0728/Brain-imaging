function [coincidence_rate,test] = coincidence(masks,refChannel)
% input  : masks, 3D matrix with 2 masks from 2 channels (512x512x2)
%          refChannel, the channel on the denominator
% 
% output : coincidence_rate, single value from 2 channel comparison
%          test, coincidence_rate for each binary object

    m1 = masks(:,:,1);
    m2 = masks(:,:,2);
    coincidence_mask = m1&m2;
    ref_mask         = masks(:,:,refChannel);
    regions          = bwconncomp(ref_mask).PixelIdxList;

    if ~isempty(regions)
        for j = 1:length(regions)
            sumREF(j) =  sum(ref_mask(regions{j}));
            sumAND(j) =  sum(coincidence_mask(regions{j}));
        end
        overlap = sumAND./sumREF;
        coincidence_rate = length(find(overlap>0.1))/length(regions);
    else 
        overlap = 0;
        coincidence_rate = 0;
    end
    test = overlap;
end