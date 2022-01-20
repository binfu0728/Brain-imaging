% Generalized detection code for IF and DAB images
% Author: Bin Fu, bf341@cam.ac.uk
%%
clc;clear;addpath('util')
filename          = '4neurites_2';

load('./config_gdc/config_24_lb_c2.mat')
img = loadImage(filename,s.imgLoad,s.time,s.zaxis,s.colour,s.channel);

% Pre-processing
[imgg,i]          = preFiltering(img,s.upsampling,s.gaussian_size,s.bpass_size_l,s.bpass_size_h,s.bpass_order,s.mode);

% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>0.975);
t                 = (idx(1) - 1) / (num_bins - 1);
BW                = imbinarize(i,t);
BW                = imfill(BW,'holes');

% %% Post-processing
BW                = postFiltering(BW,imgg,s.intensity_precent,'intensity');
BW                = postFiltering(BW,imgg,s.area_precent,'area');
BW                = postFiltering(BW,imgg,0,'structural_open',s.strelSize);

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
        case 'max'  %for LB/LN
            tmpt = reshape(img,size(img,1),size(img,2),z,t*c);
            tmpt = tmpt(:,:,:,ch:c:t*c);
            tmpt = mean(tmpt,4);
            img  = mean(squeeze(max(tmpt,[],3)),3);     
        case 'mean' %for oligomer
            tmpt = reshape(img,size(img,1),size(img,2),z,t*c);
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
