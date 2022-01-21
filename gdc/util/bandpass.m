function res = bandpass(image_array,lnoise,lobject)
% 
% ; NAME:
% ;               bpass
% ; PURPOSE:
% ;               Implements a real-space bandpass filter which suppress 
% ;               pixel noise and long-wavelength image variations while 
% ;               retaining information of a characteristic size.
% ;
% ; CATEGORY:
% ;               Image Processing
% ; CALLING SEQUENCE:
% ;               res = bpass( image, lnoise, lobject )
% ; INPUTS:
% ;               image:  The two-dimensional array to be filtered.
% ;               lnoise: Characteristic lengthscale of noise in pixels.
% ;                       Additive noise averaged over this length should
% ;                       vanish. MAy assume any positive floating value.
% ;               lobject: A length in pixels somewhat larger than a typical
% ;                       object. Must be an odd valued integer.
% ; OUTPUTS:
% ;               res:    filtered image.
% ; PROCEDURE:
% ;               simple 'wavelet' convolution yields spatial bandpass filtering.
% ; NOTES:
% ; MODIFICATION HISTORY:
% ;               Written by David G. Grier, The University of Chicago, 2/93.
% ;               Greatly revised version DGG 5/95.
% ;               Added /field keyword JCC 12/95.
% ;               Memory optimizations and fixed normalization, DGG 8/99.
%                 Converted to Matlab by D.Blair 4/2004-ish
%                 Fixed some bugs with conv2 to make sure the edges are
%                 removed D.B. 6/05
%                 Removed inadvertent image shift ERD 6/05
%                 Added threshold to output.  Now sets all pixels with
%                 negative values equal to zero.  Gets rid of ringing which
%                 was destroying sub-pixel accuracy, unless window size in
%                 cntrd was picked perfectly.  Now centrd gets sub-pixel
%                 accuracy much more robustly ERD 8/24/05
% ;
% ;       This code 'bpass.pro' is copyright 1997, John C. Crocker and 
% ;       David G. Grier.  It should be considered 'freeware'- and may be
% ;       distributed freely in its original form when properly attributed.
% 
    normalize = @(x) x/sum(x);

    image_array = double(image_array);

    if lnoise == 0
      gaussian_kernel = 1;
    else      
      gaussian_kernel = normalize(...
        exp(-((-ceil(5*lnoise):ceil(5*lnoise))/(2*lnoise)).^2));
    end

    if lobject  
      boxcar_kernel = normalize(...
          ones(1,length(-round(lobject):round(lobject))));
    end

    gconv = conv2(image_array',gaussian_kernel','same');
    gconv = conv2(gconv',gaussian_kernel','same');

    if lobject
      bconv = conv2(image_array',boxcar_kernel','same');
      bconv = conv2(bconv',boxcar_kernel','same');

      filtered = gconv - bconv;
    else
      filtered = gconv;
    end

    % Zero out the values on the edges to signal that they're not useful.     
%     lzero = max(lobject,ceil(5*lnoise));
% 
%     filtered(1:(round(lzero)),:) = 0;
%     filtered((end - lzero + 1):end,:) = 0;
%     filtered(:,1:(round(lzero))) = 0;
%     filtered(:,(end - lzero + 1):end) = 0;

%     res = filtered;
    filtered(filtered < 0) = 0;
    res = filtered;
end