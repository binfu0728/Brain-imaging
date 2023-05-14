clc;clear;addpath(genpath('C:\Users\bf341\Desktop\code_v3\'));

[gain,offset] = load.loadMap('sycamore'); %load gain and offset map from the specific microscope
[filenames,filepath,z,rsid] = load.loadMeta('test_metadata.csv'); %load metadata to specify where images are saved and how to load them
[k1,k2]    = core.createKernel(1.4,2); %create kernels for the image processing

gain    = repmat(gain,[1 1 17]);
offset  = repmat(offset,[1 1 17]);

%% process
saved               = 0;
oligomer_result     = []; %x,y,z,intensity,background,rsid
non_oligomer_result = []; %x,y,z,rsid
numbers             = []; %oligomer_nums,non_oligomer_nums,rsid

for i = 1%:4:length(filenames)
    img = double(load.Tifread(filenames{i}));
    img = (img-offset).*gain;

    tic
    % create repository for result binary masks
    smallM = false(size(img));
    largeM = main.lbDetection(img);
    centroids = cell(size(img,3),1);
    
    % aggregate detection
    parfor j = 1:size(img,3)
    % for j = 1:size(img,3) 
        [smallM(:,:,j),largeM2,centroids{j}] = main.aggregateDetection(img(:,:,j),k1,k2,0.05,[0.1,10]);
        length(centroids{j})
        largeM(:,:,j) = largeM(:,:,j)|largeM2; %combine LB,LN and medium-sized aggregates
    end
    
    % save objects
    if saved == 1
        [tmpt_oligomer,tmpt_non_oligomer,tmpt_num] = load.BW2table(img,centroids,largeM,rsid(i));
        oligomer_result     = [oligomer_result;tmpt_oligomer];
        non_oligomer_result = [non_oligomer_result;tmpt_non_oligomer];
        numbers             = [numbers;tmpt_num];
    else
        f = visual.plotAllMask(img,smallM,largeM,1,1,[0 500],0.25);
        close all
    end
    ttime = toc;

    fprintf(['Estimate remaining time: ',num2str((ttime*(length(filenames)-i)/60),'%.1f'),' min, finish ',num2str(i),'/',num2str(length(filenames)),'\n']);
end

%% long-format result save
T1 = array2table(numbers,"VariableNames",{'small_nums','large_nums','rsid'});
writetable(T1,'numbers_result.csv');

T2 = array2table(oligomer_result,"VariableNames",{'x','y','z','sum_intensity','bg','rsid'});
writetable(T2,'oligomer_result.csv');

T3 = array2table(non_oligomer_result,"VariableNames",{'x','y','z','rsid'});
writetable(T3,'non_oligomer_result.csv');