clc;clear;addpath(genpath('C:\Users\bf341\Desktop\code_v3_1'));

filedir = 'S:\ASAP_Imaging_Data\Emma\20231003_psyn_comparison_rerun'; %main directory where you have the data (above round)
T = makeMetadata(filedir);
writetable(T,'abrerun231004_metadata.xlsx');

%% function
function T = makeMetadata(filedir)
% input  : fildir, the mian folder where the data is saved
% 
% output : T, the metadata table

% folder structure: name->round->sample->image
    if filedir(end) ~= '\'; filedir = [filedir,'\'];end
    files     = dir([filedir,'\**\*.tif']);
    names     = {files.name}';
    folders   = {files.folder}';
    filenames = fullfile(folders,names);
    num_slash = length(strfind(filedir,'\')); % how many slashes in the file direction
    
    rounds    = cell(length(filenames),1);
    samples   = cell(length(filenames),1);
    rsid      = cell(length(filenames),1); %round + 0.01*sample
  
    for i = 1:length(files)
        tmpt = filenames{i};
        idx  = strfind(tmpt,'\');
        rounds{i}   = tmpt(idx(num_slash)+1:idx(num_slash+1)-1);
        samples{i}  = tmpt(idx(num_slash+1)+1:idx(num_slash+2)-1);
        r           = regexp(rounds{i},'\d*','Match'); %extract the number in the round name
        s           = regexp(samples{i},'\d*','Match'); %extract the number in the sample name
        r           = str2double(r{1});
        s           = str2double(s{1});
        rsid{i}     = r + 0.01*s; %assign rsid based on the sample
    end
    T  = [filenames,rounds,samples,rsid];
    T  = cell2table(T,'VariableNames',{'filenames','round','samples','rsid'});
end

