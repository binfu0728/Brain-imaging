% Generalized detection code for IF and DAB images
% Author: Bin Fu, bf341@cam.ac.uk
%%
clc;clear;addpath('util')
filename          = '9_1_MMStack_Default.ome';

%% lb/ln analysis
load('./config_gdc/config_16_lb_c1.mat');
s.imgLoad = 'mean';
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

%% Oligomer analysis (elimination of large objects), run lb first and then run this block
load('config_16_olig_c1.mat');

% Pre-processing
[imgg,i]          = preFiltering(img,s.upsampling,s.gaussian_size,s.bpass_size_l,s.bpass_size_h,s.bpass_order,s.mode);

% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>0.975);
t                 = (idx(1) - 1) / (num_bins - 1);
BW2               = imbinarize(i,t);
BW2               = imfill(BW2,'holes');

% Post-processing
BW2               = postFiltering(BW2,imgg,s.area_precent,'area'); %if dab change to i
BW2               = postFiltering(BW2,imgg,s.intensity_precent,'intensity');
BW2               = postFiltering(BW2,imgg,0,'structural_open',s.strelSize);
% plotBinaryMask(BW,(imgg));

CC            = bwconncomp(BW2);
regions       = CC.PixelIdxList;

masks = cat(3,BW,BW2);
[~,~,test] = findCoincidence(masks,[1,2],2,'LB/LN');

idx = find(test>0.3);
for k = 1:length(idx)
    BW2(regions{idx(k)}) = 0;
end

plotBinaryMask(BW2,imgg);

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
