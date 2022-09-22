function [fov,inCell,outCell,percentage,outPoints] = calcDensity(cell_mask,oligPoints,plot)
% input  : cell_mask, 2048x2048 binary mask of cell
%          oligPoints, centroids of oligomers, in (x,y) form and in pixel unit
%          plot, a flag for visualizing in/out oligomers and cells
% 
% output : fov, field-of-view density, irrespective of cell position
%          inCell, in-cell density
%          outCell, out-cell density
%          percentage, the percentage area occupied by the cell
%          outPoints, the centroids of oligomers which are outside the cell and in nm unit

    [~,numCell]  = bwlabel(cell_mask);
    oligPoints(:,2) = abs(oligPoints(:,2)-2048);
    oligPoints      = oligPoints/4*0.107;
    
    boundaries  = bwboundaries(cell_mask, 'noholes');
    tmpt        = false(size(oligPoints,1),1);

    if plot == 1
        f = figure;
    end

    for k = 1:numCell
        cellb      = boundaries{k};
        cellb(:,1) = abs(cellb(:,1)-2048); %[y,x]
        cellb      = cellb/4*0.107;
        s          = inpolygon(oligPoints(:,1),oligPoints(:,2),cellb(:,2),cellb(:,1));
        tmpt       = tmpt | s;

        if plot == 1 
            plot(cellb(:,2),cellb(:,1),'r.');hold on;
        end
    end
    inPoints   = oligPoints(tmpt==1,:);
    outPoints  = oligPoints(tmpt==0,:);

    if plot == 1
        plot(inPoints(:,1),inPoints(:,2),'.','Color','r');
        plot(outPoints(:,1),outPoints(:,2),'.','Color','b');
        xticks('');yticks(''); axis image;
        xlim([0 55]); ylim([0 55]);
    end

    fov = size(oligPoints,1) / (0.107*512)^2;
    if numCell ~= 0
        inCell = size(inPoints,1) / (sum(cell_mask,'all') / 16 * (0.107^2));
    else
        inCell = 0;
    end
    outCell = size(outPoints,1) / ((2048*2048-sum(cell_mask,'all')) / 16 * (0.107^2));
    percentage = sum(cell_mask,'all')/(2048*2048);
end