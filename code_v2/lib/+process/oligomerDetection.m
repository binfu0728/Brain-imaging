function BW = oligomerDetection(img,h,s)
% detect small objects but will have artefacts around large objects
% input  : img, 2D raw image
%          s, config
% 
% output : BW, binary mask of the image for oligomers

    img1  = img - imgaussfilt(img,s.k2_dog);
    img1  = max(img1,0);
    img1  = imfilter(img1,h,'replicate','conv','same');
    BW    = core.threshold(img1,s);
    BW    = imopen(BW,strel('disk',s.disk)); %structure post-filtering
end