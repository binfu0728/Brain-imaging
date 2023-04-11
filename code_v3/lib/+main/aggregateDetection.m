function [smallM,largeM,centroids,radiality] = aggregateDetection(img,hs1,hs2,hs3,thres,rdl)  
% input:  img,   double matrix, the raw image for processing 
%         hs1,   double matrix, the kernel for background subtraction
%         hs2,   double matrix, the kernel for feature enhancement
%         thres, double, the absolute value or percentage value for determining the binary mask
%         rdl,   double, the value for checking radiality
% output: smallM,     logical matrix, the binary mask for small aggregates (smaller than diffraction limit)
%         largeM,     logical matrix, the binary mask for large aggregates (larger than or equal to diffraction limit)
%         centroids,  double matrix, the floored centroid for each detected small aggregates

    % signal(i.e. image) filtering
    img1 = images.internal.padarray_algo(img, size(hs1)-floor((size(hs1) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img1 = img - conv2(img1,hs1,'valid'); %background suppression
    img1 = max(img1,0);
    img2 = images.internal.padarray_algo(img, size(hs2)-floor((size(hs2) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img2 = conv2(img2,hs2,'valid'); %smooth blobs for the radiality check
    img1 = images.internal.padarray_algo(img1, size(hs3)-floor((size(hs3) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img1 = conv2(img1,hs3,'valid'); %feature enhancement

    BW    = false(size(img1));
    if thres < 1
        thres = core.findPercentileValue(img1,thres);
    end

    BW(img1>thres) = 1;
    BW   = bwareaopen(BW,5); %filter tiny objects from spurious pixel noise
    imsz = size(img);
    
    % simplified regionprops
    [pixelIdxList,areas,centroids,aspect_ratios] = core.simplifiedRegionProps(BW,imsz);
    
    % classify non-diffraction limit and diifraction limit objects
    idxb = centroids(:,1)>6 & centroids(:,1)<imsz(2)-6 & centroids(:,2)>6 & centroids(:,2)<imsz(1)-6; %boundary objects
    idxl = (areas>=30 & idxb); %indices for objects larger than or equal to diffraction limit
    idxs = (areas<30  & idxb & aspect_ratios<1.6); %indices for round objects smaller than rayleigh diffraction limit

    %non-diffraction limit objects filtering
    pil_large = pixelIdxList(idxl);
    idxl      = false(length(pil_large),1);
    for k = 1:length(pil_large)
        idxl(k) = (sum(img(pil_large{k})>400)/length(pil_large{k})) > 0.05; % 5% of values large than 400 - whether bright enough
    end
    largeM = core.fillRegion(imsz,pil_large(idxl));
    largeM = imclose(largeM,strel('disk',2)); %connect some seperate sections

    %diffraction limit objects filtering
    pil_small = pixelIdxList(idxs);
    centroids = centroids(idxs,:);
    radiality = core.calculateRadiality(pil_small,img2,imsz);
    idxs      = radiality>=rdl; %objects with enough radiality
    centroids = floor(centroids(idxs,:));
    smallM    = core.fillRegion(imsz,pil_small(idxs));
end