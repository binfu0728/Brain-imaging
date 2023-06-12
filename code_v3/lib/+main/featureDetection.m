function [dlMask,ndlMask,centroids] = featureDetection(img,img2,Gx,Gy,k2,percentage,radiality,z)
    dlMask     = false(size(img)); %diffraction-limited objects
    ndlMask    = false(size(img)); %non-diffraction-limited objects
    largeMask  = core.largeFeatureKernel(img); %large objects
    centroids  = cell(size(img,3),1); %centroid for diffraction-limited objects
    parfor j = z(1):z(2)
        [dlMask(:,:,j),ndlMask(:,:,j),centroids{j}] = core.smallFeatureKernel(img(:,:,j),largeMask(:,:,j),img2(:,:,j),Gx(:,:,j),Gy(:,:,j),k2,percentage,radiality);
    end
end