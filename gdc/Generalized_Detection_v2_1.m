clc;clear;addpath('util')
filename          = '5neurites_1.tif';

%% lb/ln analysis
s = loadJSON('config_16_lb_c1.json');

img = loadImage(filename,s);
%img orginal image 512x512
% Pre-processing
[imgg,i]          = preFiltering(img,s.upsampling,s.gaussian_size,s.bpass_size_l,s.bpass_size_h,s.bpass_order,s.mode);
%imgg resampled image 2048x2048
%i after-prefiltered image

% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>0.975);
t                 = (idx(1) - 1) / (num_bins - 1);
BW                = imbinarize(i,t);
BW                = imfill(BW,'holes');%binary mask

% %% Post-processing
BW                = postFiltering(BW,imgg,s.intensity_precent,'intensity');
BW                = postFiltering(BW,imgg,s.area_precent,'area');
BW                = postFiltering(BW,imgg,0,'structural_open',s.strelSize);

f1 = figure; imshow(imgg,[]);
plotBinaryMask(f1,BW,[0.6350 0.0780 0.1840]);
plotScaleBar(f1,imgg,0.107/s.upsampling,5);