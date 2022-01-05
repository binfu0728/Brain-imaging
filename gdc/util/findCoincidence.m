function [coincidence_rate,coincidence_mask] = findCoincidence(masks,usedChannel,mainChannel,mode)
% input type:stack of binary image
    switch mode
        case 'spots'
            mask_1 = masks(:,:,usedChannel(1));  mask_2 =  masks(:,:,usedChannel(2));
            s1 = regionprops(mask_1,'centroid'); c1 = cat(1,s1.Centroid); p1 = round(c1);
            s2 = regionprops(mask_2,'centroid'); c2 = cat(1,s2.Centroid); p2 = round(c2);

            m1 = zeros(size(mask_1)); 
            m2 = zeros(size(mask_1)); 
            for i = 1:length(s1)
                m1(p1(i,2),p1(i,1)) = 1;
            end

            for i = 1:length(s2)
                m2(p2(i,2),p2(i,1)) = 1;
            end

            m1 = logical(m1); m2 = logical(m2);
            se = strel('square',3);
            m1 = imdilate(m1,se); 
            m2 = imdilate(m2,se);
        case 'LB/LN'
            m1 = masks(:,:,usedChannel(1));
            m2 = masks(:,:,usedChannel(2));
        otherwise
            error('not supported');
    end
    
    coincidence_mask = m1&m2;
    ref_mask         = masks(:,:,usedChannel(usedChannel==mainChannel));
    regions          = bwconncomp(ref_mask).PixelIdxList;
    for j = 1:length(regions)
        sumREF(j) =  sum(ref_mask(regions{j}));
        sumAND(j) =  sum(coincidence_mask(regions{j}));
    end
    overlap = sumAND./sumREF;
    coincidence_rate = length(find(overlap>0.1))/length(regions);
end