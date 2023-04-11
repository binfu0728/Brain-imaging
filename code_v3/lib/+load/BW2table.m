function [oligomer_result,non_oligomer_result,numbers] = BW2table(img,centroids,largeM,rsid)
    if nargin < 4
        rsid = 0;
    end
    oligomer_result     = []; %x,y,z,intensity,background,rsid
    non_oligomer_result = []; %x,y,z,rsid
    numbers             = zeros(size(img,3),3); %oligomer_nums,non_oligomer_nums,rsid

    for j = 1:size(img,3)
        % oligomer object analysis
        if ~isempty(centroids{j})  
            [esti_inten,esti_bg] = core.fastIntensityEstimation(img(:,:,j),centroids{j});
            tmpt_oligomer = [centroids{j},repmat(j,size(centroids{j},1),1),esti_inten,esti_bg,repmat(rsid,size(centroids{j},1),1)]; %x,y,z,intensity,background,rsid
        else
            tmpt_oligomer = []; %x,y,z,intensity,background,rsid
        end
        oligomer_result = [oligomer_result;tmpt_oligomer];
        

        % non-oligomer object analysis
        L           = bwlabel(largeM(:,:,j), 8);
        boundaries  = images.internal.builtins.bwboundaries(L, 8); %boundary in cell format
        boundaries2 = cell2mat(boundaries); %boundary in double format
        if ~isempty(boundaries2)
            tmpt_non_oligomer = [boundaries2,repmat(j,size(boundaries2,1),1),repmat(rsid,size(boundaries2,1),1)]; %x,y,z,rsid
        else
            tmpt_non_oligomer = []; %x,y,z,rsid
        end
        non_oligomer_result = [non_oligomer_result;tmpt_non_oligomer];
        
        % number analysis
        numbers(j,:) = [size(centroids{j},1),size(boundaries,1),rsid];
    end
end