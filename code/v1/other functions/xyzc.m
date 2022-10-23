clc;clear;addpath(genpath('D:\code\'));

s                  = load.loadJSON('config_microglia_biscut.json');
metadata           = readtable("Pilot_metadata.csv",'VariableNamingRule','preserve');

filenames          = metadata.filenames;
[filepath,names,~] = fileparts(filenames);
filepath           = cellfun(@(x) load.extractPath(x,3),strcat(filepath),'UniformOutput',false);
z                  = [metadata.zi,metadata.zf];
rsid               = metadata.rsid;

% rr                = {2,8}; %oligodendrocyte
% ss                = {{1,2,3,4,5,6},{7,8,9,10,11,12}};
% name              = 'oligodendrocyte';

% rr                = {2,7}; %nf
% ss                = {{7 8 9 10 11 12},{13 14 15 16 17 18}};
% name              = 'neurofilament';

% rr                = {3,8}; %astrocyte
% ss                = {{1 2 3 4 5 6},{13 14 15 16 17 18}};
% name              = 'astrocyte';

rr                 = {3,8}; %microglia
ss                 = {{7 8 9 10 11 12},{1 2 3 4 5 6}};
name               = 'microglia';

ids                = load.cell2rsid(rr,ss);
idxx               = logical(sum(rsid == ids,2));

filenames          = filenames(idxx);
names              = names(idxx);
filepath           = filepath(idxx);
z                  = z(idxx,:); 
rsid               = rsid(idxx);

%%
for i = 1:length(filenames)
    img         = load.Tifread(filenames{i});
    img         = reshape(img,[s.height,s.width,s.slices,s.colour]);
    img         = cat(3,img(:,:,:,1),img(:,:,:,2));
    newFolder   = load.makeDir(fullfile(['.\',name,'_image\',filepath{i}]));
    load.Tifwrite(uint16(img),[newFolder,'\',names{i},'.tif']);
end