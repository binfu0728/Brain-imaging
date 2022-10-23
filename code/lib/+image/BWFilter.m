function BW = BWFilter(BW,img,s)
% input  : BW, binary mask
%          img, the processed image
%          s, config
% 
% output : BW, filtered binary mask

    ss     = regionprops('table',BW,img,'Area','MeanIntensity');
    area   = ss.Area;
    intens = ss.MeanIntensity;
    switch length(s.area)
        case 1 %area and intensity post-filtering
            idx = union(find(area<s.area),find(intens<s.intens));
        case 2 %area and intensity post-filtering
            idx = union(find(area<s.area(1) | area>s.area(2)),find(intens<s.intens));
        otherwise
            error('area size not supported');
    end
    BW     = image.fillRegions(BW,idx);
end