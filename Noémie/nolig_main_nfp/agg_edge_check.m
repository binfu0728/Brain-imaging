function [agg_mask_labels, agg_onZedges] = agg_edge_check(labeled_aggs, imsz)
% INPUT : mask of original image size with detected aggregates labeled
% OUTPUT :  agg_mask_labels : list of agg labels for those with no edges at all
%           agg_onZedges : list of agg labels for those found on z edges only

    agg_mask_labels = [];
    agg_onZedges = [];
    
    for i = 1: max(labeled_aggs,[],'all')
        labeled_mask_object = ones(imsz);
        labeled_mask_object(labeled_aggs ~= i) = 0; % creates binary mask for each aggregate
        
        % discard aggs on xy planes' edge
        if any(any(labeled_mask_object(1,:,:))) 
            continue
        elseif any(any(labeled_mask_object(imsz(1,1),:,:)) )
            continue
        elseif any(any(labeled_mask_object(:,1,:)))
            continue
        elseif any(any(labeled_mask_object(:,imsz(1,2),:)) )
            continue
        % detect and save any agg found on z edges 
        elseif any(any(labeled_mask_object(:,:,1))) | any(any(labeled_mask_object(:,:,imsz(1,3))))
            agg_onZedges = [agg_onZedges, i];
            continue
        else
            agg_mask_labels = [agg_mask_labels, i]; % saves aggregate labeled value
        end        

    end


end