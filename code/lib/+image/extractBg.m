function [sigImage,bgImage] =  extractBg(BW,img)
% input  : BW, binary mask
%          img, processed image
% 
% output : sigImage, the pure signal image
%          bgImage, the estimated background image, not a single value

    tt = imresize(double(BW),1/4,'bilinear');
    tt = max(tt,0);
    bgImage   = (1-tt).*img; %img - signal image = pure background 
    bgImage   = imfill(bgImage); %use flood fill algorithm to estimate the background intensity within the signal region
    sigImage  = max(img-bgImage,0); %pure signal intensity of the detected points.
    sigImage  = imresize(sigImage,4);
end