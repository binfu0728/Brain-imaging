clc;clear;addpath(genpath('D:\code\')); %path where you download the code

filedir           = 'D:\Bin\gui_test'; %main directory where you have the data (above round)
T                 = process.makeMetadata(filedir);
filenames         = T.filenames;

%% Read through all folders and select used slices

for i = 1:length(filenames)
    tiff_info   = imfinfo(filenames{i}); %length of tiffinfo = number of tif images in a tif stack
    zs(i,:)     = [11 (length(tiff_info)-10)]; %[zi zf]
    i
    end
end

%% write table
writetable(T,'prok_metadata.csv');
