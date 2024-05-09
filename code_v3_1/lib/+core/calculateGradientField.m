function [img1,Gx,Gy,focusScore,integeralScore,cfactor] = calculateGradientField(img,k1)
% calculate relative and absolute gradient (they together are called radiality) for each oligomer detected
% input  : img, original image
%          k1, kernel for background and noise suppression
% 
% output : img1, smoothed image
%          Gx, gradient image in x-direction 
%          Gy, gradient image in y-direction 
%          focusScore, focus score for the current image 
%          integralScore, integral of the focus score
%          cfactor, correction factor for the corrrection of slightly different intensity per image
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk

    img1 = zeros(size(img)); %low-passed image for the feature detection purpose 
    for i = 1:size(img,3) 
        img_pad     = images.internal.padarray_algo(img(:,:,i), size(k1)-floor((size(k1) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
        img1(:,:,i) = conv2(img_pad,k1,'valid'); %smooth blobs for the radiality calculation and background suppression
        % cfactor(i)  = median(img1(:,:,i),'all');
    end
    img = img1; img = min(img,60000); %hard thresholding for getting rid of the effect from super bright objects
    Gx = zeros(size(img)); Gy = zeros(size(img));
    Gx(:,1:end-1,:) = diff(img,1,2); %x gradient (right to left)
    Gy(1:end-1,:,:) = diff(img,1,1); %y gradient (bottom to top)
    Gmag            = sqrt(Gx.^2 + Gy.^2);
    sg         = squeeze(sum(Gmag,[1 2]));
    cfactor    = sg./max(sg);
    focusScore = log(sg);
    integeralScore  = sum(focusScore);
end