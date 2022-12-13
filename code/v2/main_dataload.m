clc;clear;addpath(genpath('D:\code\'));
s                 = load.loadJSON('config_oligomer_biscut.json');

filedir           = 'D:\Bin\gui_test';
T                 = process.makeMetadata(filedir);

filenames         = T.filenames;
[filepath,name,~] = fileparts(filenames);
filepath          = cellfun(@(x) load.extractPath(x,3),filepath,'UniformOutput',false);
rsid              = T.rsid; 

%% One-time use and the original folder will be renamed
used = [];

for i = 1:length(filenames)
    filename    = filenames{i};
    tiff_info   = imfinfo(filename);
    if length(tiff_info) ~= 340
        continue
    else
        used = [used;i];
        img         = load.loadImage(filename,s);
        img         = squeeze(mean(img,4));%xyzc
        img         = cat(3,img(:,:,:,1),img(:,:,:,2));
    
        newFolder = fullfile(load.extractPath(filedir,2),filepath{i});
        
        if ~exist(newFolder, 'dir')
            mkdir(newFolder); 
        end
        load.Tifwrite(uint16(img),fullfile(newFolder,[name{i},'.tif']));
        i
    end
end

movefile(filedir,[filedir,'_ori']);
movefile(load.extractPath(filedir,2),filedir);
%%
T1 = T(used,:);
writetable(T1,'prok_metadata.csv');