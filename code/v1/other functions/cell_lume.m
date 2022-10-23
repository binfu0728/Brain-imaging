clc;clear;addpath(genpath('D:\code\'));

s                  = load.loadJSON('config_microglia_biscut.json');
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

% rr                = {3,8}; %astrocyte
% ss                = {{1 2 3 4 5 6},{13 14 15 16 17 18}};
% name              = 'astrocyte';

rr                 = {3,8}; %microglia
ss                 = {{7 8 9 10 11 12},{1 2 3 4 5 6}};
name               = 'microglia';

ids                = load.cell2rsid(rr,ss);
idxx               = logical(sum(rsid == ids,2));

filenames          = filenames(idxx); 
filepath           = filepath(idxx);
z                  = z(idxx,:); 
rsid               = rsid(idxx);

dd = [84,87,111,112,113,114,115,119,123]; %microglia
% dd = [100,101,102,103,107,108,110,112,113];%astrocyte
% dd = [107,108,109,110,111,112,113,114,115]; %nf
% dd = [50,67,103,104,105,110,250,314,319]; %oligodendrocyte

%%
saved = 1;

for i = 1:length(dd)
    i = dd(i);
    img         = load.Tifread(filenames{i});
    img         = reshape(img,[s.height,s.width,s.slices,s.colour]);
    img         = img(:,:,z(i,1):z(i,2),s.channel);
    BW          = process.cellDetection(img,s);
    
    if saved == 1
        newFolder   = load.makeDir(fullfile(['.\',name,'_cell\',filepath{i}]));
        boundaries  = array2table(load.BW2boundary(BW,z(i,:)),'VariableNames',{'row','col','z'});
        writetable(boundaries,fullfile(newFolder,['position_',name,'.csv']))
    else 
        for j = 1:size(BW,3)
            f = visual.plotAll(img(:,:,j),BW(:,:,j),[0.9290 0.6940 0.1250],'contrast');
    %         load.Gifwrite(fullfile(newFolder,['animation_',name,'.gif']),f,j);
%             pause(0.25);
        end
        close all;
    end
    i
end