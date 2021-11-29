% The code is for selecting the tiny spots in a noisy image. The gaussian
% fitting is added for all detected spots to provide extra infomation
% for them. The gaussian fit code is adapted from Lucien Weiss's code

% Structure of code: spot detection -> centroid fitting -> bg and pure sig estimation on centroid fitting results -> bg and pure sig estimation on gaussian fitting results
% So, two intensity (and bg) will be calculated: one from centroid fitting, the other from gaussian fitting

% Author: Bin Fu, bf341@cam.ac.uk
%%
clear;clc;
% Input Parameters
filename               = 'beads_561_0.5od_HILO_3_MMStack_Default.ome'; 
fitting_radius         = 10;   %radius of region that will be used in gaussian fitting, cannot beyond 10 pixels
sigma                  = 1.5;  %Threshold used after convolution

% Image processing & aggregate counting
img                    = double(Tifread([filename,'.tif']));

%If bead experiment is used
img                    = max(img,[],3); %maximum intensity project

% %If brain imaging sample is used
% time     = 10;  %number of frame, time-scan
% zaxis    = 11;  %number of z-samples
% colour   = 3;   %number of colour channels
% channel  = 1;
% tmpt     = reshape(img,size(img,1),size(img,1),zaxis,time*colour);
% c        = tmpt(:,:,:,channel:colour:time*colour); %one colour channel, row x col x zaxis x time(4D hyperstack);
% img      = mean(squeeze(c(:,:,1,:)),3); %row x col x time, The processed image is an average

se                     = strel('disk',10); %create a flat structuring element for top-hat filtering
h                      = RW2DKernel(3,1);  %create a convolution kernel 
i_tophat               = imtophat(img,se); %top-hat filter
i_conv                 = imfilter(i_tophat,h,'conv'); %convolution

x                      = i_conv(:);
[m,s]                  = normfit(x);
i_conv(i_conv<sigma*s) = 0; %image thresholding

se                     = strel('disk',1);   %create another flat structuring element for opening operation, with 1 radius
mask                   = imopen(i_conv,se); %morphological open operation for filtering tiny structures(noise)
mask(mask>0)           = 1;                 %binary the mask
mask                   = maskFilter(mask);  %crop the edge points, which may introdu wrong estimation
maskedImage            = mask.*img;         %the tiny spots within the original image

bgEstimation_fill      = (1-mask).*img;     %bg = image - spots, estimated by performing a flood-fill operation
filledBg               = imfill(bgEstimation_fill); %bg estimation based on bgImage
sigImage               = abs(img-filledBg); %signal = image - estimated bg

mask                   = logical(mask);
CC                     = bwconncomp(mask);  %8-connectivity(all direction connection will be counted)
aggregatePoints        = CC.PixelIdxList;
s                      = regionprops(mask,'centroid','area');
centroids              = cat(1,s.Centroid); %centroid for each detected points
areas                  = cat(1,s.Area);

intensity              = zeros(length(s),1); % intensity of pure signal (no background offset)
avg_inten              = zeros(length(s),1); % average intensity of pure signal (no background offset)
% SNB                    = zeros(length(s),1);
sigmaY                 = zeros(length(s),1); %sigma in Y for a fitted spot
sigmaX                 = zeros(length(s),1); %sigma in X for a fitted spot
position               = round(centroids);
fit_spots              = zeros(2*fitting_radius+1,2*fitting_radius+1,length(s)); %fitting spots (fitted bg + fitted sig)
origin_spots           = zeros(2*fitting_radius+1,2*fitting_radius+1,length(s)); %original spots (in original image)
fit_spots_noBg         = zeros(2*fitting_radius+1,2*fitting_radius+1,length(s)); %fitting spots(fitted sig)
bgEstimation_fit       = zeros(length(s),1); %bg estimated by gaussian fitting

for k                  = 1:length(s)
    [r,c]                  = ind2sub(size(mask),cell2mat(aggregatePoints(k))); %all pixel indice for a detected spot
    intensity(k)           = sum(sigImage(cell2mat(aggregatePoints(k))));
    avg_inten(k)           = intensity(k)/areas(k);
%     SNB(k)                 = avg_inten(k)/mean(filledBg(cell2mat(aggregatePoints(k))),'all')+1;
    [fit_spots(:,:,k),origin_spots(:,:,k),sigmaY(k),sigmaX(k),bgEstimation_fit(k),fit_spots_noBg(:,:,k)] = gaussianFit(position(k,:),img,fitting_radius);
end
img = normalize16(img); maskedImage = normalize16(maskedImage);
comb(:,:,1)            = maskedImage;
comb(:,:,2)            = img+maskedImage;
comb(:,:,3)            = img;
f1                     = figure;
f1.Position            = [200 200 600 550];
image(comb); title('detected spots');
f2                     = figure;
f1.Position            = [300 300 700 650];
imshow(img,[]); title('original image');

