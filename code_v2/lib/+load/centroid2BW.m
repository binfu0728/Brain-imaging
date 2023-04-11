function BW = centroid2BW(mat,s)
% input  : mat, the centroid of small aggregates
% 
% output : BW, the converted binary mask of small agregates with a square representation
    if nargin<2
        s.width = 1200;
        s.height = 1200;
    end

    BW = false(s.width,s.height); 
    se = strel('disk',2);
    if mat(1,1) ~= 0
        for i = 1:size(mat,1)
            BW(mat(i,2),mat(i,1)) = 1;
        end
        BW = imdilate(BW,se);
    end
end