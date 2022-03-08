clc;clear;addpath('util');
% Change all related parameters here and save to configuration file
s         = struct;
% System parameters
s.name    = '20_olig_c2';


s.channel = 2;

s.width   = 512;
s.height  = 512;
s.frames  = 10;  %number of frame, time-scan
s.slices  = 11;  %number of z-samples
s.colour  = 3;   %number of colour channels
s.hyper   ='xyzct'; %from most frequenctly changing to least frequenctly changing

s.imgLoad = 'mean';

s.upsampling        = 4;
s.mode              = 'IF-olig'; %IF,DAB,IF-olig
s.gaussian_size     = 20;
s.bpass_size_l      = 0;
s.bpass_size_h      = 0;
s.bpass_order       = 0;

s.thres             = 0.975;

s.intensity_precent = -1;%default -1
s.area_precent      = -1;%default -1
s.strelSize         = 5; %default 0

saveJSON(s,['config_',s.name,'.json']);
