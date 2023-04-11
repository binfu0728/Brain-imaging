function filepath = makeDir(filepath)
    if ~exist(filepath, 'dir')
        mkdir(filepath); 
    end 
end