function cellMask = cellDetection(img,k1,k2,thres,thres2)
% Find aggregate in both non diffraction-limited (ndl) and diffraction-limited (dl) scale 
% input  : img, original image
%          k1,k2, two sigma value for difference of gaussian kernel for feature enthancement
%          thres, value for converting real-valued image to binary mask 
%          thres2, value for determining whether an object is bright enough (i.e. real cell)
% 
% output : cellMask, binary mask for cell locations
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk

    img1 = imgaussfilt3(img,k1) - imgaussfilt3(img,k2);
    BW   = img1>thres;    
    cellMask = false(size(BW));
    for j = 1:size(BW,3)
        BW(:,:,j) = imopen(BW(:,:,j),strel('disk',1));
        BW(:,:,j) = imclose(BW(:,:,j),strel('disk',4));
        BW(:,:,j) = bwareaopen(BW(:,:,j),60);
        t    = regionprops('table',BW(:,:,j),'PixelIdxList');
        pil  = t.PixelIdxList;
        idx1 = false(length(pil),1);
        imcopy = img(:,:,j);
        for k = 1:length(pil)
            idx1(k) = (sum(imcopy(pil{k})>thres2)/length(pil{k})) > 0.1; % 5% of values large than 400 - whether bright enough
        end
        if ~isempty(idx1)
            cellMask(:,:,j) = core.fillRegion(size(BW(:,:,j)),pil(idx1));
            cellMask(:,:,j) = imfill(cellMask(:,:,j),'holes');
        end
    end
end