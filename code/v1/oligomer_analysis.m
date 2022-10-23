clc;clear;addpath(genpath('D:\code\'));

s                 = load.loadJSON('config_oligomer_biscut.json');
metadata          = readtable('psyn_metadata.csv','VariableNamingRule','preserve');
prefix            = 'psyn_result\';

filenames         = metadata.filenames;
[filepath,name,~] = fileparts(filenames);
filepath          = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},name),'UniformOutput',false);
z                 = [metadata.zi,metadata.zf];
rsid              = metadata.rsid;

%%
ref      = [repmat(2,sum(rsid == 1.01 | rsid == 1.02),1);repmat(1,sum(rsid == 1.03 | rsid == 1.04 | rsid == 1.05),1);repmat(2,sum(rsid == 1.06),1)]; %mouse
% ref      = 2*ones(length(rsid),1); %561
s.width  = 2048;
s.height = 2048;

nums_s   = [zeros(length(rsid),4),rsid]; %per sample
nums_z   = []; %per slice
inten_s  = [zeros(length(rsid),2),rsid]; %per sample
inten_z  = []; %per slice
inten_i  = {}; %per oligomer
inten_t  = []; %tmpt holder
coloc_s  = [zeros(length(rsid),4),rsid];

for i = 1:length(rsid)
    if i < 28
        s.slices = 23;
    end
    [idx,filenames] = load.extractName([prefix,filepath{i}],{'large_aggregate_488','small_aggregates_488','large_aggregate_561','small_aggregates_561'});
    
    c4881 = readmatrix(filenames{idx{1}}); %large
    c4882 = readmatrix(filenames{idx{2}});
    c5611 = readmatrix(filenames{idx{3}}); %large
    c5612 = readmatrix(filenames{idx{4}});

    lists = {c4882,c5612};
    BWs   = {c4881,c5611};

    [nums,inten,inten_all,coloc_z] = process.generalAnalysis(lists,BWs,z(i,:),rsid(i),ref(i));
    nums_z          = [nums_z;nums];
    nums_s(i,1:4)   = mean(nums_z(:,1:4),1);
    inten_z         = [inten_z;inten];
    inten_s(i,1:2)  = mean(inten_z(:,1:2),1);
    inten_t         = [inten_t;inten_all];
    coloc_s(i,1:4)  = mean(coloc_z(:,1:4),1);
    i
end

for i = 1:size(inten_t,2)
    inten_i{i} = vertcat(inten_t{:,i});
end
