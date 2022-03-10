clc;clear;addpath('util');addpath('config_gdc');
filename = '5neurites_1.tif';

% Load config
s        = loadJSON('config_16_lb_c1.json');

% Load image
img      = loadImage(filename,s); %img: orginal image 512x512

% Pre-processing
[img_resampled,img_processed] = preFiltering(img,s); %img_resampled: resampled image 2048x2048, img_processed: after-prefiltered image

% Thresholding
BW = thresholding(img_processed,s);

% Post-processing
BW = postFiltering(BW,img_resampled,s.intensity_precent,'intensity'); %dab use i, IF use imgg
BW = postFiltering(BW,img_resampled,s.area_precent,'area');
BW = postFiltering(BW,img_resampled,0,'structural_open',s.strelSize);

% Plot
f1 = figure; imshow(img_resampled,[]);
plotBinaryMask(f1,BW,[0.6350 0.0780 0.1840]);
plotScaleBar(f1,img_resampled,0.107/s.upsampling,5);
