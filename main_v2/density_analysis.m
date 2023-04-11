clc;clear;addpath(genpath('D:\code\'));

prefix_cell = 'D:\Bin\Bin_pilot_result\oligodendrocyte_result\';
prefix_olig = 'pilot_result_new\';

s                 = load.loadJSON('config_oligomer_biscut.json');
metadata          = readtable('Pilot_metadata.csv','VariableNamingRule','preserve');
[filenames,filepath,z,rsid] = load.loadMeta('Pilot_metadata.csv');

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
cells = []; %fov, incell, outcell, percentage area, rsid
oligs = []; %area, centroid(xy), mean intensity, sum intensity, z, inout, rsid 
s1.width  = 2048;
s1.height = 2048;

for i = 1:length(rsid)
    tmpt1      = dir([[prefix_cell,filepath{i}],'\*.csv']);
    cell_names = strcat({tmpt1.folder}','\',{tmpt1.name}'); %find cell results
    [idx,filenames] = load.extractName([prefix_olig,filepath{i}],{'large_aggregates_561','small_aggregates_561'}); %find aggregates results
    
    result_fov = zeros(17,4);%fov density, in-cell, out-cell, num cell, percentage
    c = readmatrix(cell_names{:}); %cell results in boundary
    o = readmatrix(filenames{idx{2}}); %small aggregate results in centroid
    l = readmatrix(filenames{idx{1}}); %large aggregate results in boundary

    for j = z(i,1):z(i,2)
        cell_mask   = load.boundary2BW(c(c(:,end)==j,1:2),s,4);
        oligPoints  = o(o(:,end)==j,2:3);
        %find centroid of large aggregates
        aggrePoints = load.boundary2BW(l(l(:,end)==j,1:2),s1,1);
        aggrePoints = regionprops('table',aggrePoints,'centroid');
        aggrePoints = aggrePoints.Centroid; 
        aggrePoints = [aggrePoints;oligPoints];
        [result_fov(j,1),result_fov(j,2),result_fov(j,3),result_fov(j,4),~,inout] = analyze.calcDensity(cell_mask,aggrePoints,0,2048);
%         tmpt       = [o(o(:,end)==j,:),inout,repmat(rsid(i),[length(inout),1])]; %for oligomers only
%         oligs      = [oligs;tmpt];
    end

    result_fov = [result_fov(z(i,1):z(i,2),:),repmat(rsid(i),[length(z(i,1):z(i,2)),1])];
    cells      = [cells;result_fov];
    i
end

%%
T1 = array2table(cells,"VariableNames",{'fov','incell','outcell','occupied-percent','rsid'});
writetable(T1,['density_561_slice_',name,'_all.csv']); %density for large aggregates and oligomers

% T2 = array2table(oligs,"VariableNames",{'area','x','y','mean-intensity','sum-intensity','z','inout','rsid'});
% writetable(T2,['density_561_oligomer_',name,'_small.csv']); %oligomer result with its inside/outside info