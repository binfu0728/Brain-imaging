function [fov,inCell,outCell,percentage,inPoints,inout] = calculateDensity(cellMask,oligPoints,imsz,pixsz,plotflag)
% calculated oligomer density in an image
% input  : cellPoints, cell binary mask
%          oligPoints, centroids of oligomers, in (x,y) form and in pixel unit
%          imsz, size of an image
%          pixsz, physical pixel size at sample plane
%          plotflag, whether see the inside/outside plot
% 
% output : fov, field-of-view density, irrespective of cell position
%          inCell, in-cell density
%          outCell, out-cell density
%          percentage, the percentage area occupied by the cell
%          outPoints, the centroids of oligomers which are outside the cell
%          inout, the extra column labelling whether each object is inside or outside
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk
    
    if sum(cellMask(:))==0 || isempty(oligPoints)
        fovarea = imsz(1)*imsz(2)*pixsz^2;
        fov = size(oligPoints,1) / fovarea; inCell = 0; outCell = size(oligPoints,1) / fovarea; percentage = 0; inPoints = []; inout = zeros(size(oligPoints,1),1);
        return
    end
    
    cell_mask = cellMask;
    ops       = sub2ind([1200,1200],oligPoints(:,2),oligPoints(:,1));
    inout     = cell_mask(ops) == 1;
    inPoints  = oligPoints(inout,:);
    outPoints = oligPoints(~inout,:);

    if plotflag == 1
        f = figure;
        % plot(cellPoints(:,2)*pixsz,abs(cellPoints(:,1)-imsz(2))*pixsz,'r.');hold on;
        imshow(cell_mask,[]);hold on;
        plot(inPoints(:,1),inPoints(:,2),'.','Color','r','MarkerSize',10);
        plot(outPoints(:,1),outPoints(:,2),'.','Color','y','MarkerSize',8);
        % xticks('');yticks(''); axis image;
        % xlim([0 imsz(2)*pixsz]); ylim([0 imsz(1)*pixsz]);
    end

    fovarea  = imsz(1)*imsz(2)*pixsz^2;
    fov      = size(oligPoints,1) / fovarea; %fov density
    inCell  = size(inPoints,1) / (sum(cell_mask,'all') * pixsz^2);
    outCell = size(outPoints,1) / (fovarea - sum(cell_mask,'all') * pixsz^2); %outside cell density
    percentage = sum(cell_mask,'all') / (imsz(1)*imsz(2)); %how much area occupied by the cells
end
