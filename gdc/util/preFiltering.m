function [img_upsampled,img_processed] = preFiltering(img,s) 
% input type : double
% output type: uint16
    upsampling = s.upsampling;
    gsize      = s.gaussian_size;
    bsize_l    = s.bpass_size_l;
    bsize_h    = s.bpass_size_h;
    order      = s.bpass_order;
    mode       = s.mode;
    
    img_upsampled = normalize16(imresize(img,upsampling,'bicubic'));
    img_processed = imgaussfilt(img_upsampled,gsize);

    switch mode
        case 'IF'
            img_processed = img_upsampled - img_processed;
        case 'IF-olig'
            img_processed = img_upsampled - img_processed;    
        case 'DAB'
            img_processed = img_processed - img_upsampled;
        otherwise
            error('wrong');    
    end
    
    for i = 1:order
        img_processed = normalize16(bandpass(img_processed,bsize_l,bsize_h));
    end
    
    if strcmp(mode,'IF-olig')
        h = RW2DKernel(upsampling);  %create a convolution kernel 
        i = conv2(img_processed,h,'same'); %convolution and top-hat filter(rolling-ball filter)
        i(i<0)   = 0;
        img_processed = normalize16(i);
    end
end