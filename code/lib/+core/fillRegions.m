function BW = fillRegions(BW,idx)
% input  : BW, binary mask
%          idx, the object index in the mask which will be eliminated (filled)
%          
% output : BW, filled binary mask

    regions = bwconncomp(BW,8).PixelIdxList;
    
    for k = 1:length(idx)
        BW(regions{idx(k)}) = 0;
    end
end