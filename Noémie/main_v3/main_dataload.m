clc;clear;
mypath = 'C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab\code_v3\'; %path where you download the code
addpath(genpath(mypath)); 

filedir           = 'F:\NoemieFP_2023\ASAP Parkinsons Project\Data\Datasets\Middata\mid_rawdata'; %main directory where you have the data (above round)
T                 = core.makeMetadata(filedir);
filenames         = T.filenames; % sample folders have to contain only the original image tif file

%%

for i = 1:length(filenames)
    tiff_info   = imfinfo(filenames{i}); %length of tiffinfo = number of tif images in a tif stack
    zs(i,:)     = [1 length(tiff_info)]; %[zi zf]
    %i
end

%% write table
T.zi = zs(:,1);
T.zf = zs(:,2);

cd('C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab');
writetable(T,'midrd_metadata.xlsx'); % without previous section and z in Bin's code
%writetable(T, 'test_metadata.csv', 'Delimiter', ',', 'QuoteStrings', true); % Added 20230515 to make sure columns of T correspond to columns in csv file
