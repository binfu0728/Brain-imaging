clc;clear;addpath(genpath('D:\code\'));
[filenames,filepath,z,rsid] = load.loadMeta('dab_1_metadata.csv');

% brown
LMean_brown     = 38.35;
aMean_brown     = 27.75;
bMean_brown     = 24.9;
tolerance_brown = 10;

%blue
LMean_blue     = 75.4;
aMean_blue     = 5.5;
bMean_blue     = -3.4;
tolerance_blue = 6;

for i = 1:length(filenames)
    img     = imread(filenames{i});
    newFolder = load.makeDir(fullfile(['.\dab_result\',filepath{i}]));
    BW_asyn = colourFilterLAB(img,[LMean_brown,aMean_brown,bMean_brown,tolerance_brown],[0.75,3.5],0,0.05);
    BW_asyn = bwareaopen(BW_asyn,5);
    t_asyn  = regionprops('table',BW_asyn,'Area','Centroid','Circularity','Eccentricity','EquivDiameter','MajorAxisLength','MinorAxisLength','Perimeter');
    BW_nucl = colourFilterLAB(img,[LMean_blue,aMean_blue,bMean_blue,tolerance_blue],[1,2],1,0.08);
    t_nucl  = regionprops('table',BW_nucl,'Area','Centroid','Circularity','Eccentricity','EquivDiameter','MajorAxisLength','MinorAxisLength','Perimeter');
    
    BW_asyn = imdilate(BW_asyn,strel('disk',1));
    BW_asyn = imclearborder(BW_asyn); 
%     writetable(t_asyn,fullfile(newFolder,'result_asyn.csv'));
%     writetable(t_nucl,fullfile(newFolder,'result_nuclei.csv'));

%     figure;
%     imshow(img);
% %     pause(0.75);
    f = figure;
    imshow(img);
    visual.plotBinaryMask(f,BW_asyn,[0.4660 0.6740 0.1880]);
%     pause(0.75);
%     close all
end
