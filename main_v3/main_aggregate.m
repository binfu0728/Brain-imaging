clc;clear;addpath(genpath('C:\Users\bf341\Desktop\code_v3\'));

[gain,offset] = load.loadMap('sycamore',17);
[t_differential,t_integral] = load.loadInfocusThreshold('sycamore');
[filenames,filepath,~,rsid] = load.loadMeta('sycamore_compare_test_metadata.xlsx'); %load metadata to specify where images are saved and how to load them
[k1,k2] = core.createKernel(1.4,2); %create kernels for the image processing

%% process
saved           = 0;
oligomer_result = cell(length(filenames),1); %x,y,z,intensity,background,rsid (per aggregate)
non_oligomer_position  = cell(length(filenames),1); %x,y,z,rsid (per aggregate)
non_oligomer_intensity = cell(length(filenames),1); %intensity,background,z,rsid (per aggregate)
numbers         = cell(length(filenames),1); %oligomer_nums,non_oligomer_nums,rsid (per slice)
property        = zeros(size(filenames,1),3); %zi,zf,blank (per fov)

for i = 1%:length(filenames)
    img = double(load.Tifread(filenames{i}));
        
    tic
    img = (img-offset).*gain;

    % calculate the gradient map for autofocusing and radiality
    [img2,Gx,Gy,focusScore,integeralScore] = core.calculateGradientField(img,k1);
    
    % autofocusing checking
    if integeralScore < t_integral/1e7 %empty frame
        property(i,3) = 1;
        continue
    else
        z = core.infocusFiltering(focusScore,t_differential);
        property(i,1:2) = z;
    end
    
    %aggregate detection
    [dlMask,ndlMask,centroids] = main.featureDetection(img,img2,Gx,Gy,k2,0.05,[0.09 10],z);
    
    % save objects
    if saved == 1
        [oligomer_result{i},non_oligomer_position{i},non_oligomer_intensity{i},numbers{i}] = load.BW2table(img,centroids,ndlMask,z,rsid(i));
    else
        f = visual.plotAllMask(img,dlMask,ndlMask,1,1,[0 500],0.25);
        % close all
    end
    ttime = toc

    % fprintf(['Estimate remaining time: ',num2str((ttime*(length(filenames)-i)/60),'%.1f'),' min, finish ',num2str(i),'/',num2str(length(filenames)),'\n']);
end

% %% long-format result save
% T1 = array2table(numbers,"VariableNames",{'small_nums','large_nums','rsid'});
% writetable(T1,'numbers_result.csv');
% 
% T2 = array2table(oligomer_result,"VariableNames",{'x','y','z','sum_intensity','bg','rsid'});
% writetable(T2,'oligomer_result.csv');
% 
% T3 = array2table(non_oligomer_position,"VariableNames",{'x','y','z','rsid'});
% writetable(T3,'non_oligomer_result.csv');