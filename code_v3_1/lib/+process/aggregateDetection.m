function [dlMask,ndlMask,centroids] = aggregateDetection(img,img2,Gx,Gy,k2,percentage,radiality,z,cfactor)
% Find aggregate in both non diffraction-limited (ndl) and diffraction-limited (dl) scale 
% input  : img, original image
%          img2, smoothed image for background supression
%          Gx, gradient image in x-direction 
%          Gy, gradient image in y-direction
%          k2, the kernel for blob feature enhancement
%          percentage, percentage of pixels would be accepted for the oligomers
%          radiality, radiality threshold
%          z, the start and final images in-focus
%          cfactor, correction factor for the corrrection of slightly different intensity per image
% 
% output : dlMask, binary mask for diffraction-limited features
%          ndlMask, binary mask for non diffraction-limited features
%          centroids, centroids for dl features (oligomers)
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk

    if nargin < 9
        cfactor = ones(size(img,3));
    end

    dlMask    = false(size(img)); %diffraction-limited objects
    ndlMask   = false(size(img)); %non-diffraction-limited objects
    largeMask = core.largeFeatureKernel(img,150); %large objects
    centroids = cell(size(img,3),1); %centroid for diffraction-limited objects
    parfor j = z(1):z(2)
        rdl    = radiality;
        rdl(2) = rdl(2)*cfactor(j);
        [dlMask(:,:,j),ndlMask(:,:,j),centroids{j}] = core.smallFeatureKernel(img(:,:,j),largeMask(:,:,j),img2(:,:,j),Gx(:,:,j),Gy(:,:,j),k2,percentage,rdl);
    end
end