function [sigImage,bgImage] =  extractBg(BW,img)
% input  : BW, binary mask
%          img, processed image
% 
% output : sigImage, the pure signal image
%          bgImage, the estimated background image, not a single value

    bgImage   = (1-BW).*img;   
    bgImage   = imfill(bgImage);
    sigImage  = max(img-bgImage,0); %pure signal intensity of the detected points.
end