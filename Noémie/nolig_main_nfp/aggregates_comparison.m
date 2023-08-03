%% get classification 

% manual classification of the aggregates shapes for first dataset 
% 1 - potato, 2 - long potato, 3 - complex or round & long, 4 - pretty long, 5 - long

% classparam = [4;1;4;4;1;3;2;1;1;1;1;1;2;4;2;5;4;4;2;4;2;1;1;3;5;5;5;2;5;4;5;1;3;3;1;5;5;5;4;5;4;3;5;1;1;2;2;2;3;4;4;...
%     3;5;4;4;4;2;5;5;2;1;1;4;3;2;5;5;5;1;2;5;1;1;1;2;1;4;5;5;5;2;1;3;3;4;4;5;2;5;4;2;1;1;4;5;4;1;2;3;4;5;3;4;5;4;2;...
%     3;1;3;3;3;5;3;1;4;4;4;3;3;3;1;1;2;3;2;5;1;3;3;3;3;4;4;3;5;3;3;4];


% manual classification of the aggregates shapes for mid_rawdata dataset 
% 1- potato       2- long potato (~< 4um)      3- long chubby      4- long thin     5- seems to be cut in half      6- complex

classparam = readmatrix('classmidrd.csv');

%% 3D data tables

% table of all aggregates previously characterized
param_all = readtable('agg_parameters_3D.xlsx','VariableNamingRule','preserve','ReadRowNames',true);
param_all.Class = classparam;

% table of all agg except those for which getting fiber didn't work 
param_no_irf = param_all((param_all.Regular_Fiber == true),:);
param_no_irf.Regular_Fiber = []; % delete column 
param_no_irf.On_Zedge = [];

% table of all agg except those on z edges 
param_no_z = param_all((param_all.On_Zedge == false),:);
param_no_z.On_Zedge = [];

% table of all aggs with reg fiber and not cut in half (class 5)
allfull = param_all((param_all.Class ~= 5 & param_all.Regular_Fiber == true),:); 
allfull.Regular_Fiber = []; % delete sorted parameter column
allfull.On_Zedge = []; % delete this col because not useful for this dataset 

% table of all aggs with reg fiber and not cut in half (class 5) and not complex (class 6)
full_noc = param_all((param_all.Class ~= 5 & param_all.Class ~= 6 & param_all.Regular_Fiber == true),:); 
full_noc.Regular_Fiber = []; % delete sorted parameter column
full_noc.On_Zedge = []; % delete this col because not useful for this dataset 

% get table of all agg with reg fiber and not on zedges (the 'perfect' ones)
sorted_param = param_no_z((param_no_z.Regular_Fiber == true),:);
sorted_param.Regular_Fiber = [];

%% 2D data tables

param2D_all = readtable('agg_parameters_2D.xlsx','VariableNamingRule','preserve');
class2D = [];

% link 3D corresponding aggregates classes to 2D sub aggregates
for q = 1:height(param2D_all)
    subaggID = param2D_all.SubAggregateID(q);
    aggID = extractBefore(subaggID,"_s");
    class2D(q,1) = table2array(param_all(aggID,end));
end
param2D_all.Class = class2D;

% table of all sub agg except those for which getting fiber didn't work 
param2D_no_irf = param2D_all((param2D_all.Regular_Fiber == true),:);
param2D_no_irf.Regular_Fiber = []; % delete column 
param2D_no_irf.On_edge = [];
param2D_no_irf.Circularity = []; % no 3D equivalent, not used for now

% table of all sub agg except those for which getting fiber didn't work and for which 3D aggregate is not in 5th class
param2D_allfull = param2D_all((param2D_all.Class ~= 5 & param2D_all.Regular_Fiber == true),:);
param2D_allfull.Regular_Fiber = []; % delete column 
param2D_allfull.On_edge = [];
param2D_allfull.Circularity = [];

%% choose dataset 

dataset = param_no_irf(:,:); % set to wanted 3D param table, dont keep aggID, on_zedge and reg fib parameters columns 

