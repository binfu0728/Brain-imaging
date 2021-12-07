% The code is for selecting the tiny spots in a brain image
% 
% Input  : 1.Number of z-scan
%          2.Number of time-scan
%          3.Number of channels
%          4.Directory name
%          5.Pixel size
%          6.Threshold (standard deviation)
%          7.Kernel size for image processing
% 
% Output : 1.csv file contains aggregates area, intensity and average intensity
%          2.masked Image that only displays the oligomers in the original image
%          3.processed Image that represents the original image being processed
% 
% Author: Bin Fu, bf341@cam.ac.uk
%% Initilization
clear;clc;

filename = '14_1_MMStack_Default.ome'; 
pixSize  = 0.1; %unit in um
time     = 10;  %number of frame, time-scan
zaxis    = 11;  %number of z-samples
colour   = 3;   %number of colour channels
sigma    = 2;   %portion of rejected background

% Image processing & aggregate counting
img      = double(Tifread([filename,'.tif']));
channel  = 1;
tmpt     = reshape(img,size(img,1),size(img,1),zaxis,time*colour);
c        = tmpt(:,:,:,channel:colour:time*colour); %one colour channel, row x col x zaxis x time(4D hyperstack);
img      = mean(squeeze(c(:,:,1,:)),3); %row x col x time, The processed image is an average
% c = squeeze(c(:,:,:,1)); %row x col x zaxis

se       = strel('disk',5); %create a flat structuring element for top-hat filtering, with 10 radius
h        = RW2DKernel(1);  %create a convolution kernel 
i_conv   = imfilter(imtophat(img,se),h,'conv'); %convolution and top-hat filter(rolling-ball filter)

x        =  i_conv(:);
[m,s]    = normfit(x);
% y        = normpdf(x,m,s);
i_conv(i_conv<sigma*s) = 0; %image thresholding

se               = strel('disk',1);     %create another flat structuring element for opening operation, with 1 radius
bgmask           = imopen(i_conv,se);   %morphological open operation for filtering ting structures(noise)
bgmask(bgmask>0) = 1;                   %binary the mask
bgmask           = maskFilter(bgmask,1);%crop the edge points due to auto-filling of convolution
maskedImage      = bgmask.*img;         %the tiny spots within the original image

CC                     = bwconncomp(bgmask); %8-connectivity(all direction connection will be counted)
aggregatePoints        = CC.PixelIdxList;
s                      = regionprops(bgmask,'centroid','area','MinorAxisLength','MajorAxisLength');
longD                  = cat(1,s.MajorAxisLength); shortD = cat(1,s.MinorAxisLength);
centroids              = cat(1,s.Centroid); %centroid for each detected points
% position               = round(centroids);

segments = false(512,512,length(s));
for i = 1:length(s)
    tmpt = false(512,512);
    tmpt(aggregatePoints{i}) = 1;
    if longD(i)-shortD(i)<5
        dilatedR = 1;
    else
        dilatedR = 2;
    end
    se = strel('disk',dilatedR);
    tmpt = imdilate(tmpt,se); 
    segments(:,:,i) = tmpt;
end
sigmask = max(segments,[],3);

bgEstimation_fill      = (1-bgmask).*img;     %bg = image - spots, estimated by performing a flood-fill operation
bgImage                = imfill(bgEstimation_fill); %bg estimation based on bgImage
sigImage               = abs(img-imfill((1-sigmask).*img)); %pure signal intensity of the detected points. (i = signal + background, filledBg = background)

intensity       = zeros(length(s),1);
background      = zeros(length(s),1);
area            = cat(1,s.Area);

for k = 1:length(s)
    intensity(k)  = sum(sigImage(aggregatePoints{k}));
    background(k) = mean(bgImage(aggregatePoints{k})); 
end

% result saving
result_excel    = [(1:length(s))',area,intensity,background];
result_excel    = array2table(result_excel,"VariableNames",["No. of Olig","Area(um)","Total Intensity","Mean Background"]);
writetable(result_excel,[filename,'_result.csv']);
maskedImage     = normalize16(maskedImage);
processedFrame  = normalize16(img);
imwrite(maskedImage,[filename,'_maksedImage.tif']);
imwrite(processedFrame,[filename,'_processedFrame.tif']);

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

function img = normalize16(img)
    img = img - min(min(img)) + 1;
    img = uint16(img./max(max(img)) .* (2^16-1));
end

function tiff_stack    = Tifread(filename)
    tiff_info              = imfinfo(filename);
    width                  = tiff_info.Width;
    height                 = tiff_info.Height;
    tiff_stack             = uint16(zeros(height(1),width(1),length(tiff_info)));
    for i                  = 1:length(tiff_info)
        tiff_stack(:,:,i)      = imread(filename, i);
    end
end