function BW = oligomerDetection(img,h,s)
% detect small objects but will have artefacts around large objects
% input  : img, 2D raw image
%          s, config
% 
% output : BW, binary mask of the image for oligomers

    s.dim = 2;
    img1  = image.multiDoG(img,s);
    img1  = max(img1,0);
    img1  = imfilter(img1,h,'replicate','conv','same');
%     img1  = max(img1,0);
    BW    = image.threshold(img1,s);
    BW    = imopen(BW,strel('disk',s.disk)); %structure post-filtering
end