function BW = LBDetection2D(img,s)
% detect large objects in a FoV
% input  : img, 2D raw image
%          s, config
% 
% output : BW, binary mask of the image for the large object

    img1 = imgaussfilt(img,s.k1_dog) - imgaussfilt(img,s.k2_dog);
    BW   = core.threshold(img1,s);

    t = regionprops('table',BW,img,'PixelValues'); %area and intensity post-filtering
    counts = cell2mat(cellfun(@(x) findPercentileMean(x,0.05),t.PixelValues,'UniformOutput',false));
    if ~isempty(counts)
        idx1  = find(counts<2^s.bit*0.5);
        BW = core.fillRegions(BW,idx1);
    end
end

function m = findPercentileMean(counts,percentile)
    counts  = sort(counts(:));
    highend = round(length(counts)*(1-percentile));
    counts  = counts(highend:end);
    m       = mean(counts);
end