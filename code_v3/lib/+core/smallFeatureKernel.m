function [dlMask,ndlMask,centroids,radiality] = smallFeatureKernel(img,largeMask,img2,Gx,Gy,k2,thres,rdl)  

    % signal(i.e. image) filtering
    img1 = img - img2; %background suppression
    img1 = max(img1,0);
    img1 = images.internal.padarray_algo(img1, size(k2)-floor((size(k2) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img1 = conv2(img1,k2,'valid'); %feature enhancement

    BW   = false(size(img1));
    if thres < 1
        thres = core.findPercentileValue(img1,thres,[401 800]);
    end

    BW(img1>thres) = 1;
    BW   = BW | largeMask; %mask contains all detected features regardless of size

    if rdl(1) == 0 && rdl(2) == 0 %no radiality is used
        BW = imopen(BW,strel('disk',1)); %filter tiny objects from spurious pixel noise
    else
        BW = bwareaopen(BW,6); %filter tiny objects from spurious pixel noise
    end
    
    imsz = size(img);
    
    % simplified regionprops
    [pixelIdxList,areas,centroids] = core.simplifiedRegionProps(BW,imsz);
    
    % classify non-diffraction limit and diifraction limit objects
    idxb = centroids(:,1)>10 & centroids(:,1)<imsz(2)-9 & centroids(:,2)>10 & centroids(:,2)<imsz(1)-9; %boundary objects
    idxl = (areas>=24 & idxb); %indices for objects larger than or equal to diffraction limit in pixel determined from simulated data 
    idxs = (areas<24  & idxb); %indices for round objects smaller than diffraction limit in pixel determined from simulated data

    %non-diffraction limit objects filtering
    pil_large = pixelIdxList(idxl);
    idxl      = false(length(pil_large),1);
    for k = 1:length(pil_large)
        idxl(k) = (sum(img(pil_large{k})>400)/length(pil_large{k})) > 0.05; % 5% of values large than 400 - whether bright enough
    end
    ndlMask = core.fillRegion(imsz,pil_large(idxl));
    ndlMask = imclose(ndlMask,strel('disk',2)); %connect some seperate sections

    %diffraction limit objects filtering (radiality)
    pil_small = pixelIdxList(idxs);
    centroids = centroids(idxs,:);

        
    % f = figure;imshow(img,[0 300]);
    % bw = core.fillRegion(imsz,pil_small);
    % visual.plotBinaryMask(f,bw,[0.6 0.3 0.7]);

    radiality = core.calculateRadiality(pil_small,img2,Gx,Gy,imsz);
    
    idxs      = radiality(:,1)>=rdl(1) & radiality(:,2)>=rdl(2) & radiality(:,3)>=rdl(3); %objects with enough radiality
    centroids = floor(centroids(idxs,:));
    dlMask    = core.fillRegion(imsz,pil_small(idxs));
end