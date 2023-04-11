function dmin = calculateOutDensity(cell_mask,outPoints)
% input  : cell_mask, 2048x2048 binary mask of cell
%          outPoints, the centroids of oligomers which are outside the cell
% 
% output : dmin, the shortest distance of each oligomer to the cell boundary

    cells           = regionprops('table',bwperim(cell_mask,8),'PixelList'); %[x,y]
    % cells         = bwboundaries(cell_mask, 'noholes'); %[y,x]
    ks              = zeros(size(outPoints,1),size(cells,1)); %repo for indices of other points sorted by the distance to a single point
    ds              = zeros(size(outPoints,1),size(cells,1)); %repo for distance of other points to a single points sorted by from shortest to longest
    
    for n = 1:size(cells,1)
        p1       = cells.PixelList{n}; %[x,y], vector form of cell boundary
        p1(:,2)  = abs(p1(:,2)-2048); %[x,y]
        p1       = p1/4*0.107; %change from pixel unit to um
    %     p1 = fliplr(cells{n}); %[x,y]
        [ks(:,n),ds(:,n)] = dsearchn(p1,outPoints); %core function to find the closest point & distance between oligomers and cell boundary
    end
    [dmin,cmin]     = min(ds,[],2); %cmin means belongs to which cell

    distImg         = zeros(size(cell_mask)); %an image with oligomers which are colour-code by its distance to the cell boundary
    outPoints       = round(outPoints/0.107*4);
    outPoints(:,2)  = abs(2048-outPoints(:,2)); %[x,y]
    for n = 1:size(outPoints,1)
        distImg(outPoints(n,2),outPoints(n,1)) = dmin(n)*10; %*10 to make sure a clear point, no influence on result
    end
    
%     figure;
%     colormap_custom = flipud(parula(ceil((max(dmin)+1)*10)));
%     SE              = strel('diamond',10);
%     distImg         = imdilate(distImg,SE) + cell_mask;
%     imagesc(label2rgb(round(distImg),colormap_custom,'w'));
%     colormap(colormap_custom);
%     caxis([0 ceil((max(dmin)+1))])
%     colorbar;
%     xticks('');yticks(''); axis image;
%     xlim([0 55]); ylim([0 55]);
end