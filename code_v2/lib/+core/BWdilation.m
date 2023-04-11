function [aps,BW] = BWdilation(BW)
% input  : BW, binary mask from the aggregate detection directly 
% 
% output : aps, the indices of each dilated binary objects in the binary mask
%          BW, the dilated binary mask to cover all oligomers for a better estimamtion of the intensity

    result_z = regionprops ('table',BW,'MinorAxisLength');
    aps      = bwconncomp(logical(BW)).PixelIdxList'; 
    shortD   = cat(1,result_z.MinorAxisLength);
    segments = false(size(BW,2),size(BW,1),length(ss)); %dilate oligomers seperately
    for p = 1:size(result_z,1)
        tmpt            = false(size(BW));
        tmpt(aps{p})    = 1;
        dilatedR        = ceil(shortD(p)/2); %dilate each binary object with its 1/2 minor axis length
        se              = strel('disk',dilatedR); %the binary structure for the dilation
        tmpt            = imdilate(tmpt,se); 
        segments(:,:,p) = tmpt;
        aps(p)          = bwconncomp(tmpt).PixelIdxList; %the indice for a dilated binary object
    end
    BW = max(segments,[],3); %the dilated binary mask (MIP all the dilations)
end