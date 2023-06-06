clc;clear;
mypath = 'C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab\code_v3\'; % Added 20230515
addpath(genpath(mypath)); %path where you download the code

filedir           = 'E:\Parkinsons Project\Sycamore_data\Test Noemie\'; %main directory where you have the data (above round)
T                 = core.makeMetadata(filedir);
filenames         = T.filenames; % sample folders have to contain only the original image tif file

%% Read through all folders and select used slices

for i = 1:length(filenames)
    tiff_info   = imfinfo(filenames{i}); %length of tiffinfo = number of tif images in a tif stack
    zs(i,:)     = [1 length(tiff_info)]; %[zi zf]
    i
end

%% write table
T.zi = zs(:,1);
T.zf = zs(:,2);
cd('C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab'); % Added 20230515
writetable(T, 'test_metadata.csv', 'Delimiter', ',', 'QuoteStrings', true); % Added 20230515 to make sure columns of T correspond to columns in csv file
