function [coincidence_rate,test] = coincidence(masks,refChannel)
% input  : masks, 3D matrix with 2 masks from 2 channels (512x512x2)
%          refChannel, the channel on the denominator
% 
% output : coincidence_rate, single value from 2 channel comparison
%          test, coincidence_rate for each binary object

    m1 = masks(:,:,1);
    m2 = masks(:,:,2);
    coincidence_mask = m1&m2;
    ref_mask         = masks(:,:,refChannel);
    regions          = bwconncomp(ref_mask).PixelIdxList; %return the indices of objects from all overlapping regions between two compared channels

    if ~isempty(regions) %if there is a overlapping
        for j = 1:length(regions)
            sumREF(j) =  sum(ref_mask(regions{j})); %how many individual objects are in the ref channel
            sumAND(j) =  sum(coincidence_mask(regions{j})); %how many overlapped objects
        end
        overlap = sumAND./sumREF; %overlap ratio for each objects in the ref channel
        coincidence_rate = length(find(overlap>0.1))/length(regions); %any overlapped objects with more than 10% overlapping ratio will be considered 
    else 
        overlap = 0;
        coincidence_rate = 0;
    end
    test = overlap; 
end