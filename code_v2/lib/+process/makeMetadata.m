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

%     idx       = cell2mat(cellfun(@(x) strfind(x,'Round'),filenames,'UniformOutput',false));
%     rounds    = cellfun(@(x) x(idx:idx+5),filenames,'UniformOutput',false);
%     rsid      = cellfun(@(x) x(idx+5:idx+5),filenames,'UniformOutput',false); %assign rsid based on the round
    
    rounds    = cell(length(filenames),1);
    samples   = cell(length(filenames),1);
    rsid      = cell(length(filenames),1);
  
    for i = 1:length(files)
        tmpt = filenames{i};
        idx  = strfind(tmpt,'\');
        rounds{i}   = tmpt(idx(num_slash)+1:idx(num_slash+1)-1);
        samples{i}  = tmpt(idx(num_slash+1)+1:idx(num_slash+2)-1);
        r           = regexp(rounds{i},'\d*','Match'); %extract the number in the round name
        s           = regexp(samples{i},'\d*','Match'); %extract the number in the sample name
        r           = str2num(r{1});
        s           = str2num(s{1});
        rsid{i}     = r + 0.01*s; %assign rsid based on the sample
    end
    zi = num2cell(zeros(length(filenames),1));
    zf = zi;
    T  = [filenames,rsid,rounds,samples,zi,zf];
    T  = cell2table(T,'VariableNames',{'filenames','rsid','round','samples','zi','zf'});
end