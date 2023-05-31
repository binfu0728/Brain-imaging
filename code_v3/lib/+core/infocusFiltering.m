function z = infocusFiltering(focusScore,t_differential)
    [clusterID,cluster] = mDBSCAN(focusScore,t_differential);
    clusterMean         = cell2mat(cellfun(@mean,cluster,'UniformOutput',false)); %for the case number of cluster > 1 (i.e, unfocused & focused form 2 clusters)
    if length(clusterMean) > 1
        [~,idx] = max(clusterMean);
        clusterID(clusterID~=idx) = 0;
    end
    idx = find(clusterID~=0);
    if ~isempty(idx)
        z = [idx(1),idx(end)];
    else
        [~,idx] = max(focusScore);
        z = [idx,idx];
    end
end

function [clusterID,cluster] = mDBSCAN(X,epsilon)
% X: double array, focus score of a stack of z-slices within the same FoV
% epsilon: the threshold for determining whether two point belong to the same cluster
    MinPts  = 2; %minimum points within a cluster
    n       = length(X); %number of points
    clusterID = zeros(n,1); % id per cluster
    cluster = {}; %each cell store the idx in a cluster
    
    idx     = 1; %start from the first z-slice
    dist    = diff(X(1:end)); %differential score
    c       = 1; %start from the first cluster

    while idx <= n
        idx_start = idx;
        idx_end   = find(abs(dist)>epsilon,1);
        if isempty(idx_end) %all slices has differential score less than the epsilon
            idx_end = length(X);
        end

        if (idx_end-idx_start)+1 >= MinPts
            clusterID(idx_start:idx_end) = c;
            cluster{c} = X(idx_start:idx_end);
            c   = c + 1;
            idx = idx_end + 1;
        else
            idx = idx + 1;
        end
        dist(1:idx-1) = 0; %clear the used differential score
    end
end