%%
function RW = RW2DKernel(a,sigma)
% Laplacian of Gaussian operator, also called as 2D Ricker wavelet,
% similar to difference of Gaussian kernel, frequently used as a blob detector
    x                   = (0:8*sigma) - 4*sigma; y = x;
    [X,Y]               = meshgrid(x,y);
    amplitude           = 1.0 / (pi * sigma * 4) * a;
    rr_ww               = (X.^2+Y.^2)/(2.*sigma.^2);
    RW                  = amplitude*(1-rr_ww).*exp(-rr_ww);
end

function mask = maskFilter(mask)
    mask(1:10,:)        = 0;
    mask(end-10:end,:)  = 0;
    mask(:,1:10)        = 0;
    mask(:,end-10:end)  = 0;
end

function img = normalize16(img)
    img                 = img - min(min(img)) + 1;
    img                 = uint16(img./max(max(img)) .* (2^16-1));
end

function tiff_stack = Tifread(filename)
    tiff_info           = imfinfo(filename);
    width               = tiff_info.Width;
    height              = tiff_info.Height;
    tiff_stack          = uint16(zeros(height(1),width(1),length(tiff_info)));
    for i               = 1:length(tiff_info)
        tiff_stack(:,:,i)   = imread(filename, i);
    end
end

function [fit_spot,image_Region,sigmaY,sigmaX,bgEstimation,fit_spot_noBg] = gaussianFit(position,original_img,fitting_radius) 
% Gaussian fitting function by using non-linear equation solver
% INPUT
% position       : The position for a fitted point in [x,y] (centroid position)
% original_img   : The original image
% fitting_radius : The radius of fitting_region (in Luc's code, this is named as fitting_region)
% 
% OUTPUT
% fit_spot       : The fit spot based on the 2D gaussian fitting
% image_Region   : The original spot in the image
% sigmaY         : the sigma in y (row) for a fitted spot
% sigmaX         : the sigma in x (column) for a fitted spot
% bgEstimation   : Estimated background value for a given spot
% fit_spot_noBg  : The fit spot without background value

%     fitting_radius                              = 5;
    amplitude_limits                            = [0 2^16];
    amplitude_range                             = diff(amplitude_limits);
    background_limits                           = [0 2^16];
    background_range                            = diff(background_limits);
    sigma_limits                                = [.1 fitting_radius];
    sigma_range                                 = diff(sigma_limits);
    image_Region                                = original_img(position(2)-fitting_radius:position(2)+fitting_radius,position(1)-fitting_radius:position(1)+fitting_radius);
    
    % Placeholder
    border_region                               = ones(fitting_radius*2+1); 
    border_region(2:end-1,2:end-1)              = nan;
    fitting_options                             = optimset('FunValCheck','on', 'MaxIter',1000, 'Display','off', 'TolFun',1e-4, 'TolX',1e-4);

    % Setup for localization
    [regional_indices_row,regional_indices_col] = ndgrid(-fitting_radius:fitting_radius,-fitting_radius:fitting_radius);
    
    % Intial guess
    BG_guess                                    = (nanmean(border_region(:).*image_Region(:))-background_limits(1))/background_range;
    AMP_guess                                   = (max(image_Region(:))-nanmean(border_region(:).*image_Region(:))-amplitude_limits(1))/amplitude_range;
    
    % non-linear fitting
    fitted_param                                = lsqnonlin(@ASYMMETRIC_GAUSSIAN_FIT, [.5, .5, AMP_guess, .5, .5, BG_guess], [0 0 0 0 0 0], [1, 1, 1, 1, 1, 1], fitting_options);
    fit_spot                                    = (fitted_param(6)*background_range+background_limits(1)) + (fitted_param(3)*amplitude_range+amplitude_limits(1))*...
                                                   exp( (-(regional_indices_row-((fitted_param(1)-.5)*fitting_radius)).^2) / (2*(fitted_param(4)*sigma_range+sigma_limits(1))^2) - ...
                                                   ((regional_indices_col-((fitted_param(2)-.5)*fitting_radius)).^2) / (2*(fitted_param(5)*sigma_range+sigma_limits(1))^2) );
    sigmaY                                      = fitted_param(4)*sigma_range+sigma_limits(1);
    sigmaX                                      = fitted_param(5)*sigma_range+sigma_limits(1);
    bgEstimation                                = fitted_param(6)*background_range+background_limits(1);
    fit_spot_noBg                               = fit_spot - bgEstimation;
    
    function Delta = ASYMMETRIC_GAUSSIAN_FIT(guess)
        Row            = (guess(1)-.5)*fitting_radius;
        Col            = (guess(2)-.5)*fitting_radius;
        Amplitude      = guess(3)*amplitude_range+amplitude_limits(1);
        Sigma_row      = guess(4)*sigma_range+sigma_limits(1);
        Sigma_col      = guess(5)*sigma_range+sigma_limits(1);
        Background     = guess(6)*background_range+background_limits(1);
        Guess_Image    = Background + Amplitude*exp(-((regional_indices_row-Row).^2)/(2*Sigma_row^2)-((regional_indices_col-Col).^2)/(2*Sigma_col^2));
        Delta          = - image_Region(:) + Guess_Image(:);
    end
end