function BW = LBDetection2D(img,s)
% detect large objects in a FoV
% input  : img, 2D raw image
%          s, config
% 
% output : BW, binary mask of the image for the large object
    s.k1_dog   = 2;
    s.k2_dog   = 16;
    img = image.multiDoG(img,s);
%     img = max(img,0);
    BW  = image.threshold(img,s);
    BW  = image.BWFilter(BW,img,s); %area and intensity post-filtering
end