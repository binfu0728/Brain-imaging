function BW = LBDetection2D(img,s)
% detect large objects in a FoV
% input  : img, 2D raw image
%          s, config
% 
% output : BW, binary mask of the image for the large object
    s.k1_dog   = 2;
    s.k2_dog   = 16;
    s.otsu_num = 1;
    img = imgaussfilt(img,s.k1_dog) - imgaussfilt(img,s.k2_dog);
    BW  = core.threshold(img,s);
    BW  = core.BWFilter(BW,img,s); %area and intensity post-filtering
end