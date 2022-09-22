clc;clear;addpath(genpath('D:\code\'));
s.channel       = 1;
s.width         = 512;
s.height        = 512;
s.frames        = 10;  %number of frame, time-scan
s.slices        = 23;  %number of z-samples
s.colour        = 2;   %number of colour channels
s.hyper         = 'xytcz'; %from most frequenctly changing to least frequenctly changing

s.k1_dog        = 0;
s.k2_dog        = 0;
s.k_log         = [4 4];
s.dim           = 2;

s.thres_method  = 'percentage'; %otsu/percentage
s.ostu_num      = 0;
s.percent       = 0.975;

s.area          = 0; %unit:pixel
s.intens_ratio  = 0; %unit:ratio
s.disk          = 5; %unit:counts

load.saveJSON(s,'config_oligomer_biscut_2.json');