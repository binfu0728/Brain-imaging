clc;clear;addpath(genpath('D:\code\'));
[filenames,filepath,z,rsid] = load.loadMeta('dab_1_metadata.csv');

% brown
LMean_brown     = 38.35; %L-value for brown
aMean_brown     = 27.75; %a-value for brown
bMean_brown     = 24.9; %b-value for brown
tolerance_brown = 10; %initial threshold value for brown colour (value 5-20 is good)
param = [LMean_brown,aMean_brown,bMean_brown,tolerance_brown];

%blue
LMean_blue     = 75.4;
aMean_blue     = 5.5;
bMean_blue     = -3.4;
tolerance_blue = 6;

%%
for i = 1:length(filenames)
    img       = imread(filenames{i});
    newFolder = load.makeDir(fullfile(['.\dab_result\',filepath{i}])); %result folder
    [BW_asyn] = process.colourFilterLAB(img,param,[0.75,4],0,0.075);

    BW_asyn = imclose(BW_asyn,strel('disk',1));
    BW_asyn = imfill(BW_asyn,'holes');
    BW_asyn = imclearborder(BW_asyn); 

    t_asyn  = regionprops('table',BW_asyn,'MinorAxisLength');
    minorA  = t_asyn.MinorAxisLength;
    idx1    = find(minorA<3); %anything less than 3 pixel in minor length is deleted
    BW_asyn = core.fillRegions(BW_asyn,idx1); 
    BW_asyn = bwareaopen(BW_asyn,9); %anything less than 9 pixel area is deleted
    t_asyn  = regionprops('table',BW_asyn,'Area','Centroid','MajorAxisLength','MinorAxisLength');
    pseduo_circ = 2*t_asyn.MinorAxisLength./(t_asyn.MinorAxisLength + t_asyn.MajorAxisLength);
    tmpt = array2table(pseduo_circ,'VariableNames', {'cp'});
    t_asyn = [t_asyn,tmpt];

    BW_nucl = process.colourFilterLAB(img,[Lmean_bl,amean_bl,bmean_bl,6],[1,2],1,0.08);
    t_nucl  = regionprops('table',BW_nucl,'Area','Centroid');
    
%     writetable(t_asyn,fullfile(newFolder,'result_asyn.csv'));
%     writetable(t_nucl,fullfile(newFolder,'result_nuclei.csv'));

end
