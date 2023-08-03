function [xx,yy,zz,cc,alphadata,contour, ctpositions] = scatterdata(stats,perim,vox_height)
% get data for 3D scatter plotting - 3D aggregates visualization

linP = stats.VoxelIdxList;
lincoor = linP{:};
P = stats.VoxelList;
Voxvals = stats.VoxelValues;
coor = P{1,1}*vox_height; % to have microns for axes units
xx = coor(:,1);
yy = coor(:,2);
zz = coor(:,3);
cc = Voxvals{1,1};

% to not show points on perim values (edges shown with alphashape)
alphadata = zeros([length(xx), 1]);
alphadata(:) = 0.1;
pidx = find(perim == 1);

for nd = 1:length(pidx)
    ndx = pidx(nd); % linear indice 
    cdx = find(lincoor == ndx);
    alphadata(cdx) = 0;
end


% alphashape 
ashape = alphaShape(coor);
[contour, ctpositions] = boundaryFacets(ashape);
%figure, plot(ashape,FaceColor='interp',EdgeColor='interp', CData=cc)

%plot(ashape,FaceColor='r',EdgeColor='none',FaceAlpha=0.1) % to show alphashape on top of scatter plot

end