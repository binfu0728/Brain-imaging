function T = makeMetadata(filedir)
% input  : fildir, the mian folder where the data is saved
% 
% output : T, the metadata table

% folder structure: name->round->sample->image
    files     = dir([filedir,'\**\*.tif']);
    names     = {files.name}';
    folders   = {files.folder}';
    filenames = fullfile(folders,names);

    idx       = cell2mat(cellfun(@(x) strfind(x,'Round'),filenames,'UniformOutput',false));
    rounds    = cellfun(@(x) x(idx:idx+5),filenames,'UniformOutput',false);
    rsid      = cellfun(@(x) x(idx+5:idx+5),filenames,'UniformOutput',false);
    
    samples   = cell(length(filenames),1);

    for i = 1:length(files)
        tmpt = filenames{i};
        idx  = strfind(tmpt,'\');
        samples{i}  = tmpt(idx(4)+1:idx(5)-1);
        s           = regexp(samples{i},'\d*','Match');
        s           = str2num(s{1});
        rsid{i}     = str2num(rsid{i}) + 0.01*s;
    end
    zi = num2cell(zeros(length(filenames),1));
    zf = zi;
    T  = [filenames,rsid,rounds,samples,zi,zf];
    T  = cell2table(T,'VariableNames',{'filenames','rsid','round','samples','zi','zf'});
end