clc;clear;addpath(genpath('D:\code\')); %path where you download the code

% user input
s       = load.loadJSON('config_oligomer_sycamore.json'); %config file used in aggregate detection (LB/oligomer both are fine)
[filenames,filepath,z,rsid] = load.loadMeta('sycamore_compare_2_metadata.csv'); %metadata name for the current data
prefix  = 'sycamore_compare_2_result\'; %result folder name

%% turn seperate files into long format
nums_z   = []; %number per slice
inten_i  = {}; %intensity per oligomer 
inten_t  = []; %tmpt holder
bg_i     = {}; %intensity per oligomer 
bg_t     = []; %tmpt holder

for i = 1%:length(filenames)

    [idx,filenames] = load.extractName([prefix,filepath{i}],{'large','small'}); %find correspounding results (specified in keywords {'large','small'}) in the folder

    large = readmatrix(filenames{idx{1}}); %large aggregate result
    small = readmatrix(filenames{idx{2}}); %small aggregate result

    [nums,~,inten_all,bg,bg_all] = process.longFormatting({small},{large},z(i,:),rsid(i),s);
    nums_z  = [nums_z;nums];
    inten_t = [inten_t;inten_all];
    bg_t    = [bg_t;bg_all];
    i
end

%concat intensity into single cell
for i = 1:size(inten_t,2)
    inten_i{i} = vertcat(inten_t{:,i});
    bg_i{i}    = vertcat(bg_t{:,i});
end

%% write table
T1 = array2table(nums_z,"VariableNames",{'small_nums_561','large_nums_561','rsid'});
writetable(T1,'numbers_561_slice_.csv');

T2 = array2table([inten_i{1},bg_i{1}],"VariableNames",{'sum_intensity','rsid1','bg','rsid2'});
writetable(T2,'intensity_561_oligomer.csv');
