clc;clear;addpath(genpath('D:\code\'));

prefix_cell = 'D:\Bin\Bin_pilot_result\oligodendrocyte_result\';
prefix_olig = 'D:\Bin\Bin_pilot_result\olig_excels_v4\';

s                 = load.loadJSON('config_oligomer_biscut.json');
metadata          = readtable('Pilot_metadata.csv','VariableNamingRule','preserve');

filenames         = metadata.filenames;
[filepath,name,~] = fileparts(filenames);
filepath          = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},name),'UniformOutput',false);
z                 = [metadata.zi,metadata.zf];
rsid              = metadata.rsid;

rr               = {2,8}; %oligodendrocyte
ss               = {{1,2,3,4,5,6},{7,8,9,10,11,12}};
name             = 'oligodendrocyte';

% rr               = {2,7}; %nf
% ss               = {{7 8 9 10 11 12},{13 14 15 16 17 18}};
% name              = 'neurofilament';

% rr                = {3,8}; %astrocyte
% ss                = {{1 2 3 4 5 6},{13 14 15 16 17 18}};
% name              = 'astrocyte';

% rr                = {3,8}; %microglia
% ss                = {{7 8 9 10 11 12},{1 2 3 4 5 6}};
% name              = 'microglia';

ids               = load.cell2rsid(rr,ss);
idxx              = logical(sum(rsid == ids,2));

filenames         = filenames(idxx); 
filepath          = filepath(idxx);
z                 = z(idxx,:); 
rsid              = rsid(idxx);

%%
cells  = [];

for i = 1:length(rsid)
    tmpt1      = dir([[prefix_cell,filepath{i}],'\*.csv']);
    cell_names = strcat({tmpt1.folder}','\',{tmpt1.name}');
    tmpt2      = dir([[prefix_olig,filepath{i}],'\*.csv']);
    olig_names = strcat({tmpt2.folder}','\',{tmpt2.name}');
    
    result_fov = zeros(17,4);%fov density, in-cell, out-cell, num cell, percentage
    c = readmatrix(cell_names{:});
    o = readmatrix(olig_names{:});

%     parfor (j = z(i,1):z(i,2),8)
    for j = z(i,1):z(i,2)
        cell_mask  = load.boundary2BW(c(c(:,end)==j,1:2),s,4);
        oligPoints = o(o(:,end)==j,2:3);
        [result_fov(j,1),result_fov(j,2),result_fov(j,3),result_fov(j,4)] = spatial.calcDensity(cell_mask,oligPoints,0);
    end

    result_fov = [result_fov(z(i,1):z(i,2),:),repmat(rsid(i),[length(z(i,1):z(i,2)),1])];
    cells      = [cells;result_fov];
    i
end
