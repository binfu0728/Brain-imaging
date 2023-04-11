function [filenames,filepath,z,rsid,metadata] = loadMeta(fileDir)
    metadata           = readtable(fileDir,'VariableNamingRule','preserve');
    filenames          = metadata.filenames;
    [filepath,names,~] = fileparts(filenames);
    filepath           = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},names),'UniformOutput',false);
    z                  = [metadata.zi,metadata.zf];
    rsid               = metadata.rsid;
end