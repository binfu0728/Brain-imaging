% version used with mid_rawdata dataset and before, adapted version of 2023.05 Bin's code for aggregate extraction in Noemie's code
% some called functions have been updated to recent version (2023.06)

clc;clear;
mypath = 'C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab\code_v3\'; 
addpath(genpath(mypath)); %path where you download the code

[gain,offset] = load.loadMap('sycamore'); %load gain and offset map from the specific microscope
[t_differential,t_integral] = load.loadInfocusThreshold('sycamore');
[filenames,filepaths,zo,rsid] = load.loadMeta('midrd_metadata.xlsx'); %load metadata to specify where images are saved and how to load them
[k1,k2]    = core.createKernel(1.4,2); %create kernels for the image processing

%% process

saved               = 1; % set to 1 to get csv file needed to run aggregate_extraction
ds_save             = 1; % set to 1 to be able to run aggregate_extraction
%disp_og             = 0; % added 20230519 to display original images  

oligomer_result     = []; %x,y,z,intensity,background,rsid              small objects = oligomers
non_oligomer_result = []; %x,y,z,rsid                                   large objects = non oligomers
numbers             = []; %oligomer_nums,non_oligomer_nums,rsid 

%% process pt2 

for i = 1:length(filenames) %filenames is a nx1 cell array, n being nb of files
    
    format shortG; % added 20230530 to get better idea of pixel intensity values in img

    pgain    = (repmat(gain,[1 1 zo(i,2)])); % moved and modified 20230519, last dim has to correspond to zf, may not be 17
    poffset  = (repmat(offset,[1 1 zo(i,2)]));

    img     = double(load.Tifread(filenames{i})); % img is a tif stack of height x width x zslices dimension
    img     = (img-poffset).*pgain;

        % if disp_og == 1
        %     im = (img(:,:,i));
        %     image(im)
        %     title 'no conversion'
        %     %imagesc does this job
        %     imd = (double(im)+1)/65535; %convert to double and adjust to 8bit pixel values 
        %     figure, imagesc(imd) % matlab doesnt display 16bit images but im_{i} stores the right uint16 data
        %     colormap gray; title 'converted'
        % end

    % datastore save - could move it to the end to save only 3D images of samples that contain non oligo results 
    matfilename_id = string(rsid(i));
    matfilename = strcat('image_',matfilename_id, '.mat');
    if ds_save == 1
        save(matfilename, 'img',"-v7","-nocompression")
    end

    tic

    %%

    % create repository for result binary masks
    smallM = false(size(img)); % gives logical zeros array
    largeM = main.LBDetection(img); % gives a logical array of where there should be large LBs
    centroids = cell(size(img,3),1); % creates a zf x 1 dim empty cell

    % aggregate detection in each separate slice 
    thres = 0.05;
    rad_thres = [0.1,10]; % radiality magnitude threshold 

    for j = 1:size(img,3) % = 1:zf
        [smallM(:,:,j),largeM2,centroids{j}] = main.aggregateDetection(img(:,:,j),k1,k2,thres,rad_thres); 
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

    %%
    ttime = toc;

    fprintf(['Estimate remaining time: ',num2str((ttime*(length(filenames)-i)/60),'%.1f'),' min, finish ',num2str(i),'/',num2str(length(filenames)),'\n']);
    % doesnt display right approximation when multiple rounds 

end

%% long-format result save
if saved == 1
    T1 = array2table(numbers,"VariableNames",{'small_nums','large_nums','rsid'});
    writetable(T1,'numbers_result.csv');

    T2 = array2table(oligomer_result,"VariableNames",{'x','y','z','sum_intensity','bg','rsid'});
    writetable(T2,'oligomer_result.csv');

    T3 = array2table(non_oligomer_result,"VariableNames",{'x','y','z','rsid'});
    writetable(T3,'non_oligomer_result.csv');
    
end


