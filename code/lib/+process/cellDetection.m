function BW = cellDetection(img,s)
% detect cells in a FoV, similar to LB Detection 3D
% input  : img, 3D raw image
%          s, config
% 
% output : BW, binary mask of the image for oligomers

    img1 = image.multiDoG(img,s);
    img1 = max(img1,0);
    BW   = image.threshold(img1,s);

    for j = 1:size(BW,3)
        if s.disk ~= 0
            BW(:,:,j) = imopen(BW(:,:,j),strel('disk',s.disk(1)));
            BW(:,:,j) = imclose(BW(:,:,j),strel('disk',s.disk(2)));
        end
        s.intens  = s.intens_ratio*mean2(img(:,:,j));
        BW(:,:,j) = image.BWFilter(BW(:,:,j),img(:,:,j),s);
    end
end