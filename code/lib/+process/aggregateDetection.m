function [smallM,largeM,result_oligomer] = aggregateDetection(img,s1,s2,saved,gain,offset)
% input  : img, the original image stack, has to be in single/double
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
%     result_slice    = [];

    r         = 1; %the ratio between the max(LB) and saturation (65535)
    s1.intens = 0.05*2^(s1.bit)*r;
    BW_mip    = process.LBDetection2D(max(img,[],3),s1); %determine the large objects position in the FoV (through MIP)
    smallM    = false(s1.width,s1.height,size(img,3));
    largeM    = smallM;
    h         = core.rickerWavelet(s2.k_log);

    NA        = 1.45;
    lamda     = 600; %nm
    pixelsize = 107; %nm
    rd        = ceil((0.61*lamda/NA/pixelsize)^2*pi/1);%rayleigh diffraction limit,in pixel

    % 3D rough detection for large objects
    img1      = imgaussfilt3(img,s1.k1_dog) - imgaussfilt3(img,s1.k2_dog);
    BW1       = core.threshold(img1,s1);
    intens_ratio = s1.intens_ratio;

%     parfor (j = 1:size(img,3),8)
    for j = 1:size(img,3)
        zimg = img(:,:,j);
        zimg = (zimg-offset).*gain;
        % large object detection
        BW1(:,:,j) = BWFilter(BW1(:,:,j),zimg,intens_ratio*mean2(zimg)); %area and intensity post-filtering
        BW1(:,:,j) = imfill(BW1(:,:,j),'holes');
        BW1(:,:,j) = process.findCoincidence(BW_mip,BW1(:,:,j),2); %position post-filtering

        % blob detection
        BW2 = process.oligomerDetection(zimg,h,s2); %detect small objects in the FoV (not the oligomers)

        %large and small selection
        BW  = BW1(:,:,j) | BW2;
        BW  = imclose(BW,strel('disk',2));
        t   = regionprops('table',BW,zimg,'Area','MeanIntensity');
        a   = t.Area; it = t.MeanIntensity;

        if ~isempty(a)
            idx1  = find(a>=rd);
            smallM(:,:,j) = core.fillRegions(BW,idx1);
            idx1  = find(a<rd); %rayleigh diffraction limit
%             idx1  = find((a<rd) | (it<400 & a>170) | (it<280 & a<170 & a>1.5*rd));
            largeM(:,:,j) = core.fillRegions(BW,idx1);
        end
        
        if saved
            [r_z,~] = core.findInfo(smallM(:,:,j),img(:,:,j),j);
            result_oligomer = [result_oligomer;r_z];
%             result_slice    = [result_slice;r_avg];
        end
    end
end

function BW = BWFilter(BW,img,intens_thresh)
% input  : BW, binary mask
%          img, the processed image
%          s, config
% 
% output : BW, filtered binary mask

    ss     = regionprops('table',BW,img,'MeanIntensity');
    intens = ss.MeanIntensity;
    idx    = find(intens<intens_thresh);
    BW     = core.fillRegions(BW,idx);
end