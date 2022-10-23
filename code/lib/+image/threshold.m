function BW = threshold(img,s)
% input  : img, processed image
%          s, config
%          
% output : BW, binark mask after thresholding

    method = s.thres_method;
    switch method
        case 'otsu'
            level = multithresh(img,s.ostu_num);
            BW    = logical(imquantize(img,level)-1);
        case 'percentage'
            thres    = s.percent;
            img      = uint16(img);
            num_bins = 2^16;
            counts   = imhist(img,num_bins);
            p        = counts / sum(counts);
            omega    = cumsum(p);
            
            idx      = find(omega>thres);
            t        = (idx(1) - 1) / (num_bins - 1);
            BW       = imbinarize(img,t);
        otherwise
            error('not supported method');
    end
    BW = imfill(BW,'holes');
end