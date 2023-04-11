clc;clear;addpath(genpath('C:\Users\bf341\Desktop\code_v3\'));

[gain,offset] = load.loadMap('sycamore'); %load gain and offset map from the specific microscope
[filenames,filepath,z,rsid] = load.loadMeta('test_metadata.csv'); %load metadata to specify where images are saved and how to load them
[k1,k2,k3]    = core.createKernel(1.4,1,2); %create kernels for the image processing

%% process
saved               = 0;
oligomer_result     = []; %x,y,z,intensity,background,rsid
non_oligomer_result = []; %x,y,z,rsid
numbers             = []; %oligomer_nums,non_oligomer_nums,rsid

for i = 1%length(filenames)
    img    = double(load.Tifread(filenames{i}));
    tic
    % create repository for result binary masks
    smallM = false(size(img));
    largeM = main.LBDetection(img);
    centroids = cell(size(img,3),1);
    
    % aggregate detection
%     parfor j = 1:size(img,3)
    for j = 17%:size(img,3) 
        zimg = (img(:,:,j) - offset) .* gain; %convert to number of photons
        [smallM(:,:,j),largeM2,centroids{j}] = main.aggregateDetection(zimg,k1,k2,k3,25,1.6);
        largeM(:,:,j) = largeM(:,:,j) | largeM2; %combine LB,LN and medium-sized aggregates
    end
    
    % save objects
    if saved == 1
        [tmpt_oligomer,tmpt_non_oligomer,tmpt_num] = load.BW2table(img,centroids,largeM,rsid(i));
        oligomer_result     = [oligomer_result;tmpt_oligomer];
        non_oligomer_result = [non_oligomer_result;tmpt_non_oligomer];
        numbers             = [numbers;tmpt_num];
    else
        figure;imshow(img(:,:,17),[0 500]);
        f = figure;imshow(img(:,:,17),[0 500]);
        length(centroids{17})
%         f = visual.plotAllMask(img,smallM,largeM,1,1,[0 500],[17 17],0.5);
        visual.plotBinaryMask(f,smallM(:,:,17),[0,0.5,1]);
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