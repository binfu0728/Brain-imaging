clc;clear;addpath(genpath('D:\code\'));
s.channel       = 1;
s.width         = 1200;
s.height        = 1200;
s.frames        = 1;  %number of frame, time-scan
s.slices        = 17;  %number of z-samples
s.colour        = 1;   %number of colour channels
s.hyper         = 'xytcz'; %from most frequenctly changing to least frequenctly changing

s.k1_dog        = 4;
s.k2_dog        = 40;
s.k_log         = 0;
s.dim           = 2;

s.thres_method  = 'otsu'; %otsu/percentage
s.ostu_num      = 1;
s.percent       = 0;

s.area          = 20; %unit:pixel
s.intens_ratio  = 1.2; %unit:ratio
s.disk          = 0; %unit:counts

load.saveJSON(s,'config_lb_sycamore.json');