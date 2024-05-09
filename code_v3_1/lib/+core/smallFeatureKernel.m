function [dlMask,ndlMask,centroids,radiality,idxs] = smallFeatureKernel(img,largeMask,img2,Gx,Gy,k2,thres,rdl)
% find small features in an image and determine diffraction-limited (dl) and non diffraction-limited (ndl) features
% input  : img, original image
%          largeMask, binary mask for the large feature
%          img2, smoothed image for background suppression
%          Gx, gradient image in x-direction 
%          Gy, gradient image in y-direction
%          k2, the kernel for blob feature enhancement
%          thres, converting real-valued image into a binary mask
%          rdl, radiality threshold
% 
% output : dlMask, binary mask for diffraction-limited features
%          ndlMask, binary mask for non diffraction-limited features
%          centroids, centroids for dl features (oligomers)
%          radiality, radiality value for all features (before the filtering based on the radiality)
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk

    % signal(i.e. image) filtering
    img1 = img - img2; %background suppression
    img1 = max(img1,0);
    img1 = images.internal.padarray_algo(img1, size(k2)-floor((size(k2) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
    img1 = conv2(img1,k2,'valid'); %feature enhancement

    BW   = false(size(img1));
    if thres < 1
        thres = findPercentileValue(img1,thres);
    end

    BW(img1>thres) = 1;
    BW = BW | largeMask; %mask contains all detected features regardless of size
    BW = imopen(BW,strel('disk',1)); %filter tiny objects from spurious pixel noise
    
    imsz = size(img);
    
    % simplified regionprops
    [pixelIdxList,areas,centroids] = core.simplifiedRegionProps(BW,imsz);
    
    % classify non-diffraction limit and diifraction limit objects
    idxb = centroids(:,1)>10 & centroids(:,1)<imsz(2)-10 & centroids(:,2)>10 & centroids(:,2)<imsz(1)-9; %boundary objects
    idxl = (areas>=27 & idxb); %indices for objects larger than or equal to diffraction limit in pixel determined from simulated data 
    idxs = (areas<27  & idxb); %indices for round objects smaller than diffraction limit in pixel determined from simulated data

    %non-diffraction limit objects filtering
    pil_large = pixelIdxList(idxl);
    idxl      = false(length(pil_large),1);
    for k = 1:length(pil_large)
        idxl(k) = (sum(img(pil_large{k})>250)/length(pil_large{k})) > 0.05; % 5% of values large than 400 - whether bright enough
    end
    ndlMask = core.fillRegion(imsz,pil_large(idxl));
    ndlMask = imclose(ndlMask,strel('disk',2)); %connect some seperate sections

    %diffraction limit objects filtering (radiality)
    pil_small = pixelIdxList(idxs);
    centroids = centroids(idxs,:);
    radiality = core.calculateRadiality(pil_small,img2,Gx,Gy);
    
    idxs      = radiality(:,1)<=rdl(1) & radiality(:,2)>=rdl(2); %objects with enough radiality
    centroids = floor(centroids(idxs,:));
    dlMask    = core.fillRegion(imsz,pil_small(idxs));
end

function m = findPercentileValue(counts,percentile,range)
    if nargin == 3
        counts = counts(range(1):range(2),range(1):range(2),:);
    end
    counts  = sort(counts(:));
    highend = round(length(counts)*(1-percentile));
    m = counts(highend);
end