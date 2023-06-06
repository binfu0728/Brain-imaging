function newFolder = saveBW(filepath)
    newFolder  = load.makeDir(filepath);
    writetable(r_z,fullfile(newFolder,'result_small_aggregates_561.csv'));
    boundaries = array2table(load.BW2boundary(largeM),'VariableNames',{'row','col','z'});
    writetable(boundaries,fullfile(newFolder,'result_large_aggregates_561.csv'));
end