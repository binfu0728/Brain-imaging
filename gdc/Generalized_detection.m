% Generalized detection code for IF and DAB images
% Author: Bin Fu, bf341@cam.ac.uk
%%
clc;clear;addpath('util')
% filename          = '7_OD0.3_40x_4_MMStack_Default.ome';
filename          = '4neurites_2';
% filename          = '4_LB_40x_4_MMStack_Default.ome';

channel  = 2;
time     = 10;  %number of frame, time-scan
zaxis    = 11;  %number of z-samples
colour   = 3;   %number of colour channels

img = loadImage(filename,'multi-max',time,zaxis,colour,channel);

upsampling        = 4;
mode              = 'IF';
gaussian_size     = 200; %200 for 40x and 100x, if img has undetected but wanted large obj, choose a larger value
bpass_size_l      = 4;   %4 for 40x and 100x, if img has undetected but wanted small obj, choose a smaller value
bpass_size_h      = 200;
bpass_order       = 4;   %1 for 40X IF image, 4 for DAB due to less distinguishable background
% intensity_precent = 0.25; %intensity post-fitering is not used in DAB image
intensity_precent = 0.5; %intensity post-fitering is not used in DAB image
% area_precent      = 0.2;  

% %% Pre-processing
[imgg,i]          = preFiltering(img,upsampling,gaussian_size,bpass_size_l,bpass_size_h,bpass_order,mode);

% %% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>0.975);
t                 = (idx(1) - 1) / (num_bins - 1);
BW                = imbinarize(i,t);
BW                = imfill(BW,'holes');

% %% Post-processing
BW                = postFiltering(BW,i,intensity_precent,'intensity');
% BW                = postFiltering(BW,i,area_precent,'area');
% BW              = postFiltering(BW,img,0,'structural_open',4);

plotBinaryMask(BW,imgg);

% % %% Analysis
% % CC            = bwconncomp(BW);
% % regions       = CC.PixelIdxList;
% % s             = regionprops('table',BW,'Area','MajorAxisLength','MinorAxisLength');
% % area          = s.Area;
% % minorL        = s.MinorAxisLength;
% % majorL        = s.MajorAxisLength;
% 
% % result_excel    = [(1:size(s,1))',area,minorL,majorL];
% % result_excel    = array2table(result_excel,"VariableNames",["No. of LB/LN","Area(pixel)","MinorAxisLength","MajorAxisLength"]);
% % writetable(result_excel,[filename,'_result.csv']);
%%
BW              = BW*(2^16-1);
processedFrame  = imgg;
imwrite(BW,[filename,'_mask_c',num2str(channel),'.tif']);
% imwrite(processedFrame,[filename,'_processedFrame.tif']);

%% Functions
function img = loadImage(filename,mode,t,z,c,ch) 
% input type : none
% output type: double
    if nargin<3
        t = nan;z = nan; c = nan; ch = nan;
    end
    
    img = double(Tifread([filename,'.tif']));
    switch mode
        case 'single-mean' %for LB/LN
            img = mean(img,3);
        case 'multi-max'  %for LB/LN
            tmpt = reshape(img,size(img,1),size(img,1),z,t*c);
            tmpt = tmpt(:,:,:,ch:c:t*c);
            img  = mean(squeeze(max(tmpt,[],3)),3);     
        case 'multi-mean' %for oligomer
            tmpt = reshape(img,size(img,1),size(img,1),z,t*c);
            tmpt = tmpt(:,:,:,ch:c:t*c);
            img  = mean(squeeze(tmpt(:,:,1,:)),3);
        otherwise
            error('wrong');    
    end
end

function [img_upsampled,img_processed] = preFiltering(img,upsampling,gsize,bsize_l,bsize_h,order,mode) 
% input type : double
% output type: uint16
    img_upsampled = normalize16(imresize(img,upsampling,'bicubic'));
    img_processed = imgaussfilt(img_upsampled,gsize);

    switch mode
        case 'IF'
            img_processed = img_upsampled - img_processed;
        case 'IF-olig'
            img_processed = img_upsampled - img_processed;    
        case 'DAB'
            img_processed = img_processed - img_upsampled;
        otherwise
            error('wrong');    
    end
    
    for i = 1:order
        img_processed = normalize16(bandpass(img_processed,bsize_l,bsize_h));
    end
    
    if strcmp(mode,'IF-olig')
        h = RW2DKernel(upsampling);  %create a convolution kernel 
        i = conv2(img_processed,h,'same'); %convolution and top-hat filter(rolling-ball filter)
        i(i<0)   = 0;
        img_processed = normalize16(i);
    end
end

function [BW,idx] = postFiltering(BW,img,percentage,method,upsampling)
% input type: uint16
    if nargin<5
       upsampling = nan; 
    end
    
    CC         = bwconncomp(BW);
    regions    = CC.PixelIdxList; 
    
    switch method
        case 'area'
            s          = regionprops('table',BW,'Area');
            areas      = s.Area;
            sorting    = normalize16(areas);
        case 'intensity'
            sigImage        = abs(img-imfill(uint16((1-BW)).*img));
            avg_intensity   = zeros(length(regions),1);
            for k = 1:length(regions)
                avg_intensity(k)  = mean(sigImage(regions{k}));
            end
            sorting         = normalize16(avg_intensity);
        case 'structural_open'
            se = strel('disk',upsampling);
            BW = imopen(BW,se); 
            return
        otherwise
            error('wrong method');
    end
    
    num_bins     = 2^16;
    counts       = imhist(sorting,num_bins);
    p            = counts / sum(counts);
    omega        = cumsum(p);

    idx          = find(omega>percentage);
    idx          = find(sorting<idx(1));
    
    for k = 1:length(idx)
        BW(regions{idx(k)}) = 0;
    end
end