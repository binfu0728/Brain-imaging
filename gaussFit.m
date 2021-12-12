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

mask                   = aggreMask(img,sigma);
bgmask                 = mask;


bgEstimation_fill      = (1-mask).*img;     %bg = image - spots, estimated by performing a flood-fill operation
filledBg               = imfill(bgEstimation_fill); %bg estimation based on bgImage
sigImage               = abs(img-filledBg); %signal = image - estimated bg

mask                   = logical(mask);
CC                     = bwconncomp(mask);  %8-connectivity(all direction connection will be counted)
aggregatePoints        = CC.PixelIdxList;
s                      = regionprops(mask,'centroid','MinorAxisLength','MajorAxisLength');
centroids              = cat(1,s.Centroid); %centroid for each detected points
longD                  = cat(1,s.MajorAxisLength); 
shortD                 = cat(1,s.MinorAxisLength);

segments  = false(512,512,length(s));
for p = 1:length(s)
    tmpt = false(512,512);
    tmpt(aggregatePoints{p}) = 1;
    dilatedR = ceil(shortD(p)/2);
    se = strel('disk',dilatedR);
    tmpt = imdilate(tmpt,se); 
    segments(:,:,p) = tmpt;
end
sigmask = max(segments,[],3);

bgEstimation_fill      = (1-sigmask).*img;     %bg = image - spots, estimated by performing a flood-fill operation
bgImage                = imfill(bgEstimation_fill); %bg estimation based on bgImage
sigImage               = abs(img-imfill((1-sigmask).*img)); %pure signal intensity of the detected points.

sigmaY_Gaussian                 = zeros(length(s),1); %sigma in Y for a fitted spot
sigmaX_Gaussian                 = zeros(length(s),1); %sigma in X for a fitted spot
position_estimation_centroid    = round(centroids);
Gaussian_fit_spots              = zeros(2*5+1,2*5+1,length(s)); %fitting spots (fitted bg + fitted sig)
original_spots                  = zeros(2*5+1,2*5+1,length(s)); %original spots (in original image)
Gaussian_fit_spots_noBg         = zeros(2*5+1,2*5+1,length(s)); %fitting spots(fitted sig)

Centroid_intensity_estimation_noBg = zeros(length(s),1); %pure signal estimation from centriod fitting
Gaussian_intensity_estimation_noBg = zeros(length(s),1); %pure signal estimation from gaussian fitting

Gaussian_bgEstimation          = zeros(length(s),1); %bg estimated by gaussian fitting
Centroid_bgEstimation          = zeros(length(s),1); %bg estimated by centroid fitting

for k = 1:length(s)
    Centroid_intensity_estimation_noBg(k) = sum(sigImage(aggregatePoints{k}));
    Centroid_bgEstimation(k)              = mean(bgImage(aggregatePoints{k}));
    [Gaussian_fit_spots(:,:,k),original_spots(:,:,k),sigmaY_Gaussian(k),sigmaX_Gaussian(k),Gaussian_bgEstimation(k),Gaussian_fit_spots_noBg(:,:,k)] = gaussianFit(position_estimation_centroid(k,:),img);
end

Gaussian_intensity_estimation_noBg = squeeze(sum(sum(Gaussian_fit_spots_noBg,1),2));

Centroid_intensity_estimation_noBg = mean(Centroid_intensity_estimation_noBg);
Gaussian_intensity_estimation_noBg = mean(Gaussian_intensity_estimation_noBg);

maskedImage            = mask.*img;         %the tiny spots within the original image
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

%% Functions
function RW = RW2DKernel(sigma)
% Inverse Laplacian of Gaussian operator, also called as 2D Ricker wavelet,
% similar to difference of Gaussian kernel, frequently used as a blob detector
    x = (0:8*sigma) - 4*sigma; y = x;
    [X,Y] = meshgrid(x,y);
    amplitude = 1.0 / (pi * sigma * 4);
    rr_ww = (X.^2+Y.^2)/(2.*sigma.^2);
    RW = amplitude*(1-rr_ww).*exp(-rr_ww);
