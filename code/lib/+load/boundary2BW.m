function BW = boundary2BW(mat,s)
% input  : mat, the boundary of the cell/large aggregates
%          s, conig
%          ratio, upsampling ratio
% 
% output : BW, the converted binary mask
    BW = false(s.height,s.width);
    if mat(1,1)~=0            
        tmpt = sub2ind(size(BW),mat(:,1)',mat(:,2)');
        BW(tmpt) = 1;
        BW = imfill(BW,'holes');
    end
end