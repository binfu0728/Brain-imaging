function [filenames,filepath,rsid,metadata] = loadMeta(fileDir)
    metadata           = readtable(fileDir,'VariableNamingRule','preserve');
    filenames          = metadata.filenames;
    [filepath,names,~] = fileparts(filenames);
    filepath           = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},names),'UniformOutput',false);
    rsid               = metadata.rsid;
end