end

function mask = maskFilter(mask,sigma)
    mask(1:4*sigma,:) = 0;
    mask(end-4*sigma:end,:) = 0;
    mask(:,1:4*sigma) = 0;
    mask(:,end-4*sigma:end) = 0;
    mask = logical(mask);
end

function mask = aggreMask(img,std)
    se                   = strel('disk',5);
    ksize                = 1;
    h                    = RW2DKernel(ksize);
    i_conv               = imfilter(imtophat(img,se),h,'conv'); 
    x                    = i_conv(:);
    [~,s]                = normfit(x);
    i_conv(i_conv<std*s) = 0;

    se                   = strel('disk',1);
    mask                 = imopen(i_conv,se); %morphological open operation for filtering ting structures(noise)
    mask(mask>0)         = 1;
    mask                 = maskFilter(mask,ksize);
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

function [fit_spot,image_Region,sigmaY,sigmaX,bgEstimation,fit_spot_noBg] = gaussianFit(position,original_img) 
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

    fitting_radius                              = 5;
    amplitude_limits                            = [0 2^16];
    amplitude_range                             = diff(amplitude_limits);
    background_limits                           = [0 2^16];
    background_range                            = diff(background_limits);
    sigma_limits                                = [.1 fitting_radius];
    sigma_range                                 = diff(sigma_limits);
    image_Region                                = original_img(position(2)-fitting_radius:position(2)+fitting_radius,position(1)-fitting_radius:position(1)+fitting_radius);
    theta_limits                                = [-pi/4 pi/4];
    theta_range                                 =  diff(theta_limits);
    
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
    fitted_param                                = lsqnonlin(@ASYMMETRIC_GAUSSIAN_FIT, [.5, .5, AMP_guess, .5, .5, .5, BG_guess], [0 0 0 0 0 0 0], [1, 1, 1, 1, 1, 1, 1], fitting_options);
    [~,Guess_Image]                             = ASYMMETRIC_GAUSSIAN_FIT(fitted_param);
    fit_spot                                    = reshape(Guess_Image,fitting_radius*2+1,fitting_radius*2+1);
    sigmaY                                      = fitted_param(4)*sigma_range+sigma_limits(1);
    sigmaX                                      = fitted_param(5)*sigma_range+sigma_limits(1);
    bgEstimation                                = fitted_param(7)*background_range+background_limits(1);
    fit_spot_noBg                               = fit_spot - bgEstimation;
    
    function [Delta,Guess_Image] = ASYMMETRIC_GAUSSIAN_FIT(guess)
        Row            = (guess(1)-.5)*fitting_radius;
        Col            = (guess(2)-.5)*fitting_radius;
        Amplitude      = guess(3)*amplitude_range+amplitude_limits(1);
        Sigma_row      = guess(4)*sigma_range+sigma_limits(1);
        Sigma_col      = guess(5)*sigma_range+sigma_limits(1);
        Theta          = guess(6)*theta_range+theta_limits(1);
        Background     = guess(7)*background_range+background_limits(1);
        
        
        a              = ( cos(Theta)^2 / (2*Sigma_row^2)) + (sin(Theta)^2 / (2*Sigma_col^2));
        b              = (-sin(2*Theta) / (4*Sigma_row^2)) + (sin(2*Theta) / (4*Sigma_col^2));
        c              = ( sin(Theta)^2 / (2*Sigma_row^2)) + (cos(Theta)^2 / (2*Sigma_col^2));
    
        Guess_Image    = Background + Amplitude*exp(-(a*(regional_indices_row-Row).^2 + 2*b*(regional_indices_row-Row).*(regional_indices_col-Col)+c*(regional_indices_col-Col).^2));
        Delta          = - image_Region(:) + Guess_Image(:);
    end
end
