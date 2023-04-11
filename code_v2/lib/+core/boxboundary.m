function [DIST,rbox,lambda] = boxboundary(data,box) 
    lb     = repmat(box(1:end,1)',[size(data,1),1]); %lower bound of box
    ub     = repmat(box(1:end,2)',[size(data,1),1]); %upper bound of box
    rbox   = min([data-lb,ub-data],[],2); %the nearest distance of each datapoint to the box
    
    DIST   = squareform(pdist(data,'euclidean'));
    DIST   = sort(DIST);
    lambda = size(data,1)/prod(diff(box,1,2),'all');
end