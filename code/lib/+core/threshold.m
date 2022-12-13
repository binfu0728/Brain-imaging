function BW = threshold(img,s)
% input  : img, processed image, should be uint16 for speed
%          s, config
%          
% output : BW, binark mask after thresholding

    method = s.thres_method; %percentage or ostu
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
            BW       = img > t*num_bins;
        otherwise
            error('not supported method');
    end
end