clc;clear;addpath(genpath('D:\code\'));
load('gain_sycamore.mat');
load('offset_sycamore.mat');

% for small and large aggregtes
s1 = load.loadJSON('config_lb_sycamore.json'); %large object (LB)
s2 = load.loadJSON('config_oligomer_sycamore.json'); %small object (oligomers)
s2.k2_dog  = 1.75; %should be similar to sigma of the blobs
s2.percent = 0.975; %percentage thresholding (throwing ratio), for changing code sensitivity
[filenames,filepath,z,rsid] = load.loadMeta('test_metadata.csv'); %input metadata

%%
saved = 0; %1 for saving results but no visualization, 1 for only visualization but no saving

for i = 1%:length(filenames)
    img        = load.Tifread(filenames{i});
    img_c      = double(img(:,:,z(i,1):z(i,2)));
    [smallM,largeM,r_z] = process.aggregateDetection(img_c,s1,s2,saved,gain,offset);

    if saved == 1
        newFolder  = load.makeDir(fullfile(['.\pilot_result\',filepath{i}]));
        boundaries = array2table(load.BW2boundary(largeM,z(i,1)),'VariableNames',{'row','col','z'});
        writetable(r_z,fullfile(newFolder,'result_small_aggregates_561.csv'));
        writetable(boundaries,fullfile(newFolder,'result_large_aggregates_561.csv'));
    else
        for j = 1:size(img_c,3)
            zimg = uint16(img_c(:,:,j));
            f1   = figure;imshow((zimg),[100 600]);
            f    = figure;imshow((zimg),[100 600]);
            visual.plotBinaryMask(f,largeM(:,:,j),[0.6350 0.0780 0.1840]);
            visual.plotBinaryMask(f,smallM(:,:,j),[0.8500 0.3250 0.0980])
            pause(0.1);
        end
        close all
    end
    i
end
