clc;clear;addpath(genpath('D:\code\'));

s1                 = load.loadJSON('config_lb_biscut.json');
s2                 = load.loadJSON('config_oligomer_biscut.json');
metadata           = readtable('pilot_metadata.csv','VariableNamingRule','preserve');

filenames          = metadata.filenames;
[filepath,names,~] = fileparts(filenames);
filepath           = cellfun(@(x) load.extractPath(x,3),strcat(filepath,{'\'},names),'UniformOutput',false);
z                  = [metadata.zi,metadata.zf];
rsid               = metadata.rsid;

% rr                = {2,8}; %oligodendrocyte
% ss                = {{1,2,3,4,5,6},{7,8,9,10,11,12}};
% name              = 'oligodendrocyte';

% rr                = {2,7}; %nf
% ss                = {{7 8 9 10 11 12},{13 14 15 16 17 18}};
% name              = 'neurofilament';

rr                = {3,8}; %astrocyte
ss                = {{1 2 3 4 5 6},{13 14 15 16 17 18}};
name              = 'astrocyte';

% rr                 = {3,8}; %microglia
% ss                 = {{7 8 9 10 11 12},{1 2 3 4 5 6}};
% name               = 'microglia';

ids               = load.cell2rsid(rr,ss);
idxx              = logical(sum(rsid == ids,2));

filenames         = filenames(idxx); 
filepath          = filepath(idxx);
z                 = z(idxx,:); 
rsid              = rsid(idxx);

% dd = [84,87,111,112,113,114,115,119,123]; %microglia
dd = [100,101,102,103,107,108,110,112,113];%astrocyte
% dd = [107,108,109,110,111,112,113,114,115]; %nf
% dd = [50,67,103,104,105,110,250,314,319]; %oligodendrocyte

%%
result_avg = []; %number(small),intensity,bg,rsid per slice
saved      = 1;

for i = 1:length(dd)
    i = dd(i);
    newFolder  = load.makeDir(fullfile(['.\',name,'_aggregate\',filepath{i}]));
    newFolder2 = load.makeDir(fullfile(['.\',name,'_image\',filepath{i}]));
    img        = load.Tifread(filenames{i});
    img        = reshape(img,[s1.height,s1.width,s1.slices,s1.channel]);
    img_c      = img(:,:,z(i,1):z(i,2),s1.channel);
    [smallM,largeM,r_z,r_avg,BW1] = process.aggregateDetection(img_c,s1,s2,z(i,1),saved);

    if saved == 1
        r_avg      = [r_avg,repmat(rsid(i),size(r_avg,1),1)];
        boundaries = load.BW2boundary(imresize3(largeM,[512,512,17]),z(i,1));
        boundaries = [boundaries,ones(length(boundaries),1)];
        a          = [r_z.Centroid/4,r_z.z,zeros(size(r_z,1),1)];
        rr         = [boundaries;a];
        rr         = array2table(rr,'VariableNames',{'row','col','z','id'});
        writetable(rr,fullfile(newFolder,'result_aggregates_561.csv'));
        load.Tifwrite(uint16(img),[newFolder2,'\',names{i},'.tif']);
    else
        for j = 1:size(img_c,3)
            zimg = double(imresize(img_c(:,:,j),4));
            pause(0.1);
            figure;imshow(zimg,[]);
            f    = visual.plotAll(zimg,largeM(:,:,j),[0.6350 0.0780 0.1840],'contrast');
                   visual.plotBinaryMask(f,smallM(:,:,j),[0.8500 0.3250 0.0980])
        end
    end
    i
%     close all
end
