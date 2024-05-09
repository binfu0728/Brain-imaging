function [coincidence_rate,test] = coincidence(masks,refChannel)
% find colocazation of objects on two binary masks
% input  : masks, 3D matrix with 2 masks from 2 channels
%          refChannel, the channel on the denominator
% 
% output : coincidence_rate, single value from 2 channel comparison
%          test, coincidence_rate for each binary object
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk
    
    m1 = masks(:,:,1);
    m2 = masks(:,:,2);
    coincidence_mask = m1&m2;
    ref_mask         = masks(:,:,refChannel);
    regions          = bwconncomp(ref_mask,8).PixelIdxList; %return the indices of objects from all overlapping regions between two compared channels

    if ~isempty(regions) %if there is a overlapping
        for j = 1:length(regions)
            sumREF(j) =  sum(ref_mask(regions{j})); %how many individual objects are in the ref channel
            sumAND(j) =  sum(coincidence_mask(regions{j})); %how many overlapped objects
        end
        overlap = sumAND./sumREF; %overlap ratio for each objects in the ref channel
        coincidence_rate = length(find(overlap>0.01))/length(regions); %any overlapped objects with more than 10% overlapping ratio will be considered 
    else 
        overlap = 0;
        coincidence_rate = 0;
    end
    test = overlap; 
end