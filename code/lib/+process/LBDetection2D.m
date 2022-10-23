function BW = LBDetection2D(img,s)
% detect large objects in a FoV
    s.k1_dog   = 2;
    s.k2_dog   = 16;
    img = image.multiDoG(img,s);
    img = max(img,0);
    BW  = image.threshold(img,s);
    BW  = image.BWFilter(BW,img,s);
end