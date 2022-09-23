function BW = centroid2BW(mat)
% input  : mat, the centroid of small aggregates
% 
% output : BW, the converted binary mask of small agregates with a square representation

    BW = false(2048,2048); 
    se = strel('square',3*4);
    if mat(1,1) ~= 0
        for i = 1:size(mat,1)
            BW(mat(i,2),mat(i,1)) = 1;
        end
        BW = imdilate(BW,se);
    end
end