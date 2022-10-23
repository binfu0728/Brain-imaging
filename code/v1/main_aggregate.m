clc;clear;addpath(genpath('D:\code\'));
% for small and large aggregtes
s1                 = load.loadJSON('config_lb_biscut.json');
s2                 = load.loadJSON('config_oligomer_biscut.json');
metadata           = readtable('pilot_metadata.csv','VariableNamingRule','preserve');

filenames          = metadata.filenames;
[filepath,names,~] = fileparts(filenames);
filepath           = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},names),'UniformOutput',false);
z                  = [metadata.zi,metadata.zf];
rsid               = metadata.rsid;

%%
saved = 0;

for i = 1:length(filenames)
    img        = load.Tifread(filenames{i});
    img        = reshape(img,[s1.height,s1.width,s1.slices,s1.channel]);
    img_c      = img(:,:,z(i,1):z(i,2),s1.channel);
    [smallM,largeM] = process.aggregateDetection(img_c,s1,s2,z(i,1),saved);

    if saved == 1
        newFolder  = load.makeDir(fullfile(['.\pilot_result\',filepath{i}]));
        boundaries = array2table(load.BW2boundary(largeM,z(i,1)),'VariableNames',{'row','col','z'});
        writetable(r_z,fullfile(newFolder,'result_small_aggregates_561.csv'));
        writetable(boundaries,fullfile(newFolder,'result_large_aggregates_561.csv'));
    else
        for j = 1:size(img_c,3)
            zimg = double(imresize(img_c(:,:,j),4));
            figure;imshow(zimg,[]);
            f    = visual.plotAll(zimg,largeM(:,:,j),[0.6350 0.0780 0.1840]);
                   visual.plotBinaryMask(f,smallM(:,:,j),[0.8500 0.3250 0.0980])
            pause(0.1);
        end
        close all
    end
    i
end
