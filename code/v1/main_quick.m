% quick look version, put images and this script into the same folder
clc;clear;addpath(genpath('D:\code\'));
zi       = 4; %initial slice
zf       = 14; %final slice
channel  = 2; %used colour channel

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
    [smallM,largeM] = process.aggregateDetection(img,s1,s2,zi,0); %aggregate, large and small
%     cellM           = process.cellDetection(img,s); %cell
%     smallM          = zeros(2048,2048,size(img,3)); %oligomer, only small
%     for j = 1:size(img,3)
%         zimg          = double(imresize(img(:,:,j),4));
%         smallM(:,:,j) = process.oligomerDetection(zimg,s);
%     end

    for j = 1:size(img,3)
        %aggregate / oligomer
        f    = visual.plotAll(imresize(img(:,:,j),4),largeM(:,:,j),[0.6350 0.0780 0.1840],'contrast'); %comment this line if oligomer is used
               visual.plotBinaryMask(f,smallM(:,:,j),[0.8500 0.3250 0.0980]);
        pause(0.25);

%         %cell
%         f = visual.plotAll(img(:,:,j),BW(:,:,j),[0.9290 0.6940 0.1250],'contrast');
%         pause(0.25);
    end
    close all;
end
