clc;clear;addpath(genpath('D\code\')); %path where you download the code

filedir           = 'C:\Users\Bigtree\Desktop\test'; %main directory where you have the data (above round)
T                 = process.makeMetadata(filedir);
filenames         = T.filenames;

%% Read through all folders and select used slices

for i = 1:length(filenames)
    tiff_info   = imfinfo(filenames{i}); %length of tiffinfo = number of tif images in a tif stack
    zs(i,:)     = [1 length(tiff_info)]; %[zi zf]
    i
end

%% write table
T.zi = zs(:,1);
T.zf = zs(:,2);
writetable(T,'test_metadata.csv');
