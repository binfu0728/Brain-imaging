clc;clear;addpath(genpath('D:\code\'));
% for small (if no super big aggregates in FoV, can use this directly)
s                 = load.loadJSON('config_oligomer_biscut.json');
metadata          = readtable("Pilot_metadata.csv",'VariableNamingRule','preserve');

filenames         = metadata.filenames;
[filepath,name,~] = fileparts(filenames);
filepath          = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},name),'UniformOutput',false);
z                 = [metadata.zi,metadata.zf];
rsid              = metadata.rsid;

%%
result = []; %number,intensity,bg,rsid per slice

for i = 1%:length(filenames)
    tic;
    img          = load.Tifread(filenames{i});
    img          = reshape(img,[s.height,s.width,s.slices,s.colour]);
    img          = img(:,:,z(i,1):z(i,2),s.channel);
    result_z_all = [];
    result_t     = [];
    initz        = z(i,1);

%     newFolder    = load.makeDir(fullfile(['.\pilot_result\',filepath{i}]));
%     parfor (j = 1:size(img,3),8)
    for j = 1:size(img,3)
        zimg     = double(imresize(img(:,:,j),4));
        BW       = process.oligomerDetection(zimg,s);
%         f        = visual.plotAll(zimg,BW,[0.9290 0.6940 0.1250]);
        [result_z,result_avg] = process.findInfo(BW,zimg,initz,j);
        result_z_all = [result_z_all;result_z];
        result_t     = [result_t;result_avg];
    end
%     writetable(result_z_all,fullfile(newFolder,'result_oligomer.csv'));
    result_t = [result_t,repmat(rsid(i),size(result_t,1),1)];
    result   = [result;result_t];
    ttime    = toc
    i
end
