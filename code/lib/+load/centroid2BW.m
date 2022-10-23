function BW = centroid2BW(mat,s)
% input  : mat, the centroid of small aggregates
% 
% output : BW, the converted binary mask of small agregates with a square representation
    if nargin<2
        s.width = 2048;
        s.height = 2048;
    end
    
    BW = false(s.width,s.height); 
    se = strel('square',3*4);
    if mat(1,1) ~= 0
        for i = 1:size(mat,1)
            BW(mat(i,2),mat(i,1)) = 1;
        end
        BW = imdilate(BW,se);
    end
end