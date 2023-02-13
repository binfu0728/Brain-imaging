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

    bits      = (s1.bit);
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

%     parfor (j = 1:size(img,3),8)
    for j = 1:size(img,3)
        zimg = img(:,:,j);
        zimg = (zimg-offset).*gain;
        % large object detection
        t = regionprops('table',BW1(:,:,j),zimg,'PixelValues'); %area and intensity post-filtering
        counts = cell2mat(cellfun(@(x) findPercentileMean(x,0.05),t.PixelValues,'UniformOutput',false));
        if ~isempty(counts)
            idx1  = find(counts<2^bits*0.5);
            BW1(:,:,j) = core.fillRegions(BW1(:,:,j),idx1);
        end
%         BW1(:,:,j) = imfill(BW1(:,:,j),'holes');
        BW1(:,:,j) = process.findCoincidence(BW_mip,BW1(:,:,j),2); %position post-filtering

        % blob detection
        BW2 = process.oligomerDetection2(zimg,h,s2); %detect small objects in the FoV (not the oligomers)

        %large and small selection
        BW  = BW1(:,:,j) | BW2;
        BW  = imclose(BW,strel('disk',2));
        t   = regionprops('table',BW,zimg,'Area','MeanIntensity');
        a   = t.Area;

        if ~isempty(a)
            idx1  = find(a>=rd);
            smallM(:,:,j) = core.fillRegions(BW,idx1);
            idx1  = find(a<rd); %rayleigh diffraction limit
            largeM(:,:,j) = core.fillRegions(BW,idx1);
        end
        
        if saved
            [r_z,~] = core.findInfo(smallM(:,:,j),img(:,:,j),j);
            result_oligomer = [result_oligomer;r_z];
%             result_slice    = [result_slice;r_avg];
        end
    end
end

function m = findPercentileMean(counts,percentile)
    counts  = sort(counts(:));
    highend = round(length(counts)*(1-percentile));
    counts  = counts(highend:end);
    m       = mean(counts);
end