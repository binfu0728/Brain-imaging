function [smallM,largeM,result_oligomer,result_slice] = aggregateDetection(img,s1,s2,z,saved)
% input  : img, the original image stack
%          s1, the config for lb detection
%          s2, the config for oligomer detection
%          z, the initial slice for the img stack 
%          saved, whether save the result
%          
% output : smallM, binary mask for small aggregates
%          largeM, binary mask for large aggregats
%          result_oligomer, result per oligomer
%          result_slice, result per slice

    result_oligomer = [];
    result_slice    = [];

%     r          = double(max(max(img,[],'all')*0.8,4*median(img,'all')))/65535; 
    r          = 1; %the ratio between the max(LB) and saturation (65535)
    BW1        = process.LBDetection3D(img,s1,r); %detect large objects in the FoV (not the large aggregates)
    smallM     = false(s1.width*4,s1.height*4,size(BW1,3));
    largeM     = smallM;
    
%     parfor (j = 1:size(img,3),8)
    for j = 1:size(img,3)
        zimg     = double(imresize(img(:,:,j),4));
        BW2      = process.oligomerDetection(zimg,s2); %detect small objects in the FoV (not the oligomers)
        % add pixelidx dilation
        BW2      = BW2 - process.findCoincidence(imresize(BW1(:,:,j),4),BW2,2); %get rid of the overlapping region between BW1 and BW2s

        BW       = imresize(BW1(:,:,j),4) | BW2; %BW1 + BW2
        a        = regionprops ('table',BW,'Area').Area; 
        if ~isempty(bwconncomp(BW).PixelIdxList)
            idx1  = find(a>=300); %rayleigh diffraction limit
            smallM(:,:,j) = image.fillRegions(BW,idx1);
            idx1  = find(a<300); %rayleigh diffraction limit
            largeM(:,:,j) = image.fillRegions(BW,idx1);
        end

        if saved
            [r_z,r_avg]     = image.findInfo(smallM(:,:,j),zimg,z,j);
            result_oligomer = [result_oligomer;r_z];
            result_slice    = [result_slice;r_avg];
        end
    end
end