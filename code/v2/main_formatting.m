clc;clear;addpath(genpath('D:\code\'));

s       = load.loadJSON('config_oligomer_sycamore.json');
[filenames,filepath,z,rsid] = load.loadMeta('sycamore_compare_2_metadata.csv');
prefix  = 'sycamore_compare_2_result\';

%%
nums_s   = [zeros(length(rsid),2),rsid];
nums_z   = [];
inten_s  = [zeros(length(rsid),1),rsid];
inten_z  = [];
inten_i  = {};
inten_t  = []; %tmpt holder

for i = 1:108%length(rsid)

    [idx,filenames] = load.extractName([prefix,filepath{i}],{'large_aggregates_561','small_aggregates_561'});

    large = readmatrix(filenames{idx{1}}); %large
    small = readmatrix(filenames{idx{2}});

    lists = {small};
    BWs   = {large};

    [nums,inten,inten_all] = process.longFormatting(lists,BWs,z(i,:),rsid(i),s);
    nums_z          = [nums_z;nums];
    nums_s(i,1:2)   = mean(nums(:,1:2),1);
    inten_z         = [inten_z;inten];
    inten_s(i,1)    = mean(inten(:,1),1);
    inten_t         = [inten_t;inten_all];
    i
end

for i = 1:size(inten_t,2)
    inten_i{i} = vertcat(inten_t{:,i});
end
