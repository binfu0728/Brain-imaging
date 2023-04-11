clc;clear;addpath(genpath('D:\code\'));
[filenames,filepath,~,rsid] = load.loadMeta('dab_1_metadata.csv');

Lmean_br = [38.35,47.27,42.77];
amean_br = [27.75,21.54,26.11];
bmean_br = [24.90,25.16,22.65];

Lmean_bl = 75.4;
amean_bl = 5.5;
bmean_bl = -3.4;

% brown
LMean_brown     = Lmean_br(1); 
aMean_brown     = amean_br(1);
bMean_brown     = bmean_br(1);
tolerance_brown = 15;
param = [LMean_brown,aMean_brown,bMean_brown,tolerance_brown];

%%
for i = 100%:length(filenames)
    img     = imread(filenames{i});
    newFolder = load.makeDir(fullfile(['.\dab_result_round1\',filepath{i}]));
    [BW_asyn] = process.colourFilterLAB(img,param,[0.75,4],0,0.075);

    BW_asyn = imclose(BW_asyn,strel('disk',1)); %connect some fractions from a large LN
    BW_asyn = imfill(BW_asyn,'holes');
    BW_asyn = imclearborder(BW_asyn); % clear objects at the border

    t_asyn  = regionprops('table',BW_asyn,'MinorAxisLength'); 
    minorA  = t_asyn.MinorAxisLength;
    idx1    = find(minorA<3); %find minor axis length < 3 (i.e. inaccurate binary mask)
    BW_asyn = core.fillRegions(BW_asyn,idx1); %erase objects with minor axis length < 3 on the binary mask
    BW_asyn = bwareaopen(BW_asyn,9); %further clean some diffraction-limited object (3x3)
    
    t_asyn  = regionprops('table',BW_asyn,'Area','Centroid','MajorAxisLength','MinorAxisLength');
    if ~isempty(t_asyn)
        pseduo_circ = 2*t_asyn.MinorAxisLength./(t_asyn.MinorAxisLength + t_asyn.MajorAxisLength);
        tmpt = array2table(pseduo_circ,'VariableNames', {'cp'});
        t_asyn = [t_asyn,tmpt];
    else
        continue
    end

    BW_nucl = process.colourFilterLAB(img,[Lmean_bl,amean_bl,bmean_bl,6],[1,2],1,0.075);
    t_nucl  = regionprops('table',BW_nucl,'Area','Centroid');
    
%     writetable(t_asyn,fullfile(newFolder,'result_asyn.csv'));
%     writetable(t_nucl,fullfile(newFolder,'result_nuclei.csv'));

    figure;
    imshow(img);
    pause(0.75);
    f = figure;
    imshow(img);
    visual.plotBinaryMask(f,BW_asyn,[0.4660 0.6740 0.1880]);
    pause(0.75);
    visual.plotBinaryMask(f,BW_nucl,[0.3010 0.7450 0.9330]);
    pause(1);
%     close all
    i
end
