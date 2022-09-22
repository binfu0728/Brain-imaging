% quick look version, put images and this script into the same folder
clc;clear;addpath(genpath('D:\code\'));
zi       = 4;
zf       = 14;
channel  = 2;

%%
files    = dir([pwd,'\*.tif']);
names    = {files.name}';
s1       = load.loadJSON('config_lb_biscut.json'); %lb
s2       = load.loadJSON('config_oligomer_biscut.json'); %oligomer
s        = load.loadJSON('config_microglia_biscut.json'); %cell

for i = 1%:length(names)
    img = load.loadImage(names{i},s);
    img = squeeze(mean(img,4));%xyzc
    img = img(:,:,zi:zf,channel);
    [smallM,largeM] = process.aggregateDetection(img,s1,s2,zi,0); %aggregate
%     cellM           = process.cellDetection(img,s); %cell

    for j = 1:size(img,3)
        %aggregate
        f    = visual.plotAll(imresize(img(:,:,j),4),largeM(:,:,j),[0.6350 0.0780 0.1840],'contrast');
               visual.plotBinaryMask(f,smallM(:,:,j),[0.8500 0.3250 0.0980])
        pause(0.25);

%         %cell
%         f = visual.plotAll(img(:,:,j),BW(:,:,j),[0.9290 0.6940 0.1250],'contrast');
%         pause(0.25);
    end
    close all;
end