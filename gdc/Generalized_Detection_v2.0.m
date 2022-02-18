clc;clear;addpath('util')
filename          = '9_1_MMStack_Default.ome';

s                 = loadJSON('config_16_lb_c1.json');
img               = loadImage(filename,s.imgLoad,s.time,s.zaxis,s.colour,s.channel);
%img is the original 512x512 image by different loading method (mean/max)

% Pre-processing
[imgg,i]          = preFiltering(img,s.upsampling,s.gaussian_size,s.bpass_size_l,s.bpass_size_h,s.bpass_order,s.mode);
%imgg is the original image but resampled (e.g. 2048x2048), i is processed image for the thresholding

% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>s.thres);
t                 = (idx(1) - 1) / (num_bins - 1);
BW                = imbinarize(i,t);
BW                = imfill(BW,'holes');

% Post-processing
BW                = postFiltering(BW,imgg,s.intensity_precent,'intensity'); %DAB use i, IF use imgg
BW                = postFiltering(BW,imgg,s.area_precent,'area');
BW                = postFiltering(BW,imgg,0,'structural_open',s.strelSize);

f1 = figure;
imshow(imgg,[]);
plotScaleBar(f1,imgg,0.107/s.upsampling,5);

f2 = figure;
imshow(imgg,[]);
plotBinaryMask(f2,BW,[0.6350 0.0780 0.1840]);
plotScaleBar(f2,imgg,0.107/s.upsampling,5);
