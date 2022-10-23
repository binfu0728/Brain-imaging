function [aps,BW] = BWdilation(BW)
    result_z = regionprops ('table',BW,'MinorAxisLength');
    aps      = bwconncomp(logical(BW)).PixelIdxList'; 
    shortD   = cat(1,result_z.MinorAxisLength);
    segments = false(size(BW,2),size(BW,1),length(ss));
    for p = 1:size(result_z,1)
        tmpt            = false(size(BW));
        tmpt(aps{p})    = 1;
        dilatedR        = ceil(shortD(p)/2);
        se              = strel('disk',dilatedR);
        tmpt            = imdilate(tmpt,se); 
        segments(:,:,p) = tmpt;
        aps(p)          = bwconncomp(tmpt).PixelIdxList;
    end
    BW = max(segments,[],3);
end