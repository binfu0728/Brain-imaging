%% This is the main code for cell and a-syn aggregate detection
% author: Bin Fu, University of Cambridge, bf341@cam.ac.uk

%% add library and check license
clc;clear;
libpath = 'lib';
addpath(genpath(libpath));

files     = dir([pwd,'\*.tif']);
names     = {files.name}';
folders   = {files.folder}';
filenames = fullfile(folders,names);

[gain,offset] = load.loadMap('sycamore',1);
[t_differential,t_integral] = load.loadInfocusThreshold('sycamore');
[k1,k2] = core.createKernel(1.4,2); %create kernels for the image processing

%%
for i = 1:length(filenames) %process for all the images within the data folder
    img = double(load.Tifread(filenames{i})); %read image as a 3D-tiff stack
        
    tic
    img = (img-offset).*gain/0.95; %QE
    z = core.infocusFiltering(focusScore,t_differential*0.5);

    % calculate the gradient map for autofocusing and radiality
    [img2,Gx,Gy,focusScore,integeralScore,cfactor] = core.calculateGradientField(img,k1);

    %aggregate detection
    [dlMask,ndlMask,centroids] = process.aggregateDetection(img,img2,Gx,Gy,k2,0.05,[0.93 60],z,cfactor);
    centroids = centroids{1};

    f = figure;
    imshow(img,[0 400]);
    f1 = figure;
    imshow(img,[0 400]);hold on;
    plot(centroids(:,1),centroids(:,2),'o','MarkerSize',4,'MarkerEdgeColor',[1 0.5 0.5]);
    visual.plotBinaryMask(f1,ndlMask,[0.5 0.5 1]);

    % exportgraphics(f,['./original_img/original_img_',num2str(i),'.png'],'Resolution',300);
    % exportgraphics(f1,['./masked_img/masked_img_',num2str(i),'.png'],'Resolution',300);

    close all;
end
