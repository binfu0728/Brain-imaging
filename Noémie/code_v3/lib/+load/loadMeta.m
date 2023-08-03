function [filenames,filepath,z,rsid] = loadMeta(fileDir)
    metadata           = readtable(fileDir,'VariableNamingRule','preserve'); %,'Delimiter',',',); 
    filenames          = metadata.filenames;
    [filepath,names,~] = fileparts(filenames); % filepath is actually files' directories
    filepath           = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},names),'UniformOutput',false);
    % previous line : why do we keep only a part of the path ? gives path from after 3rd '\' including file name
    z                  = [metadata.zi,metadata.zf];
    rsid               = metadata.rsid;
end