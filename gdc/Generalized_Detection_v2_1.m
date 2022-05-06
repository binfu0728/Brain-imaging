clc;clear;addpath('lib')addpath('config_gdc');
filename = '5neurites_1.tif';

% Load config
s        = load.loadJSON('config_16_lb_c1.json');

% Load image
img      = load.loadImage(filename,s); %img: orginal image 512x512

% Pre-processing
[img_upsampled,img_processed] = image.preFiltering(img,s); %img_resampled: resampled image 2048x2048, img_processed: after-prefiltered image

% Thresholding
BW = image.thresholding(img_processed,s);

% Post-processing
BW = image.postFiltering(BW,img_upsampled,s.intensity_precent,'intensity'); %dab use i, IF use imgg
BW = image.postFiltering(BW,img_upsampled,s.area_precent,'area');
BW = image.postFiltering(BW,img_upsampled,0,'structural_open',s.strelSize);

% Plot
f1 = figure;
imshow(img_upsampled,[]);
visual.plotBinaryMask(f1,BW,[0.6350 0.0780 0.1840]);
visual.plotScaleBar(f1,img_upsampled,0.107/s.upsampling,5);
