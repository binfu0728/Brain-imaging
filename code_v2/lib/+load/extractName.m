function [idx,filenames] = extractName(filepath,substring)
% input  : filepath, the path where the result/image is saved
%          substring, the keyword in the filename to select the specific file
% 
% output : idx, which file contains the wanted substring
%          filenames, all the files under the filepath

    files       = dir([filepath,'\*.csv']);
    filenames   = {files.name}';
    [~,name,~] = fileparts(filenames);

    idx = cell(length(substring),1);
    for i = 1:length(substring) 
        idx{i} = cell2mat(cellfun(@(x) contains(x,substring{i}),name,'UniformOutput',false));
    end
    filenames = strcat({files.folder}','\',{files.name}');
end