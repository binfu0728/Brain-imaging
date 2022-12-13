function [fov,inCell,outCell,percentage,outPoints,inout] = calcDensity(cell_mask,oligPoints,width,plotflag)
% input  : cell_mask, 2048x2048 binary mask of cell
%          oligPoints, centroids of oligomers, in (x,y) form and in pixel unit
%          plot, a flag for visualizing in/out oligomers and cells
%          width, the size of an image
% 
% output : fov, field-of-view density, irrespective of cell position
%          inCell, in-cell density
%          outCell, out-cell density
%          percentage, the percentage area occupied by the cell
%          outPoints, the centroids of oligomers which are outside the cell and in nm unit
%          inout, the extra column labelling whether each object is inside or outside

    [~,numCell]     = bwlabel(cell_mask); %number of cells per fov
    oligPoints(:,2) = abs(oligPoints(:,2)-width); %change to normal cartisian coordinate
    oligPoints      = oligPoints/4*0.107; %change from pixel unit to um
    
    boundaries  = bwboundaries(cell_mask, 'noholes');
    inout       = false(size(oligPoints,1),1); %repo for all points to indicate whether it is inside or outside the cell
    
    if plotflag == 1
        f = figure;
    end

    for k = 1:numCell %find whether points inside or outside through each cell
        cellb      = boundaries{k};
        cellb(:,1) = abs(cellb(:,1)-width); %[y,x]
        cellb      = cellb/4*0.107; %change from pixel unit to um
        s          = inpolygon(oligPoints(:,1),oligPoints(:,2),cellb(:,2),cellb(:,1)); %inside or outside core function
        inout      = inout | s;

        if plotflag == 1
            plot(cellb(:,2),cellb(:,1),'r.');hold on;
        end
    end
    inPoints  = oligPoints(inout==1,:);
    outPoints = oligPoints(inout==0,:);

    if plotflag == 1
        plot(inPoints(:,1),inPoints(:,2),'.','Color','r');
        plot(outPoints(:,1),outPoints(:,2),'.','Color','b');
        xticks('');yticks(''); axis image;
        xlim([0 55]); ylim([0 55]);
    end

    fov = size(oligPoints,1) / (0.107*width/4)^2; %fov density
    if numCell ~= 0
        inCell = size(inPoints,1) / (sum(cell_mask,'all') / 16 * (0.107^2));
    else
        inCell = 0;
    end
    outCell = size(outPoints,1) / ((width*width-sum(cell_mask,'all')) / 16 * (0.107^2)); %outside cell density
    percentage = sum(cell_mask,'all')/(width*width); %how much area occupied by the cells

end