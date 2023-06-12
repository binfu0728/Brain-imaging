function [img1,Gx,Gy,focusScore,integeralScore] = calculateGradientField(img,k1)
    img1 = zeros(size(img)); %low-passed image for the feature detection purpose 
    for i = 1:size(img,3) 
        img_pad     = images.internal.padarray_algo(img(:,:,i), size(k1)-floor((size(k1) + 1)/2), 'replicate', [], 'both'); %replicate padding for convolution
        img1(:,:,i) = conv2(img_pad,k1,'valid'); %smooth blobs for the radiality calculation and background suppression
        % figure;imshow(img(:,:,i),[0 200]);
    end
    img = img1; img = min(img,800); %hard thresholding for getting rid of the effect from super bright objects
    Gx = zeros(size(img)); Gy = zeros(size(img));
    Gx(:,1:end-1,:) = diff(img,1,2); %x gradient (right to left)
    Gy(1:end-1,:,:) = diff(img,1,1); %y gradient (bottom to top)
    Gmag            = sqrt(Gx.^2 + Gy.^2);
    focusScore      = log(squeeze(sum(Gmag,[1 2])));
    integeralScore  = sum(focusScore);
end