function BW = thresholding(img,s)
% input type : double
% output type: binary
    thres = s.thres;
    num_bins          = 2^16;
    counts            = imhist(img,num_bins);
    p                 = counts / sum(counts);
    omega             = cumsum(p);
    
    idx               = find(omega>thres);
    t                 = (idx(1) - 1) / (num_bins - 1);
    BW                = imbinarize(img,t);
    BW                = imfill(BW,'holes'); %binary mask
end