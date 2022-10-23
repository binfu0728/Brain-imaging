function BW = oligomerDetection(img,s)
% detect small objects but will have artefacts around large objects
% input  : img, 2D raw image
%          s, config
% 
% output : BW, binary mask of the image for oligomers

    s.dim = 2;
    img1  = image.multiDoG(img,s);
    img1  = max(img1,0);
    img1  = image.multiLoG(img1,s);
    img1  = max(img1,0);
    BW    = image.threshold(img1,s);
    BW    = imopen(BW,strel('disk',s.disk)); %structure post-filtering
end