% dataset = param2D_no_irf(:,2:end); % set to wanted 2D param table, dont keep aggID, on_zedge and reg fib parameters columns 
% 2D data is too large and dataset needs to be cut randomly 
% rowstodel = round([linspace(1,height(dataset),round(0.8*height(dataset)))]'); 
% dataset(rowstodel,:) = [];

%% prepare data for analysis

% normalize data
nums = table2array(dataset);
for d = 1:(size(nums,2)-1)
    rawdata = nums(:,d);
    prdata = (rawdata - mean(rawdata)) / std(rawdata);
    dataset(:,d) = array2table(prdata);
end

classparam2 = dataset.Class;
numgroups = length(unique(classparam2));
clr = jet(numgroups);

% classify aggregates by volume - not used
% vol_range = range(dataset.Volume);
% Q = quantile(dataset.Volume,[0.25, 0.5, 0.75]);
% small = sorted_param.Volume <= Q(1);
% medium = sorted_param.Volume > Q(1) & sorted_param.Volume <= Q(2);
% large = sorted_param.Volume > Q(2) & sorted_param.Volume <= Q(3);
% fat = sorted_param.Volume > Q(3);
% 
% vol_classes = double(small);
% vol_classes(medium == 1) = 2;
% vol_classes(large == 1) = 3;
% vol_classes(fat == 1) = 4;

%% tsne plotting

figure
data = table2array(dataset(:,1:end-1)); % to not count class parameter

% for loops to test different exagg and perplex settings
for exaggeration = 50% [2 50 75 100]
    for perplexity = 50%[50 75 500]
        hi = tsne(data,"Algorithm","exact","Perplexity",perplexity,'Exaggeration',exaggeration);
        nexttile;
        g = gscatter(hi(:,1), hi(:,2), classparam2 ,clr); %15,'filled')
        title(['ex ', num2str(exaggeration), ' perp ', num2str(perplexity)]);
        xlabel('tsne-1');       ylabel('tsne-2');
        xlim([prctile(hi(:,1),[2 98])])
        ylim([prctile(hi(:,2),[2 98])])
        %legend off;
    end
end
set(gcf,'color','w') % set background color to white 

% 3D tsne plot
% hi = tsne(data,"Algorithm","exact","NumDimensions",3);
% figure, scatter3(hi(:,1), hi(:,2), hi(:,3), 15,'filled')

% test not working
%figure, scatterhistogram(dataset, "Fiber","Convexity",GroupVariable="Volume",GroupData=vol_classes)

%% plot 3D data 

% figure, scatter(dataset,"Fiber", "Volume", "filled")
% figure, scatter(dataset, "Fiber", "Surface Area", "filled")
% figure, histogram(dataset.Elongation,10), title Elongation 
% figure, histogram(dataset.Convexity,10), title Convexity
% figure, scatterhistogram(dataset, "Fiber", "Convexity")
% figure, scatterhistogram(param_wz, "Solidity","Extent",'GroupVariable', 'On_Zedge')
% figure, scatter(dataset,"Fiber", "Convexity", "filled")
% figure, scatter(dataset, "Fiber", "Surface Area", "filled")


%% function to display aggregates pictures on click in plots - copied from online and not adapted/applied yet

function [coordinateSelected, minIdx] = showZValueFcn(hObj, event)
%  FIND NEAREST (X,Y,Z) COORDINATE TO MOUSE CLICK
% Inputs:
%  hObj (unused) the axes
%  event: info about mouse click
% OUTPUT
%  coordinateSelected: the (x,y,z) coordinate you selected
%  minIDx: The index of your inputs that match coordinateSelected. 
x = hObj.XData; 
y = hObj.YData; 
z = hObj.ZData; 
pt = event.IntersectionPoint;       % The (x0,y0,z0) coordinate you just selected
coordinates = [x(:),y(:),z(:)];     % matrix of your input coordinates
dist = pdist2(pt,coordinates);      %distance between your selection and all points
[~, minIdx] = min(dist);            % index of minimum distance to points
coordinateSelected = coordinates(minIdx,:); %the selected coordinate
% from here you can do anything you want with the output.  This demo
% just displays it in the command window.  
fprintf('[x,y,z] = [%.5f, %.5f, %.5f]\n', coordinateSelected)
end %


