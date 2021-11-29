%%
% This code is the adaptive version of Trevor Wu's code in Python with
% some changes to be suitable for the MATLAB running. The code is for
% selecting the tiny spots in a noisy image. It is not fully tested on very
% high SNR image(vrey little background noise).
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
% Arthor: Bin Fu, bf341@cam.ac.uk
%%
clear;clc;

% Initilization
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

se       = strel('disk',10); %create a flat structuring element for top-hat filtering, with 10 radius
h        = RW2DKernel(3,1);  %create a convolution kernel 
i_conv   = imfilter(imtophat(img,se),h,'conv'); %convolution and top-hat filter(rolling-ball filter)

x        =  i_conv(:);
[m,s]    = normfit(x);
% y        = normpdf(x,m,s);
i_conv(i_conv<sigma*s) = 0; %image thresholding

se       = strel('disk',1);   %create another flat structuring element for opening operation, with 1 radius
mask     = imopen(i_conv,se); %morphological open operation for filtering ting structures(noise)
mask(mask>0) = 1;             %binary the mask
mask     = maskFilter(mask);  %crop the edge points, which may introdu wrong estimation
maskedImage = mask.*img;        %the tiny spots within the original image

bgImage  = (1-mask).*img; %pure background of image (without regions of detected points)
filledBg = imfill(bgImage); %pure background of image (with regions of detected points, the value is estimated)
sigImage = abs(img-filledBg); %pure signal intensity of the detected points. (i = signal + background, filledBg = background)

mask     = logical(mask);
CC       = bwconncomp(mask); %8-connectivity(all direction connection will be counted)
aggregatePoints = CC.PixelIdxList;
s               = regionprops(mask,'centroid','area');
centroids       = cat(1,s.Centroid); %centroid for each detected points
% areas           = cat(1,s.Area);
intensity       = zeros(length(s),1);
avg_inten       = zeros(length(s),1);
area            = zeros(length(s),1);

for k = 1:length(s)
    idx         = ind2sub(size(mask),cell2mat(aggregatePoints(k))); %all pixel indice for a detected spot 
    intensity(k)= sum(sigImage(idx));
    avg_inten(k)= intensity(k)/length(idx);
    area(k)     = length(idx)*pixSize^2;
end

% result saving
result_excel    = [(1:length(area))',area,intensity,avg_inten];
result_excel    = array2table(result_excel,"VariableNames",["No. of Olig","Area(um)","Intensity","Avg_inten"]);
writetable(result_excel,[filename,'_result.csv']);
maskedImage     = normalize16(maskedImage);
processedFrame  = normalize16(img);
imwrite(maskedImage,[filename,'_maksedImage.tif']);
imwrite(processedFrame,[filename,'_processedFrame.tif']);

function RW = RW2DKernel(a,sigma)
% Inverse Laplacian of Gaussian operator, also called as 2D Ricker wavelet,
% similar to difference of Gaussian kernel, frequently used as a blob detector
    x = (0:8*sigma) - 4*sigma; y = x;
    [X,Y] = meshgrid(x,y);
    amplitude = 1.0 / (pi * sigma * 4) * a;
    rr_ww = (X.^2+Y.^2)/(2.*sigma.^2);
    RW = amplitude*(1-rr_ww).*exp(-rr_ww);
end

function mask = maskFilter(mask)
    mask(1:10,:) = 0;
    mask(end-10:end,:) = 0;
    mask(:,1:10) = 0;
    mask(:,end-10:end) = 0;
end

function img = normalize16(img)
    img = img - min(min(img)) + 1;
    img = uint16(img./max(max(img)) .* (2^16-1));
end

function tiff_stack = Tifread(filename)
    tiff_info = imfinfo(filename); % return tiff structure, one element per image
    tiff_stack = imread(filename, 1) ; % read in first image
    %concatenate each successive tiff to tiff_stack
    if size(tiff_info, 1) > 1
        for ii = 2 : size(tiff_info, 1)
            temp_tiff = imread(filename, ii);
            tiff_stack = cat(3 , tiff_stack, temp_tiff);
        end
    end
end