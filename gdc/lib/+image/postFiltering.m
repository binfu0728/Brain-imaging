function [BW,idx] = postFiltering(BW,img,percentage,method,upsampling)
% input type: uint16
    if nargin<5
       upsampling = nan; 
    end
    
    CC         = bwconncomp(BW);
    regions    = CC.PixelIdxList; 
    
    switch method
        case 'area'
            s          = regionprops('table',BW,'Area');
            areas      = s.Area;
            sorting    = image.normalize16(areas);
        case 'intensity'
            sigImage        = abs(img-imfill(uint16((1-BW)).*img));
            avg_intensity   = zeros(length(regions),1);
            for k = 1:length(regions)
                avg_intensity(k)  = mean(sigImage(regions{k}));
            end
            sorting         = image.normalize16(avg_intensity);
        case 'structural_open'
            se = strel('disk',upsampling);
            BW = imopen(BW,se); 
            return
        otherwise
            error('wrong method');
    end
    
    num_bins     = 2^16;
    counts       = imhist(sorting,num_bins);
    p            = counts / sum(counts);
    omega        = cumsum(p);

    idx          = find(omega>percentage);
    idx          = find(sorting<idx(1));
    
    for k = 1:length(idx)
        BW(regions{idx(k)}) = 0;
    end
end