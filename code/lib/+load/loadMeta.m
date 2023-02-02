function [filenames,filepath,z,rsid,metadata] = loadMeta(fileDir)
    metadata           = readtable(fileDir,'VariableNamingRule','preserve');
    filenames          = metadata.filenames;
    [filepath,names,~] = fileparts(filenames);
    idx                = cell2mat(cellfun(@(x) strfind(x,'Round'),filepath,'UniformOutput',false));
    filepath           = cellfun(@(x) x(idx:end),strcat(filepath,{'\'},names),'UniformOutput',false);
    z                  = [metadata.zi,metadata.zf];
    rsid               = metadata.rsid;
end
