%% lb/ln analysis
clc;clear;addpath('util')
filename          = '9_1_MMStack_Default.ome';

s = loadJSON('config_16_lb_c1.json');
img = loadImage(filename,s.imgLoad,s.time,s.zaxis,s.colour,s.channel);

% Pre-processing
[imgg,i]          = preFiltering(img,s.upsampling,s.gaussian_size,s.bpass_size_l,s.bpass_size_h,s.bpass_order,s.mode);

% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>s.thres);
t                 = (idx(1) - 1) / (num_bins - 1);
BW                = imbinarize(i,t);
BW                = imfill(BW,'holes');

% %% Post-processing
BW                = postFiltering(BW,imgg,s.intensity_precent,'intensity');
BW                = postFiltering(BW,imgg,s.area_precent,'area');
BW                = postFiltering(BW,imgg,0,'structural_open',s.strelSize);

f1 = figure; imshow(imgg,[]);
plotBinaryMask(f1,BW,[0.6350 0.0780 0.1840]);
plotScaleBar(f1,imgg,0.107/s.upsampling,5);

%% Oligomer analysis (elimination of large objects), run lb first and then run this block
load('config_16_olig_c1.mat');

% Pre-processing
[imgg,i]          = preFiltering(img,s.upsampling,s.gaussian_size,s.bpass_size_l,s.bpass_size_h,s.bpass_order,s.mode);

% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>s.thres);
t                 = (idx(1) - 1) / (num_bins - 1);
BW2               = imbinarize(i,t);
BW2               = imfill(BW2,'holes');

% Post-processing
BW2               = postFiltering(BW2,imgg,s.area_precent,'area'); %if dab change to i
BW2               = postFiltering(BW2,imgg,s.intensity_precent,'intensity');
BW2               = postFiltering(BW2,imgg,0,'structural_open',s.strelSize);
% f2 = figure; imshow(imgg,[]);
% plotBinaryMask(f2,BW2,[0.4940 0.1840 0.5560]);
% plotScaleBar(f1,imgg,0.107/s.upsampling,5);

CC            = bwconncomp(BW2);
regions       = CC.PixelIdxList;

masks = cat(3,BW,BW2);
[~,~,test] = findCoincidence(masks,[1,2],2,'LB/LN');

idx = find(test>0.3);
for k = 1:length(idx)
    BW2(regions{idx(k)}) = 0;
end

f3 = figure; imshow(imgg,[]);
plotBinaryMask(f3,BW2,[0.9290 0.6940 0.1250]);
plotScaleBar(f3,imgg,0.107/s.upsampling,5);

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
