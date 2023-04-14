function [smallM,largeM,centroids,radiality] = aggregateDetection(img,k1,k2,thres,rdl)  
% input:  img,   double matrix, the raw image for processing 
%         hs1,   double matrix, the kernel for background subtraction
%         hs2,   double matrix, the kernel for feature enhancement
%         thres, double, the absolute value or percentage value for determining the binary mask
%         rdl,   double, the value for radiality magnitude threshold
% output: smallM,     logical matrix, the binary mask for small aggregates (smaller than diffraction limit)
%         largeM,     logical matrix, the binary mask for large aggregates (larger than or equal to diffraction limit)
%         centroids,  double matrix, the floored centroid for each detected small aggregates

    % signal(i.e. image) filtering
    img1 = images.internal.padarray_algo(img, size(k1)-floor((size(k1) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img2 = conv2(img1,k1,'valid'); %smooth blobs for the radiality calculation and background suppression
    img1 = img - img2; %background suppression
    img1 = images.internal.padarray_algo(img1, size(k2)-floor((size(k2) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img1 = conv2(img1,k2,'valid'); %feature enhancement

    BW    = false(size(img1));
    if thres < 1
        thres = core.findPercentileValue(img1,thres,[401 800]);
    end

    BW(img1>thres) = 1;
    BW   = bwareaopen(BW,5); %filter tiny objects from spurious pixel noise
    imsz = size(img);
    
    % simplified regionprops
    [pixelIdxList,areas,centroids] = core.simplifiedRegionProps(BW,imsz);
    
    % classify non-diffraction limit and diifraction limit objects
    idxb = centroids(:,1)>10 & centroids(:,1)<imsz(2)-9 & centroids(:,2)>10 & centroids(:,2)<imsz(1)-9; %boundary objects
    idxl = (areas>=24 & idxb & areas<=250); %indices for objects larger than or equal to diffraction limit in pixel determined from simulated data 
    idxs = (areas<24  & idxb); %indices for round objects smaller than diffraction limit in pixel determined from simulated data

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
    
    idxs      = radiality(:,1)>=rdl(1) & radiality(:,2)>=rdl(2); %objects with enough radiality
    centroids = floor(centroids(idxs,:));
    smallM    = core.fillRegion(imsz,pil_small(idxs));
end