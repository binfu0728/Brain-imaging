function [fov,inCell,outCell,numCell,outPoints] = densityCal(cell_mask,olig_mask)
%input: two binary mask
    [~,numCell]  = bwlabel(cell_mask);
    s           = regionprops ('table',olig_mask,'centroid');
    points      = s.Centroid;
    points(:,2) = abs(points(:,2)-2048);
    points      = points/4*0.107;
    
    boundaries  = bwboundaries(cell_mask, 'noholes');
    tmpt        = false(size(points,1),1);

%     figure;
    for k = 1:numCell
        cellb      = boundaries{k};
        cellb(:,1) = abs(cellb(:,1)-2048); %[y,x]
        cellb      = cellb/4*0.107;
        s          = inpolygon(points(:,1),points(:,2),cellb(:,2),cellb(:,1));
        tmpt       = tmpt | s;
        plot(cellb(:,2),cellb(:,1),'r.');hold on;
    end
    inPoints   = points(tmpt==1,:);
    outPoints  = points(tmpt==0,:);
%     plot(inPoints(:,1),inPoints(:,2),'.','Color','r');
%     plot(outPoints(:,1),outPoints(:,2),'.','Color','b');
%     xticks('');yticks(''); axis image;
%     xlim([0 55]); ylim([0 55]);

    fov = size(points,1) / (0.107*512)^2;
    inCell  = size(inPoints,1) / (sum(cell_mask,'all') / 16 * (0.107^2));
    outCell = size(outPoints,1) / ((2048*2048-sum(cell_mask,'all')) / 16 * (0.107^2));
%     percentage = (2048*2048-sum(cell_mask,'all'))/(2048*2048);
end